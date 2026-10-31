-- =====================================================================
-- XEP HANG ASM (sheet BaocaoXepHangASM_T2): bang su kien fct_asm_value + thu tuc sp_xephang_asm.
-- XH1 theo ASM (LTN/PSDN/duyet AVG luy ke, bo NULL); NPL theo vung.
-- XH2 theo vung tu Tonghop (CIR/Margin/HS von/HSBQ giong nhau ca vung).
-- Tong = QM + FIN; RANK() dong diem cung hang (co gap). Can chay Tonghop truoc.
-- Bang tam da tach sang sql/tmp/; 4 view da tach sang sql/rpt/.
-- Thu tu chay: ingestion -> sql/dim -> sql/tmp -> file nay -> CALL tung thang -> sql/rpt.
-- =====================================================================

SET search_path TO banking_project, public;

-- 01. BANG FACT TALL XEP HANG (chi luu khua asm_id) --------------------------
-- report_id (xem sql/dim/dim_report_detail.sql):
--   201 LTN | 202 PSDN | 203 duyet | 204 NPL | 205..208 4 rank QM
--   209 Diem QM | 210 rank PTKD
--   211 CIR | 212 rank | 213 Margin | 214 rank | 215 HS von | 216 rank
--   217 HSBQ | 218 rank | 219 Diem FIN | 220 rank FIN
--   221 Tong diem | 222 rank tong ket
DROP TABLE IF EXISTS fct_asm_value CASCADE;
CREATE TABLE fct_asm_value (
    month_key   INT NOT NULL,
    asm_id      INT NOT NULL,          -- FK -> dim_asm(asm_id)
    report_id   INT NOT NULL,          -- FK logic -> dim_report_detail
    value       NUMERIC(24,6),         -- VND/ty so 6 so le, rank/diem so le 0
    PRIMARY KEY (month_key, asm_id, report_id),
    CONSTRAINT fk_fct_asm_dim_asm FOREIGN KEY (asm_id) REFERENCES dim_asm(asm_id)
);
CREATE INDEX IF NOT EXISTS idx_fct_asm_value_month
    ON fct_asm_value (month_key);
CREATE INDEX IF NOT EXISTS idx_fct_asm_value_asm
    ON fct_asm_value (asm_id);

-- 02. PROCEDURE backdate (chay Tonghop cua thang do truoc) -------------------
CREATE OR REPLACE PROCEDURE sp_xephang_asm(p_month INT)
LANGUAGE plpgsql AS $$
DECLARE
    v_step TEXT;
    v_ys   INT; -- thang 1 dau nam (YYYY01)
    v_nth  INT; -- so vung co so lieu Tonghop (kiem tra chay Tonghop truoc)
