-- LỚP DANH MỤC: ba bảng dim_month, dim_date, dim_sm_headcount.
-- Chạy một lần sau bước nạp liệu; hai bảng dim_area và dim_param_area do bước 01 tạo,
-- còn dim_asm thuộc về sql/dim/dim_asm.sql.
SET search_path TO banking_project, public;

-- 1. dim_month — mỗi dòng là một tháng, khớp khoá tháng của bảng sự kiện
DROP TABLE IF EXISTS dim_month CASCADE;
CREATE TABLE dim_month (
    month_key            INT PRIMARY KEY,   -- 202301
    nam                  INT NOT NULL,
    thang                INT NOT NULL,
    ten_thang            VARCHAR(20) NOT NULL,
    ngay_dau_thang       DATE NOT NULL,     -- 2023-01-01
    ngay_cuoi_thang      DATE NOT NULL,     -- ngày chốt số: 2023-01-31
    so_ngay_trong_thang  INT NOT NULL       -- 31
);
-- Danh sách tháng khai một lần trong thủ tục sp_load_dim bên dưới.

-- 1b. dim_date — mỗi dòng là một ngày, suy ra từ dim_month
-- Không dồn ngày vào dim_month vì đơn vị báo cáo là tháng. Khi cần lọc hoặc vẽ
-- biểu đồ theo ngày thì dùng dim_date nối với dim_month qua month_key (khoá ngoại ảo).
DROP TABLE IF EXISTS dim_date CASCADE;
CREATE TABLE dim_date (
    date_key           INT PRIMARY KEY,    -- 20230115 = ngày 15 tháng 1 năm 2023
    ngay               DATE NOT NULL,
    nam                INT NOT NULL,
    thang              INT NOT NULL,
    ngay_trong_thang   INT NOT NULL,       -- 1 đến 31
    month_key          INT NOT NULL,       -- 202301, nối sang dim_month.month_key
    so_thu             INT NOT NULL,       -- thứ trong tuần theo chuẩn quốc tế: 1 là thứ Hai, 7 là Chủ nhật
    ten_thu            VARCHAR(10) NOT NULL,
    la_ngay_cuoi_thang BOOLEAN NOT NULL,   -- TRUE là ngày chốt số của tháng
    UNIQUE (ngay)
);
CREATE INDEX IF NOT EXISTS idx_dim_date_month
    ON dim_date (month_key);

