-- =====================================================================
-- VIEW BAO CAO P&L (trieu dong cho Power BI Import, VND cho xuat Excel).
-- Nguon = banking_project.fct_pnl_value pivot; loai pool '00' (Hoi so) de khong cong trung.
-- Phai chay SAU sql/fct: tao lai bang fact co DROP ... CASCADE nen view bi xoa theo.
-- =====================================================================

SET search_path TO banking_project, public;

-- 04. VIEW cho PBI Import (khong luu du lieu, don vi trieu dong) ------
-- Giu NGUYEN ten 31 cot cua view cu (PBIX dang dung khong bi vo).
-- Nguon = fct_pnl_value pivot; loai pool '00' (view cu chi co 7 vung).
DROP VIEW IF EXISTS v_baocao_tonghop;
CREATE VIEW v_baocao_tonghop AS
SELECT
    month_key                                            AS month_key,
    area_code                                            AS area_code,
    MAX(area_name)                                       AS area_name,
    MAX(value) FILTER (WHERE report_id = 1)  / 1e6       AS lai_trong_han_trieu_dong,
    MAX(value) FILTER (WHERE report_id = 2)  / 1e6       AS lai_qua_han_trieu_dong,
    MAX(value) FILTER (WHERE report_id = 3)  / 1e6       AS phi_bh_trieu_dong,
    MAX(value) FILTER (WHERE report_id = 4)  / 1e6       AS phi_tang_hm_trieu_dong,
    MAX(value) FILTER (WHERE report_id = 5)  / 1e6       AS phi_cham_tra_trieu_dong,
    MAX(value) FILTER (WHERE report_id = 11) / 1e6       AS thu_nhap_the_trieu_dong,
    MAX(value) FILTER (WHERE report_id = 24) / 1e6       AS cp_kdv_trieu_dong,
    MAX(value) FILTER (WHERE report_id = 21) / 1e6       AS von_tt2_trieu_dong,
    MAX(value) FILTER (WHERE report_id = 22) / 1e6       AS von_tt1_trieu_dong,
    MAX(value) FILTER (WHERE report_id = 23) / 1e6       AS von_cctg_trieu_dong,
    MAX(value) FILTER (WHERE report_id = 34) / 1e6       AS cp_hd_khac_trieu_dong,
    MAX(value) FILTER (WHERE report_id = 31) / 1e6       AS dt_kd_trieu_dong,
    MAX(value) FILTER (WHERE report_id = 32) / 1e6       AS cp_hoahong_trieu_dong,
    MAX(value) FILTER (WHERE report_id = 33) / 1e6       AS cp_kd_khac_trieu_dong,
    MAX(value) FILTER (WHERE report_id = 40) / 1e6       AS tong_thunhap_trieu_dong,
    MAX(value) FILTER (WHERE report_id = 56) / 1e6       AS tong_chiphi_trieu_dong,
    MAX(value) FILTER (WHERE report_id = 51) / 1e6       AS cp_thue_trieu_dong,
    MAX(value) FILTER (WHERE report_id = 52) / 1e6       AS cp_nv_trieu_dong,
    MAX(value) FILTER (WHERE report_id = 53) / 1e6       AS cp_qly_trieu_dong,
    MAX(value) FILTER (WHERE report_id = 54) / 1e6       AS cp_ts_trieu_dong,
    MAX(value) FILTER (WHERE report_id = 60) / 1e6       AS du_phong_trieu_dong,
    MAX(value) FILTER (WHERE report_id = 80) / 1e6       AS tong_dt_trieu_dong,
    MAX(value) FILTER (WHERE report_id = 70) / 1e6       AS lntt_trieu_dong,
    MAX(value) FILTER (WHERE report_id = 90)             AS sm_count,
    MAX(value) FILTER (WHERE report_id = 91)             AS cir,
    MAX(value) FILTER (WHERE report_id = 92)             AS margin,
    MAX(value) FILTER (WHERE report_id = 93)             AS hs_von,
    MAX(value) FILTER (WHERE report_id = 94) / 1e6       AS nsbq_trieu_dong
FROM banking_project.fct_pnl_value
WHERE area_code <> '00'
GROUP BY month_key, area_code;

