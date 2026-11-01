-- =====================================================================
-- XẾP HẠNG ASM (mỗi ASM một quản lý kinh doanh vùng): bảng sự kiện
-- fct_asm_value và thủ tục điều phối sp_xephang_asm.
-- Phần một tính theo từng ASM: doanh số cho vay mới, PSDN và tỷ lệ duyệt là
-- trung bình luỹ kế từ đầu năm (bỏ qua ô trống); tỷ lệ nợ xấu lấy theo vùng.
-- Phần hai là bốn chỉ số tài chính của vùng (chi phí trên doanh thu, lợi nhuận
-- biên, hệ số vốn, kết quả bình quân một quản lý) — mọi ASM cùng vùng như nhau.
-- Điểm tổng = điểm phần một cộng điểm phần hai. RANK() để cùng điểm thì cùng
-- hạng nên dãy hạng có thể nhảy cóc. Phải chạy báo cáo lãi lỗ của tháng đang
-- xét trước khi gọi thủ tục này.
-- Sáu bảng tạm cùng thủ tục nạp của từng bảng ở sql/tmp/tmp_xh_step.sql; bốn
-- khung nhìn ở sql/rpt/.
-- Thứ tự chạy: ingestion, sql/dim, sql/tmp, tệp này, gọi thủ tục từng tháng,
-- rồi sql/rpt.
-- =====================================================================

SET search_path TO banking_project, public;

-- 01. BẢNG SỰ KIỆN DẠNG DỌC CỦA BẢNG XẾP HẠNG (khoá chỉ có asm_id) -----------
-- report_id (bản đầy đủ ở sql/dim/dim_report_detail.sql):
--   201 doanh số cho vay mới | 202 PSDN | 203 tỷ lệ duyệt | 204 tỷ lệ nợ xấu
--   205 đến 208 là bốn hạng của bốn chỉ số vừa nêu | 209 điểm quy mô
--   210 hạng theo điểm quy mô
--   211 chi phí trên doanh thu | 212 hạng | 213 lợi nhuận biên | 214 hạng
--   215 hệ số vốn | 216 hạng | 217 kết quả bình quân một quản lý | 218 hạng
--   219 điểm tài chính | 220 hạng theo điểm tài chính
--   221 điểm tổng | 222 hạng tổng kết
DROP TABLE IF EXISTS fct_asm_value CASCADE;
CREATE TABLE fct_asm_value (
    month_key   INT NOT NULL,
    asm_id      INT NOT NULL,          -- khoá logic nối sang dim_asm theo asm_id
    report_id   INT NOT NULL,          -- khoá logic nối sang dim_report_detail
    value       NUMERIC(24,6),         -- cột cho phép 6 chữ số; số làm tròn đến chữ số nào ghi ở bước nạp
    PRIMARY KEY (month_key, asm_id, report_id)
);
CREATE INDEX IF NOT EXISTS idx_fct_asm_value_month
    ON fct_asm_value (month_key);
CREATE INDEX IF NOT EXISTS idx_fct_asm_value_asm
    ON fct_asm_value (asm_id);

-- 02. THỦ TỤC ĐIỀU PHỐI THEO THÁNG (báo cáo lãi lỗ của tháng đó phải chạy trước)
-- Tệp này chỉ làm ba việc: xoá số cũ của tháng trên bảng sự kiện, gọi lần lượt
-- ba thủ tục bước trong sql/tmp/tmp_xh_step.sql, rồi tính ba bước cuối ghi
-- fct_asm_value.
CREATE OR REPLACE PROCEDURE sp_xephang_asm(p_month INT)
LANGUAGE plpgsql AS $$
DECLARE
    v_step TEXT;
