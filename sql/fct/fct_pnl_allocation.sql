-- =====================================================================
-- BÁO CÁO LÃI LỖ THEO BẢY VÙNG: bảng sự kiện fct_pnl_value và thủ tục
-- điều phối sp_baocao_tonghop.
-- Số của một vùng = phần gán thẳng theo mã đơn vị (quy tắc 1) cộng phần hội
-- sở chia theo tỷ lệ hệ số (quy tắc 2). Mọi số là luỹ kế từ đầu năm, nên số
-- của tháng Hai là tổng của tháng Một và tháng Hai.
-- Bảng lưu dạng dọc: một giá trị là một dòng (month_key, area_code,
-- report_id, value); ý nghĩa từng report_id xem sql/dim/dim_report_detail.sql.
-- Bảng theo dõi tiến trình log_proc_run đặt ở đầu tệp vì thủ tục ghi từng bước.
-- Index trên các bảng stg_ và dim_param_area do chính bước ingestion tạo
-- (quy ước: chủ bảng tạo index).
-- Sáu bảng tạm cùng thủ tục nạp của từng bảng nằm ở sql/tmp/; bốn khung nhìn
-- đã tách sang sql/rpt/.
-- Thứ tự chạy: ingestion, sql/dim, sql/tmp, tệp này, gọi thủ tục từng tháng,
-- rồi sql/rpt.
-- =====================================================================

SET search_path TO banking_project, public;

-- 00. BẢNG THEO DÕI TIẾN TRÌNH: xem chạy đến đâu, hỏng ở đâu trong log_proc_run --
DROP TABLE IF EXISTS log_proc_run CASCADE;
CREATE TABLE log_proc_run (
    run_id      SERIAL PRIMARY KEY,
    proc_name   VARCHAR(100) NOT NULL,
    month_key   INT NOT NULL,
    step_name   VARCHAR(100) NOT NULL,
    status      VARCHAR(20) NOT NULL,   -- START, OK hoặc FAIL
    note        TEXT,
    created_at  TIMESTAMP DEFAULT NOW()
);

-- 02. BẢNG SỰ KIỆN DẠNG DỌC: một giá trị là một dòng (tháng, vùng, report_id) --
-- report_id (bản đầy đủ ở sql/dim/dim_report_detail.sql):
--   1 đến 5 là năm dòng thu nhập nhóm B | 11 là tổng B
--   21 đến 23 là vốn kinh doanh, 24 là tổng C
--   31 đến 33 là doanh thu và chi phí kinh doanh, 34 là tổng D
--   40 là tổng thu nhập E | 51 đến 54 là bốn dòng chi phí | 56 là tổng F
--   60 là dự phòng rủi ro G | 70 là A (kết quả sau cùng) | 80 là H | 90 là số quản lý J
--   91 đến 94 là bốn chỉ số: CIR, lợi nhuận biên, hệ số vốn, kết quả bình quân một quản lý
-- Dòng area_code='00' là phần hội sở: chưa chia cho vùng nào, chỉ có dòng lá và tổng.
DROP TABLE IF EXISTS fct_pnl_value CASCADE;
CREATE TABLE fct_pnl_value (
    month_key   INT NOT NULL,
    area_code   VARCHAR(10) NOT NULL,  -- bảy mã vùng, thêm '00' là hội sở
    area_name   VARCHAR(100),
    report_id   INT NOT NULL,          -- khoá logic nối sang dim_report_detail
    value       NUMERIC(24,6),         -- tiền 2 chữ số, tỷ lệ 6 chữ số, số đếm 0 chữ số
    PRIMARY KEY (month_key, area_code, report_id)
);
CREATE INDEX IF NOT EXISTS idx_fct_pnl_value_month
    ON fct_pnl_value (month_key);
CREATE INDEX IF NOT EXISTS idx_fct_pnl_value_report
    ON fct_pnl_value (report_id);

-- 03. THỦ TỤC ĐIỀU PHỐI THEO THÁNG (mỗi lần gọi xử lý một tháng) ------------
-- Tệp này chỉ làm ba việc: xoá số cũ của tháng trên bảng sự kiện, gọi lần lượt
-- ba thủ tục bước trong sql/tmp/tmp_pnl_step.sql, rồi cộng gộp ở hai bước cuối
-- để ghi fct_pnl_value.
CREATE OR REPLACE PROCEDURE sp_baocao_tonghop(p_month INT)
LANGUAGE plpgsql AS $$
DECLARE
    v_step TEXT;
