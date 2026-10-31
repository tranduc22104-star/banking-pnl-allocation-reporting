-- DIM: dim_month + dim_date + dim_sm_headcount (chay 1 lan, sau ingestion).
-- Bang phan tich P&L (pnl) va ASM doc thang STG (khong qua DIM trung gian).
-- Chu duy nhat cua dim_asm la sql/dim/dim_asm.sql - file nay khong tao, khong drop.
SET search_path TO banking_project, public;

-- 1. dim_month: truc thoi gian theo thang (khop grain fact) -----------------
-- Bao cao lap theo kieu thang (month to date / luy ke tu dau nam) nen moi dong
-- thang mang theo ngay bat dau, ngay chot so va so ngay cua thang do.
-- Ngay khong nhap tay: tinh tu nam + thang de thang 2 nam nhuan khong sai.
DROP TABLE IF EXISTS dim_month CASCADE;
CREATE TABLE dim_month (
    month_key            INT PRIMARY KEY,   -- 202301
    nam                  INT NOT NULL,
    thang                INT NOT NULL,
    ten_thang            VARCHAR(20) NOT NULL,
    ngay_dau_thang       DATE NOT NULL,     -- 2023-01-01
    ngay_cuoi_thang      DATE NOT NULL,     -- ngay chot so: 2023-01-31
    so_ngay_trong_thang  INT NOT NULL       -- 31
);
-- Danh sach thang ghi mot cho duoi duoi trong sp_load_dim().

-- 1b. dim_date: mot dong = mot ngay, noi xuong tu dim_month ------------------
-- dim_month GIU DUNG hat thang: ba quan he month_key cua bao cao (P&L, xep hang,
-- headcount) tro vao no; dua ngay vao dim_month se mat don vi cap thang va
-- nhan doi so lieu. Ai can tinh theo ngay (loc theo ngay, ve bieu do duong,
-- dem so trong thang) thi dung dim_date va join nguoc len month_key.
-- Chi co index, KHONG khai bao khoa ngoai month_key -> dim_month de kho van dung
-- quy uoc "mot khoa ngoai that" (fk_fct_asm_dim_asm); quan he do phia doc thuc hien.
DROP TABLE IF EXISTS dim_date CASCADE;
CREATE TABLE dim_date (
    date_key           INT PRIMARY KEY,    -- 20230115 = 15/01/2023
    ngay               DATE NOT NULL,
    nam                INT NOT NULL,
    thang              INT NOT NULL,
    ngay_trong_thang   INT NOT NULL,       -- 1..31
    month_key          INT NOT NULL,       -- 202301, khop dim_month.month_key
    so_thu             INT NOT NULL,       -- ISO: 1 = thu 2 ... 7 = chu nhat
    ten_thu            VARCHAR(10) NOT NULL,
    la_ngay_cuoi_thang BOOLEAN NOT NULL,   -- dung = ngay chot so cua thang
    UNIQUE (ngay)
);
CREATE INDEX IF NOT EXISTS idx_dim_date_month
    ON dim_date (month_key);

-- 2. PROCEDURE nap dim (dim_param_area do ingestion nap tu Excel) -----------
-- Gom dim_month + dim_date + dim_sm_headcount (headcount: so nguoi that theo PTKD,
-- khac so email ASM; chi co so T2 nen tam dung cho moi thang).
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
    -- Nguoi them thang moi chi can them month_key vao ARRAY, ngay tu tinh lai.
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

    -- dim_date sinh tu dim_month, khong nhap tay bat ky dong nao: them thang moi
    -- o ARRAY tren thi ngay duoi tu co du, thang 2 nam nhuan tu ra 29 dong.
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

-- Don bang cu khong ai doc (da xac minh khong procedure/view nao dung).
DROP TABLE IF EXISTS dim_pnl_line_item CASCADE;

-- So dong kiem tra -----------------------------------------------------------
SELECT 'dim_param_area' AS tbl, COUNT(*) FROM dim_param_area
UNION ALL SELECT 'dim_month', COUNT(*) FROM dim_month
UNION ALL SELECT 'dim_date', COUNT(*) FROM dim_date;

-- Truc thoi gian sau khi nap (ngay chot so phai la ngay cuoi thang) ----------
SELECT month_key, ten_thang, ngay_dau_thang, ngay_cuoi_thang, so_ngay_trong_thang
FROM dim_month ORDER BY month_key;

-- dim_date theo thang: moi thang mot dong, so ngay phai bang dim_month -------
SELECT month_key, COUNT(*) AS so_dong, MIN(ngay) AS ngay_dau, MAX(ngay) AS ngay_cuoi,
       COUNT(*) FILTER (WHERE la_ngay_cuoi_thang) AS so_ngay_chot,
       COUNT(*) FILTER (WHERE so_thu IN (6, 7)) AS so_ngay_cuoi_tuan
FROM dim_date GROUP BY month_key ORDER BY month_key;