-- 04b. VIEW VND dung cho Excel export (ten cot = 100% fct wide cu,
-- bao gom ca cot c_dt_nguonvon luon 0) — drop-in thay fct_baocao_tonghop.
DROP VIEW IF EXISTS v_baocao_tonghop_vnd;
CREATE VIEW v_baocao_tonghop_vnd AS
SELECT
    month_key                                            AS month_key,
    area_code                                            AS area_code,
    MAX(area_name)                                       AS area_name,
    MAX(value) FILTER (WHERE report_id = 1)              AS b2_lai_trong_han,
    MAX(value) FILTER (WHERE report_id = 2)              AS b1_lai_qua_han,
    MAX(value) FILTER (WHERE report_id = 3)              AS b3_phi_bh,
    MAX(value) FILTER (WHERE report_id = 4)              AS b4_phi_tang_hm,
    MAX(value) FILTER (WHERE report_id = 5)              AS b5_phi_cham_tra,
    MAX(value) FILTER (WHERE report_id = 11)             AS b_tong,
    0::NUMERIC(20,2)                                     AS c_dt_nguonvon,
    MAX(value) FILTER (WHERE report_id = 21)             AS c3_von_tt2,
    MAX(value) FILTER (WHERE report_id = 22)             AS c2_von_tt1,
    MAX(value) FILTER (WHERE report_id = 23)             AS c1_von_cctg,
    MAX(value) FILTER (WHERE report_id = 24)             AS c_tong,
    MAX(value) FILTER (WHERE report_id = 31)             AS d3_dt_kd,
    MAX(value) FILTER (WHERE report_id = 32)             AS d1_cp_hoahong,
    MAX(value) FILTER (WHERE report_id = 33)             AS d2_cp_kd_khac,
    MAX(value) FILTER (WHERE report_id = 34)             AS d_tong,
    MAX(value) FILTER (WHERE report_id = 40)             AS e_tong_thunhap,
    MAX(value) FILTER (WHERE report_id = 51)             AS f1_cp_thue,
    MAX(value) FILTER (WHERE report_id = 52)             AS f2_cp_nv,
    MAX(value) FILTER (WHERE report_id = 53)             AS f3_cp_qly,
    MAX(value) FILTER (WHERE report_id = 54)             AS f4_cp_ts,
    MAX(value) FILTER (WHERE report_id = 56)             AS f_tong_chiphi,
    MAX(value) FILTER (WHERE report_id = 60)             AS g_du_phong,
    MAX(value) FILTER (WHERE report_id = 70)             AS a_lntt,
    MAX(value) FILTER (WHERE report_id = 80)             AS h_tong_dt,
    MAX(value) FILTER (WHERE report_id = 90)             AS j_sm_count,
    MAX(value) FILTER (WHERE report_id = 91)             AS cir,
    MAX(value) FILTER (WHERE report_id = 92)             AS margin,
    MAX(value) FILTER (WHERE report_id = 93)             AS hs_von,
    MAX(value) FILTER (WHERE report_id = 94)             AS nsbq
FROM banking_project.fct_pnl_value
WHERE area_code <> '00'
GROUP BY month_key, area_code;

-- 04c. VIEW BÓC TÁCH NGUYÊN NHÂN P&L (Root Cause Analysis) — ĐÃ XOÁ KHỎI DB NGÀY 2026-10-30
-- Kho còn đúng 4 view (v_baocao_tonghop, v_xephang_asm và 2 bản _vnd). Không tạo lại view này,
-- Định nghĩa cũ không còn trong kho mã; ai cần tra lại thì hỏi người bàn giao tệp bak_view_root_cause_20261030.sql.

-- 04c. VIEW BOC TACH NGUYEN NHAN P&L (Root Cause Analysis) da xoa khoi database
-- ngay 2026-10-30. Kho con dung 4 view (2 view P&L va 2 ban _vnd). Khong tao lai
-- view nay; can tra lai dinh nghia cu thi hoi nguoi ban giao
-- bak_view_root_cause_20261030.sql.

-- CHECK nhanh: SELECT COUNT(*) FROM banking_project.v_baocao_tonghop; -- 35 dong (7 vung x 5 thang)
