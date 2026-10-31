-- =====================================================================
-- BAO CAO TONG HOP P&L theo 7 vung: bang su kien fct_pnl_value + thu tuc sp_baocao_tonghop.
-- Tong = Rule1 (DVML.xx gan thang ve vung) + Rule2 (HEAD x % driver).
-- Moi so luy ke tu dau nam (YTD); mau T2 = Jan+Feb cong don.
-- Cau truc TALL: moi gia tri = 1 dong (month_key, area_code, report_id, value);
-- y nghia report_id xem sql/dim/dim_report_detail.sql.
-- Log tien trinh (log_proc_run) dat o dau file vi thu tuc can ghi tung buoc.
-- Index tren stg_fact_kpi_month / stg_fact_txn_month / stg_asm_target /
-- dim_param_area do chinh buoc ingestion tao (quy che: chu bang tao index).
-- 6 bang tam da tach sang sql/tmp/; 4 view da tach sang sql/rpt/.
-- Thu tu chay: ingestion -> sql/dim -> sql/tmp -> file nay -> CALL tung thang -> sql/rpt.
-- =====================================================================

SET search_path TO banking_project, public;

-- 00. LOG tien trinh (xem ket qua/khi loi o log_proc_run) ------------------
DROP TABLE IF EXISTS log_proc_run CASCADE;
CREATE TABLE log_proc_run (
    run_id      SERIAL PRIMARY KEY,
    proc_name   VARCHAR(100) NOT NULL,
    month_key   INT NOT NULL,
    step_name   VARCHAR(100) NOT NULL,
    status      VARCHAR(20) NOT NULL,   -- START/OK/FAIL
    note        TEXT,
    created_at  TIMESTAMP DEFAULT NOW()
);

-- 02. BANG FACT TALL: moi gia tri = 1 dong (month, vung, report_id) ----------
-- report_id (xem sql/dim/dim_report_detail.sql):
--   1..5 = B2..B5 | 11 = B | 21..23 = C3..C1 | 24 = C
--   31..33 = D3/D1/D2 | 34 = D | 40 = E | 51..54 = F1..F4 | 56 = F
--   60 = G | 70 = A (LNTT) | 80 = H | 90 = J (SM)
--   91..94 = CIR / Margin / HS von / NSBQ
-- Dong area_code='00' = pool HEAD (hoi so, chua phan bo, chi co la + tong).
DROP TABLE IF EXISTS fct_pnl_value CASCADE;
CREATE TABLE fct_pnl_value (
    month_key   INT NOT NULL,
    area_code   VARCHAR(10) NOT NULL,  -- A..G + '00' (pool HEAD)
    area_name   VARCHAR(100),
    report_id   INT NOT NULL,          -- FK logic -> dim_report_detail
    value       NUMERIC(24,6),         -- VND 2 so le / % 6 so le / so le 0
    PRIMARY KEY (month_key, area_code, report_id)
);
CREATE INDEX IF NOT EXISTS idx_fct_pnl_value_month
    ON fct_pnl_value (month_key);
CREATE INDEX IF NOT EXISTS idx_fct_pnl_value_report
    ON fct_pnl_value (report_id);

-- 03. PROCEDURE backdate theo thang (chay 1 thang 1 lan) --------------------
CREATE OR REPLACE PROCEDURE sp_baocao_tonghop(p_month INT)
LANGUAGE plpgsql AS $$
DECLARE
    v_step TEXT;
    v_ys   INT; -- thang 1 dau nam (YYYY01): moi so luy ke YTD
