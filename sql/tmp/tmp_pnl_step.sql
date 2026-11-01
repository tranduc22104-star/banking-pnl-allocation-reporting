-- =====================================================================
-- BẢNG TẠM CHO BÁO CÁO LÃI LỖ: ba bảng (bước 1 đến 3) và thủ tục tính từng bước.
-- Mỗi bảng lưu dạng dọc: month_key, đối tượng, report_id, value.
-- MỖI BẢNG CÓ MỘT CHỦ DUY NHẤT (AGENTS.md mục 4) — tệp này là chủ ba bảng tạm:
-- khai báo cấu trúc, nạp số bằng ba thủ tục sp_pnl_stepN bên dưới, tạo index.
-- Thủ tục điều phối sp_baocao_tonghop ở sql/fct chỉ gọi lần lượt ba thủ tục này,
-- rồi cộng gộp ở bước 4 và bước 5 để ghi fct_pnl_value.
-- Tên bảng nói luôn nội dung: tmp_pnl_step{N}_{lam gi}; thủ tục trùng tên bảng.
-- Mỗi thủ tục bước: chỉ xoá dòng của chính tháng trên chính bảng của nó, tự ghi
-- log_proc_run dưới tên mình và KHÔNG CÓ COMMIT, để một lần CALL là một đơn vị
-- trọn vẹn — hỏng giữa chừng thì tháng đó còn nguyên 0 dòng, không nửa ghi nửa huỷ.
-- Thứ tự chạy: sql/dim, sql/tmp (tệp này), sql/fct, gọi thủ tục từng tháng, sql/rpt.
-- =====================================================================

SET search_path TO banking_project, public;

-- 01. BA BẢNG TRUNG GIAN — dạng dọc, report_id là phần lãi lỗ tương ứng
-- 01a. Bước 1: hệ số dẫn xuất để phân bổ, 9 mã cho mỗi vùng.
-- Gom ba nhóm hệ số vào một bảng vì chúng cùng đơn vị (vùng theo tháng) và bước 2
-- đọc lại toàn bộ:
--   nhóm 1 cấp cho 1 (B2) và 4 (B4) | nhóm 2 cấp cho 2 (B1) | dư nợ nhóm 2 đến 5
--   sau xoá nợ cấp cho 5 (B5) | trước xoá nợ cấp cho 60 (G) | tổng dư nợ sau xoá nợ
--   cấp cho 24 (C và D dùng chung) | số hợp đồng PSDN cấp cho 3 (B3) | số quản lý
--   cấp cho 56 (F) và 90 (J)
-- Phần thập phân: 6 hệ số KPI làm tròn 4 chữ số, đúng như cột hệ số cũ kiểu
-- NUMERIC(20,4); số hợp đồng PSDN và số quản lý giữ nguyên số như cột cũ.
DROP TABLE IF EXISTS tmp_pnl_step1_driver CASCADE;
CREATE TABLE tmp_pnl_step1_driver (
    month_key   INT NOT NULL,
    area_code   VARCHAR(10) NOT NULL,
    report_id   INT NOT NULL,           -- 1, 2, 3, 4, 5, 24, 56, 60, 90
    value       NUMERIC,
    PRIMARY KEY (month_key, area_code, report_id)
);
CREATE INDEX IF NOT EXISTS idx_tmp_pnl_step1_driver_month
    ON tmp_pnl_step1_driver (month_key);

