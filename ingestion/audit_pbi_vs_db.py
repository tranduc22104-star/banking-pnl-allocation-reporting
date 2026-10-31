# Đối soát số liệu Power BI ↔ PostgreSQL
#
# Quy trình: export DAX ra CSV (export_pbi.ps1) → tính lại độc lập bằng SQL → diff từng ô.
# Không hard-code mật khẩu: đọc từ biến môi trường PGHOST/PGPORT/PGUSER/PGPASSWORD/PGDATABASE.
#
# Cách dùng:
#   1) powershell -File ingestion/export_pbi.ps1 -Port <cổng msmdsrv> -Catalog <tên database>
#   2) python ingestion/audit_pbi_vs_db.py
#   Hai tệp CSV đối soát nằm ở .staging/audit/ (đặt biến môi trường AUDIT_DATA_DIR để đổi chỗ).

import csv
import io
import os
import sys

import psycopg2

sys.stdout.reconfigure(encoding="utf-8")

_PROJECT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_DIR = os.environ.get("AUDIT_DATA_DIR", os.path.join(_PROJECT_DIR, ".staging", "audit"))
TOL = 0.02          # dung sai cho giá trị triệu đồng
TOL_PCT = 0.0001    # dung sai cho tỷ lệ %

COLS = {
    "tn_gop": "thu_nhap_the_trieu_dong",
    "cpvon": "cp_kdv_trieu_dong",
    "cpkd": "cp_hd_khac_trieu_dong",
    "tnthuan": "tong_thunhap_trieu_dong",
    "opex": "tong_chiphi_trieu_dong",
    "dp": "du_phong_trieu_dong",
    "lntt": "lntt_trieu_dong",
}


def load(path, key):
    out = {}
    with io.open(path, encoding="utf-8") as f:
        for row in csv.DictReader(f):
            out[row[key]] = {
                k.replace("[", "").replace("]", ""): (float(v) if v not in ("", None) else None)
                for k, v in row.items() if k != key
            }
    return out


def main():
    pbi_pnl = load(os.path.join(DATA_DIR, "pbi_pnl.csv"),
                   "banking_project v_baocao_tonghop[area_code]")
    pbi_asm = load(os.path.join(DATA_DIR, "pbi_asm.csv"),
                   "banking_project v_xephang_asm[area_code]")

    # Ưu tiên DB_* (giống ingestion/db_config.py); nếu không có thì để psycopg2 đọc PG* từ môi trường
    kw = {"connect_timeout": 10}
    if os.getenv("DB_HOST") or os.getenv("DB_NAME"):
        kw.update(host=os.getenv("DB_HOST", "localhost"),
                  port=int(os.getenv("DB_PORT", "5432")),
                  user=os.getenv("DB_USER", "postgres"),
                  password=os.getenv("DB_PASS", ""),
                  dbname=os.getenv("DB_NAME", "postgres"))
    conn = psycopg2.connect(**kw)
    cur = conn.cursor()

    sql = {}
    for key, col in COLS.items():
        cur.execute(f"""
            SELECT area_code,
                   SUM(CASE WHEN month_key = 202305 THEN {col} END),
                   SUM(CASE WHEN month_key = 202304 THEN {col} END),
                   SUM(CASE WHEN month_key = 202303 THEN {col} END)
            FROM banking_project.v_baocao_tonghop
            GROUP BY area_code""")
        for area, m5, m4, m3 in cur.fetchall():
            flow5 = float(m5) - float(m4)
            flow4 = float(m4) - float(m3)
            d = sql.setdefault(area, {})
            d[key + "_flow"] = flow5
            d[key + "_delta"] = flow5 - flow4

    cur.execute("""
        SELECT area_code, COUNT(*),
               SUM(CASE WHEN rank_final <= 25 THEN 1 ELSE 0 END),
               SUM(CASE WHEN rank_final >= 61 THEN 1 ELSE 0 END),
               AVG(npl), SUM(ltn_trieu_dong)
        FROM banking_project.v_xephang_asm
        WHERE month_key = 202305
        GROUP BY area_code""")
    for area, tot, top, bot, npl, ltn in cur.fetchall():
        d = sql.setdefault(area, {})
        d.update(total=tot, top25=top, bot24=bot, npl=float(npl), ltn_ytd=float(ltn))
    conn.close()

    checks, issues = 0, []

    def cmp(area, label, pbi, db, tol=TOL):
        nonlocal checks
        checks += 1
        p = 0.0 if pbi is None else pbi
        s = 0.0 if db is None else float(db)
        if abs(p - s) > tol:
            issues.append((area, label, p, s, p - s))

    for area, s in sorted(sql.items()):
        p, a = pbi_pnl.get(area, {}), pbi_asm.get(area, {})
        cmp(area, "flow_lntt", p.get("@flow"), s.get("lntt_flow"))
        cmp(area, "delta_lntt", p.get("@delta"), s.get("lntt_delta"))
        for k in ("tn_gop", "cpvon", "cpkd", "tnthuan", "opex", "dp"):
            cmp(area, "mom_" + k, p.get("@" + k), s.get(k + "_delta"))
        cmp(area, "asm_total", a.get("@total"), s.get("total"))
        cmp(area, "asm_top25", a.get("@top25"), s.get("top25"))
        cmp(area, "asm_bot24", a.get("@bot24"), s.get("bot24"))
        cmp(area, "npl", a.get("@npl"), s.get("npl"), TOL_PCT)
        cmp(area, "ltn_ytd", a.get("@ltn_ytd"), s.get("ltn_ytd"))

    print(f"so phep so sanh: {checks}")
    print(f"so lech: {len(issues)}")
    for area, label, p, s, diff in issues:
        print(f"  LECH {area:>2} {label:<14} PBI={p:>14,.4f} SQL={s:>14,.4f} diff={diff:>10,.4f}")

    tot_pbi = sum((pbi_pnl[a].get("@delta") or 0) for a in pbi_pnl)
    tot_sql = sum((sql[a].get("lntt_delta") or 0) for a in sql)
    print(f"\ntong delta: PBI={tot_pbi:,.4f} SQL={tot_sql:,.4f}")
    return 1 if issues else 0


if __name__ == "__main__":
    sys.exit(main())
