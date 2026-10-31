-- =====================================================================
-- DIM_ASM: Bảng thứ nguyên thông tin ASM (Area Sales Manager).
-- Chuẩn hóa mô hình dữ liệu: gom sale_name, email, area_code về dim_asm.
-- Các bảng tính toán (fct_asm_value, tmp_xh_step1_asm_avg) chỉ cần lưu asm_id.
-- Tệp này là chủ duy nhất của dim_asm (khai báo, index, nạp); bước 02 ingestion
-- chỉ còn nạp stg_asm_target. Chạy lại tệp này nhiều lần không sinh dòng trùng.
-- =====================================================================
SET search_path TO banking_project, public;

CREATE TABLE IF NOT EXISTS dim_asm (
    asm_id      INT NOT NULL,
    sale_name   VARCHAR(100) NOT NULL,
    email       VARCHAR(100) NOT NULL,
    area_code   VARCHAR(10),
    area_name   VARCHAR(100),
    PRIMARY KEY (asm_id),
    CONSTRAINT uq_dim_asm_email UNIQUE (email)
);

CREATE INDEX IF NOT EXISTS idx_dim_asm_area
    ON dim_asm (area_code);

-- Nạp/đồng bộ dữ liệu từ stg_asm_target (84 ASM duy nhất)
INSERT INTO dim_asm (asm_id, sale_name, email, area_code, area_name)
SELECT 
    s.asm_id,
    s.sale_name,
    s.email,
    s.area_code,
    s.area_name
FROM (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY COALESCE(area_code, 'ZZ'), LOWER(TRIM(email)))::INT AS asm_id,
        TRIM(sale_name) AS sale_name,
        LOWER(TRIM(email)) AS email,
        TRIM(area_code) AS area_code,
        TRIM(area_name) AS area_name
    FROM (
        SELECT DISTINCT email, sale_name, area_code, area_name
        FROM banking_project.stg_asm_target
        WHERE email IS NOT NULL AND TRIM(email) <> ''
    ) t
) s
ON CONFLICT (email) DO UPDATE SET
    sale_name = EXCLUDED.sale_name,
    area_code = EXCLUDED.area_code,
    area_name = EXCLUDED.area_name;