-- 01b. Bước 2: tỷ lệ phân bổ theo vùng — ghi một dòng cho mỗi mã được chia phần.
-- Một hệ số dùng chung cho nhiều mã thì ghi đủ từng mã: tỷ lệ nhóm 1 cho 1 và 4;
-- tỷ lệ dư nợ kinh doanh và tổng dư nợ cho 21, 22, 23 (C) và 31, 32, 33 (D);
-- tỷ lệ số quản lý cho 51 đến 54 (F).
-- Kiểu NUMERIC(12,8) giống cột tỷ lệ cũ: giữ 8 chữ số thập phân.
DROP TABLE IF EXISTS tmp_pnl_step2_ratio CASCADE;
CREATE TABLE tmp_pnl_step2_ratio (
    month_key   INT NOT NULL,
    area_code   VARCHAR(10) NOT NULL,
    report_id   INT NOT NULL,           -- 16 mã: 1, 4, 2, 5, 3, 21 đến 23, 31 đến 33, 51 đến 54, 60
    value       NUMERIC(12,8),
    PRIMARY KEY (month_key, area_code, report_id)
);
CREATE INDEX IF NOT EXISTS idx_tmp_pnl_step2_ratio_month
    ON tmp_pnl_step2_ratio (month_key);

-- 01c. Bước 3: tách số ghi sổ thành phần HỘI SỞ (area_code 'A') và phần GÁN THẲNG
-- theo vùng theo quy tắc 1.
-- Phần hội sở có 16 mã: 1 đến 5, 21 đến 23, 31 đến 33, 51 đến 54, 60.
-- Phần gán thẳng có 13 mã mỗi vùng (không có nhóm C).
DROP TABLE IF EXISTS tmp_pnl_step3_gl_split CASCADE;
CREATE TABLE tmp_pnl_step3_gl_split (
    month_key   INT NOT NULL,
    area_code   VARCHAR(10) NOT NULL,   -- 'A' = hội sở, 'B'..'H' = 7 vùng kinh doanh
    report_id   INT NOT NULL,
    value       NUMERIC(20,4),
    PRIMARY KEY (month_key, area_code, report_id)
);
CREATE INDEX IF NOT EXISTS idx_tmp_pnl_step3_gl_split_month
    ON tmp_pnl_step3_gl_split (month_key);

-- =====================================================================
-- THỦ TỤC BƯỚC — mỗi thủ tục chỉ ghi bảng của chính bước đó.
-- Gọi lẻ trong DBeaver được: CALL sp_pnl_step2_ratio(202302);
-- bảng của bước khác giữ nguyên nên bước sau vẫn đọc được kết quả bước trước.
-- =====================================================================

-- 02. BƯỚC 1: hệ số dẫn xuất theo vùng
CREATE OR REPLACE PROCEDURE sp_pnl_step1_driver(p_month INT)
LANGUAGE plpgsql AS $$
DECLARE
    v_step TEXT;
    v_ys   INT; -- tháng đầu năm đang xét (dạng YYYY01): mọi số lấy luỹ kế từ đầu năm
