-- =====================================================================
-- BẢNG TẠM CHO BÁO CÁO XẾP HẠNG: ba bảng (bước 1 đến 3) và thủ tục tính từng bước.
-- Mỗi bảng lưu dạng dọc; ba thủ tục sp_xh_stepN bên dưới nạp số cho bảng của mình.
-- MỖI BẢNG CÓ MỘT CHỦ DUY NHẤT (AGENTS.md mục 4) — tệp này là chủ ba bảng tạm:
-- khai báo cấu trúc, nạp số, tạo index; thủ tục điều phối sp_xephang_asm chỉ gọi.
-- QUY ƯỚC MÃ CHỈ TIÊU: (a) dòng sẽ thành dòng bảng sự kiện thì giữ nguyên mã của
-- bảng sự kiện (201 đến 222); (b) dòng chỉ để đối chiếu thì lấy dải 231 đến 239,
-- không nằm trong cây báo cáo.
-- Thứ tự chạy: sql/dim, sql/tmp (tệp này), sql/fct, gọi thủ tục từng tháng, sql/rpt.
-- =====================================================================

SET search_path TO banking_project, public;

-- 01a. Bảng trung gian BƯỚC 1: trung bình luỹ kế từng ASM, dạng dọc theo asm_id.
-- Mỗi người ba dòng: 201 doanh số cho vay mới, 202 PSDN, 203 tỷ lệ duyệt hồ sơ.
-- Khi ghi vào bảng, ép về đúng phần thập phân của cột cũ: mã 201 và 202 giữ 2 chữ
-- số, mã 203 giữ 6 chữ số.
DROP TABLE IF EXISTS tmp_xh_step1_asm_avg CASCADE;
CREATE TABLE tmp_xh_step1_asm_avg (
    month_key   INT NOT NULL,
    asm_id      INT NOT NULL,          -- asm_id của người đó trong dim_asm
    report_id   INT NOT NULL,           -- 201, 202, 203
    value       NUMERIC(20,6),
    PRIMARY KEY (month_key, asm_id, report_id)
);
CREATE INDEX IF NOT EXISTS idx_tmp_xh_step1_asm_month
    ON tmp_xh_step1_asm_avg (month_key);

-- 01b. Bảng trung gian BƯỚC 2: nợ xấu theo vùng, dạng dọc ba mã mỗi vùng.
-- 204 là tỷ lệ nợ xấu (6 chữ số thập phân, bằng cột cũ); 231 là tử số (dư nợ nhóm
-- 3 đến 5 cộng nợ xoá phát sinh trong năm); 232 là mẫu số (tổng dư nợ cộng nợ xoá
-- trong năm). Trước đây tử số và mẫu số nằm ở hai cột riêng; chuyển sang dạng dọc
-- thì bảng vẫn gọn mà đối chiếu được thẳng với bảng sao kê hợp đồng.
-- Không lưu tên vùng: bảng tạm chỉ cần mã vùng, tên lấy từ dim_param_area.
DROP TABLE IF EXISTS tmp_xh_step2_npl_area CASCADE;
CREATE TABLE tmp_xh_step2_npl_area (
    month_key   INT NOT NULL,
    area_code   VARCHAR(10) NOT NULL,
    report_id   INT NOT NULL,                -- 204 / 231 / 232
    value       NUMERIC,                     -- tỷ lệ phần trăm (6 chữ số) hoặc đồng (4 chữ số)
    PRIMARY KEY (month_key, area_code, report_id)
);
CREATE INDEX IF NOT EXISTS idx_tmp_xh_step2_npl_month
    ON tmp_xh_step2_npl_area (month_key);

-- 01c. Bảng trung gian BƯỚC 3: chỉ tiêu tài chính cấp vùng, dạng dọc 9 mã mỗi vùng.
-- Lấy bốn chỉ tiêu từ fct_pnl_value của vùng (91 chi phí trên doanh thu, 92 lợi nhuận
-- biên, 93 hệ số vốn); riêng hiệu suất bình quân nhân sự tính A chia J giữ nguyên số
-- thập phân từ mã 70 và mã 90, KHÔNG dùng mã 94 vì mã đó đã làm tròn.
-- Bốn hạng của bảy vùng cộng lại thành điểm tài chính. Đây là nơi duy nhất sinh ra
-- hạng tài chính; bước 5 của thủ tục điều phối chỉ chép 9 dòng này cho từng người
-- bán hàng thuộc vùng, giữ nguyên mã 211 đến 219.
-- Để trống kiểu số cho value vì mã 217 phải giữ nguyên thập phân, bước 5 mới làm
-- tròn về 2 chữ số; các mã 211, 213, 215 làm tròn 6 chữ số ngay khi ghi (bằng cột
-- cũ NUMERIC(12,6)).
-- Câu đọc dạng ngang, chỉ dùng khi soi số trong DBeaver:
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
    report_id   INT NOT NULL,                -- 211 đến 219 (mã của bảng sự kiện được ghi sang)
    value       NUMERIC,
    PRIMARY KEY (month_key, area_code, report_id)
);
CREATE INDEX IF NOT EXISTS idx_tmp_xh_step3_fin_month
    ON tmp_xh_step3_fin_area (month_key);

