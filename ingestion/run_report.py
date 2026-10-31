#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
WORKFLOW BÁO CÁO P&L 7 VÙNG — chạy trên CMD, 1 cửa sổ:
  [1] CHECK dữ liệu mới (fingerprint staging vs lần chạy trước)
  [2] TỰ chạy procedure từ tháng thay đổi → tháng mới nhất (YTD cascade)
  [3] HỎI tháng xuất báo cáo (Enter = tháng gần nhất)
  [4] XUẤT Excel YTD theo style file mau report_xep_hang_kinh_doanh_monthly.xlsx:
      BaocaoTonghop_T{MM} + BaocaoXepHangASM_T{MM} (layout/cong thuc giong mau),
      KPI_ASM_DATA (pivot tu stg), Param / Mo Ta NV / Tu Viet Tat GIU NGUYEN tu file mau,
      ThamSo.

Sử dụng:  py ingestion/run_report.py
"""

import sys
if sys.platform.startswith('win'):
    try:
        sys.stdout.reconfigure(encoding='utf-8')
        sys.stderr.reconfigure(encoding='utf-8')
    except Exception:
        pass
import os
import datetime
from copy import copy

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from db_config import get_connection, SCHEMA_NAME

from openpyxl import load_workbook
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.utils import get_column_letter

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUTPUT_DIR = os.path.join(BASE_DIR, "output")
TEMPLATE_XLSX = os.path.join(BASE_DIR, "input", "report_xep_hang_kinh_doanh_monthly.xlsx")

# (ten nguon, bang staging, cot thang, cot so de fingerprint)
SOURCES = [
    ("kpi", "stg_fact_kpi_month", "kpi_month", "outstanding_principal"),
    ("txn", "stg_fact_txn_month", "txn_month", "amount"),
    ("asm", "stg_asm_target",     "month_key", "ltn_amount"),
]

HDR_FILL   = PatternFill("solid", fgColor="1F3864")
HDR_FONT   = Font(bold=True, color="FFFFFF", size=10)
TITLE_FONT = Font(bold=True, size=13, color="1F3864")
BORDER     = Border(*[Side(style="thin", color="BFBFBF")] * 4)


def banner(text):
    print("\n" + "=" * 64)
    print(f"  {text}")
    print("=" * 64)


def ensure_helper_table(cur):
    cur.execute(f"""
        CREATE TABLE IF NOT EXISTS {SCHEMA_NAME}.log_data_fingerprint (
            source     VARCHAR(10) NOT NULL,
            month_key  INT NOT NULL,
            row_count  BIGINT NOT NULL,
            sum_val    NUMERIC(30, 4) NOT NULL DEFAULT 0,
            checked_at TIMESTAMP DEFAULT NOW(),
            PRIMARY KEY (source, month_key)
        );
    """)


def table_exists(cur, name):
    cur.execute(
        "SELECT 1 FROM information_schema.tables "
        "WHERE table_schema = %s AND table_name = %s",
        (SCHEMA_NAME, name),
    )
    return cur.fetchone() is not None


def proc_exists(cur, name):
    cur.execute("SELECT 1 FROM pg_proc WHERE proname = %s", (name,))
    return cur.fetchone() is not None


def read_staging(cur):
    """{(source, month): (cnt, sum)} hien tai cua toan bo staging."""
    cur.execute(f"""
        SELECT source, month_key, row_count, sum_val
        FROM {SCHEMA_NAME}.log_data_fingerprint
    """)
    stored = {(r[0], r[1]): (r[2], r[3]) for r in cur.fetchall()}

    current = {}
    for src, tbl, mcol, scol in SOURCES:
        if not table_exists(cur, tbl):
            continue
        cur.execute(f"""
            SELECT {mcol}, COUNT(*), COALESCE(SUM({scol}), 0)
            FROM {SCHEMA_NAME}.{tbl}
            GROUP BY {mcol}
        """)
        for m, cnt, s in cur.fetchall():
            current[(src, int(m))] = (cnt, s)
    return stored, current


def detect_changes(cur, stored, current):
    """Tra ve (thang_chay_dau_tien, chi_tiet). None = khong co gi moi."""
    stg_months = {k[1] for k in current}
    if not table_exists(cur, "fct_pnl_value"):
        return (min(stg_months) if stg_months else None), ["Fct chua co — chay toan bo"]

    cur.execute(f"SELECT DISTINCT month_key FROM {SCHEMA_NAME}.fct_pnl_value")
    fct_months = {r[0] for r in cur.fetchall()}

    detail, changed = [], set()
    for key, cur_val in sorted(current.items()):
        src, m = key
        if m not in fct_months:
            changed.add(m)
            detail.append(f"[+] {src} {m}: chua xu ly trong fct")
        elif key not in stored:
            detail.append(f"[?] {src} {m}: lan dau ghi nhan (baseline)")
        elif stored[key] != cur_val:
            changed.add(m)
            c0, s0 = stored[key]
            c1, s1 = cur_val
            detail.append(
                f"[!] {src} {m}: du lieu thay doi (dong {c0}->{c1}, tong {s0}->{s1})"
            )
    for (src, m) in sorted(set(stored) - set(current)):
        if src == "kpi" and m in fct_months:
            detail.append(f"[?] {src} {m}: mat khoi staging — bo qua (khong xoa fct)")

    if not stored:
        missing = sorted(stg_months - fct_months)
        if missing:
            return missing[0], detail or ["Fct thieu thang — chay bo sung"]
        return None, detail or ["Lan dau chay — da ghi baseline, khong can procedure"]

    if not changed:
        return None, detail or ["Khong phat hien du lieu moi"]

    return min(changed), detail


def run_procedures(conn, start_month):
    """Chay tang dan start→thang moi nhat. Tra ve (ok, da_chay)."""
    cur = conn.cursor()
    cur.execute(f"SELECT MAX(month_key) FROM {SCHEMA_NAME}.fct_pnl_value")
    candidates = [r[0] for r in [cur.fetchone()] if r[0]]
    for _, tbl, mcol, _scol in SOURCES:
        if table_exists(cur, tbl):
            cur.execute(f"SELECT MAX({mcol}) FROM {SCHEMA_NAME}.{tbl}")
            v = cur.fetchone()[0]
            if v:
                candidates.append(v)
    if not candidates:
        return True, []
    latest = max(candidates)
    if latest < start_month:
        return True, []

    ran = []
    for m in range(start_month, latest + 1):
        if m % 100 < 1 or m % 100 > 12:
            continue
        for proc in ("sp_baocao_tonghop", "sp_xephang_asm"):
            print(f"  -> {proc}({m}) ...", end=" ", flush=True)
            try:
                cur.execute(f"CALL {SCHEMA_NAME}.{proc}(%s)", (m,))
                conn.commit()
                print("OK")
                ran.append((proc, m))
            except Exception as e:
                conn.rollback()
                cur.execute("""
                    SELECT step_name, COALESCE(note, '') FROM banking_project.log_proc_run
                    WHERE proc_name = %s AND month_key = %s AND status = 'FAIL'
                    ORDER BY run_id DESC LIMIT 1
                """, (proc, m))
                row = cur.fetchone()
                step, note = row if row else ("?", str(e))
                print(f"FAIL tai {step}: {note}")
                return False, ran
    return True, ran


def refresh_fingerprints(conn):
    cur = conn.cursor()
    cur.execute(f"DELETE FROM {SCHEMA_NAME}.log_data_fingerprint")
    for src, tbl, mcol, scol in SOURCES:
        if not table_exists(cur, tbl):
            continue
        cur.execute(f"""
            INSERT INTO {SCHEMA_NAME}.log_data_fingerprint (source, month_key, row_count, sum_val)
            SELECT %s, {mcol}, COUNT(*), COALESCE(SUM({scol}), 0)
            FROM {SCHEMA_NAME}.{tbl}
            GROUP BY {mcol}
        """, (src,))
    conn.commit()


def ask_report_month(cur, latest_default):
    valid_months = None
    while True:
        try:
            ans = input(
                f"\nBáo cáo tháng nào? (YYYYMM, Enter = tháng gần nhất {latest_default}): "
            ).strip()
        except EOFError:
            print(f"\n  (Không có input — dùng tháng gần nhất {latest_default})")
            return latest_default
        if not ans:
            return latest_default
        if not (ans.isdigit() and len(ans) == 6):
            print("  [!] Nhập dạng YYYYMM, ví dụ 202305.")
            continue
        m = int(ans)
        if valid_months is None:
            cur.execute(f"SELECT DISTINCT month_key FROM {SCHEMA_NAME}.fct_pnl_value")
            valid_months = {r[0] for r in cur.fetchall()}
        if m in valid_months:
            return m
        print(f"  [!] Tháng {m} chưa có dữ liệu báo cáo. Enter để lấy tháng gần nhất.")


def style_header(ws, row, ncols):
    for c in range(1, ncols + 1):
        cell = ws.cell(row=row, column=c)
        cell.fill, cell.font = HDR_FILL, HDR_FONT
        cell.alignment = Alignment(horizontal="center", vertical="center", wrap_text=True)
        cell.border = BORDER


def autosize(ws, widths):
    for i, w in enumerate(widths, 1):
        ws.column_dimensions[get_column_letter(i)].width = w


def copy_row_style(ws, src_row, dst_row, max_col):
    ws.row_dimensions[dst_row].height = ws.row_dimensions[src_row].height
    for c in range(1, max_col + 1):
        ws.cell(row=dst_row, column=c)._style = copy(ws.cell(row=src_row, column=c)._style)


def xl_value(v):
    """Decimal -> float, None/str/int giu nguyen (openpyxl khong doc Decimal)."""
    if v is None:
        return None
    if isinstance(v, (int, float, str)):
        return v
    try:
        return float(v)
    except (TypeError, ValueError):
        return v


# --- Danh so dong BaocaoTonghop (layout doc nhat cua file mau, giu nguyen) ---
# Cot B = pool HEAD (prov='00') can phan bo; cot H..N = 7 vung da phan bo.
BT_LEFT_POOL = {5: "h_b2", 6: "h_b1", 7: "h_b3", 8: "h_b4", 9: "h_b5",
                11: None,  # DT Nguon von = 0
                12: "h_c3", 13: "h_c2", 14: "h_c1",
                16: None, 17: None, 18: "h_d3", 19: "h_d1", 20: "h_d2", 21: None,
                24: "h_f1", 25: "h_f2", 26: "h_f3", 27: "h_f4", 28: "h_g"}
BT_RIGHT = {5: "b2_lai_trong_han", 6: "b1_lai_qua_han", 7: "b3_phi_bh",
            8: "b4_phi_tang_hm", 9: "b5_phi_cham_tra",
            12: "c3_von_tt2", 13: "c2_von_tt1", 14: "c1_von_cctg",
            18: "d3_dt_kd", 19: "d1_cp_hoahong", 20: "d2_cp_kd_khac",
            24: "f1_cp_thue", 25: "f2_cp_nv", 26: "f3_cp_qly", 27: "f4_cp_ts",
            28: "g_du_phong"}
BT_RIGHT_ZERO = (11, 16, 17, 21)   # dong khong co du lieu -> 0.0 ro rang
REGION_COL = {"B": 8, "C": 9, "D": 10, "E": 11, "F": 12, "G": 13, "H": 14}  # H..N
BT_SM_ROW = 29

# Cot BaocaoXepHangASM (E=5, O=15, Y=25 la cong thuc, khong dat vao day)
XH_COLS = {1: "month_key", 2: "area_code", 3: "area_name", 4: "email",
           6: "rank_final", 7: "ltn_avg", 8: "rank_ltn_avg",
           9: "psdn_avg", 10: "rank_psdn_avg",
           11: "approval_rate_avg", 12: "rank_approval_rate_avg",
           13: "npl_truoc_wo_luy_ke", 14: "rank_npl", 16: "rank_ptkd",
           17: "cir", 18: "rank_cir", 19: "margin", 20: "rank_margin",
           21: "hs_von", 22: "rank_hs_von", 23: "hsbq_nhan_su",
           24: "rank_hsbq_nhan_su", 26: "rank_fin"}

# Pool HEAD (fct_pnl_value, area_code='00'), don vi trieu dong.
# report_id: 1,2,3,4,5 = B2..B5 | 21,22,23 = C3,C2,C1
#            31,32,33 = D3,D1,D2 | 60 = G | 51..54 = F1..F4
HEAD_POOL_SQL = """
    SELECT
        MAX(value) FILTER (WHERE report_id = 1)  / 1e6 AS h_b2,
        MAX(value) FILTER (WHERE report_id = 2)  / 1e6 AS h_b1,
        MAX(value) FILTER (WHERE report_id = 3)  / 1e6 AS h_b3,
        MAX(value) FILTER (WHERE report_id = 4)  / 1e6 AS h_b4,
        MAX(value) FILTER (WHERE report_id = 5)  / 1e6 AS h_b5,
        MAX(value) FILTER (WHERE report_id = 21) / 1e6 AS h_c3,
        MAX(value) FILTER (WHERE report_id = 22) / 1e6 AS h_c2,
        MAX(value) FILTER (WHERE report_id = 23) / 1e6 AS h_c1,
        MAX(value) FILTER (WHERE report_id = 31) / 1e6 AS h_d3,
        MAX(value) FILTER (WHERE report_id = 32) / 1e6 AS h_d1,
        MAX(value) FILTER (WHERE report_id = 33) / 1e6 AS h_d2,
        MAX(value) FILTER (WHERE report_id = 60) / 1e6 AS h_g,
        MAX(value) FILTER (WHERE report_id = 51) / 1e6 AS h_f1,
        MAX(value) FILTER (WHERE report_id = 52) / 1e6 AS h_f2,
        MAX(value) FILTER (WHERE report_id = 53) / 1e6 AS h_f3,
        MAX(value) FILTER (WHERE report_id = 54) / 1e6 AS h_f4
    FROM {schema}.fct_pnl_value
    WHERE month_key = %s AND area_code = '00'