BEGIN
    v_step := 'STEP1_DRIVER';
    INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status)
    VALUES ('sp_pnl_step1_driver', p_month, v_step, 'START');
    v_ys := (p_month - (p_month % 100)) + 1; -- ví dụ 202302 thì lấy từ 202301
    DELETE FROM banking_project.tmp_pnl_step1_driver WHERE month_key = p_month;

    -- Hệ số là trung bình các tháng từ đầu năm đến tháng đang xét; tháng Hai là
    -- trung bình của tháng Một và tháng Hai.
    -- Dư nợ sau xoá nợ = outstanding; trước xoá nợ = outstanding cộng write-off
    -- phát sinh trong năm.
    -- PSDN = số hợp đồng có psdn = 1 trong sao kê, không phải số email ASM.
    -- SM = số quản lý thực tế theo vùng và tháng, khác số ASM trong dim_asm.
    -- Ghi 9 dòng cho mỗi vùng: 1 và 4 (nhóm 1) | 2 (nhóm 2) | 5 (nhóm 2 đến 5 sau
    -- xoá nợ) | 24 (tổng sau xoá nợ) | 60 (trước xoá nợ) | 3 (PSDN) | 56 và 90 (SM).
    -- 6 hệ số KPI làm tròn 4 chữ số đúng bằng cột hệ số cũ kiểu NUMERIC(20,4);
    -- PSDN giữ nguyên số như cột nguồn, tỷ lệ phần trăm tính ở bước 2.
    WITH kpi_norm AS ( -- chuẩn hoá: gắn vùng cho từng hợp đồng, vẫn một dòng một hợp đồng
        SELECT
            k.kpi_month            AS m,
            COALESCE(p.area_code, 'UNKNOWN') AS area_code,
            COALESCE(k.outstanding_principal, 0) AS os,
            COALESCE(k.write_off_balance_principal, 0) AS wo,
            COALESCE(k.psdn, 0) AS psdn,
            TRIM(COALESCE(k.max_bucket, '')) AS bk
        FROM banking_project.stg_fact_kpi_month AS k
        LEFT JOIN banking_project.dim_param_area AS p
            ON k.pos_city_norm = LOWER(TRIM(p.city_name))
        WHERE k.kpi_month BETWEEN v_ys AND p_month
    ),
    kpi_monthly AS ( -- cộng dư nợ và đếm hợp đồng theo từng vùng từng tháng
        SELECT
            n.m                    AS m,
            n.area_code            AS area_code,
            SUM(CASE WHEN n.bk IN ('1', '1.0', '') THEN n.os ELSE 0 END) AS d1,
            SUM(CASE WHEN n.bk IN ('2', '2.0') THEN n.os ELSE 0 END) AS d2,
            SUM(CASE WHEN n.bk IN ('2','2.0','3','3.0','4','4.0','5','5.0')
                THEN n.os ELSE 0 END) AS d25_sau,
            SUM(CASE WHEN n.bk IN ('2','2.0','3','3.0','4','4.0','5','5.0')
                THEN n.os + n.wo ELSE 0 END) AS dtruoc,
            SUM(n.os) AS dtot,
            COUNT(*) FILTER (WHERE n.psdn = 1) AS psdn
        FROM kpi_norm AS n
        WHERE n.area_code <> 'UNKNOWN'
        GROUP BY 1, 2
    ),
    kpi_agg AS ( -- bình quân các tháng từ đầu năm đến tháng đang xét, theo vùng
        SELECT
            area_code,
            AVG(d1) AS d1, AVG(d2) AS d2, AVG(d25_sau) AS d25_sau,
            AVG(dtruoc) AS dtruoc, AVG(dtot) AS dtot, AVG(psdn) AS psdn
        FROM kpi_monthly
        GROUP BY area_code
    ),
    sm_snap AS ( -- số quản lý thực tế của tháng đang xét, mỗi vùng một dòng
        SELECT area_code, MAX(sm_count) AS sm
        FROM banking_project.dim_sm_headcount
        WHERE month_key = p_month
        GROUP BY area_code
    )
    INSERT INTO tmp_pnl_step1_driver (month_key, area_code, report_id, value)
    SELECT p_month, k.area_code, v.rid, v.val
    FROM kpi_agg AS k
    LEFT JOIN sm_snap AS s ON s.area_code = k.area_code
    CROSS JOIN LATERAL (
        VALUES
            (1,  ROUND(k.d1, 4)),        -- mã 1 (B2): dư nợ nhóm 1
            (4,  ROUND(k.d1, 4)),        -- mã 4 (B4): cùng hệ số nhóm 1
            (2,  ROUND(k.d2, 4)),        -- mã 2 (B1): dư nợ nhóm 2
            (5,  ROUND(k.d25_sau, 4)),   -- mã 5 (B5): dư nợ nhóm 2 đến 5 sau xoá nợ
            (24, ROUND(k.dtot, 4)),      -- mã 24 (C): tổng dư nợ sau xoá nợ, dùng chung cho C và D
            (60, ROUND(k.dtruoc, 4)),    -- mã 60 (G): dư nợ trước xoá nợ
            (3,  COALESCE(k.psdn, 0)),   -- mã 3 (B3): số hợp đồng PSDN, để thô, không làm tròn
            (56, COALESCE(s.sm, 0)),     -- mã 56 (F): số quản lý
            (90, COALESCE(s.sm, 0))      -- mã 90 (J): số quản lý
    ) AS v(rid, val);
    INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status)
    VALUES ('sp_pnl_step1_driver', p_month, v_step, 'OK');