-- =====================================================================
-- THỦ TỤC BƯỚC — mỗi thủ tục chỉ ghi bảng của chính bước đó.
-- Thủ tục điều phối sp_xephang_asm (sql/fct) gọi lần lượt ba thủ tục này, rồi
-- tính bước 4, bước 5, bước 6 để ghi fct_asm_value.
-- BƯỚC 3 CÓ CHẶN ĐIỀU KIỆN: fct_pnl_value của tháng đang xét phải có đủ 7 vùng,
-- nghĩa là sp_baocao_tonghop phải chạy tháng đó trước.
-- Mỗi thủ tục: chỉ xoá dòng của chính tháng trên chính bảng của nó, tự ghi
-- log_proc_run dưới tên mình, KHÔNG CÓ COMMIT.
-- Gọi lẻ trong DBeaver được: CALL sp_xh_step2_npl_area(202302);
-- =====================================================================

-- 02. BƯỚC 1: trung bình luỹ kế theo người bán hàng (bỏ ô trống khi tính trung bình)
CREATE OR REPLACE PROCEDURE sp_xh_step1_asm_avg(p_month INT)
LANGUAGE plpgsql AS $$
DECLARE
    v_step TEXT;
    v_ys   INT; -- tháng 1 của năm đang xét (YYYY01)
BEGIN
    v_step := 'STEP1_ASM_AVG';
    INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status)
    VALUES ('sp_xh_step1_asm_avg', p_month, v_step, 'START');
    v_ys := (p_month - (p_month % 100)) + 1; -- ví dụ 202302 thì lấy từ 202301
    DELETE FROM banking_project.tmp_xh_step1_asm_avg WHERE month_key = p_month;

    -- Lấy những người có ít nhất một tháng có số liệu kể từ đầu năm.
    -- Ghi dạng dọc, mỗi người ba dòng (201, 202, 203) theo asm_id — asm_id tra từ
    -- dim_asm qua email; ép về đúng phần thập phân của cột cũ ngay khi ghi để kết
    -- quả làm tròn không đổi.
    -- Nợ xấu và hạng chưa tính ở đây: xem bước 2 và bước 4 của thủ tục điều phối.
    WITH asm_avg AS (
        SELECT
            LOWER(TRIM(t.email)) AS email,
            AVG(t.ltn_amount) AS ltn_avg,
            AVG(t.psdn_count) AS psdn_avg,
            AVG(t.approval_rate) AS appr_avg
        FROM banking_project.stg_asm_target AS t
        WHERE t.month_key BETWEEN v_ys AND p_month
        GROUP BY 1
        HAVING COUNT(t.ltn_amount) + COUNT(t.psdn_count)
             + COUNT(t.app_approved) + COUNT(t.approval_rate) > 0
    ),
    asm_ids AS (
        SELECT a.email, d.asm_id, a.ltn_avg, a.psdn_avg, a.appr_avg
        FROM asm_avg AS a
        JOIN banking_project.dim_asm AS d
            ON d.email = a.email
    )
    INSERT INTO tmp_xh_step1_asm_avg (month_key, asm_id, report_id, value)
    SELECT p_month, m.asm_id, v.rid, v.val
    FROM asm_ids AS m
    CROSS JOIN LATERAL (
        VALUES
            (201, m.ltn_avg::NUMERIC(20,2)),        -- doanh số cho vay mới: 2 chữ số thập phân
            (202, m.psdn_avg::NUMERIC(12,2)),       -- PSDN (cột psdn_count trong nguồn): 2 chữ số thập phân
            (203, m.appr_avg::NUMERIC(12,6))        -- tỷ lệ duyệt hồ sơ: 6 chữ số thập phân
    ) AS v(rid, val);
    INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status)
    VALUES ('sp_xh_step1_asm_avg', p_month, v_step, 'OK');

EXCEPTION WHEN OTHERS THEN -- ghi log rồi ném lỗi ra ngoài
    INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status, note)
    VALUES ('sp_xh_step1_asm_avg', p_month, v_step, 'FAIL', SQLERRM);
    RAISE;
END; $$;

-- 03. BƯỚC 2: nợ xấu theo vùng
CREATE OR REPLACE PROCEDURE sp_xh_step2_npl_area(p_month INT)
LANGUAGE plpgsql AS $$
DECLARE
    v_step TEXT;
    v_ys   INT;
