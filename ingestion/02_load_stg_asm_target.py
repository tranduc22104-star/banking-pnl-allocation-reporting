#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
TASK 02: kpi_asm_data_202305.xlsx -> stg_asm_target (unpivot ngang -> doc).
1 ASM x 1 thang = 1 dong (84 ASM x 5 thang = 420 dong).
Khoi LTN/PSDN/Approved/In/Rate cach nhau 12 cot thang.
"""

import os
import time
import openpyxl
from db_config import (
    get_connection, ensure_schema_exists, write_log, 
    INPUT_DATA_DIR, CSV_STAGING_DIR, SCHEMA_NAME
)

FILE_ASM_XLSX = os.path.join(INPUT_DATA_DIR, "kpi_asm_data_202305.xlsx")
OUT_CSV = os.path.join(CSV_STAGING_DIR, "stg_asm_target.csv")
TABLE_NAME = "stg_asm_target"


def _q(s):
    if s is None:
        return "NULL"
    t = str(s).strip()
    if t == "":
        return "NULL"
    return '"' + t.replace('"', '""') + '"'

def _num(v, fmt="num"):
    """So -> chuoi CSV; rong -> 'NULL' (khong de 0 gia)."""
    if v is None or (isinstance(v, str) and v.strip() == ""):
        return "NULL"
    try:
        if fmt == "int":
            return str(int(float(v)))
        if fmt == "rate":
            return f"{float(v):.6f}"
        return f"{float(v):.2f}"
    except Exception:
        return "NULL"

def _next_month(ym, step):
    """Cong thang co lan nam (202312 + 1 -> 202401)."""
    y, m = ym // 100, ym % 100
    m += step
    y += (m - 1) // 12
    m = (m - 1) % 12 + 1
    return y * 100 + m

def _load_area_map():
    """Ma vung lay tu CSV dim_area cua task 01 (task 01 phai chay truoc)."""
    import csv
    m = {}
    p = os.path.join(CSV_STAGING_DIR, "dim_area.csv")
    try:
        with open(p, 'r', encoding='utf-8') as f:
            for r in csv.DictReader(f):
                if r.get('area_name') and r.get('area_code'):
                    m[r['area_name'].strip()] = r['area_code'].strip()
    except FileNotFoundError:
        pass
    return m

def extract_data():
    """Unpivot 84 dong ASM -> CSV doc theo thang."""
    os.makedirs(CSV_STAGING_DIR, exist_ok=True)
    area_map = _load_area_map()
    wb = openpyxl.load_workbook(FILE_ASM_XLSX, data_only=True)
    ws = wb['KPI_ASM_DATA']
    
    rows_written = 0
    with open(OUT_CSV, 'w', encoding='utf-8') as f:
        f.write("month_key,area_code,sale_name,email,ltn_amount,psdn_count,app_approved,app_in,approval_rate\n")
        
        for r in range(3, ws.max_row + 1):
            area_name = ws.cell(r, 2).value
            sale_name = ws.cell(r, 3).value
            email = ws.cell(r, 4).value
            
            if not sale_name or not email:
                continue
                
            area_str = str(area_name).strip() if area_name else ""
            sale_str = str(sale_name).strip() if sale_name else ""
            email_str = str(email).strip() if email else ""
            
            # 5 thang co du lieu (202301 - 202305)
            base_ym = 202301
            for m_idx in range(5):
                m_key = _next_month(base_ym, m_idx)
                
                ltn = ws.cell(r, 5 + m_idx).value
                psdn = ws.cell(r, 17 + m_idx).value
                app_appr = ws.cell(r, 29 + m_idx).value
                app_in = ws.cell(r, 41 + m_idx).value
                app_rate = ws.cell(r, 53 + m_idx).value
                
                ltn_val = _num(ltn, "amt")
                psdn_val = _num(psdn, "int")
                app_appr_val = _num(app_appr, "int")
                app_in_val = _num(app_in, "int")
                app_rate_val = _num(app_rate, "rate")
                
                f.write(f'{m_key},{_q(area_map.get(area_str, "UNKNOWN"))},{_q(sale_str)},{_q(email_str)},{ltn_val},{psdn_val},{app_appr_val},{app_in_val},{app_rate_val}\n')
                rows_written += 1
                
    wb.close()
    return rows_written


def load_to_postgres():
    t0 = time.time()
    write_log(f"--- BẮT ĐẦU TASK: {TABLE_NAME} ---")
    
    # 1. Trich xuat
    row_count = extract_data()
    write_log(f"  [1] Trích xuất và Unpivot CSV thành công: {row_count} bản ghi monthly.")
    
    # 2. Nap DB
    conn = get_connection()
    try:
        ensure_schema_exists(conn)
        with conn.cursor() as cur:
            cur.execute(f"""
                CREATE UNLOGGED TABLE IF NOT EXISTS {SCHEMA_NAME}.{TABLE_NAME} (
                    month_key        INT,
                    area_code        VARCHAR(10),
                    sale_name        VARCHAR(100),
                    email            VARCHAR(100),
                    ltn_amount       NUMERIC(20, 4),
                    psdn_count       INT,
                    app_approved     INT,
                    app_in           INT,
                    approval_rate    NUMERIC(10, 6)
                );
                ALTER TABLE {SCHEMA_NAME}.{TABLE_NAME} DROP COLUMN IF EXISTS area_name CASCADE;
                TRUNCATE TABLE {SCHEMA_NAME}.{TABLE_NAME};
            """)
            
            with open(OUT_CSV, 'r', encoding='utf-8') as f:
                cur.copy_expert(f"COPY {SCHEMA_NAME}.{TABLE_NAME} FROM STDIN WITH CSV HEADER NULL AS 'NULL';", f)
                
            cur.execute(f"SELECT COUNT(*) FROM {SCHEMA_NAME}.{TABLE_NAME};")
            total_db = cur.fetchone()[0]

            # Index phuc vu thu tuc doc bang nay (quy che: chu bang tao index).
            # dim_asm khong con duoc tao o buoc 02 nua - chu duy nhat la sql/dim/dim_asm.sql.
            cur.execute(f"""
                CREATE INDEX IF NOT EXISTS idx_asm_month_area
                    ON {SCHEMA_NAME}.{TABLE_NAME} (month_key, area_code);
            """)
            
        conn.commit()
        write_log(f"  [2] Nạp PostgreSQL thành công: {total_db} dòng trong {time.time()-t0:.2f}s!")
    except Exception as e:
        conn.rollback()
        write_log(f"  [!] THẤT BẠI: {e}")
        raise e
    finally:
        conn.close()


if __name__ == '__main__':
    load_to_postgres()