EXCEPTION WHEN OTHERS THEN -- ghi log rồi ném lỗi ra ngoài
    INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status, note)
    VALUES ('sp_pnl_step1_driver', p_month, v_step, 'FAIL', SQLERRM);
    RAISE;
END; $$;

-- 03. BƯỚC 2: tỷ lệ phân bổ
CREATE OR REPLACE PROCEDURE sp_pnl_step2_ratio(p_month INT)
LANGUAGE plpgsql AS $$
DECLARE
    v_step TEXT;
BEGIN
    v_step := 'STEP2_RATIO';
    INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status)
    VALUES ('sp_pnl_step2_ratio', p_month, v_step, 'START');
    DELETE FROM banking_project.tmp_pnl_step2_ratio WHERE month_key = p_month;

    -- Tỷ lệ từng vùng = hệ số của vùng chia tổng hệ số bảy vùng, đọc từ bảng bước 1.
    -- Vùng được chia mã nào thì ghi đúng mã đó: nhóm 1 cho 1 và 4; tổng dư nợ và
    -- dư nợ kinh doanh cho 21 đến 23 và 31 đến 33; số quản lý cho 51 đến 54.
    WITH d1p AS ( -- trải các dòng hệ số của mỗi vùng thành một dòng
        SELECT
            area_code,
            MAX(value) FILTER (WHERE report_id = 1)  AS d1,
            MAX(value) FILTER (WHERE report_id = 2)  AS d2,
            MAX(value) FILTER (WHERE report_id = 5)  AS d25,
            MAX(value) FILTER (WHERE report_id = 60) AS dtruoc,
            MAX(value) FILTER (WHERE report_id = 24) AS dtot,
            MAX(value) FILTER (WHERE report_id = 3)  AS dpsdn,
            MAX(value) FILTER (WHERE report_id = 56) AS dsm
        FROM tmp_pnl_step1_driver
        WHERE month_key = p_month
        GROUP BY area_code
    ),
    tot AS ( -- tổng hệ số bảy vùng, dùng làm mẫu số
        SELECT SUM(d1) AS t1, SUM(d2) AS t2, SUM(d25) AS t25,
               SUM(dtruoc) AS tt, SUM(dtot) AS ttot,
               SUM(dpsdn) AS tpsdn, SUM(dsm) AS tsm
        FROM d1p
    )
    INSERT INTO tmp_pnl_step2_ratio (month_key, area_code, report_id, value)
    SELECT p_month, s.area_code, v.rid, v.val
    FROM d1p AS s
    CROSS JOIN tot AS t
    CROSS JOIN LATERAL (
        VALUES
            (1,  CASE WHEN t.t1 = 0 THEN 0 ELSE s.d1 / t.t1 END),      -- mã 1 (B2): theo dư nợ nhóm 1
            (4,  CASE WHEN t.t1 = 0 THEN 0 ELSE s.d1 / t.t1 END),      -- mã 4 (B4): cùng hệ số với mã 1
            (2,  CASE WHEN t.t2 = 0 THEN 0 ELSE s.d2 / t.t2 END),      -- mã 2 (B1): theo dư nợ nhóm 2
            (5,  CASE WHEN t.t25 = 0 THEN 0 ELSE s.d25 / t.t25 END),   -- mã 5 (B5): theo nhóm 2 đến 5 sau xoá nợ
            (3,  CASE WHEN t.tpsdn = 0 THEN 0
                      ELSE COALESCE(s.dpsdn, 0) / t.tpsdn END),        -- mã 3 (B3): theo số hợp đồng PSDN
            (21, CASE WHEN t.ttot = 0 THEN 0 ELSE s.dtot / t.ttot END),-- mã 21 (C3): theo tổng dư nợ
            (22, CASE WHEN t.ttot = 0 THEN 0 ELSE s.dtot / t.ttot END),-- mã 22 (C2): theo tổng dư nợ
            (23, CASE WHEN t.ttot = 0 THEN 0 ELSE s.dtot / t.ttot END),-- mã 23 (C1): theo tổng dư nợ
            (31, CASE WHEN t.ttot = 0 THEN 0 ELSE s.dtot / t.ttot END),-- mã 31 (D3): theo tổng dư nợ
            (32, CASE WHEN t.ttot = 0 THEN 0 ELSE s.dtot / t.ttot END),-- mã 32 (D1): theo tổng dư nợ
            (33, CASE WHEN t.ttot = 0 THEN 0 ELSE s.dtot / t.ttot END),-- mã 33 (D2): theo tổng dư nợ
            (51, CASE WHEN t.tsm = 0 THEN 0
                      ELSE COALESCE(s.dsm, 0) / t.tsm END),            -- mã 51 (F1): theo số quản lý
            (52, CASE WHEN t.tsm = 0 THEN 0
                      ELSE COALESCE(s.dsm, 0) / t.tsm END),            -- mã 52 (F2): theo số quản lý
            (53, CASE WHEN t.tsm = 0 THEN 0
                      ELSE COALESCE(s.dsm, 0) / t.tsm END),            -- mã 53 (F3): theo số quản lý
            (54, CASE WHEN t.tsm = 0 THEN 0
                      ELSE COALESCE(s.dsm, 0) / t.tsm END),            -- mã 54 (F4): theo số quản lý
            (60, CASE WHEN t.tt = 0 THEN 0
                      ELSE s.dtruoc / t.tt END)                        -- mã 60 (G): theo dư nợ trước xoá nợ
    ) AS v(rid, val);
    INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status)
    VALUES ('sp_pnl_step2_ratio', p_month, v_step, 'OK');