BEGIN
    v_step := 'STEP2_NPL_AREA';
    INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status)
    VALUES ('sp_xh_step2_npl_area', p_month, v_step, 'START');
    v_ys := (p_month - (p_month % 100)) + 1;
    DELETE FROM banking_project.tmp_xh_step2_npl_area WHERE month_key = p_month;

    -- Nợ xấu theo vùng, dạng dọc ba mã mỗi vùng (204, 231, 232).
    -- Dư nợ sau xoá nợ = outstanding; trước xoá nợ = outstanding cộng write-off
    -- phát sinh từ đầu năm.
    WITH src AS (
        SELECT
            COALESCE(p.area_code, 'UNKNOWN') AS area_code,
            SUM(CASE WHEN TRIM(COALESCE(k.max_bucket, '')) IN ('3','3.0','4','4.0','5','5.0')
                     THEN COALESCE(k.outstanding_principal, 0) ELSE 0 END)
                + SUM(CASE WHEN k.write_off_month IS NOT NULL
                            AND k.write_off_month BETWEEN v_ys AND p_month
                           THEN COALESCE(k.write_off_balance_principal, 0) ELSE 0 END) AS num,
            SUM(COALESCE(k.outstanding_principal, 0))
                + SUM(CASE WHEN k.write_off_month IS NOT NULL
                            AND k.write_off_month BETWEEN v_ys AND p_month
                           THEN COALESCE(k.write_off_balance_principal, 0) ELSE 0 END) AS den
        FROM banking_project.stg_fact_kpi_month AS k
        LEFT JOIN banking_project.dim_param_area AS p
            ON k.pos_city_norm = LOWER(TRIM(p.city_name))
        WHERE k.kpi_month = p_month
        GROUP BY 1
    )
    INSERT INTO tmp_xh_step2_npl_area
        (month_key, area_code, report_id, value)
    SELECT p_month, s.area_code, v.rid, v.val
    FROM src AS s
    CROSS JOIN LATERAL (VALUES
        (204, CASE WHEN s.den IS NULL OR s.den = 0 THEN NULL
                   ELSE ROUND((s.num / s.den) * 100, 6) END),   -- tỷ lệ nợ xấu: 6 chữ số thập phân
        (231, ROUND(s.num, 4)),                                 -- tử số: 4 chữ số thập phân
        (232, ROUND(s.den, 4))                                  -- mẫu số: 4 chữ số thập phân
    ) AS v(rid, val);
    INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status)
    VALUES ('sp_xh_step2_npl_area', p_month, v_step, 'OK');

EXCEPTION WHEN OTHERS THEN
    INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status, note)
    VALUES ('sp_xh_step2_npl_area', p_month, v_step, 'FAIL', SQLERRM);
    RAISE;
END; $$;

-- 04. BƯỚC 3: bốn chỉ tiêu tài chính và bốn hạng của bảy vùng
CREATE OR REPLACE PROCEDURE sp_xh_step3_fin_area(p_month INT)
LANGUAGE plpgsql AS $$
DECLARE
    v_step TEXT;
    v_nth  INT; -- số vùng đã có số liệu lãi lỗ, dùng để chặn trước khi ghi