-- 2. Thủ tục nạp ba bảng dim_month, dim_date, dim_sm_headcount
-- Quân số quản lý bán hàng (sm_count) là số nhân sự thực tế theo vùng, khác với số
-- quản lý vùng trong dim_asm; nguồn chỉ có số tháng Hai nên dùng chung cho năm tháng.
DROP TABLE IF EXISTS dim_sm_headcount CASCADE;
CREATE TABLE dim_sm_headcount (
    month_key INT NOT NULL,
    area_code VARCHAR(10) NOT NULL,
    sm_count  INT NOT NULL,
    PRIMARY KEY (month_key, area_code)
);
CREATE OR REPLACE PROCEDURE sp_load_dim()
LANGUAGE plpgsql AS $$
BEGIN
    TRUNCATE TABLE dim_month;
    -- Thêm tháng mới: chỉ cần ghi month_key vào mảng, ngày tự tính lại.
    INSERT INTO dim_month (month_key, nam, thang, ten_thang,
                           ngay_dau_thang, ngay_cuoi_thang, so_ngay_trong_thang)
    SELECT mk,
           mk / 100,
           mk % 100,
           'Thang ' || (mk % 100),
           make_date(mk / 100, mk % 100, 1),
           (make_date(mk / 100, mk % 100, 1) + INTERVAL '1 month - 1 day')::date,
           EXTRACT(DAY FROM (make_date(mk / 100, mk % 100, 1)
                             + INTERVAL '1 month - 1 day')::date)::int
    FROM unnest(ARRAY[202301, 202302, 202303, 202304, 202305]) AS mk;

    -- dim_date sinh tự động từ dim_month, không phải nhập dòng nào: thêm tháng ở
    -- mảng trên là có đủ ngày, tháng Hai năm nhuận tự ra 29 dòng.
    TRUNCATE TABLE dim_date;
    INSERT INTO dim_date (date_key, ngay, nam, thang, ngay_trong_thang,
                          month_key, so_thu, ten_thu, la_ngay_cuoi_thang)
    SELECT (EXTRACT(YEAR FROM d.ngay)::INT * 10000
            + EXTRACT(MONTH FROM d.ngay)::INT * 100
            + EXTRACT(DAY FROM d.ngay)::INT),
           d.ngay,
           m.nam,
           m.thang,
           EXTRACT(DAY FROM d.ngay)::INT,
           m.month_key,
           EXTRACT(ISODOW FROM d.ngay)::INT,
           CASE EXTRACT(ISODOW FROM d.ngay)::INT
               WHEN 1 THEN 'Thu 2'
               WHEN 2 THEN 'Thu 3'
               WHEN 3 THEN 'Thu 4'
               WHEN 4 THEN 'Thu 5'
               WHEN 5 THEN 'Thu 6'
               WHEN 6 THEN 'Thu 7'
               ELSE 'Chu nhat'
           END,
           d.ngay = m.ngay_cuoi_thang
    FROM dim_month m
    CROSS JOIN LATERAL (
        SELECT generate_series(m.ngay_dau_thang, m.ngay_cuoi_thang,
                               INTERVAL '1 day')::date AS ngay
    ) d;

    TRUNCATE TABLE banking_project.dim_sm_headcount;
    INSERT INTO banking_project.dim_sm_headcount (month_key, area_code, sm_count) VALUES
    (202301,'B',8),(202301,'C',7),(202301,'D',22),(202301,'E',5),(202301,'F',5),(202301,'G',11),(202301,'H',15),
    (202302,'B',8),(202302,'C',7),(202302,'D',22),(202302,'E',5),(202302,'F',5),(202302,'G',11),(202302,'H',15),
    (202303,'B',8),(202303,'C',7),(202303,'D',22),(202303,'E',5),(202303,'F',5),(202303,'G',11),(202303,'H',15),
    (202304,'B',8),(202304,'C',7),(202304,'D',22),(202304,'E',5),(202304,'F',5),(202304,'G',11),(202304,'H',15),
    (202305,'B',8),(202305,'C',7),(202305,'D',22),(202305,'E',5),(202305,'F',5),(202305,'G',11),(202305,'H',15);
END; $$;

CALL sp_load_dim();

-- Bảng cũ không còn ai đọc (đã xác minh không thủ tục hay view nào tham chiếu).
DROP TABLE IF EXISTS dim_pnl_line_item CASCADE;

-- Kiểm tra số dòng sau khi nạp
SELECT 'dim_area' AS tbl, COUNT(*) FROM dim_area
UNION ALL SELECT 'dim_param_area', COUNT(*) FROM dim_param_area
UNION ALL SELECT 'dim_month', COUNT(*) FROM dim_month
UNION ALL SELECT 'dim_date', COUNT(*) FROM dim_date;

-- Kiểm tra trục thời gian: ngày chốt phải là ngày cuối tháng
SELECT month_key, ten_thang, ngay_dau_thang, ngay_cuoi_thang, so_ngay_trong_thang
FROM dim_month ORDER BY month_key;

-- Kiểm tra dim_date: số ngày mỗi tháng phải khớp dim_month
SELECT month_key, COUNT(*) AS so_dong, MIN(ngay) AS ngay_dau, MAX(ngay) AS ngay_cuoi,
       COUNT(*) FILTER (WHERE la_ngay_cuoi_thang) AS so_ngay_chot,
       COUNT(*) FILTER (WHERE so_thu IN (6, 7)) AS so_ngay_cuoi_tuan
FROM dim_date GROUP BY month_key ORDER BY month_key;