BEGIN
    -- BƯỚC 0: xoá số của tháng trên bảng sự kiện để chạy lại không bị trùng.
    -- Sáu bảng tạm do chính thủ tục bước xoá dòng của tháng đó trên bảng của nó.
    v_step := 'STEP0_DELETE_MONTH';
    INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status)
    VALUES ('sp_baocao_tonghop', p_month, v_step, 'START');
    DELETE FROM fct_pnl_value
    WHERE month_key = p_month;

    -- Ba bước tạm (sp_pnl_step1_driver, sp_pnl_step2_ratio, sp_pnl_step3_gl_split):
    -- Đổi biến v_step trước mỗi lần gọi để lỗi ở bước nào in ra đúng tên bước đó.
    v_step := 'CALL_STEP1_DRIVER';
    CALL sp_pnl_step1_driver(p_month);
    v_step := 'CALL_STEP2_RATIO';
    CALL sp_pnl_step2_ratio(p_month);
    v_step := 'CALL_STEP3_GL_SPLIT';
    CALL sp_pnl_step3_gl_split(p_month);

    -- BƯỚC 4: ghép hai phần thành số của vùng, theo từng report_id:
    --   số ở bảng sự kiện = phần gán thẳng + phần hội sở nhân tỷ lệ.
    -- Dòng tổng 11, 24, 34 cộng trực tiếp từ các dòng lá đã chia, nên chỉ làm
    -- tròn một lần ở đây, không làm tròn rồi cộng tiếp.
    v_step := 'STEP4_COMBINE';
    -- Mỗi vùng 16 dòng lá, bảy vùng thành 112 dòng.
    INSERT INTO banking_project.fct_pnl_value
        (month_key, area_code, area_name, report_id, value)
    SELECT p_month, c.area_code, c.area_name, c.report_id,
           ROUND(COALESCE(d.value, 0) + h.value * c.value, 2)
    FROM banking_project.tmp_pnl_step2_ratio AS c
    JOIN banking_project.tmp_pnl_step3_gl_split AS h
        ON h.month_key = p_month AND h.area_code = '00' AND h.report_id = c.report_id
    LEFT JOIN banking_project.tmp_pnl_step3_gl_split AS d
        ON d.month_key = p_month AND d.area_code = c.area_code AND d.report_id = c.report_id
    WHERE c.month_key = p_month;
    -- Dòng tổng của từng nhóm: 11 là tổng B (mã 1 đến 5), 24 là tổng C (21 đến 23),
    -- 34 là tổng D (31 đến 33).
    INSERT INTO banking_project.fct_pnl_value
        (month_key, area_code, area_name, report_id, value)
    SELECT p_month, g.area_code, g.an, g.rid, ROUND(g.sdir + g.shp, 2)
    FROM (
        SELECT c.area_code, MAX(c.area_name) AS an,
               CASE WHEN c.report_id IN (1,2,3,4,5) THEN 11
                    WHEN c.report_id IN (21,22,23)  THEN 24
                    WHEN c.report_id IN (31,32,33)  THEN 34 END AS rid,
               SUM(COALESCE(d.value, 0)) AS sdir,
               SUM(h.value * c.value)    AS shp
        FROM banking_project.tmp_pnl_step2_ratio AS c
        JOIN banking_project.tmp_pnl_step3_gl_split AS h
            ON h.month_key = p_month AND h.area_code = '00' AND h.report_id = c.report_id
        LEFT JOIN banking_project.tmp_pnl_step3_gl_split AS d
            ON d.month_key = p_month AND d.area_code = c.area_code AND d.report_id = c.report_id
        WHERE c.month_key = p_month
        GROUP BY c.area_code,
                 CASE WHEN c.report_id IN (1,2,3,4,5) THEN 11
                      WHEN c.report_id IN (21,22,23)  THEN 24
                      WHEN c.report_id IN (31,32,33)  THEN 34 END
    ) AS g
    WHERE g.rid IS NOT NULL;
    -- Mã 90 (J): số quản lý của vùng, chép thẳng từ hệ số ở bước 1.
    INSERT INTO banking_project.fct_pnl_value
        (month_key, area_code, area_name, report_id, value)
    SELECT p_month, s.area_code, s.area_name, 90, s.value
    FROM banking_project.tmp_pnl_step1_driver AS s
    WHERE s.month_key = p_month AND s.report_id = 90;
    -- Phần hội sở '00': 16 dòng lá giữ nguyên số, không nhân tỷ lệ cho ai.
    INSERT INTO banking_project.fct_pnl_value
        (month_key, area_code, area_name, report_id, value)
    SELECT p_month, h.area_code, h.area_name, h.report_id, ROUND(h.value, 2)
    FROM banking_project.tmp_pnl_step3_gl_split AS h
    WHERE h.month_key = p_month AND h.area_code = '00';
    -- Phần hội sở '00': ba dòng tổng 11, 24, 34 cộng từ mười một dòng lá của nó.
    INSERT INTO banking_project.fct_pnl_value
        (month_key, area_code, area_name, report_id, value)
    SELECT p_month, '00', 'Hoi so (HEAD)',
           CASE WHEN report_id IN (1,2,3,4,5) THEN 11
                WHEN report_id IN (21,22,23)  THEN 24
                WHEN report_id IN (31,32,33)  THEN 34 END AS rid,
           ROUND(SUM(value), 2)
    FROM banking_project.tmp_pnl_step3_gl_split
    WHERE month_key = p_month AND area_code = '00'
      AND report_id IN (1,2,3,4,5,21,22,23,31,32,33)
    GROUP BY 4;
    INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status)
    VALUES ('sp_baocao_tonghop', p_month, v_step, 'OK');

    -- BƯỚC 5: cộng các dòng tổng E, F, A, H rồi tính bốn chỉ số, đọc lại chính
    -- những dòng vừa ghi. Ghi lại mã 56 (tổng F) từ bốn dòng lá ĐÃ LÀM TRÒN,
    -- giống hệt cách làm trước khi tách bước, rồi mới dùng F để tính A và chỉ số.
    v_step := 'STEP5_TONG_CHISO';
    DELETE FROM banking_project.fct_pnl_value
    WHERE month_key = p_month AND report_id = 56;
    INSERT INTO banking_project.fct_pnl_value
        (month_key, area_code, area_name, report_id, value)
    SELECT p_month, w.area_code, w.an, v.rid, v.val
    FROM (
        SELECT area_code, MAX(area_name) AS an,
               MAX(value) FILTER (WHERE report_id = 11) AS b,
               MAX(value) FILTER (WHERE report_id = 24) AS c,
               MAX(value) FILTER (WHERE report_id = 34) AS d,
               MAX(value) FILTER (WHERE report_id = 31) AS d3,
               MAX(value) FILTER (WHERE report_id = 51) AS f1,
               MAX(value) FILTER (WHERE report_id = 52) AS f2,
               MAX(value) FILTER (WHERE report_id = 53) AS f3,
               MAX(value) FILTER (WHERE report_id = 54) AS f4,
               MAX(value) FILTER (WHERE report_id = 60) AS g
        FROM banking_project.fct_pnl_value
        WHERE month_key = p_month
        GROUP BY area_code
    ) AS w
    CROSS JOIN LATERAL (
        VALUES
            (56, w.f1 + w.f2 + w.f3 + w.f4),           -- mã 56 (F): cộng bốn dòng lá đã làm tròn
            (40, w.b + w.c + w.d),                      -- mã 40 (E): B cộng C cộng D
            (80, w.b + w.d3),                           -- mã 80 (H): B cộng doanh thu kinh doanh D3
            (70, w.b + w.c + w.d + w.f1 + w.f2 + w.f3 + w.f4 + w.g)  -- mã 70 (A): E cộng F cộng G
    ) AS v(rid, val);

    -- Bốn chỉ số, đổi ra phần trăm và để dấu dương: chi phí trên doanh thu là
    -- trừ F chia E; ba chỉ số còn lại là A chia H, A chia trị tuyệt đối của C
    -- (C mang giá trị âm), A chia số quản lý J.
    INSERT INTO banking_project.fct_pnl_value
        (month_key, area_code, area_name, report_id, value)
    SELECT p_month, w.area_code, w.an, v.rid, v.val
    FROM (
        SELECT area_code, MAX(area_name) AS an,
               MAX(value) FILTER (WHERE report_id = 40) AS e,
               MAX(value) FILTER (WHERE report_id = 80) AS h,
               MAX(value) FILTER (WHERE report_id = 70) AS a,
               MAX(value) FILTER (WHERE report_id = 24) AS c,
               MAX(value) FILTER (WHERE report_id = 56) AS f,
               MAX(value) FILTER (WHERE report_id = 90) AS j
        FROM banking_project.fct_pnl_value
        WHERE month_key = p_month
        GROUP BY area_code
    ) AS w
    CROSS JOIN LATERAL (
        VALUES
            (91, CASE WHEN w.e = 0 THEN NULL
                      ELSE ROUND(-w.f / w.e * 100, 6) END),
            (92, CASE WHEN w.h = 0 THEN NULL
                      ELSE ROUND(w.a / w.h * 100, 6) END),
            (93, CASE WHEN w.c = 0 THEN NULL
                      ELSE ROUND(w.a / NULLIF(-w.c, 0) * 100, 6) END),
            (94, CASE WHEN w.j = 0 THEN NULL
                      ELSE ROUND(w.a / w.j, 2) END)
    ) AS v(rid, val);
    INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status)
    VALUES ('sp_baocao_tonghop', p_month, v_step, 'OK');

