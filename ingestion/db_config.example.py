# Mẫu cấu hình kết nối — copy thành `db_config.py` rồi điền giá trị của bạn.
# `db_config.py` đã nằm trong .gitignore (không đẩy mật khẩu lên GitHub).
import os

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = int(os.getenv("DB_PORT", "5432"))
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASS = os.getenv("DB_PASS", "")          # điền mật khẩu của bạn
DB_NAME = os.getenv("DB_NAME", "postgres")
SCHEMA_NAME = os.getenv("SCHEMA_NAME", "banking_project")

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT_DIR = BASE_DIR
INPUT_DATA_DIR = os.path.join(PROJECT_DIR, "input")
CSV_STAGING_DIR = os.path.join(PROJECT_DIR, ".staging")
LOG_FILE = os.path.join(CSV_STAGING_DIR, "ingestion_log.txt")