EXCEPTION WHEN OTHERS THEN
    INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status, note)
    VALUES ('sp_pnl_step2_ratio', p_month, v_step, 'FAIL', SQLERRM);
    RAISE;
END; $$;

-- 04. BƯỚC 3: tách số ghi sổ thành hội sở và gán thẳng theo vùng
CREATE OR REPLACE PROCEDURE sp_pnl_step3_gl_split(p_month INT)
LANGUAGE plpgsql AS $$
DECLARE
    v_step TEXT;
    v_ys   INT;
BEGIN
    v_step := 'STEP3_GL_SPLIT';
    INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status)
    VALUES ('sp_pnl_step3_gl_split', p_month, v_step, 'START');
    v_ys := (p_month - (p_month % 100)) + 1;
    DELETE FROM banking_project.tmp_pnl_step3_gl_split WHERE month_key = p_month;

    -- Tách bảng ghi sổ thành hai phần: HỘI SỞ (bút toán có mã tỉnh prov = '00',
    -- ghi vào vùng 'A') và GÁN THẲNG theo vùng 'B'..'H' (quy tắc 1, nối qua
    -- dim_param_area). Dấu của số tiền giữ nguyên như nguồn: chi phí âm, vốn dương.
    WITH gl AS (
        SELECT
            g.txn_month AS m,
            TRIM(g.account_code) AS acc,
            COALESCE(NULLIF(TRIM(g.prov), ''), '00') AS prov, -- tỉnh trống coi là hội sở
            COALESCE(g.amount, 0) AS amt
        FROM banking_project.stg_fact_txn_month AS g
        WHERE g.txn_month BETWEEN v_ys AND p_month -- số ghi sổ lấy luỹ kế từ đầu năm
    ),
    head AS ( -- một dòng tổng hợp phần hội sở, để bước sau nhân tỷ lệ
        SELECT
            SUM(CASE WHEN h.acc IN ('702000030002','702000030001','702000030102')
                THEN h.amt ELSE 0 END) AS h_b2,
            SUM(CASE WHEN h.acc IN ('702000030012','702000030112')
                THEN h.amt ELSE 0 END) AS h_b1,
            SUM(CASE WHEN h.acc IN ('716000000001')
                THEN h.amt ELSE 0 END) AS h_b3,
            SUM(CASE WHEN h.acc IN ('719000030002')
                THEN h.amt ELSE 0 END) AS h_b4,
            SUM(CASE WHEN h.acc IN ('719000030003','719000030103','790000030003',
                    '790000030103','790000030004','790000030104')
                THEN h.amt ELSE 0 END) AS h_b5,
            SUM(CASE WHEN h.acc IN ('801000000001','802000000001')
                THEN h.amt ELSE 0 END) AS h_c3,
            SUM(CASE WHEN h.acc IN ('802000000002','802000000003','802014000001','802037000001')
                THEN h.amt ELSE 0 END) AS h_c2,
            SUM(CASE WHEN h.acc IN ('803000000001')
                THEN h.amt ELSE 0 END) AS h_c1,
            SUM(CASE WHEN h.acc IN ('702000010001','702000010002','704000000001',
                    '705000000001','709000000001','714000000002','714000000003',
                    '714037000001','714000000004','714014000001','715000000001',
                    '715037000001','719000000001','709000000101','719000000101')
                THEN h.amt ELSE 0 END) AS h_d3,
            SUM(CASE WHEN h.acc IN ('816000000001','816000000002','816000000003')
                THEN h.amt ELSE 0 END) AS h_d1,
            SUM(CASE WHEN h.acc IN ('809000000002','809000000001','811000000001',
                    '811000000102','811000000002','811014000001','811037000001',
                    '811039000001','811041000001','815000000001','819000000002',
                    '819000000003','819000000001','790000000003',
                    '790000000101','790037000001','849000000001','899000000003',
                    '899000000002','811000000101','819000060001')
                THEN h.amt ELSE 0 END) AS h_d2,
            SUM(CASE WHEN h.acc IN ('790000050001','882200050001','790000030001',
                    '882200030001','790000000001','790000020101','882200000001',
                    '882200050101','882200020101','882200060001','790000050101',
                    '882200030101')
                THEN h.amt ELSE 0 END) AS h_g,
            SUM(CASE WHEN h.acc IN ('831000000001','831000000002','832000000101',
                    '832000000001','831000000102')
                THEN h.amt ELSE 0 END) AS h_f1,
            SUM(CASE WHEN h.acc LIKE '85%' THEN h.amt ELSE 0 END) AS h_f2,
            SUM(CASE WHEN h.acc LIKE '86%' THEN h.amt ELSE 0 END) AS h_f3,
            SUM(CASE WHEN h.acc LIKE '87%' THEN h.amt ELSE 0 END) AS h_f4
        FROM gl AS h
        WHERE h.prov = '00'
    ),
    direct AS ( -- quy tắc 1: cộng thẳng vào vùng theo mã tỉnh
        SELECT
            p.area_code AS area_code,
            SUM(CASE WHEN g.acc IN ('702000030002','702000030001','702000030102')
                THEN g.amt ELSE 0 END) AS d_b2,
            SUM(CASE WHEN g.acc IN ('702000030012','702000030112')
                THEN g.amt ELSE 0 END) AS d_b1,
            SUM(CASE WHEN g.acc IN ('716000000001')
                THEN g.amt ELSE 0 END) AS d_b3,
            SUM(CASE WHEN g.acc IN ('719000030002')
                THEN g.amt ELSE 0 END) AS d_b4,
            SUM(CASE WHEN g.acc IN ('719000030003','719000030103','790000030003',
                    '790000030103','790000030004','790000030104')
                THEN g.amt ELSE 0 END) AS d_b5,
            SUM(CASE WHEN g.acc IN ('702000010001','702000010002','704000000001',
                    '705000000001','709000000001','714000000002','714000000003',
                    '714037000001','714000000004','714014000001','715000000001',
                    '715037000001','719000000001','709000000101','719000000101')
                THEN g.amt ELSE 0 END) AS d_d3,
            SUM(CASE WHEN g.acc IN ('816000000001','816000000002','816000000003')
                THEN g.amt ELSE 0 END) AS d_d1,
            SUM(CASE WHEN g.acc IN ('809000000002','809000000001','811000000001',
                    '811000000102','811000000002','811014000001','811037000001',
                    '811039000001','811041000001','815000000001','819000000002',
                    '819000000003','819000000001','790000000003',
                    '790000000101','790037000001','849000000001','899000000003',
                    '899000000002','811000000101','819000060001')
                THEN g.amt ELSE 0 END) AS d_d2,
            SUM(CASE WHEN g.acc IN ('790000050001','882200050001','790000030001',
                    '882200030001','790000000001','790000020101','882200000001',
                    '882200050101','882200020101','882200060001','790000050101',
                    '882200030101')
                THEN g.amt ELSE 0 END) AS d_g,
            SUM(CASE WHEN g.acc IN ('831000000001','831000000002','832000000101',
                    '832000000001','831000000102')
                THEN g.amt ELSE 0 END) AS d_f1,
            SUM(CASE WHEN g.acc LIKE '85%' THEN g.amt ELSE 0 END) AS d_f2,
            SUM(CASE WHEN g.acc LIKE '86%' THEN g.amt ELSE 0 END) AS d_f3,
            SUM(CASE WHEN g.acc LIKE '87%' THEN g.amt ELSE 0 END) AS d_f4
        FROM gl AS g
        JOIN banking_project.dim_param_area AS p
            ON p.city_code = g.prov
        WHERE g.prov <> '00'
        GROUP BY p.area_code
    )
    -- Ghi dạng dọc: hội sở 16 mã ('A') cộng gán thẳng 13 mã mỗi vùng ('B'..'H').
    INSERT INTO tmp_pnl_step3_gl_split (month_key, area_code, report_id, value)
    SELECT p_month, 'A', v.rid, v.val
    FROM head AS h
    CROSS JOIN LATERAL (
        VALUES
            (1,  h.h_b2), (2,  h.h_b1), (3,  h.h_b3), (4,  h.h_b4), (5,  h.h_b5),
            (21, h.h_c3), (22, h.h_c2), (23, h.h_c1),
            (31, h.h_d3), (32, h.h_d1), (33, h.h_d2),
            (51, h.h_f1), (52, h.h_f2), (53, h.h_f3), (54, h.h_f4),
            (60, h.h_g)
    ) AS v(rid, val)
    UNION ALL
    SELECT p_month, d.area_code, v.rid, v.val
    FROM direct AS d
    CROSS JOIN LATERAL (
        VALUES
            (1,  d.d_b2), (2,  d.d_b1), (3,  d.d_b3), (4,  d.d_b4), (5,  d.d_b5),
            (31, d.d_d3), (32, d.d_d1), (33, d.d_d2),
            (51, d.d_f1), (52, d.d_f2), (53, d.d_f3), (54, d.d_f4),
            (60, d.d_g)
    ) AS v(rid, val);
    INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status)
    VALUES ('sp_pnl_step3_gl_split', p_month, v_step, 'OK');

EXCEPTION WHEN OTHERS THEN
    INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status, note)
    VALUES ('sp_pnl_step3_gl_split', p_month, v_step, 'FAIL', SQLERRM);
    RAISE;
END; $$;

-- KIỂM TRA TỪNG THỦ TỤC BƯỚC (gọi lẻ được, bảng của bước khác giữ nguyên):
-- CALL sp_pnl_step1_driver(202302);
-- SELECT report_id, COUNT(*) FROM tmp_pnl_step1_driver
--     WHERE month_key = 202302 GROUP BY 1; -- 9 mã nhân 7 vùng = 63 dòng
-- CALL sp_pnl_step2_ratio(202302);
-- SELECT report_id, SUM(value) FROM tmp_pnl_step2_ratio
--     WHERE month_key = 202302 GROUP BY 1 ORDER BY 1; -- mỗi mã tổng tỷ lệ = 1
-- CALL sp_pnl_step3_gl_split(202302);
-- SELECT area_code, COUNT(*) FROM tmp_pnl_step3_gl_split
--     WHERE month_key = 202302 GROUP BY 1; -- 'A' có 16 mã, mỗi vùng 'B'..'H' có 13 mã
