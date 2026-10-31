-- =====================================================================
-- DIM_REPORT_DETAIL: cay bao cao (metadata) cho cau truc TALL.
-- Moi gia tri so lieu nam trong fct_pnl_value / fct_asm_value,
-- moi dong o day = 1 report_id (la la, tong, ti so, diem, rank).
--   report_group : 'PNL' = bao cao tong hop P&L | 'XH' = xep hang ASM
--   report_id    : ma so rieng trong nhom (cot, khong doi)
--   parent_id    : cha tren cay (tong = cong cac con); -1 = nut goc
--   sort_order   : thu tu hien thi theo layout Excel
--   unit         : VND / count / pct / rank / score
-- Chay truoc 2 file procedure. KHONG seed cot c_dt_nguonvon (fct cu
-- luon 0, khong phai report_id).
-- =====================================================================
SET search_path TO banking_project, public;

DROP TABLE IF EXISTS dim_report_detail CASCADE;
CREATE TABLE dim_report_detail (
    report_group VARCHAR(3)  NOT NULL,   -- 'PNL' | 'XH'
    report_id    INT         NOT NULL,
    report_name  VARCHAR(120) NOT NULL,
    parent_id    INT         NOT NULL DEFAULT -1, -- -1 = nut goc
    sort_order   INT         NOT NULL,   -- thu tu layout Excel
    unit         VARCHAR(10) NOT NULL,   -- VND/count/pct/rank/score
    PRIMARY KEY (report_group, report_id)
);
CREATE INDEX idx_report_detail_parent
    ON dim_report_detail (report_group, parent_id);

-- 01. PNL — 28 report_id (16 la + 4 tong nhom + E/H/A + J + 4 ti so)
-- Cay: 1..5 -> 11 -> 40 | 21..23 -> 24 -> 40 | 31..33 -> 34 -> 40
--      40,56,60 -> 70 (A); 80 (H = B+D3) & 90..94 dung rieng
INSERT INTO dim_report_detail
    (report_group, report_id, report_name, parent_id, sort_order, unit)
VALUES
    ('PNL',  1, 'Lai trong han (B2)',                 11,  10, 'VND'),
    ('PNL',  2, 'Lai qua han (B1)',                   11,  20, 'VND'),
    ('PNL',  3, 'Phi bao hiem (B3)',                  11,  30, 'VND'),
    ('PNL',  4, 'Phi tang hoa don (B4)',              11,  40, 'VND'),
    ('PNL',  5, 'Phi cham tra (B5)',                  11,  50, 'VND'),
    ('PNL', 11, 'Tong thu nhap the (B)',              40,  60, 'VND'),
    ('PNL', 21, 'Von tai toan ca (C3)',               24,  70, 'VND'),
    ('PNL', 22, 'Von tai toan 1 (C2)',                24,  80, 'VND'),
    ('PNL', 23, 'Von CCTG (C1)',                      24,  90, 'VND'),
    ('PNL', 24, 'Tong von kinh doanh the (C)',        40, 100, 'VND'),
    ('PNL', 31, 'Doanh thu kinh doanh (D3)',          34, 110, 'VND'),
    ('PNL', 32, 'Chi phi hoa hong (D1)',              34, 120, 'VND'),
    ('PNL', 33, 'Chi phi kinh doanh khac (D2)',       34, 130, 'VND'),
    ('PNL', 34, 'Tong hoa hong + chi phi KD khac (D)',40, 140, 'VND'),
    ('PNL', 40, 'Tong thu nhap (E = B + C + D)',      70, 150, 'VND'),
    ('PNL', 51, 'Chi phi thue (F1)',                  56, 160, 'VND'),
    ('PNL', 52, 'Chi phi nhan su (F2)',               56, 170, 'VND'),
    ('PNL', 53, 'Chi phi quan ly (F3)',               56, 180, 'VND'),
    ('PNL', 54, 'Chi phi tai san (F4)',               56, 190, 'VND'),
    ('PNL', 56, 'Tong chi phi (F)',                   70, 200, 'VND'),
    ('PNL', 60, 'Du phong rui ro (G)',                70, 210, 'VND'),
    ('PNL', 70, 'LN sau thue (A = E + F + G)',        -1, 220, 'VND'),
    ('PNL', 80, 'Tong doanh thu (H = B + D3)',        -1, 230, 'VND'),
    ('PNL', 90, 'So luong SM (J)',                    -1, 240, 'count'),
    ('PNL', 91, 'Chi so CIR (-F/E %)',                -1, 250, 'pct'),
    ('PNL', 92, 'Chi so Margin (A/H %)',              -1, 260, 'pct'),
    ('PNL', 93, 'Chi so he so von (A/|C| %)',         -1, 270, 'pct'),
    ('PNL', 94, 'LN sau thue binh quan nhan su (A/J)',-1, 280, 'VND');

