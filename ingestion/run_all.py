#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
DATA PIPELINE ORCHESTRATOR
==========================
Điều phối chạy tuần tự 4 task nạp dữ liệu.
"""

import sys
if sys.platform.startswith('win'):
    try:
        sys.stdout.reconfigure(encoding='utf-8')
        sys.stderr.reconfigure(encoding='utf-8')
    except Exception:
        pass
import time
import subprocess
import os

SCRIPTS = [
    "01_load_dim_param_area.py",
    "02_load_stg_asm_target.py",
    "03_load_stg_fact_txn_month.py",
    "04_load_stg_fact_kpi_month.py"
]

def main():
    print("="*70)
    print("KHỞI ĐỘNG DATA PIPELINE CAPSTONE PROJECT (4 TASKS)")
    print("="*70)
    
    current_dir = os.path.dirname(os.path.abspath(__file__))
    total_t0 = time.time()
    
    for idx, script in enumerate(SCRIPTS, 1):
        print(f"\n>>> [TASK {idx}/4] Đang thực thi {script}...")
        script_path = os.path.join(current_dir, script)
        res = subprocess.run([sys.executable, script_path])
        if res.returncode != 0:
            print(f"[!] Pipeline dừng do {script} thất bại!")
            sys.exit(1)
            
    print("\n" + "="*70)
    print(f"TOÀN BỘ 4 TASKS ĐÃ CHẠY THÀNH CÔNG TRONG {time.time()-total_t0:.2f} GIÂY!")
    print("="*70)

if __name__ == '__main__':
    main()