EXCEPTION WHEN OTHERS THEN -- ghi dòng FAIL rồi ném lỗi ra ngoài
    INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status, note)
    VALUES ('sp_baocao_tonghop', p_month, v_step, 'FAIL', SQLERRM);
    RAISE;
END; $$;

-- 05. CÁC PHÉP KIỂM TRA NHANH ----------------------------------------------
-- Tổng tỷ lệ mỗi nhóm hệ số phải bằng 1; tổng các thành phần phải khớp dòng tổng.
-- Kiểm tra tổng tỷ lệ theo từng report_id:
-- SELECT report_id, SUM(value) FROM tmp_pnl_step2_ratio
--     WHERE month_key = 202302 GROUP BY report_id ORDER BY report_id;
--     -- mỗi report_id có bảy dòng (bảy vùng), tổng phải bằng 1
-- Kiểm tra E bằng đúng B cộng C cộng D, hiệu số phải bằng 0:
-- SELECT SUM(b + c + d - e) FROM (
--     SELECT MAX(value) FILTER (WHERE report_id=11) AS b,
--            MAX(value) FILTER (WHERE report_id=24) AS c,
--            MAX(value) FILTER (WHERE report_id=34) AS d,
--            MAX(value) FILTER (WHERE report_id=40) AS e
--     FROM fct_pnl_value WHERE month_key=202302 AND area_code<>'00'
--     GROUP BY area_code) x;
-- SELECT COUNT(*) FROM fct_pnl_value WHERE month_key=202302; -- 223 dòng
--     -- bằng bảy vùng nhân hai mươi tám report_id, thêm hai mươi bảy dòng hội sở (không có mã 90)
-- SELECT COUNT(*) FROM fct_pnl_value WHERE month_key=202302 AND area_code='00';
--     -- 27 dòng hội sở

-- Kiểm tra từng bước tạm: xem năm lệnh SELECT cuối tệp sql/tmp/tmp_pnl_step.sql
-- (mỗi bước có thủ tục riêng nên gọi lẻ và đọc từng bảng tạm một được).
-- SELECT proc_name, status, step_name, note FROM log_proc_run WHERE month_key = 202302
--     ORDER BY run_id;
--     -- Riêng báo cáo lãi lỗ, một tháng để lại 9 dòng: START của bước xoá tháng
--     -- (sp_baocao_tonghop), START và OK của ba thủ tục bước, rồi OK của bước cộng
--     -- ghép và bước tổng chỉ số; không có dòng FAIL.

-- CALL sp_baocao_tonghop(202301); -- gọi lại từng tháng, từ 202301 đến 202305