-- 02. XH — 22 report_id (4 chi so + 4 rank QM + diem/rank + FIN + tong)
-- Cay: 205..208 -> 209 (diem QM) ; 212/214/216/218 -> 219 (diem FIN)
--      209,219 -> 221 (tong diem); chi so va rank goc dung rieng
INSERT INTO dim_report_detail
    (report_group, report_id, report_name, parent_id, sort_order, unit)
VALUES
    ('XH', 201, 'LTN binh quan YTD',            -1,  10, 'VND'),
    ('XH', 205, 'Rank LTN',                     209,  20, 'rank'),
    ('XH', 202, 'PSDN binh quan YTD',           -1,  30, 'count'),
    ('XH', 206, 'Rank PSDN',                    209,  40, 'rank'),
    ('XH', 203, 'Ty le duyet binh quan YTD',     -1,  50, 'pct'),
    ('XH', 207, 'Rank ty le duyet',              209,  60, 'rank'),
    ('XH', 204, 'NPL truoc WO luy ke',          -1,  70, 'pct'),
    ('XH', 208, 'Rank NPL',                     209,  80, 'rank'),
    ('XH', 209, 'Diem quy mo (QM)',             221,  90, 'score'),
    ('XH', 210, 'Rank PTKD (diem QM)',          209, 100, 'rank'),
    ('XH', 211, 'CIR cua vung',                 -1, 110, 'pct'),
    ('XH', 212, 'Rank CIR',                     219, 120, 'rank'),
    ('XH', 213, 'Margin cua vung',              -1, 130, 'pct'),
    ('XH', 214, 'Rank Margin',                  219, 140, 'rank'),
    ('XH', 215, 'He so von cua vung',           -1, 150, 'pct'),
    ('XH', 216, 'Rank he so von',               219, 160, 'rank'),
    ('XH', 217, 'HSBQ nhan su cua vung',        -1, 170, 'VND'),
    ('XH', 218, 'Rank HSBQ',                    219, 180, 'rank'),
    ('XH', 219, 'Diem tai chinh (FIN)',         221, 190, 'score'),
    ('XH', 220, 'Rank FIN (diem FIN)',          219, 200, 'rank'),
    ('XH', 221, 'Tong diem (QM + FIN)',         -1, 210, 'score'),
    ('XH', 222, 'Rank tong ket',                221, 220, 'rank');

-- CHECK:
-- SELECT report_group, COUNT(*) FROM dim_report_detail GROUP BY 1; -- 28 + 22
-- SELECT COUNT(*) FROM dim_report_detail WHERE parent_id = -1; -- 7 + 9 = 16 goc
-- SELECT d.report_group, d.report_id, d.report_name, p.report_name AS parent
-- FROM dim_report_detail d LEFT JOIN dim_report_detail p
--   ON p.report_group = d.report_group AND p.report_id = d.parent_id
-- WHERE d.parent_id <> -1 AND p.report_id IS NULL; -- 0 dong (cha ton tai)
