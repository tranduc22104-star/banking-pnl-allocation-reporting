-- =====================================================================
-- KHUNG NHÌN BÁO CÁO LÃI LỖ: một bản tính bằng triệu đồng cho Power BI,
-- một bản giữ nguyên đơn vị đồng cho bước xuất Excel.
-- Nguồn là bảng sự kiện fct_pnl_value trải ngang; loại dòng hội sở '00' để khi
-- cộng gộp không bị tính hai lần.
-- Phải chạy sau sql/fct: tệp đó tạo lại bảng sự kiện bằng DROP ... CASCADE nên
-- khung nhìn bị xoá theo.
-- =====================================================================

SET search_path TO banking_project, public;

-- 04. KHUNG NHÌN CHO POWER BI (đơn vị triệu đồng, không lưu dữ liệu) ---------
-- Giữ nguyên ba mươi mốt tên cột của khung nhìn cũ để tệp .pbix đang dùng không bị vỡ.
-- Nguồn là fct_pnl_value trải ngang, loại dòng hội sở '00' vì khung nhìn cũ chỉ có bảy vùng.
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

-- 04b. KHUNG NHÌN ĐƠN VỊ ĐỒNG cho bước xuất Excel: tên cột lấy nguyên từ bảng
-- rộng cũ, kể cả cột c_dt_nguonvon luôn bằng 0, để thay thế trực tiếp cho
-- fct_baocao_tonghop.
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

-- 04c. KHUNG NHÌN BÓC TÁCH NGUYÊN NHÂN (phân tích nguyên nhân) ĐÃ GỠ KHỎI
-- DATABASE NGÀY 2026-10-30: không tạo lại. Kho còn đúng bốn khung nhìn, gồm hai
-- bản lãi lỗ ở tệp này và hai bản xếp hạng ở sql/rpt/rpt_xephang_view.sql. Cần
-- xem lại định nghĩa cũ thì hỏi người bàn giao tệp bak_view_root_cause_20261030.sql.


-- Kiểm tra nhanh: SELECT COUNT(*) FROM banking_project.v_baocao_tonghop; -- 35 dòng, bảy vùng nhân năm tháng
