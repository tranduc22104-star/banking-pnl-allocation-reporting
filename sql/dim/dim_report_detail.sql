-- =====================================================================
-- BẢNG CHIỀU CHỈ TIÊU BÁO CÁO (dim_report_detail):
-- Định nghĩa cây chỉ tiêu cho hai báo cáo; số liệu nằm ở fct_pnl_value và fct_asm_value.
--   report_group : 'PNL' là báo cáo tổng hợp lãi lỗ, 'XH' là xếp hạng quản lý vùng
--   report_id    : mã chỉ tiêu cố định trong từng nhóm (lãi lỗ 1..94, xếp hạng 201..222)
--   parent_id    : mã chỉ tiêu cha (-1 là nút gốc)
--   sort_order   : thứ tự dòng theo mẫu đối chiếu Excel
--   unit         : đơn vị tính (VND, count, pct, rank, score)
-- Chạy trước hai tệp thủ tục điều phối.
-- =====================================================================
SET search_path TO banking_project, public;

DROP TABLE IF EXISTS dim_report_detail CASCADE;
CREATE TABLE dim_report_detail (
    report_group VARCHAR(3)   NOT NULL,   -- 'PNL' hoặc 'XH'
    report_id    INT          NOT NULL,
    report_name  VARCHAR(120) NOT NULL,
    parent_id    INT          NOT NULL DEFAULT -1, -- -1 là nút gốc
    sort_order   INT          NOT NULL,   -- thứ tự hiển thị trên báo cáo
    unit         VARCHAR(10)  NOT NULL,   -- VND / count / pct / rank / score
    PRIMARY KEY (report_group, report_id)
);
CREATE INDEX idx_report_detail_parent
    ON dim_report_detail (report_group, parent_id);

-- 01. PNL — 28 mã (16 mã lá, 4 mã tổng nhóm, E/H/A, J và 4 tỷ số)
-- Cây: 1 đến 5 lên 11 lên 40 | 21 đến 23 lên 24 lên 40 | 31 đến 33 lên 34 lên 40
--      40, 56, 60 lên 70 (A); 80 (H) và 90 đến 94 đứng riêng
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

-- 02. XH — 22 mã (4 chỉ số, 4 hạng quy mô, điểm và hạng, phần tài chính, phần tổng)
-- Cây: 205 đến 208 lên 209 (điểm quy mô) | 212, 214, 216, 218 lên 219 (điểm tài chính)
--      209 và 219 lên 221 (điểm tổng); chỉ số và hạng gốc đứng riêng
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

-- Kiểm tra:
-- SELECT report_group, COUNT(*) FROM dim_report_detail GROUP BY 1; -- 28 + 22
-- SELECT COUNT(*) FROM dim_report_detail WHERE parent_id = -1; -- 7 + 9 = 16 nút gốc
-- SELECT d.report_group, d.report_id, d.report_name, p.report_name AS parent
-- FROM dim_report_detail d LEFT JOIN dim_report_detail p
--   ON p.report_group = d.report_group AND p.report_id = d.parent_id
-- WHERE d.parent_id <> -1 AND p.report_id IS NULL; -- 0 dòng: mọi mã cha đều có thật