BEGIN
    -- BƯỚC 0: xoá số của tháng trên bảng sự kiện để chạy lại không bị trùng.
    -- Ba bảng tạm do chính thủ tục bước xoá dòng của tháng đó trên bảng của nó.
    v_step := 'STEP0_DELETE_MONTH';
    INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status)
    VALUES ('sp_xephang_asm', p_month, v_step, 'START');
    DELETE FROM fct_asm_value
    WHERE month_key = p_month;

    -- Ba bước tạm (sp_xh_step1_asm_avg, sp_xh_step2_npl_area, sp_xh_step3_fin_area):
    -- sp_xh_step3_fin_area có chặn: báo cáo lãi lỗ tháng này phải đủ bảy vùng.
    v_step := 'CALL_STEP1_ASM_AVG';
    CALL sp_xh_step1_asm_avg(p_month);
    v_step := 'CALL_STEP2_NPL_AREA';
    CALL sp_xh_step2_npl_area(p_month);
    v_step := 'CALL_STEP3_FIN_AREA';
    CALL sp_xh_step3_fin_area(p_month);

    -- BƯỚC 4: xếp hạng bốn chỉ số phần một (ba chỉ số đầu lấy cao trước, tỷ lệ nợ
    -- xấu lấy thấp trước), cộng thành điểm quy mô rồi hạng theo điểm quy mô.
    -- Ghi vào bảng sự kiện, mỗi ASM mười dòng: bốn chỉ số, bốn hạng, một điểm và
    -- một hạng tổng của phần một. Bốn chỉ số đọc từ bảng bước 1 đã trải ngang, tỷ
    -- lệ nợ xấu đọc từ bảng bước 2 (report_id 204), mã vùng lấy theo asm_id trong
    -- dim_asm.
    v_step := 'STEP4_RANK_QM';
    WITH asm_vals AS ( -- trải ba dòng của mỗi ASM thành một dòng
        SELECT
            t.asm_id,
            MAX(d.area_code) AS area_code,
            MAX(value) FILTER (WHERE t.report_id = 201) AS ltn_avg,
            MAX(value) FILTER (WHERE t.report_id = 202) AS psdn_avg,
            MAX(value) FILTER (WHERE t.report_id = 203) AS approval_rate_avg
        FROM tmp_xh_step1_asm_avg AS t
        JOIN banking_project.dim_asm AS d ON d.asm_id = t.asm_id
        WHERE t.month_key = p_month
        GROUP BY t.asm_id
    ),
    rows AS (
        SELECT
            a.asm_id, a.area_code, a.ltn_avg, a.psdn_avg, a.approval_rate_avg,
            n.value AS npl
        FROM asm_vals AS a
        LEFT JOIN tmp_xh_step2_npl_area AS n
            ON n.month_key = p_month
           AND n.area_code = a.area_code
           AND n.report_id = 204
    ),
    ranked AS (
        SELECT
            r.asm_id, r.area_code, r.ltn_avg, r.psdn_avg, r.approval_rate_avg, r.npl,
            RANK() OVER (ORDER BY r.ltn_avg DESC NULLS LAST) AS r_ltn,
            RANK() OVER (ORDER BY r.psdn_avg DESC NULLS LAST) AS r_psdn,
            RANK() OVER (ORDER BY r.approval_rate_avg DESC NULLS LAST) AS r_appr,
            RANK() OVER (ORDER BY r.npl ASC NULLS LAST) AS r_npl
        FROM rows AS r
    ),
    scored AS (
        SELECT
            d.*,
            (d.r_ltn + d.r_psdn + d.r_appr + d.r_npl) AS qm,
            RANK() OVER (ORDER BY (d.r_ltn + d.r_psdn + d.r_appr + d.r_npl) ASC)
                AS r_ptkd
        FROM ranked AS d
    )
    INSERT INTO banking_project.fct_asm_value
        (month_key, asm_id, report_id, value)
    SELECT p_month, s.asm_id, v.rid, v.val
    FROM scored AS s
    CROSS JOIN LATERAL (
        VALUES
            (201, s.ltn_avg),
            (202, s.psdn_avg),
            (203, s.approval_rate_avg),
            (204, s.npl),
            (205, s.r_ltn::NUMERIC),
            (206, s.r_psdn::NUMERIC),
            (207, s.r_appr::NUMERIC),
            (208, s.r_npl::NUMERIC),
            (209, s.qm::NUMERIC),
            (210, s.r_ptkd::NUMERIC)
    ) AS v(rid, val);
    INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status)
    VALUES ('sp_xephang_asm', p_month, v_step, 'OK');

    -- BƯỚC 5: chép chín dòng tài chính của vùng sang từng ASM thuộc vùng đó.
    -- Bước này không tính lại gì: hạng đã chốt ở bước 3 của bảng tạm, ở đây chỉ
    -- nhân bản theo (area_code, report_id). Riêng mã 217 (kết quả bình quân một
    -- quản lý) làm tròn hai chữ số lúc ghi vì bảng tạm giữ nguyên phép chia.
    v_step := 'STEP5_ADD_FIN';
    WITH asm_list AS ( -- danh sách ASM của tháng này, kèm mã vùng lấy từ dim_asm
        SELECT DISTINCT t.asm_id, d.area_code
        FROM tmp_xh_step1_asm_avg AS t
        JOIN banking_project.dim_asm AS d ON d.asm_id = t.asm_id
        WHERE t.month_key = p_month
    )
    INSERT INTO banking_project.fct_asm_value
        (month_key, asm_id, report_id, value)
    SELECT p_month, x.asm_id, f.report_id,
           CASE WHEN f.report_id = 217 THEN ROUND(f.value, 2) ELSE f.value END
    FROM asm_list AS x
    JOIN banking_project.tmp_xh_step3_fin_area AS f
        ON f.month_key = p_month AND f.area_code = x.area_code
    WHERE f.report_id BETWEEN 211 AND 219;
    INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status)
    VALUES ('sp_xephang_asm', p_month, v_step, 'OK');

    -- BƯỚC 6: cộng điểm quy mô với điểm tài chính thành điểm tổng, xếp hạng tổng
    -- kết và hạng theo điểm tài chính. Hạng theo điểm quy mô đã có từ bước 4 nên
    -- không ghi lại.
    v_step := 'STEP6_TONG_FINAL';
    WITH s AS (
        SELECT
            asm_id,
            MAX(value) FILTER (WHERE report_id = 209) AS qm,
            MAX(value) FILTER (WHERE report_id = 219) AS fin
        FROM banking_project.fct_asm_value
        WHERE month_key = p_month
        GROUP BY asm_id
    ),
    r AS (
        SELECT
            s.asm_id, s.qm, s.fin,
            (s.qm + s.fin) AS tong,
            RANK() OVER (ORDER BY s.fin ASC) AS r_fin,
            RANK() OVER (ORDER BY (s.qm + s.fin) ASC) AS r_final
        FROM s
    )
    INSERT INTO banking_project.fct_asm_value (month_key, asm_id, report_id, value)
    SELECT p_month, r.asm_id, v.rid, v.val
    FROM r
    CROSS JOIN LATERAL (
        VALUES
            (220, r.r_fin::NUMERIC),
            (221, r.tong),
            (222, r.r_final::NUMERIC)
    ) AS v(rid, val);
    INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status)
    VALUES ('sp_xephang_asm', p_month, v_step, 'OK');

