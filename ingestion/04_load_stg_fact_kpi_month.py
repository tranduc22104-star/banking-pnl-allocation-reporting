#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
TASK 04: fact_kpi_month_raw_data (2.9M hop dong, 2 file tach tu 1 file 117MB) -> stg_fact_kpi_month.
Streaming nhu task 03 + chuan hoa ten tinh.
"""

import os
import time
import zipfile
import xml.etree.ElementTree as ET
from db_config import (
    get_connection, ensure_schema_exists, write_log, 
    INPUT_DATA_DIR, CSV_STAGING_DIR, SCHEMA_NAME
)

FILE_KPI_XLSX = [os.path.join(INPUT_DATA_DIR, f"fact_kpi_month_raw_data_202402020653_part{n}.xlsx") for n in (1, 2)]
OUT_CSV = os.path.join(CSV_STAGING_DIR, "stg_fact_kpi_month.csv")
TABLE_NAME = "stg_fact_kpi_month"


def _cell_text(c):
    """Dich 1 o XML (file nay: chu inlineStr, so lay <v>)."""
    NS = 'http://schemas.openxmlformats.org/spreadsheetml/2006/main'
    t = c.attrib.get('t')
    if t in ('inlineStr', 'str'):
        n = c.find(f'.//{{{NS}}}t')
        return n.text if n is not None else None
    v = c.find(f'{{{NS}}}v')
    return v.text if v is not None else None

def _q(s):
    if s is None:
        return "NULL"
    t = str(s).strip()
    if t == "":
        return "NULL"
    return '"' + t.replace('"', '""') + '"'

def _n(s, kind="amt"):
    if s is None or str(s).strip() == "":
        return "NULL"
    try:
        if kind == "int":
            return str(int(float(s)))
        return f"{float(s):.4f}"
    except Exception:
        return "NULL"

def _norm_city(s):
    """Ten tinh ve dang chuan de JOIN = truc tiep (thay OR alias trong SQL)."""
    if s is None:
        return None
    t = str(s).strip().lower()
    if t == "":
        return None
    t = t.replace(' - ', '-').replace('  ', ' ').strip()
    alias = {
        'dak lak': 'đắk lắk', 'dak nong': 'đắk nông',
        'đak lak': 'đắk lắk', 'đak nong': 'đắk nông',
        'khanh hoa': 'khánh hòa', 'khánh hoà': 'khánh hòa',
        'thanh hoa': 'thanh hóa', 'thanh hoá': 'thanh hóa',
        'thua thien hue': 'huế', 'thừa thiên-huế': 'huế',
        'vung tau': 'vũng tàu', 'ba ria-vung tau': 'vũng tàu',
        'ba ria vung tau': 'vũng tàu', 'bà rịa-vũng tàu': 'vũng tàu',
        'bà rịa vũng tàu': 'vũng tàu',
    }
    return alias.get(t, t)

def extract_data():
    """Streaming 2 file tach (moi file chay thu sheet trong zip) -> CSV, log tien do 500k dong lan."""
    os.makedirs(CSV_STAGING_DIR, exist_ok=True)
    
    row_tag = '{http://schemas.openxmlformats.org/spreadsheetml/2006/main}row'
    c_tag = '{http://schemas.openxmlformats.org/spreadsheetml/2006/main}c'
    
    total_written = 0
    t0 = time.time()
    
    with open(OUT_CSV, 'w', encoding='utf-8') as out_f:
        out_f.write("kpi_month,pos_cde,pos_city,pos_city_norm,application_id,outstanding_principal,write_off_month,write_off_balance_principal,psdn,max_bucket\n")
        
        for part_path in FILE_KPI_XLSX:
            with zipfile.ZipFile(part_path, 'r') as z:
                sheets = sorted(n for n in z.namelist()
                                if n.startswith('xl/worksheets/sheet') and n.endswith('.xml'))
                for s_path in sheets:
                    with z.open(s_path) as sheet_f:
                        for event, elem in ET.iterparse(sheet_f, events=('end',)):
                            if elem.tag == row_tag:
                                row_idx = int(elem.attrib.get('r', '0'))
                                if row_idx <= 1:
                                    elem.clear()
                                    continue

                                cells = {}
                                for c in elem.findall(c_tag):
                                    col_ref = c.attrib.get('r', '')
                                    col_letter = ''.join([ch for ch in col_ref if ch.isalpha()])
                                    cells[col_letter] = _cell_text(c)

                                # A int; B/C text + ten chuan; D-H so (rong -> NULL, khong 0 gia)
                                kpi_csv = _n(cells.get('A'), "int")
                                pos_raw = cells.get('C')
                                pos_cde_csv = _q(cells.get('B'))
                                pos_city_csv = _q(pos_raw)
                                norm = _norm_city(pos_raw)
                                pos_norm_csv = _q(norm)
                                raw_app = cells.get('D')
                                app_csv = _n(raw_app, "int") if raw_app and str(raw_app).strip() else "NULL"
                                bal_csv = _n(cells.get('E'), "amt")
                                raw_wo_m = cells.get('F')
                                wo_m_csv = _n(raw_wo_m, "int") if raw_wo_m and str(raw_wo_m).strip() else "NULL"
                                wo_bal_csv = _n(cells.get('G'), "amt")
                                psdn_csv = _n(cells.get('H'), "int")
                                mb_csv = _q(cells.get('I'))

                                out_f.write(f'{kpi_csv},{pos_cde_csv},{pos_city_csv},{pos_norm_csv},{app_csv},{bal_csv},{wo_m_csv},{wo_bal_csv},{psdn_csv},{mb_csv}\n')

                                total_written += 1
                                if total_written % 500000 == 0:
                                    print(f"    ... Đã ghi {total_written:,} dòng ({time.time()-t0:.2f}s)")
                                elem.clear()
                        
    return total_written


def load_to_postgres():
    t0 = time.time()
    write_log(f"--- BẮT ĐẦU TASK: {TABLE_NAME} ---")
    
    row_count = extract_data()
    write_log(f"  [1] Boc tach CSV: {row_count:,} dong.")
        
    # 2. Nap DB
    conn = get_connection()
    try:
        ensure_schema_exists(conn)
        with conn.cursor() as cur:
            cur.execute(f"""
                CREATE UNLOGGED TABLE IF NOT EXISTS {SCHEMA_NAME}.{TABLE_NAME} (
                    kpi_month                     INT,
                    pos_cde                       VARCHAR(30),
                    pos_city                      VARCHAR(100),
                    pos_city_norm                 VARCHAR(100),
                    application_id                VARCHAR(50),
                    outstanding_principal         NUMERIC(20, 4),
                    write_off_month               INT,
                    write_off_balance_principal   NUMERIC(20, 4),
                    psdn                          INT,
                    max_bucket                    VARCHAR(20)
                );
                TRUNCATE TABLE {SCHEMA_NAME}.{TABLE_NAME};
            """)
            
            write_log("  [2] Đang nạp COPY vào PostgreSQL...")
            copy_t0 = time.time()
            with open(OUT_CSV, 'r', encoding='utf-8') as f:
                cur.copy_expert(f"COPY {SCHEMA_NAME}.{TABLE_NAME} FROM STDIN WITH CSV HEADER NULL AS 'NULL';", f)
            copy_duration = time.time() - copy_t0
            
            cur.execute(f"SELECT COUNT(*) FROM {SCHEMA_NAME}.{TABLE_NAME};")
            total_db = cur.fetchone()[0]

            # Index phuc vu thu tuc doc bang nay (quy che: chu bang tao index).
            # Tao sau COPY de nap 2,9 trieu dong khong phai duy index theo tung dong.
            cur.execute(f"""
                CREATE INDEX IF NOT EXISTS idx_kpi_month_norm
                    ON {SCHEMA_NAME}.{TABLE_NAME} (kpi_month, pos_city_norm);
            """)
            
            cur.execute(f"""
                SELECT kpi_month, COUNT(*), SUM(outstanding_principal) 
                FROM {SCHEMA_NAME}.{TABLE_NAME} 
                GROUP BY kpi_month 
                ORDER BY kpi_month;
            """)
            kpi_sums = cur.fetchall()
            
        conn.commit()
        write_log(f"  [V] Nạp PostgreSQL thành công: {total_db:,} dòng trong {copy_duration:.2f}s (Tổng pipeline: {time.time()-t0:.2f}s)!")
        write_log("  [*] Chi tiết dư nợ theo 5 tháng:")
        for km, cnt, sm in kpi_sums:
            sm_val = float(sm) if sm else 0.0
            write_log(f"      + Tháng {km}: {cnt:,} HĐ | Dư nợ: {sm_val:,.2f} VNĐ")
    except Exception as e:
        conn.rollback()
        write_log(f"  [!] THẤT BẠI: {e}")
        raise e
    finally:
        conn.close()


if __name__ == '__main__':
    load_to_postgres()