BEGIN
    v_step := 'STEP3_FIN_AREA';
    INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status)
    VALUES ('sp_xh_step3_fin_area', p_month, v_step, 'START');
    DELETE FROM banking_project.tmp_xh_step3_fin_area WHERE month_key = p_month;

    -- Chặn ở đây, trước khi ghi bất kỳ dòng nào: báo cáo lãi lỗ của tháng này
    -- phải có đủ 7 vùng. Loại hội sở '00' vì hội sở không có hạng tài chính.
    SELECT COUNT(DISTINCT area_code) INTO v_nth
    FROM banking_project.fct_pnl_value
    WHERE month_key = p_month AND area_code <> '00' AND report_id = 70;
    IF v_nth < 7 THEN
        INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status, note)
        VALUES ('sp_xh_step3_fin_area', p_month, v_step, 'FAIL',
                'Thieu Tonghop thang nay: moi co ' || v_nth || '/7 vung');
        RAISE EXCEPTION 'Chua co fct_pnl_value du 7 vung cho thang % - chay sp_baocao_tonghop truoc', p_month;
    END IF;

    WITH w AS ( -- bốn chỉ tiêu và hai số liệu gốc của từng vùng
        SELECT
            area_code,
            MAX(value) FILTER (WHERE report_id = 91) AS cir,
            MAX(value) FILTER (WHERE report_id = 92) AS margin,
            MAX(value) FILTER (WHERE report_id = 93) AS hs,
            MAX(value) FILTER (WHERE report_id = 70) AS a,
            MAX(value) FILTER (WHERE report_id = 90) AS j
        FROM banking_project.fct_pnl_value
        WHERE month_key = p_month AND area_code <> '00'
        GROUP BY area_code
    ),
    fin AS ( -- xếp hạng 7 vùng: chi phí trên doanh thu lấy thấp nhất, ba chỉ tiêu còn lại lấy cao nhất
        SELECT
            w.area_code, w.cir, w.margin, w.hs,
            w.a / NULLIF(w.j, 0) AS hsbq,
            RANK() OVER (ORDER BY w.cir ASC NULLS LAST) AS r_cir,
            RANK() OVER (ORDER BY w.margin DESC NULLS LAST) AS r_margin,
            RANK() OVER (ORDER BY w.hs DESC NULLS LAST) AS r_hs,
            RANK() OVER (ORDER BY w.a / NULLIF(w.j, 0) DESC NULLS LAST) AS r_hsbq
        FROM w
    )
    INSERT INTO tmp_xh_step3_fin_area
        (month_key, area_code, report_id, value)
    SELECT p_month, f.area_code, v.rid, v.val
    FROM fin AS f
    CROSS JOIN LATERAL (VALUES
        (211, ROUND(f.cir, 6)),        -- tỷ lệ chi phí trên doanh thu (6 chữ số thập phân)
        (212, f.r_cir::NUMERIC),       -- hạng chi phí trên doanh thu (thấp tốt)
        (213, ROUND(f.margin, 6)),     -- tỷ lệ lợi nhuận biên
        (214, f.r_margin::NUMERIC),
        (215, ROUND(f.hs, 6)),         -- tỷ lệ lợi nhuận trên vốn
        (216, f.r_hs::NUMERIC),
        (217, f.hsbq),                 -- lợi nhuận chia số quản lý, giữ nguyên; bước 5 làm tròn 2 chữ số
        (218, f.r_hsbq::NUMERIC),
        (219, (f.r_cir + f.r_margin + f.r_hs + f.r_hsbq)::NUMERIC)  -- điểm tài chính
    ) AS v(rid, val);
    INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status)
    VALUES ('sp_xh_step3_fin_area', p_month, v_step, 'OK');

EXCEPTION WHEN OTHERS THEN
    INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status, note)
    VALUES ('sp_xh_step3_fin_area', p_month, v_step, 'FAIL', SQLERRM);
    RAISE;
END; $$;

-- KIỂM TRA TỪNG THỦ TỤC BƯỚC (mỗi bước một bảng riêng, đọc được ngay trong DBeaver):
-- CALL sp_xh_step1_asm_avg(202302);
-- SELECT report_id, COUNT(*) FROM tmp_xh_step1_asm_avg WHERE month_key = 202302
--     GROUP BY 1; -- 3 mã nhân số người bán hàng (tháng 202302: 222 dòng)
-- CALL sp_xh_step2_npl_area(202302);
-- SELECT report_id, COUNT(*) FROM tmp_xh_step2_npl_area WHERE month_key = 202302
--     GROUP BY 1; -- 3 mã (204 tỷ lệ, 231 tử số, 232 mẫu số) nhân 7 vùng = 21 dòng
-- SELECT area_code, MAX(value) FILTER (WHERE report_id = 231) AS tu_so,
--        MAX(value) FILTER (WHERE report_id = 232) AS mau_so,
--        MAX(value) FILTER (WHERE report_id = 204) AS npl_pct
-- FROM tmp_xh_step2_npl_area WHERE month_key = 202302
-- GROUP BY area_code ORDER BY area_code; -- 7 vùng; tử số và mẫu số đối chiếu được với sao kê
-- CALL sp_xh_step3_fin_area(202302);   -- phải chạy sp_baocao_tonghop(202302) trước
-- SELECT report_id, COUNT(*) FROM tmp_xh_step3_fin_area WHERE month_key = 202302
--     GROUP BY 1; -- 9 mã (211 đến 219) nhân 7 vùng = 63 dòng
-- SELECT area_code, MAX(value) FILTER (WHERE report_id = 211) AS cir,
--        MAX(value) FILTER (WHERE report_id = 213) AS margin,
--        MAX(value) FILTER (WHERE report_id = 215) AS hs_von,
--        MAX(value) FILTER (WHERE report_id = 217) AS hsbq,
--        MAX(value) FILTER (WHERE report_id = 212) AS r_cir,
--        MAX(value) FILTER (WHERE report_id = 214) AS r_margin,
--        MAX(value) FILTER (WHERE report_id = 216) AS r_hs,
--        MAX(value) FILTER (WHERE report_id = 218) AS r_hsbq,
--        MAX(value) FILTER (WHERE report_id = 219) AS diem_fin
-- FROM tmp_xh_step3_fin_area WHERE month_key = 202302
-- GROUP BY area_code ORDER BY diem_fin; -- 7 dòng, mỗi hạng từ 1 đến 7