BEGIN
    -- STEP0: xoa thang cu truoc de chay lai khong trung
    v_step := 'STEP0_DELETE_MONTH';
    INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status)
    VALUES ('sp_baocao_tonghop', p_month, v_step, 'START');
    DELETE FROM tmp_pnl_step1_driver
    WHERE month_key = p_month;
    DELETE FROM tmp_pnl_step2_ratio
    WHERE month_key = p_month;
    DELETE FROM tmp_pnl_step3_gl_split
    WHERE month_key = p_month;
    DELETE FROM fct_pnl_value
    WHERE month_key = p_month;
    v_ys := (p_month - (p_month % 100)) + 1; -- vd 202302 -> 202301

    -- STEP1: driver phan bo theo vung (AVG cac thang YTD, mau T2 = AVG Jan+Feb).
    -- sau WO = outstanding; truoc WO = outstanding + write-off (chi tu dau nam).
    -- PSDN = dem hop dong co psdn=1 trong sao ke (KHONG phai so ASM).
    -- SM = headcount that theo vung-thang (khac COUNT email ASM).
    -- Ghi TALL 9 dong/vung: 1,4 (nhom 1) | 2 (nhom 2) | 5 (nhom 2-5 sau WO)
    --   | 24 (tong sau WO) | 60 (truoc WO) | 3 (psdn) | 56 va 90 (sm).
    -- 6 driver KPI ROUND(4) = dung do le cot driver cu NUMERIC(20,4);
    -- psdn giu NGUYEN AVG tho nhu cot psdn_avg cu (le % tinh o STEP2).
    v_step := 'STEP1_DRIVER';
    WITH kpi_norm AS ( -- giu grain hop dong
        SELECT
            k.kpi_month            AS m,
            COALESCE(p.area_code, 'UNKNOWN') AS area_code,
            COALESCE(p.area_name, 'Chua phan vung') AS area_name,
            COALESCE(k.outstanding_principal, 0) AS os,
            COALESCE(k.write_off_balance_principal, 0) AS wo,
            COALESCE(k.psdn, 0) AS psdn,
            TRIM(COALESCE(k.max_bucket, '')) AS bk
        FROM banking_project.stg_fact_kpi_month AS k
        LEFT JOIN banking_project.dim_param_area AS p
            ON k.pos_city_norm = LOWER(TRIM(p.city_name))
        WHERE k.kpi_month BETWEEN v_ys AND p_month
    ),
    kpi_monthly AS ( -- driver theo vung-thang
        SELECT
            n.m                    AS m,
            n.area_code            AS area_code,
            MAX(n.area_name)       AS area_name,
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
    kpi_agg AS ( -- binh quan cac thang YTD theo vung
        SELECT
            area_code,
            MAX(area_name) AS area_name,
            AVG(d1) AS d1, AVG(d2) AS d2, AVG(d25_sau) AS d25_sau,
            AVG(dtruoc) AS dtruoc, AVG(dtot) AS dtot, AVG(psdn) AS psdn
        FROM kpi_monthly
        GROUP BY area_code
    ),
    sm_snap AS ( -- headcount SM thang xet, 1 dong/vung
        SELECT area_code, MAX(sm_count) AS sm
        FROM banking_project.dim_sm_headcount
        WHERE month_key = p_month
        GROUP BY area_code
    )
    INSERT INTO tmp_pnl_step1_driver (month_key, area_code, area_name, report_id, value)
    SELECT p_month, k.area_code, k.area_name, v.rid, v.val
    FROM kpi_agg AS k
    LEFT JOIN sm_snap AS s ON s.area_code = k.area_code
    CROSS JOIN LATERAL (
        VALUES
            (1,  ROUND(k.d1, 4)),        -- B2 (Lai trong han) — driver nhom 1
            (4,  ROUND(k.d1, 4)),        -- B4 (Phi tang HMD) cung driver nhom 1
            (2,  ROUND(k.d2, 4)),        -- B1 (Lai qua han) — driver nhom 2
            (5,  ROUND(k.d25_sau, 4)),   -- B5 (Phi cham tra) — driver nhom 2-5 sau WO
            (24, ROUND(k.dtot, 4)),      -- C/D (von dung chung) — driver tong sau WO
            (60, ROUND(k.dtruoc, 4)),    -- G (Du phong) — driver truoc WO
            (3,  COALESCE(k.psdn, 0)),   -- B3: driver PSDN (AVG tho, khong ROUND)
            (56, COALESCE(s.sm, 0)),     -- F: driver SM headcount
            (90, COALESCE(s.sm, 0))      -- J: so luong SM
    ) AS v(rid, val);
    INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status)
    VALUES ('sp_baocao_tonghop', p_month, v_step, 'OK');

    -- STEP2: % phan bo — doc driver STEP1, ghi theo id phan duoc phan bo.
    -- Driver dung chung thi ghep day du id: nhom1 -> 1 + 4; tong/dnck -> 21..23
    -- + 31..33; sm -> 51..54. Value NUMERIC(12,8) giong cot pct cu.
    v_step := 'STEP2_RATIO';
    WITH d1p AS ( -- pivot driver (9 id -> 1 dong/vung)
        SELECT
            area_code, MAX(area_name) AS an,
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
    tot AS (
        SELECT SUM(d1) AS t1, SUM(d2) AS t2, SUM(d25) AS t25,
               SUM(dtruoc) AS tt, SUM(dtot) AS ttot,
               SUM(dpsdn) AS tpsdn, SUM(dsm) AS tsm
        FROM d1p
    )
    INSERT INTO tmp_pnl_step2_ratio (month_key, area_code, area_name, report_id, value)
    SELECT p_month, s.area_code, s.an, v.rid, v.val
    FROM d1p AS s
    CROSS JOIN tot AS t
    CROSS JOIN LATERAL (
        VALUES
            (1,  CASE WHEN t.t1 = 0 THEN 0 ELSE s.d1 / t.t1 END),      -- B2: nhom 1
            (4,  CASE WHEN t.t1 = 0 THEN 0 ELSE s.d1 / t.t1 END),      -- B4: cung nhom 1
            (2,  CASE WHEN t.t2 = 0 THEN 0 ELSE s.d2 / t.t2 END),      -- B1: nhom 2
            (5,  CASE WHEN t.t25 = 0 THEN 0 ELSE s.d25 / t.t25 END),   -- B5: nhom 2-5
            (3,  CASE WHEN t.tpsdn = 0 THEN 0
                      ELSE COALESCE(s.dpsdn, 0) / t.tpsdn END),        -- B3: psdn
            (21, CASE WHEN t.ttot = 0 THEN 0 ELSE s.dtot / t.ttot END),-- C3: dnck
            (22, CASE WHEN t.ttot = 0 THEN 0 ELSE s.dtot / t.ttot END),-- C2
            (23, CASE WHEN t.ttot = 0 THEN 0 ELSE s.dtot / t.ttot END),-- C1
            (31, CASE WHEN t.ttot = 0 THEN 0 ELSE s.dtot / t.ttot END),-- D3: tong
            (32, CASE WHEN t.ttot = 0 THEN 0 ELSE s.dtot / t.ttot END),-- D1
            (33, CASE WHEN t.ttot = 0 THEN 0 ELSE s.dtot / t.ttot END),-- D2
            (51, CASE WHEN t.tsm = 0 THEN 0
                      ELSE COALESCE(s.dsm, 0) / t.tsm END),            -- F1: sm
            (52, CASE WHEN t.tsm = 0 THEN 0
                      ELSE COALESCE(s.dsm, 0) / t.tsm END),            -- F2
            (53, CASE WHEN t.tsm = 0 THEN 0
                      ELSE COALESCE(s.dsm, 0) / t.tsm END),            -- F3
            (54, CASE WHEN t.tsm = 0 THEN 0
                      ELSE COALESCE(s.dsm, 0) / t.tsm END),            -- F4
            (60, CASE WHEN t.tt = 0 THEN 0
                      ELSE s.dtruoc / t.tt END)                        -- G: truoc WO
    ) AS v(rid, val);
    INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status)
    VALUES ('sp_baocao_tonghop', p_month, v_step, 'OK');

    -- STEP3: tach GL thanh HEAD (prov 00) vs DIRECT (tinh -> vung),
    -- luu rieng vao tmp_pnl_step3_gl_split de doi chieu tung phan.
    -- amount giu nguyen dau (D am / C duong). Ghi TALL theo id tung dong.
    v_step := 'STEP3_GL_SPLIT';
    WITH gl AS (
        SELECT
            g.txn_month AS m,
            TRIM(g.account_code) AS acc,
            COALESCE(NULLIF(TRIM(g.prov), ''), '00') AS prov, -- 00 = HEAD
            COALESCE(g.amount, 0) AS amt
        FROM banking_project.stg_fact_txn_month AS g
        WHERE g.txn_month BETWEEN v_ys AND p_month -- GL luy ke YTD
    ),
    head AS ( -- 1 dong tong HEAD de nhan %
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
    direct AS ( -- Rule1: cong truc tiep theo vung
        SELECT
            p.area_code AS area_code,
            MAX(p.area_name) AS area_name,
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
    -- STEP3: luu TALL — HEAD 16 id ('00') + DIRECT 13 id moi vung.
    INSERT INTO tmp_pnl_step3_gl_split (month_key, area_code, area_name, report_id, value)
    SELECT p_month, '00', 'Hoi so (HEAD)', v.rid, v.val
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
    SELECT p_month, d.area_code, d.area_name, v.rid, v.val
    FROM direct AS d
    CROSS JOIN LATERAL (
        VALUES
            (1,  d.d_b2), (2,  d.d_b1), (3,  d.d_b3), (4,  d.d_b4), (5,  d.d_b5),
            (31, d.d_d3), (32, d.d_d1), (33, d.d_d2),
            (51, d.d_f1), (52, d.d_f2), (53, d.d_f3), (54, d.d_f4),
            (60, d.d_g)
    ) AS v(rid, val);
    INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status)
    VALUES ('sp_baocao_tonghop', p_month, v_step, 'OK');

    -- STEP4: tong Rule1 + HEAD x % — moi dong la bang nhau theo report_id:
    -- fct(rid) = direct(rid) + head(rid) * pct(rid); tong 11/24/34 cong
    -- truc tiep tu cac dong da chia (khong lam tron la con, ROUND 1 lan).
    v_step := 'STEP4_COMBINE';
    -- 16 la vung
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
    -- tong nhom vung: 11 = B (1..5), 24 = C (21..23), 34 = D (31..33)
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
    -- J = so luong SM (doc driver STEP1)
    INSERT INTO banking_project.fct_pnl_value
        (month_key, area_code, area_name, report_id, value)
    SELECT p_month, s.area_code, s.area_name, 90, s.value
    FROM banking_project.tmp_pnl_step1_driver AS s
    WHERE s.month_key = p_month AND s.report_id = 90;
    -- Pool HEAD '00': 16 la tu head (khong nhan %)
    INSERT INTO banking_project.fct_pnl_value
        (month_key, area_code, area_name, report_id, value)
    SELECT p_month, h.area_code, h.area_name, h.report_id, ROUND(h.value, 2)
    FROM banking_project.tmp_pnl_step3_gl_split AS h
    WHERE h.month_key = p_month AND h.area_code = '00';
    -- Pool HEAD '00': tong 11/24/34
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

    -- STEP5: tong E/F/A/H + chi so — doc cac dong da luu, ghi tiep vao tall.
    -- Ghi lai F (56) = tong 4 la DA LAM TRON (giong STEP5 fct wide cu;
    -- khac voi STEP4 dang ghi tu expression) truoc khi tinh A va ti so.
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
            (56, w.f1 + w.f2 + w.f3 + w.f4),           -- F = F1+F2+F3+F4 (da tron)
            (40, w.b + w.c + w.d),                      -- E = B + C + D
            (80, w.b + w.d3),                           -- H = B + D3
            (70, w.b + w.c + w.d + w.f1 + w.f2 + w.f3 + w.f4 + w.g)  -- A = E+F+G
    ) AS v(rid, val);

    -- Ti so dang % (*100), dau duong: -F/E, A/H, A/|C| (C am), A/J.
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