""".format(schema=SCHEMA_NAME)


def export_excel(conn, month):
    """Xuat Excel dua chinh file mau lam template — chi thay so lieu."""
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    path = os.path.join(OUTPUT_DIR, f"BC_PNL_YTD_{month}.xlsx")
    mm = month % 100
    cur = conn.cursor()
    wb = load_workbook(TEMPLATE_XLSX)

    # --- Sheet 1: BaocaoTonghop_T{MM} ---
    ws = wb["BaocaoTonghop_T2"]
    ws.title = f"BaocaoTonghop_T{mm}"
    cur.execute(HEAD_POOL_SQL, (month,))
    pool_names = [d[0] for d in cur.description]
    pools = dict(zip(pool_names, cur.fetchone()))
    for row, field in BT_LEFT_POOL.items():
        v = pools.get(field) if field else None
        ws.cell(row=row, column=2).value = float(v) if v is not None else 0.0
    cur.execute(f"""
        SELECT area_code, b2_lai_trong_han, b1_lai_qua_han, b3_phi_bh,
               b4_phi_tang_hm, b5_phi_cham_tra, c3_von_tt2, c2_von_tt1,
               c1_von_cctg, d3_dt_kd, d1_cp_hoahong, d2_cp_kd_khac,
               f1_cp_thue, f2_cp_nv, f3_cp_qly, f4_cp_ts, g_du_phong,
               j_sm_count
        FROM {SCHEMA_NAME}.v_baocao_tonghop_vnd
        WHERE month_key = %s
    """, (month,))
    f_names = [d[0] for d in cur.description]
    fct_rows = {r[0]: dict(zip(f_names, r)) for r in cur.fetchall()}
    for area, col in REGION_COL.items():
        rec = fct_rows.get(area)
        if not rec:
            continue
        for row, field in BT_RIGHT.items():
            v = rec.get(field)
            # fct luu VND, file mau don vi trieu dong
            ws.cell(row=row, column=col).value = float(v) / 1e6 if v is not None else 0.0
        for row in BT_RIGHT_ZERO:
            ws.cell(row=row, column=col).value = 0.0
        sm = rec.get("j_sm_count")
        ws.cell(row=BT_SM_ROW, column=col).value = float(sm) if sm is not None else 0.0

    # --- Sheet 2: BaocaoXepHangASM_T{MM} ---
    wsx = wb["BaocaoXepHangASM_T2"]
    wsx.title = f"BaocaoXepHangASM_T{mm}"
    cur.execute(
        f"SELECT * FROM {SCHEMA_NAME}.v_xephang_asm_vnd "
        "WHERE month_key = %s ORDER BY rank_final, area_code, email",
        (month,),
    )
    xh_names = [d[0] for d in cur.description]
    recs = [dict(zip(xh_names, r)) for r in cur.fetchall()]
    n_tpl = wsx.max_row - 2  # dong 1-2 = header
    if len(recs) > n_tpl:
        for i in range(n_tpl, len(recs)):
            copy_row_style(wsx, 3, 3 + i, 26)
    elif len(recs) < n_tpl:
        wsx.delete_rows(3 + len(recs), n_tpl - len(recs))
    for i, rec in enumerate(recs):
        r = 3 + i
        for col, field in XH_COLS.items():
            wsx.cell(row=r, column=col).value = xl_value(rec.get(field))
        wsx.cell(row=r, column=5).value = f"=O{r}+Y{r}"              # Tổng điểm
        wsx.cell(row=r, column=15).value = f"=H{r}+J{r}+L{r}+N{r}"   # Điểm Quy Mô
        wsx.cell(row=r, column=25).value = f"=R{r}+T{r}+V{r}+X{r}"   # Điểm FIN

    # --- Sheet 3: KPI_ASM_DATA (pivot tu stg, dung layout 64 cot cua mau) ---
    wsk = wb["KPI_ASM_DATA"]
    cur.execute(f"""
        SELECT area_name, sale_name, email, month_key, ltn_amount, psdn_count,
               app_approved, app_in, approval_rate
        FROM {SCHEMA_NAME}.stg_asm_target
        WHERE month_key <= %s
    """, (month,))
    groups = {}
    for area, sale, email, m, ltn, psdn, appr, appin, rate in cur.fetchall():
        groups.setdefault((area, sale, email), {})[int(m)] = (
            ltn, psdn, appr, appin, rate)
    keys = list(groups)
    n_tpl_k = wsk.max_row - 2
    if len(keys) > n_tpl_k:
        for i in range(n_tpl_k, len(keys)):
            copy_row_style(wsk, 3, 3 + i, 64)
    for r in range(3, 3 + max(len(keys), n_tpl_k)):
        for c in range(1, 65):
            wsk.cell(row=r, column=c).value = None
    for i, key in enumerate(keys):
        r = 3 + i
        md = groups[key]
        wsk.cell(row=r, column=1).value = max(md)
        wsk.cell(row=r, column=2).value = key[0]
        wsk.cell(row=r, column=3).value = key[1]
        wsk.cell(row=r, column=4).value = key[2]
        for m, vals in md.items():
            moff = (m % 100) - 1
            for b, v in enumerate(vals):
                wsk.cell(row=r, column=5 + b * 12 + moff).value = xl_value(v)

    # --- Sheet 4: ThamSo (cua minh, dat sau KPI) ---
    ws = wb.create_sheet("ThamSo", 3)
    ws.append(["THAM SỐ BÁO CÁO"])
    ws["A1"].font = TITLE_FONT
    ws.append([])
    ws.append(["Mục", "Giá trị"])
    style_header(ws, 3, 2)
    params = [
        ("Tháng báo cáo (YTD)", month),
        ("Thời điểm xuất", datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")),
        ("Đơn vị số liệu", "triệu đồng (trừ % và điểm thi đua)"),
        ("Nguồn tổng hợp",
         f"{SCHEMA_NAME}.fct_pnl_value / fct_asm_value / stg_asm_target"),
        ("Style file mẫu", "report_xep_hang_kinh_doanh_monthly.xlsx "
                           "(Param / Mô Tả NV / Từ Viết Tắt giữ nguyên)"),
        ("Workflow", "run_report.py — kiểm dấu vân tay bảng staging, gọi thủ tục, xuất Excel"),
    ]
    for k, v in params:
        ws.append([k, v])
        for c in (1, 2):
            ws.cell(row=ws.max_row, column=c).border = BORDER
    autosize(ws, [26, 78])

    wb.save(path)
    return path


def main():
    banner("WORKFLOW BÁO CÁO P&L 7 VÙNG")

    print("[1/3] CHECK DỮ LIỆU MỚI ...")
    try:
        conn = get_connection()
    except Exception:
        print("  [!] Không kết nối được PostgreSQL — dừng.")
        sys.exit(1)
    cur = conn.cursor()
    cur.execute(f"SET search_path TO {SCHEMA_NAME}, public")
    if not proc_exists(cur, "sp_baocao_tonghop"):
        print("  [!] Chưa tạo procedure — chạy sql/fct/fct_pnl_allocation.sql trước.")
        sys.exit(1)
    ensure_helper_table(cur)
    conn.commit()

    stored, current = read_staging(cur)
    if not current:
        print("  [!] Chưa có dữ liệu staging — chạy ingestion/run_all.py trước.")
        sys.exit(1)
    stg_months = sorted({k[1] for k in current})
    print(f"  Staging    : {stg_months[0]} → {stg_months[-1]} ({len(stg_months)} tháng)")
    cur.execute(f"SELECT MIN(month_key), MAX(month_key) FROM {SCHEMA_NAME}.fct_pnl_value")
    fct_min, fct_max = cur.fetchone()
    if fct_max:
        print(f"  Đã xử lý   : {fct_min} → {fct_max}")

    start_month, detail = detect_changes(cur, stored, current)
    for line in detail:
        print(f"  {line}")

    print("\n[2/3] CHẠY PROCEDURE (nếu cần) ...")
    if start_month is None:
        print("  -> Không có tháng nào cần chạy lại.")
        ran = []
        ok = True
    else:
        print(f"  -> YTD cascade từ {start_month} → tháng mới nhất:")
        ok, ran = run_procedures(conn, start_month)
    if not ok:
        print("  [!] Dừng — xem log_proc_run ở trên.")
        sys.exit(1)
    refresh_fingerprints(conn)
    if ran:
        print(f"  Đã chạy {len(ran)} lần CALL thành công.")

    print("\n[3/3] XUẤT BÁO CÁO ...")
    cur.execute(f"SELECT MAX(month_key) FROM {SCHEMA_NAME}.fct_pnl_value")
    latest = cur.fetchone()[0]
    if latest is None:
        print("  [!] Chưa có dữ liệu báo cáo.")
        sys.exit(1)
    month = ask_report_month(cur, latest)
    path = export_excel(conn, month)
    print(f"\n  ✓ Xuất: {path}")
    print(f"    ({os.path.getsize(path):,} bytes | {datetime.datetime.now():%H:%M:%S})")
    conn.close()


if __name__ == "__main__":
    main()