BEGIN
    v_step := 'STEP0_DELETE_MONTH';
    INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status)
    VALUES ('sp_xephang_asm', p_month, v_step, 'START');
    DELETE FROM tmp_xh_step1_asm_avg
    WHERE month_key = p_month;
    DELETE FROM tmp_xh_step2_npl_area
    WHERE month_key = p_month;
    DELETE FROM tmp_xh_step3_fin_area
    WHERE month_key = p_month;
    DELETE FROM fct_asm_value
    WHERE month_key = p_month;
    v_ys := (p_month - (p_month % 100)) + 1; -- vd 202302 -> 202301

    -- STEP1: trung binh luy ke theo ASM (AVG bo NULL).
    -- Universe: ASM co it nhat 1 thang co so lieu tu dau nam.
    -- Ghi TALL: 3 dong/ASM (201/202/203), khua asm_id (lay tu dim_asm qua email),
    -- CAST ve do le cot cu khi INSERT de giu nguyen lam tron xanh.
    -- NPL + rank chua tinh o day (xem STEP2/STEP4).
    v_step := 'STEP1_ASM_AVG';
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
            (201, m.ltn_avg::NUMERIC(20,2)),        -- LTN: 2 so le (cot cu)
            (202, m.psdn_avg::NUMERIC(12,2)),       -- PSDN: 2 so le (cot cu)
            (203, m.appr_avg::NUMERIC(12,6))        -- duyet: 6 so le (cot cu)
    ) AS v(rid, val);
    INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status)
    VALUES ('sp_xephang_asm', p_month, v_step, 'OK');

    -- STEP2: NPL theo vung — dang TALL 3 id moi vung (204 / 231 / 232).
    -- sau WO = outstanding; truoc WO = outstanding + write-off (chi tu dau nam).
    v_step := 'STEP2_NPL_AREA';
    INSERT INTO tmp_xh_step2_npl_area
        (month_key, area_code, report_id, value)
    SELECT p_month, s.area_code, v.rid, v.val
    FROM (
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
    ) AS s
    CROSS JOIN LATERAL (VALUES
        (204, CASE WHEN s.den IS NULL OR s.den = 0 THEN NULL
                   ELSE ROUND((s.num / s.den) * 100, 6) END),   -- %: 6 so le (cot cu)
        (231, ROUND(s.num, 4)),                                 -- tu so: VND 4 so le
        (232, ROUND(s.den, 4))                                  -- mau so: VND 4 so le
    ) AS v(rid, val);
    INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status)
    VALUES ('sp_xephang_asm', p_month, v_step, 'OK');

    -- STEP3: 4 chi so tai chinh + 4 hang CUA 7 VUNG, luu ra bang tam rieng.
    -- Guard o day (truoc khi ghi bat ky dong fact nao): Tonghop thang nay
    -- phai du 7 vung. Loai pool '00' vi hoi so khong co hang tai chinh.
    v_step := 'STEP3_FIN_AREA';
    SELECT COUNT(DISTINCT area_code) INTO v_nth
    FROM fct_pnl_value
    WHERE month_key = p_month AND area_code <> '00' AND report_id = 70;
    IF v_nth < 7 THEN
        INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status, note)
        VALUES ('sp_xephang_asm', p_month, v_step, 'FAIL',
                'Thieu Tonghop thang nay: moi co ' || v_nth || '/7 vung');
        RAISE EXCEPTION 'Chua co fct_pnl_value du 7 vung cho thang % - chay sp_baocao_tonghop truoc', p_month;
    END IF;
    WITH w AS (
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
    fin AS ( -- rank 7 vung (CIR ASC, con lai DESC; HSBQ tinh nguyen, chua ROUND)
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
        (211, ROUND(f.cir, 6)),        -- % -F/E   (6 so le = cot cu)
        (212, f.r_cir::NUMERIC),       -- hang CIR (thap tot)
        (213, ROUND(f.margin, 6)),     -- % A/H
        (214, f.r_margin::NUMERIC),
        (215, ROUND(f.hs, 6)),         -- % A/|C|
        (216, f.r_hs::NUMERIC),
        (217, f.hsbq),                 -- A/J NGUYEN, ROUND(..,2) o STEP5
        (218, f.r_hsbq::NUMERIC),
        (219, (f.r_cir + f.r_margin + f.r_hs + f.r_hsbq)::NUMERIC)  -- Diem FIN
    ) AS v(rid, val);
    INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status)
    VALUES ('sp_xephang_asm', p_month, v_step, 'OK');

    -- STEP4: 4 rank XH1 (cao tot DESC, NPL thap tot ASC) + Diem QM + rank PTKD.
    -- Ghi vao fct_asm_value (tall): 10 dong/ASM (4 chi so + 4 rank + 2 diem).
    -- Chi so doc tu step1 da pivot + npl value tu step2 (report_id 204),
    -- area_code lay tu dim_asm theo asm_id.
    v_step := 'STEP4_RANK_QM';
    WITH asm_vals AS ( -- pivot step1 (3 dong/ASM -> 1 dong)
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

    -- STEP5: copy 9 dong tai chinh cua vung cho tung ASM cung vung.
    -- Khong tinh lai gi o buoc nay — hang da chot o STEP3, o day chi nhan ban
    -- theo (area_code, report_id); rieng 217 (HSBQ) ROUND(..,2) luc ghi vi bang
    -- tam giu A/J nguyen do le.
    v_step := 'STEP5_ADD_FIN';
    WITH asm_list AS ( -- danh sach ASM thang nay (asm_id + area_code tu dim_asm)
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

    -- STEP6: tong QM + FIN + rank cuoi (rank_ptkd da co tu STEP4, khong ghi lai)
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

EXCEPTION WHEN OTHERS THEN -- ghi log roi nem loi ra
    INSERT INTO banking_project.log_proc_run (proc_name, month_key, step_name, status, note)
    VALUES ('sp_xephang_asm', p_month, v_step, 'FAIL', SQLERRM);
    RAISE;
END; $$;

-- CHECK: mau T2 tong 34 / hang 1 la nam.hoangvan (chay Tonghop 202302 truoc)
-- CALL sp_xephang_asm(202302);
-- SELECT d.email, diem_qm, rank_ptkd, diem_fin, rank_fin, tong_diem, rank_final
-- FROM v_xephang_asm WHERE month_key=202302 ORDER BY rank_final LIMIT 5;
-- CHECK tung buoc (moi buoc = 1 bang rieng, doc duoc ngay trong DBeaver):
-- SELECT report_id, COUNT(*) FROM tmp_xh_step1_asm_avg WHERE month_key = 202302
--     GROUP BY 1; -- 3 id x so ASM (vd T2: 222 dong)
-- SELECT report_id, COUNT(*) FROM tmp_xh_step2_npl_area WHERE month_key = 202302
--     GROUP BY 1; -- 3 id (204 %, 231 tu so, 232 mau so) x 7 vung = 21 dong
-- SELECT area_code, MAX(value) FILTER (WHERE report_id = 231) AS tu_so,
--        MAX(value) FILTER (WHERE report_id = 232) AS mau_so,
--        MAX(value) FILTER (WHERE report_id = 204) AS npl_pct
-- FROM tmp_xh_step2_npl_area WHERE month_key = 202302
-- GROUP BY area_code ORDER BY area_code; -- 7 vung, num/den doi chieu stg
-- SELECT report_id, COUNT(*) FROM tmp_xh_step3_fin_area WHERE month_key = 202302
--     GROUP BY 1; -- 9 id (211..219) x 7 vung = 63 dong
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
-- GROUP BY area_code ORDER BY diem_fin; -- 7 dong, moi hang 1..7
-- SELECT COUNT(*) FROM fct_asm_value WHERE month_key = 202302;
--     -- = so ASM x 13 (10 dong XH1 + 3 dong tong) + 9 x so ASM khop vung (STEP5)
-- SELECT asm_id, COUNT(*) FROM fct_asm_value WHERE month_key = 202302
--     GROUP BY asm_id HAVING COUNT(*) NOT IN (13, 22); -- 0 dong (13 hoac 22)
-- SELECT status, step_name, note FROM log_proc_run WHERE month_key = 202302
--     AND proc_name = 'sp_xephang_asm' ORDER BY run_id;
--     -- START + 6 dong OK (STEP1..STEP6), khong co FAIL
