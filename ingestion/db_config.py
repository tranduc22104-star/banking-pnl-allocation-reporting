import os
import sys
if sys.platform.startswith('win'):
    try:
        sys.stdout.reconfigure(encoding='utf-8')
        sys.stderr.reconfigure(encoding='utf-8')
    except Exception:
        pass
import psycopg2
try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = int(os.getenv("DB_PORT", "5432"))
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASS = os.getenv("DB_PASS", "123456")
DB_NAME = os.getenv("DB_NAME", "postgres")
SCHEMA_NAME = os.getenv("SCHEMA_NAME", "banking_project")

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT_DIR = BASE_DIR
INPUT_DATA_DIR = os.path.join(PROJECT_DIR, "input")
CSV_STAGING_DIR = os.path.join(PROJECT_DIR, ".staging")

LOG_FILE = os.path.join(CSV_STAGING_DIR, "ingestion_log.txt")


def get_connection():
    """Mo ket noi PostgreSQL (timeout 5s)."""
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            port=DB_PORT,
            user=DB_USER,
            password=DB_PASS,
            database=DB_NAME,
            connect_timeout=5
        )
        return conn
    except Exception as e:
        print(f"[!] Lỗi kết nối PostgreSQL ({DB_HOST}:{DB_PORT}): {e}")
        raise e


def ensure_schema_exists(conn):
    """Tao schema neu chua co."""
    with conn.cursor() as cur:
        cur.execute(f"CREATE SCHEMA IF NOT EXISTS {SCHEMA_NAME};")
    conn.commit()


def write_log(message):
    """Ghi log vua print vua luu file kem timestamp."""
    import datetime
    now_str = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    formatted_msg = f"[{now_str}] {message}\n"
    print(message)
    os.makedirs(os.path.dirname(LOG_FILE), exist_ok=True)
    with open(LOG_FILE, "a", encoding="utf-8") as f:
        f.write(formatted_msg)
