-- =====================================================================
-- BẢNG CHIỀU QUẢN LÝ KINH DOANH VÙNG (dim_asm):
-- Gom họ tên, thư điện tử và mã vùng về một bảng danh mục duy nhất; tên vùng
-- tra qua dim_area theo area_code. Các bảng tính toán (tmp_xh_step1_asm_avg,
-- fct_asm_value) chỉ lưu khoá đại diện asm_id.
-- Tệp này là chủ duy nhất của dim_asm (khai báo, tạo chỉ mục, đồng bộ từ
-- stg_asm_target); chạy lại nhiều lần không sinh dòng trùng.
-- =====================================================================
SET search_path TO banking_project, public;

CREATE TABLE IF NOT EXISTS dim_asm (
    asm_id      INT NOT NULL,
    sale_name   VARCHAR(100) NOT NULL,
    email       VARCHAR(100) NOT NULL,
    area_code   VARCHAR(10),               -- nối sang dim_area.area_code (khoá ngoại ảo)
    PRIMARY KEY (asm_id),
    CONSTRAINT uq_dim_asm_email UNIQUE (email)
);
ALTER TABLE dim_asm DROP COLUMN IF EXISTS area_name CASCADE;

CREATE INDEX IF NOT EXISTS idx_dim_asm_area
    ON dim_asm (area_code);

-- Đồng bộ danh sách 84 quản lý vùng duy nhất từ bảng tiếp nhận stg_asm_target
INSERT INTO dim_asm (asm_id, sale_name, email, area_code)
SELECT 
    s.asm_id,
    s.sale_name,
    s.email,
    s.area_code
FROM (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY COALESCE(area_code, 'ZZ'), LOWER(TRIM(email)))::INT AS asm_id,
        TRIM(sale_name) AS sale_name,
        LOWER(TRIM(email)) AS email,
        TRIM(area_code) AS area_code
    FROM (
        SELECT DISTINCT email, sale_name, area_code
        FROM banking_project.stg_asm_target
        WHERE email IS NOT NULL AND TRIM(email) <> ''
    ) t
) s
ON CONFLICT (email) DO UPDATE SET
    sale_name = EXCLUDED.sale_name,
    area_code = EXCLUDED.area_code;