EXCEPTION WHEN OTHERS THEN -- ghi log roi nem loi ra
    INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status, note)
    VALUES ('sp_baocao_tonghop', p_month, v_step, 'FAIL', SQLERRM);
    RAISE;
END; $$;

-- 05. Cau CHECK (tong % phai = 1, tong thanh phan phai = 0) ----------------
-- Tong % moi nhom driver = 1 (xem theo id):
-- SELECT report_id, SUM(value) FROM tmp_pnl_step2_ratio
--     WHERE month_key = 202302 GROUP BY report_id ORDER BY report_id;
--     -- moi id 16 dong: 7 vung x % cua 1 nhom driver — tong = 1
-- SELECT SUM(b + c + d - e) FROM (  -- E = B+C+D, phai = 0
--     SELECT MAX(value) FILTER (WHERE report_id=11) AS b,
--            MAX(value) FILTER (WHERE report_id=24) AS c,
--            MAX(value) FILTER (WHERE report_id=34) AS d,
--            MAX(value) FILTER (WHERE report_id=40) AS e
--     FROM fct_pnl_value WHERE month_key=202302 AND area_code<>'00'
--     GROUP BY area_code) x;
-- SELECT COUNT(*) FROM fct_pnl_value WHERE month_key=202302; -- 223 dong
--     -- = 7 vung x 28 report_id + pool '00' x 27 (khong co J)
-- SELECT COUNT(*) FROM fct_pnl_value WHERE month_key=202302 AND area_code='00';
--     -- 27 dong pool HEAD

-- CHECK tung buoc (moi buoc = 1 bang rieng, doc duoc ngay trong DBeaver):
-- SELECT report_id, COUNT(*) FROM tmp_pnl_step1_driver
--     WHERE month_key = 202302 GROUP BY 1; -- 9 id x 7 vung = 63 dong
-- SELECT report_id, COUNT(*) FROM tmp_pnl_step2_ratio
--     WHERE month_key = 202302 GROUP BY 1; -- 16 id x 7 vung = 112 dong
-- SELECT area_code, COUNT(*) FROM tmp_pnl_step3_gl_split
--     WHERE month_key = 202302 GROUP BY 1; -- '00' = 16, moi vung = 13
-- SELECT status, step_name, note FROM log_proc_run WHERE month_key = 202302
--     AND proc_name = 'sp_baocao_tonghop' ORDER BY run_id;
--     -- START + 5 dong OK (STEP1..STEP5), khong co FAIL

-- CALL sp_baocao_tonghop(202301); -- backdate tung thang 202301..202305
