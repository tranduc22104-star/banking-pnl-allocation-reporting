#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
TASK 03: fact_txn_month_raw_data.xlsx (63k but toan GL) -> stg_fact_txn_month.
Doc thang XML tu zip (openpyxl khong tai noi + loi dimension), tu sinh
txn_month + prov de SQL JOIN so nhanh.
"""

import os
import time
import zipfile
import datetime
import xml.etree.ElementTree as ET
from db_config import (
    get_connection, ensure_schema_exists, write_log, 
    INPUT_DATA_DIR, CSV_STAGING_DIR, SCHEMA_NAME
)

FILE_TXN_XLSX = os.path.join(INPUT_DATA_DIR, "fact_txn_month_raw_data_202402020504.xlsx")
OUT_CSV = os.path.join(CSV_STAGING_DIR, "stg_fact_txn_month.csv")
TABLE_NAME = "stg_fact_txn_month"


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

def _n(s):
    if s is None or str(s).strip() == "":
        return "NULL"
    try:
        return f"{float(s):.4f}"
    except Exception:
        return "NULL"

def _prov(analysis):
    """Ma tinh tu analysis_code (DVML.01.D.39... -> 39, HEAD... -> 00)."""
    if analysis is None or str(analysis).strip() == "":
        return None
    a = str(analysis).strip()
    if a.split('.', 1)[0] == 'HEAD':
        return '00'
    parts = a.split('.')
    if len(parts) >= 4 and parts[3].strip() != "":
        return parts[3].strip().zfill(2)
    return None

def extract_data():
    """Streaming XML sang CSV (bo header, xoa element sau moi dong de nhe RAM)."""
    os.makedirs(CSV_STAGING_DIR, exist_ok=True)
    
    row_tag = '{http://schemas.openxmlformats.org/spreadsheetml/2006/main}row'
    c_tag = '{http://schemas.openxmlformats.org/spreadsheetml/2006/main}c'
    
    rows_written = 0
    with zipfile.ZipFile(FILE_TXN_XLSX, 'r') as z, open(OUT_CSV, 'w', encoding='utf-8') as out_f:
        out_f.write("transaction_date,txn_month,prov,account_code,account_description,analysis_code,amount,d_c\n")
        
        with z.open('xl/worksheets/sheet1.xml') as sheet_f:
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
                    
                    # Ngay Excel = so serial tu 30/12/1899; ma TK dang 7.02E11 -> so nguyen
                    raw_date = (cells.get('A') or '').strip()
                    if raw_date:
                        try:
                            d = datetime.date(1899, 12, 30) + datetime.timedelta(days=int(float(raw_date)))
                            date_csv = d.strftime('%Y-%m-%d')
                            txn_month_csv = f"{d.year * 100 + d.month}"
                        except Exception:
                            date_csv = "NULL"
                            txn_month_csv = "NULL"
                    else:
                        date_csv = "NULL"
                        txn_month_csv = "NULL"
                    
                    # 2. account_code dang 7.02000030012E11, rong -> NULL
                    raw_acc = (cells.get('B') or '').strip()
                    if raw_acc:
                        try:
                            acc_csv = str(f"{int(float(raw_acc)):d}")
                        except Exception:
                            acc_csv = raw_acc
                        acc_csv = _q(acc_csv)
                    else:
                        acc_csv = "NULL"
                    
                    # Text rong -> NULL; amount rong -> NULL (khong de 0 gia)
                    desc_csv = _q(cells.get('C'))
                    analysis_csv = _q((cells.get('D') or '').strip())
                    dc_csv = _q((cells.get('F') or '').strip())
                    
                    # 5. amount: rong -> NULL (khong de 0 gia)
                    amt_csv = _n(cells.get('E'))
                    prov_csv = _q(_prov(cells.get('D')))
                    
                    if date_csv == "NULL":
                        out_f.write(f'NULL,{txn_month_csv},{prov_csv},{acc_csv},{desc_csv},{analysis_csv},{amt_csv},{dc_csv}\n')
                    else:
                        out_f.write(f'{date_csv},{txn_month_csv},{prov_csv},{acc_csv},{desc_csv},{analysis_csv},{amt_csv},{dc_csv}\n')
                    rows_written += 1
                    elem.clear()
                    
    return rows_written


def load_to_postgres():
    t0 = time.time()
    write_log(f"--- BẮT ĐẦU TASK: {TABLE_NAME} ---")
    
    # 1. Trích xuất
    row_count = extract_data()
    write_log(f"  [1] Trích xuất Streaming XML thành công: {row_count:,} dòng sổ cái GL.")
    
    # 2. Tạo bảng và nạp vào DB trong Transaction
    conn = get_connection()
    try:
        ensure_schema_exists(conn)
        with conn.cursor() as cur:
            cur.execute(f"""
                CREATE UNLOGGED TABLE IF NOT EXISTS {SCHEMA_NAME}.{TABLE_NAME} (
                    transaction_date       DATE,
                    txn_month              INT,
                    prov                   VARCHAR(10),
                    account_code           VARCHAR(30),
                    account_description    TEXT,
                    analysis_code          VARCHAR(50),
                    amount                 NUMERIC(20, 4),
                    d_c                    CHAR(1)
                );
                TRUNCATE TABLE {SCHEMA_NAME}.{TABLE_NAME};
            """)
            
            with open(OUT_CSV, 'r', encoding='utf-8') as f:
                cur.copy_expert(f"COPY {SCHEMA_NAME}.{TABLE_NAME} FROM STDIN WITH CSV HEADER NULL AS 'NULL';", f)
                
            cur.execute(f"SELECT COUNT(*), SUM(amount) FROM {SCHEMA_NAME}.{TABLE_NAME};")
            total_db, sum_gl = cur.fetchone()

            # Index phuc vu thu tuc doc bang nay (quy che: chu bang tao index).
            cur.execute(f"""
                CREATE INDEX IF NOT EXISTS idx_txn_month_prov
                    ON {SCHEMA_NAME}.{TABLE_NAME} (txn_month, prov);
                CREATE INDEX IF NOT EXISTS idx_txn_month_acc
                    ON {SCHEMA_NAME}.{TABLE_NAME} (txn_month, account_code);
            """)
            
        conn.commit()
        write_log(f"  [2] Nạp PostgreSQL thành công: {total_db:,} dòng | Tổng tiền: {float(sum_gl):,.2f} VNĐ trong {time.time()-t0:.2f}s!")
    except Exception as e:
        conn.rollback()
        write_log(f"  [!] THẤT BẠI: {e}")
        raise e
    finally:
        conn.close()


if __name__ == '__main__':
    load_to_postgres()
