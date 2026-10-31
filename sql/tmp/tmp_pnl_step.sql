-- =====================================================================
-- BANG TAM P&L (3 bang, STEP1..STEP3) -- loi khai bao ra khoi than thu tuc sp_baocao_tonghop.
-- Moi bang dang TALL (month_key, khoa doi tuong, report_id, value).
-- File nay chi khai bao cau truc; thu tuc sp_baocao_tonghop tinh va ghi du lieu.
-- Ten bang trung voi so buoc trong thu tuc: tmp_pnl_step{N}_{lam gi}.
-- Thu tu chay: sql/dim -> sql/tmp (file nay) -> sql/fct -> CALL -> sql/rpt.
-- =====================================================================

SET search_path TO banking_project, public;

-- 01. 3 BANG TRUNG GIAN — dang TALL (report_id = phan P&L tuong ung) ---------
-- 01a. STEP1: driver phan bo — 9 id moi vung. Gom ca 3 nhom driver vao MOT
-- bang vi chung grain (vung x thang) va STEP2 (% phan bo) doc lai het:
--   nhom 1 -> 1 (B2) + 4 (B4) | nhom 2 -> 2 (B1) | nhom 2-5 sau WO -> 5 (B5)
--   truoc WO -> 60 (G) | tong sau WO -> 24 (C va D dung chung)
--   psdn -> 3 (B3) | headcount SM -> 56 (F) va 90 (J)
-- Do le: 6 driver KPI da ROUND(4) dung bang do le cot cu (value NUMERIC(20,4)
-- truoc day); psdn va headcount giu NGUYEN (cot cu khong han che do le).
DROP TABLE IF EXISTS tmp_pnl_step1_driver CASCADE;
CREATE TABLE tmp_pnl_step1_driver (
    month_key   INT NOT NULL,
    area_code   VARCHAR(10) NOT NULL,
    area_name   VARCHAR(100),
    report_id   INT NOT NULL,           -- 1/2/3/4/5/24/56/60/90
    value       NUMERIC,
    PRIMARY KEY (month_key, area_code, report_id)
);
CREATE INDEX IF NOT EXISTS idx_tmp_pnl_step1_driver_month
    ON tmp_pnl_step1_driver (month_key);

-- 01b. STEP2: % phan bo — phan nao phan bo thi ghi report_id phan do.
-- Cung driver dung chung thi ghep day du: pct_nhom1 cho 1 (B2) + 4 (B4);
-- pct_dnck/tong cho 21/22/23 (C) va 31/32/33 (D); pct_sm cho 51..54 (F).
-- Value NUMERIC(12,8) nhu cot pct cu (lam tron 8 so le khi luu).
DROP TABLE IF EXISTS tmp_pnl_step2_ratio CASCADE;
CREATE TABLE tmp_pnl_step2_ratio (
    month_key   INT NOT NULL,
    area_code   VARCHAR(10) NOT NULL,
    area_name   VARCHAR(100),
    report_id   INT NOT NULL,           -- 16 id: 1,4,2,5,3,21..23,31..33,51..54,60
    value       NUMERIC(12,8),
    PRIMARY KEY (month_key, area_code, report_id)
);
CREATE INDEX IF NOT EXISTS idx_tmp_pnl_step2_ratio_month
    ON tmp_pnl_step2_ratio (month_key);

-- 01c. STEP3: GL tach HEAD (area '00') vs DIRECT (Rule1 theo vung).
-- 16 id head: 1..5, 21..23, 31..33, 51..54, 60; 13 id direct (khong co C).
DROP TABLE IF EXISTS tmp_pnl_step3_gl_split CASCADE;
CREATE TABLE tmp_pnl_step3_gl_split (
    month_key   INT NOT NULL,
    area_code   VARCHAR(10) NOT NULL,   -- '00' = HEAD (Hoi so)
    area_name   VARCHAR(100),
    report_id   INT NOT NULL,
    value       NUMERIC(20,4),
    PRIMARY KEY (month_key, area_code, report_id)
);
CREATE INDEX IF NOT EXISTS idx_tmp_pnl_step3_gl_split_month
    ON tmp_pnl_step3_gl_split (month_key);