EXCEPTION WHEN OTHERS THEN -- ghi dòng FAIL rồi ném lỗi ra ngoài
    INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status, note)
    VALUES ('sp_xephang_asm', p_month, v_step, 'FAIL', SQLERRM);
    RAISE;
END; $$;

-- Kiểm tra nhanh: tháng Hai điểm tổng dẫn đầu là 34 và người hạng nhất là
-- email nam.hoangvan (phải chạy báo cáo lãi lỗ tháng 202302 trước).
-- CALL sp_xephang_asm(202302);
-- SELECT email, diem_qm, rank_ptkd, diem_fin, rank_fin, tong_diem, rank_final
-- FROM v_xephang_asm WHERE month_key=202302 ORDER BY rank_final LIMIT 5;
-- Kiểm tra từng bước tạm: xem sáu lệnh SELECT cuối tệp sql/tmp/tmp_xh_step.sql
-- (mỗi bước có thủ tục riêng nên gọi lẻ và đọc từng bảng tạm một được).
-- SELECT COUNT(*) FROM fct_asm_value WHERE month_key = 202302;
--     -- bằng số ASM nhân 13 dòng (mười dòng phần một cộng ba dòng tổng)
--     -- rồi cộng 9 dòng tài chính cho mỗi ASM khớp được vùng
-- SELECT asm_id, COUNT(*) FROM fct_asm_value WHERE month_key = 202302
--     GROUP BY asm_id HAVING COUNT(*) NOT IN (13, 22); -- 0 dòng: mỗi ASM chỉ có 13 hoặc 22 dòng
-- SELECT proc_name, status, step_name, note FROM log_proc_run WHERE month_key = 202302
--     ORDER BY run_id;
--     -- Riêng bảng xếp hạng, một tháng để lại mười dòng: START của bước xoá tháng
--     -- (sp_xephang_asm), START và OK của ba thủ tục bước, rồi OK của ba bước cộng
--     -- ghép cuối; không có dòng FAIL.
