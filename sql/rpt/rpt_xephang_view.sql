-- =====================================================================
-- VIEW XEP HANG ASM (ten/email/vung lay tu join dim_asm).
-- Nguon = banking_project.fct_asm_value pivot; 1 ban trieu dong cho Power BI,
-- 1 ban VND cho xuat Excel. Chay sau sql/fct vi DROP ... CASCADE xoa view theo bang.
-- =====================================================================

SET search_path TO banking_project, public;

-- 03. VIEW cho PBI (ten/email/vung lay join dim_asm) --------------------------
-- Giu NGUYEN ten 27 cot cua view cu (PBIX dang dung khong bi vo).
DROP VIEW IF EXISTS v_xephang_asm;
CREATE VIEW v_xephang_asm AS
SELECT
    f.month_key                                              AS month_key,
    MAX(d.area_code)                                         AS area_code,
    MAX(d.area_name)                                         AS area_name,
    MAX(d.email)                                             AS email,
    MAX(d.sale_name)                                         AS sale_name,
    MAX(f.value) FILTER (WHERE f.report_id = 221)            AS tong_diem,
    MAX(f.value) FILTER (WHERE f.report_id = 222)            AS rank_final,
    MAX(f.value) FILTER (WHERE f.report_id = 201) / 1e6      AS ltn_trieu_dong,
    MAX(f.value) FILTER (WHERE f.report_id = 205)            AS rank_ltn,
    MAX(f.value) FILTER (WHERE f.report_id = 202)            AS psdn_avg,
    MAX(f.value) FILTER (WHERE f.report_id = 206)            AS rank_psdn,
    MAX(f.value) FILTER (WHERE f.report_id = 203)            AS approval_rate_avg,
    MAX(f.value) FILTER (WHERE f.report_id = 207)            AS rank_approval,
    MAX(f.value) FILTER (WHERE f.report_id = 204)            AS npl,
    MAX(f.value) FILTER (WHERE f.report_id = 208)            AS rank_npl,
    MAX(f.value) FILTER (WHERE f.report_id = 209)            AS diem_qm,
    MAX(f.value) FILTER (WHERE f.report_id = 210)            AS rank_ptkd,
    MAX(f.value) FILTER (WHERE f.report_id = 211)            AS cir,
    MAX(f.value) FILTER (WHERE f.report_id = 212)            AS rank_cir,
    MAX(f.value) FILTER (WHERE f.report_id = 213)            AS margin,
    MAX(f.value) FILTER (WHERE f.report_id = 214)            AS rank_margin,
    MAX(f.value) FILTER (WHERE f.report_id = 215)            AS hs_von,
    MAX(f.value) FILTER (WHERE f.report_id = 216)            AS rank_hs_von,
    MAX(f.value) FILTER (WHERE f.report_id = 217) / 1e6      AS hsbq_trieu_dong,
    MAX(f.value) FILTER (WHERE f.report_id = 218)            AS rank_hsbq,
    MAX(f.value) FILTER (WHERE f.report_id = 219)            AS diem_fin,
    MAX(f.value) FILTER (WHERE f.report_id = 220)            AS rank_fin
FROM banking_project.fct_asm_value AS f
JOIN banking_project.dim_asm AS d
    ON d.asm_id = f.asm_id
GROUP BY f.month_key, d.email;

-- 03b. VIEW VND dung cho Excel export (ten cot = 100% fct wide cu)
-- — drop-in thay fct_xephang_asm (SELECT * giong het truoc day).
DROP VIEW IF EXISTS v_xephang_asm_vnd;
CREATE VIEW v_xephang_asm_vnd AS
SELECT
    f.month_key                                              AS month_key,
    MAX(d.area_code)                                         AS area_code,
    MAX(d.area_name)                                         AS area_name,
    MAX(d.email)                                             AS email,
    MAX(d.sale_name)                                         AS sale_name,
    MAX(f.value) FILTER (WHERE f.report_id = 201)            AS ltn_avg,
    MAX(f.value) FILTER (WHERE f.report_id = 202)            AS psdn_avg,
    MAX(f.value) FILTER (WHERE f.report_id = 203)            AS approval_rate_avg,
    MAX(f.value) FILTER (WHERE f.report_id = 204)            AS npl_truoc_wo_luy_ke,
    MAX(f.value) FILTER (WHERE f.report_id = 205)            AS rank_ltn_avg,
    MAX(f.value) FILTER (WHERE f.report_id = 206)            AS rank_psdn_avg,
    MAX(f.value) FILTER (WHERE f.report_id = 207)            AS rank_approval_rate_avg,
    MAX(f.value) FILTER (WHERE f.report_id = 208)            AS rank_npl,
    MAX(f.value) FILTER (WHERE f.report_id = 209)            AS diem_qm,
    MAX(f.value) FILTER (WHERE f.report_id = 210)            AS rank_ptkd,
    MAX(f.value) FILTER (WHERE f.report_id = 211)            AS cir,
    MAX(f.value) FILTER (WHERE f.report_id = 212)            AS rank_cir,
    MAX(f.value) FILTER (WHERE f.report_id = 213)            AS margin,
    MAX(f.value) FILTER (WHERE f.report_id = 214)            AS rank_margin,
    MAX(f.value) FILTER (WHERE f.report_id = 215)            AS hs_von,
    MAX(f.value) FILTER (WHERE f.report_id = 216)            AS rank_hs_von,
    MAX(f.value) FILTER (WHERE f.report_id = 217)            AS hsbq_nhan_su,
    MAX(f.value) FILTER (WHERE f.report_id = 218)            AS rank_hsbq_nhan_su,
    MAX(f.value) FILTER (WHERE f.report_id = 219)            AS diem_fin,
    MAX(f.value) FILTER (WHERE f.report_id = 220)            AS rank_fin,
    MAX(f.value) FILTER (WHERE f.report_id = 221)            AS tong_diem,
    MAX(f.value) FILTER (WHERE f.report_id = 222)            AS rank_final
FROM banking_project.fct_asm_value AS f
JOIN banking_project.dim_asm AS d
    ON d.asm_id = f.asm_id
GROUP BY f.month_key, d.email;

-- CHECK nhanh: SELECT COUNT(*) FROM banking_project.v_xephang_asm; -- 388 dong
-- SELECT email, tong_diem, rank_final FROM banking_project.v_xephang_asm
--     WHERE month_key=202302 ORDER BY rank_final LIMIT 1; -- nam.hoangvan 34 diem
