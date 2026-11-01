#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
TASK 01: sheet Param -> dim_area (8 vung A-H) + dim_param_area (64 tinh/thanh).
Nguon: 'Tham so va mau doi chieu.xlsx' (sheet 'Param').
"""

import os
import time
import openpyxl
from db_config import (
    get_connection, ensure_schema_exists, write_log, 
    INPUT_DATA_DIR, CSV_STAGING_DIR, SCHEMA_NAME
)

FILE_PARAM_XLSX = os.path.join(INPUT_DATA_DIR, "Tham so va mau doi chieu.xlsx")
OUT_AREA_CSV = os.path.join(CSV_STAGING_DIR, "dim_area.csv")
OUT_CSV = os.path.join(CSV_STAGING_DIR, "dim_param_area.csv")
AREA_TABLE_NAME = "dim_area"
TABLE_NAME = "dim_param_area"


def _q(s):
    """Text -> CSV: rong/None ghi NULL (khong quote) de COPY hieu la NULL."""
    if s is None:
        return "NULL"
    t = str(s).strip()
    if t == "":
        return "NULL"
    return '"' + t.replace('"', '""') + '"'

def extract_data():
    """Duyet sheet Param (giua tieu de vung de gan tinh) -> CSV trung gian."""
    os.makedirs(CSV_STAGING_DIR, exist_ok=True)
    wb = openpyxl.load_workbook(FILE_PARAM_XLSX, data_only=True)
    ws = wb['Param']
    
    current_area_code = 'A'
    current_area_name = 'Hội Sở'
    province_to_area = {}
    
    area_headers = {
        'Khu vực 0 - HỘI SỞ:': ('A', 'Hội Sở'),
        'Khu vực I - Đông Bắc Bộ:': ('B', 'Đông Bắc Bộ'),
        'Khu vực II - Tây Bắc Bộ': ('C', 'Tây Bắc Bộ'),
        'Khu vực III - Đồng Bằng Sông Hồng:': ('D', 'Đồng Bằng Sông Hồng'),
        'Khu vực IV - Bắc Trung Bộ:': ('E', 'Bắc Trung Bộ'),
        'Khu vực V - Nam Trung Bộ:': ('F', 'Nam Trung Bộ'),
        'Khu vực VI - Miền Tây Nam Bộ:': ('G', 'Tây Nam Bộ'),
        'Khu vực VII - Miền Đông Nam Bộ:': ('H', 'Đông Nam Bộ'),
    }
    
    for r in range(1, ws.max_row + 1):
        j_val = ws.cell(r, 10).value
        k_val = ws.cell(r, 11).value
        if j_val is not None:
            j_str = str(j_val).strip()
            for h_prefix, (a_code, a_name) in area_headers.items():
                if j_str.startswith(h_prefix) or (k_val and str(k_val).strip() == a_code):
                    current_area_code = a_code
                    current_area_name = a_name
                    break
            if not any(j_str.startswith(p) for p in area_headers) and not j_str.startswith("Danh sách"):
                clean_name = j_str.replace("TP.", "").replace(" (Thành phố trực thuộc Trung ương)", "").strip()
                province_to_area[clean_name.lower()] = (current_area_code, current_area_name)
    
    # Ten tinh viet khong thong nhat giua cac file (dau/gach noi) -> map ve ten chuan.
    # Thieu map la mat so ma khong bao loi.
    alias_map = {
        'dak lak': ('F', 'Nam Trung Bộ'),
        'dak nông': ('F', 'Nam Trung Bộ'),
        'đắk lắk': ('F', 'Nam Trung Bộ'),
        'đắk nông': ('F', 'Nam Trung Bộ'),
        'khánh hoà': ('F', 'Nam Trung Bộ'),
        'khánh hòa': ('F', 'Nam Trung Bộ'),
        'thanh hoá': ('E', 'Bắc Trung Bộ'),
        'thanh hóa': ('E', 'Bắc Trung Bộ'),
        'thừa thiên huế': ('E', 'Bắc Trung Bộ'),
        'huế': ('E', 'Bắc Trung Bộ'),
        'vũng tàu': ('H', 'Đông Nam Bộ'),
        'bà rịa-vũng tàu': ('H', 'Đông Nam Bộ'),
    }
    
    rows_written = 0
    unknown_count = 0
    areas_seen = {}
    with open(OUT_CSV, 'w', encoding='utf-8') as f:
        f.write("city_code,city_name,area_code\n")
        for r in range(2, ws.max_row + 1):
            city_name = ws.cell(r, 1).value
            city_code = ws.cell(r, 2).value
            if city_name is not None and city_code is not None:
                city_name_str = str(city_name).strip()
                city_code_str = str(city_code).strip().zfill(2)
                if city_name_str == "" or city_code_str == "":
                    continue
                
                key = city_name_str.lower()
                if city_code_str == '00':
                    a_code, a_name = 'A', 'Hội Sở'
                elif key in alias_map:
                    a_code, a_name = alias_map[key]
                elif key in province_to_area:
                    a_code, a_name = province_to_area[key]
                else:
                    a_code, a_name = 'UNKNOWN', 'Chưa phân vùng'
                    unknown_count += 1
                
                areas_seen[a_code] = a_name
                f.write(f'{_q(city_code_str)},{_q(city_name_str)},{_q(a_code)}\n')
                rows_written += 1

    with open(OUT_AREA_CSV, 'w', encoding='utf-8') as fa:
        fa.write("area_code,area_name\n")
        for a_code, a_name in sorted(areas_seen.items()):
            fa.write(f'{_q(a_code)},{_q(a_name)}\n')
                
    wb.close()
    if unknown_count:
        write_log(f"  [!] Canh bao: {unknown_count} tinh chua map vung (UNKNOWN) - kiem tra alias_map.")
    return len(areas_seen), rows_written


def load_to_postgres():
    t0 = time.time()
    write_log(f"--- BẮT ĐẦU TASK: {AREA_TABLE_NAME} & {TABLE_NAME} ---")
    
    # 1. Trich xuat
    area_count, row_count = extract_data()
    write_log(f"  [1] Trích xuất CSV thành công: {area_count} vùng, {row_count} tỉnh/thành.")
    
    # 2. Nap DB: TRUNCATE truoc de chay lai khong trung (idempotent)
    conn = get_connection()
    try:
        ensure_schema_exists(conn)
        with conn.cursor() as cur:
            cur.execute(f"""
                CREATE TABLE IF NOT EXISTS {SCHEMA_NAME}.{AREA_TABLE_NAME} (
                    area_code    VARCHAR(10) PRIMARY KEY,
                    area_name    VARCHAR(100) NOT NULL
                );
                TRUNCATE TABLE {SCHEMA_NAME}.{AREA_TABLE_NAME};
            """)
            with open(OUT_AREA_CSV, 'r', encoding='utf-8') as fa:
                cur.copy_expert(f"COPY {SCHEMA_NAME}.{AREA_TABLE_NAME} FROM STDIN WITH CSV HEADER NULL AS 'NULL';", fa)
            cur.execute(f"SELECT COUNT(*) FROM {SCHEMA_NAME}.{AREA_TABLE_NAME};")
            total_area_db = cur.fetchone()[0]

            cur.execute(f"""
                CREATE TABLE IF NOT EXISTS {SCHEMA_NAME}.{TABLE_NAME} (
                    city_code    VARCHAR(10) PRIMARY KEY,
                    city_name    VARCHAR(100),
                    area_code    VARCHAR(10)
                );
                ALTER TABLE {SCHEMA_NAME}.{TABLE_NAME} DROP COLUMN IF EXISTS area_name CASCADE;
                TRUNCATE TABLE {SCHEMA_NAME}.{TABLE_NAME};
            """)
            
            with open(OUT_CSV, 'r', encoding='utf-8') as f:
                cur.copy_expert(f"COPY {SCHEMA_NAME}.{TABLE_NAME} FROM STDIN WITH CSV HEADER NULL AS 'NULL';", f)
                
            cur.execute(f"SELECT COUNT(*) FROM {SCHEMA_NAME}.{TABLE_NAME};")
            total_db = cur.fetchone()[0]

            # Index phuc vu thu tuc doc bang nay (quy che: chu bang tao index).
            cur.execute(f"""
                CREATE INDEX IF NOT EXISTS idx_param_city_norm
                    ON {SCHEMA_NAME}.{TABLE_NAME} ((LOWER(TRIM(city_name))));
                CREATE INDEX IF NOT EXISTS idx_param_area_code
                    ON {SCHEMA_NAME}.{TABLE_NAME} (area_code);
            """)
            
        conn.commit()
        write_log(f"  [2] Nạp PostgreSQL thành công: {total_area_db} vùng ({AREA_TABLE_NAME}), {total_db} dòng ({TABLE_NAME}) trong {time.time()-t0:.2f}s!")
    except Exception as e:
        conn.rollback()
        write_log(f"  [!] THẤT BẠI: {e}")
        raise e
    finally:
        conn.close()


if __name__ == '__main__':
    load_to_postgres()
