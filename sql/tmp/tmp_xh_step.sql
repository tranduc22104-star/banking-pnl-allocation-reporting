-- =====================================================================
-- BANG TAM XEP HANG (3 bang, STEP1..STEP3) -- loi khai bao ra khoi than thu tuc sp_xephang_asm.
-- Moi bang dang TALL; thu tuc sp_xephang_asm tinh va ghi du lieu.
-- QUY UOC report_id: (a) dong se thanh dong fact -> dung dung id cua fact (201..222);
-- (b) dong trung gian chi de doi chieu -> dai 231..239, ngoai cay bao cao.
-- Thu tu chay: sql/dim -> sql/tmp (file nay) -> sql/fct -> CALL -> sql/rpt.
-- =====================================================================

SET search_path TO banking_project, public;

-- 01b. Bang trung gian BUOC 1: AVG luy ke tung ASM — dang TALL theo asm_id.
-- 3 dong/ASM: 201 LTN, 202 PSDN, 203 duyet.
-- value NUMERIC(20,6), CAST ve dung do le cot cu khi INSERT
-- (201: 2 so le, 202: 2 so le, 203: 6 so le).
DROP TABLE IF EXISTS tmp_xh_step1_asm_avg CASCADE;
CREATE TABLE tmp_xh_step1_asm_avg (
    month_key   INT NOT NULL,
    asm_id      INT NOT NULL,          -- FK -> dim_asm(asm_id)
    report_id   INT NOT NULL,           -- 201 / 202 / 203
    value       NUMERIC(20,6),
    PRIMARY KEY (month_key, asm_id, report_id)
);
CREATE INDEX IF NOT EXISTS idx_tmp_xh_step1_asm_month
    ON tmp_xh_step1_asm_avg (month_key);

-- 01c. Bang trung gian BUOC 2: NPL tung vung — dang TALL 3 id moi vung.
-- 204 = % no xau (6 so le, dung do le cot value cu), 231 = tu so (no nhom 3-5
-- + WO trong nam), 232 = mau so (tong du no + WO trong nam). Truoc day tu/mau
-- nam cot rieng (num/den); chuyen sang dong thi bang van dang tall ma van
-- doi chieu duoc thang voi stg_fact_kpi_month.
-- Khong luu area_name: bang tam chi can khua, ten lay tu dim_param_area.
DROP TABLE IF EXISTS tmp_xh_step2_npl_area CASCADE;
CREATE TABLE tmp_xh_step2_npl_area (
    month_key   INT NOT NULL,
    area_code   VARCHAR(10) NOT NULL,
    report_id   INT NOT NULL,                -- 204 / 231 / 232
    value       NUMERIC,                     -- % (6sl) hoac VND (4sl)
    PRIMARY KEY (month_key, area_code, report_id)
);
CREATE INDEX IF NOT EXISTS idx_tmp_xh_step2_npl_month
    ON tmp_xh_step2_npl_area (month_key);

-- 01d. Bang trung gian BUOC 3: chi so tai chinh cap VUNG — dang TALL 9 id/vung.
-- Lay 4 chi so tu fct_pnl_value cua vung (91 CIR / 92 Margin / 93 HS von,
-- rieng HSBQ tinh A/J nguyen do le tu 70 va 90 — KHONG dung la 94 vi da ROUND)
-- va 4 hang cua 7 vung. Day la noi duy nhat hang tai chinh sinh ra; STEP5 chi
-- copy 9 dong nay cho tung ASM khop vung (report_id giu nguyen 211..219).
-- value de NUMERIC khong han che do le: id 217 (hsbq) phai luu NGUYEN de STEP5
-- moi ROUND(..,2); 211/213/215 lam tron 6 so le ngay trong VALUES (bang do le
-- cot cu NUMERIC(12,6)).
-- Doc dang ngang (kieu pivot-on-read, chi dung khi soi so trong DBeaver):
--   SELECT p.area_code, pa.area_name,
--          MAX(p.value) FILTER (WHERE p.report_id=212) AS r_cir,
--          MAX(p.value) FILTER (WHERE p.report_id=214) AS r_margin,
--          MAX(p.value) FILTER (WHERE p.report_id=216) AS r_hs,
--          MAX(p.value) FILTER (WHERE p.report_id=218) AS r_hsbq,
--          MAX(p.value) FILTER (WHERE p.report_id=219) AS diem_fin
--   FROM tmp_xh_step3_fin_area AS p
--   LEFT JOIN dim_param_area AS pa ON pa.area_code = p.area_code
--   WHERE p.month_key=202305 GROUP BY 1,2 ORDER BY diem_fin;
DROP TABLE IF EXISTS tmp_xh_step3_fin_area CASCADE;
CREATE TABLE tmp_xh_step3_fin_area (
    month_key   INT NOT NULL,
    area_code   VARCHAR(10) NOT NULL,
    report_id   INT NOT NULL,                -- 211..219 (id cua fact se ghi sang)
    value       NUMERIC,
    PRIMARY KEY (month_key, area_code, report_id)
);
CREATE INDEX IF NOT EXISTS idx_tmp_xh_step3_fin_month
    ON tmp_xh_step3_fin_area (month_key);
