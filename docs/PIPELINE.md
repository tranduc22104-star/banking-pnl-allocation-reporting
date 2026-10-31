# Kiến Trúc Pipeline Xử Lý Dữ Liệu — Báo Cáo Lãi Lỗ Vùng Và Xếp Hạng Giám Đốc Vùng

Tài liệu này mô tả chi tiết kiến trúc luồng dữ liệu của hệ thống báo cáo quản trị mảng thẻ tín dụng, chuẩn hóa theo luồng thực thi chính thức (**Pipeline sản xuất gồm bốn bước chạy theo thứ tự: Bước 1, Bước 2, Bước 3, Bước 4**). Nghiệp vụ lõi gồm hai báo cáo hàng tháng: **báo cáo lãi lỗ bảy vùng** (tổng bằng phần gán thẳng theo mã đơn vị cộng với phần phân bổ quỹ hội sở theo tỉ lệ, mọi số lấy lũy kế từ đầu năm) và **báo cáo xếp hạng giám đốc vùng** (hai trụ điểm: phát triển quy mô kinh doanh, và hiệu quả tài chính cùng rủi ro). Kho dữ liệu là PostgreSQL, schema `banking_project`, hiện có **19 bảng · 4 view · 3 thủ tục**.

---

## 1. Sơ Đồ Luồng Tổng Thể

```
┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
│ PIPELINE SẢN XUẤT  (BƯỚC 1 - BƯỚC 2 - BƯỚC 3 - BƯỚC 4, chạy đúng thứ tự)                         │
├──────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                  │
│ ┌──────────────────────────────┬──────────────────────────────┬──────────────────────────────┐   │
│ │ BƯỚC 1  ingestion/           │ BƯỚC 2  sql/dim/             │ BƯỚC 3  sql/tmp/ + sql/fct/  │   │
│ │                              │                              │                              │   │
│ │ Bóc 4 tệp Excel sang         │ Dựng bảng danh mục:          │ 6 bảng tạm 3 bước mỗi        │   │
│ │ bảng staging bằng            │ thời gian theo tháng,        │ nhánh + 2 bảng sự kiện       │   │
│ │ Python + openpyxl,           │ số nhân sự, giám đốc         │ dạng dọc + 2 thủ tục,        │   │
│ │ 4 task chạy tuần tự          │ vùng, cây 50 chỉ tiêu        │ gọi cho 5 tháng từ           │   │
│ │ qua run_all.py               │ (28 lãi lỗ + 22 xếp hạng)    │ 202301 đến 202305            │   │
│ └──────────────────────────────┴──────────────────────────────┴──────────────────────────────┘   │
│                                                                                                  │
│                                                                                                  │
│                                                                                                  │
│    ▼                            ▼                            ▼                                   │
│                                                                                                  │
│                                                                                                  │
│                                                                                                  │
│                                                                                                  │
│                                                                                                  │
│ dim_param_area      64        dim_month            5    fct_pnl_value    1.115                   │
│ stg_asm_target     420        dim_date           151    fct_asm_value    8.536                   │
│ stg_fact_txn_month 63.134     dim_sm_headcount    35    tmp_pnl_step1/2/3                        │
│ stg_fact_kpi_month 2.932.922  dim_asm             84          315/560/535                        │
│ log_data_fingerprint 15       dim_report_detail   50    tmp_xh_step1/2/3                         │
│ (~4 phút, task 04 chiếm       mỗi bảng có đúng một chủ:       1.164/105/315                      │
│ hết thời gian)                riêng `dim_asm` do        log_proc_run 65: 0 FAIL                  │
│                               `dim_asm.sql` tạo và nạp                                           │
├──────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                  │
│ BƯỚC 4  sql/rpt/  —  lớp trình bày, BẮT BUỘC chạy sau cùng                                       │
│ (Bước 3 xóa bảng sự kiện bằng DROP ... CASCADE nên kéo theo xóa view)                            │
│                                                                                                  │
│   4 view pivot từ bảng sự kiện:                                                                  │
│     v_baocao_tonghop       35 dòng · 31 cột  (lọc area_code <> '00')                             │
│     v_baocao_tonghop_vnd   35 dòng · 32 cột  (số đồng gốc, để xuất Excel)                        │
│     v_xephang_asm         388 dòng · 27 cột                                                      │
│     v_xephang_asm_vnd     388 dòng · 27 cột  (số đồng gốc, để xuất Excel)                        │
│                                                                                                  │
│   hai đường dùng số:                                                                             │
│     Power BI — Import, 4 bảng nạp + 72 measure + 5 trang  (Refresh khi có tháng mới)             │
│     Excel    — run_report.py xuất output/BC_PNL_YTD_202305.xlsx (124.428 byte)                   │
└──────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Chi Tiết Luồng Chính

> **Quy ước tên gọi nghiệp vụ:** bốn bước mang tên đúng thư mục mã nguồn — **Bước 1** là `ingestion/` (bóc tách và nạp), **Bước 2** là `sql/dim/` (danh mục), **Bước 3** là `sql/tmp/` cộng `sql/fct/` (tính toán), **Bước 4** là `sql/rpt/` (trình bày). Tháng viết theo định dạng `YYYYMM`, các tháng đang có là `202301` đến `202305`. Vùng kinh doanh mang mã một chữ cái từ `A` đến `H`; mã `'00'` là quỹ hội sở chưa phân bổ. Tiền trong bảng sự kiện lưu theo đơn vị đồng; view phục vụ Power BI đã chia sẵn cho một triệu đồng, view phục vụ xuất Excel giữ nguyên đơn vị đồng.

### Bước 1: `ingestion/` — Bóc Tách Excel Và Nạp Bảng Staging
- **Đầu vào**: 4 nguồn trong `input/`, nằm trong 5 tệp — `report_xep_hang_kinh_doanh_monthly.xlsx` (0,12 megabyte, tham số nghiệp vụ và mẫu đối soát), `fact_txn_month_raw_data_202402020504.xlsx` (1,95 megabyte, sổ cái), `fact_kpi_month_raw_data_202402020653_part1.xlsx` (83,6 megabyte) cộng `fact_kpi_month_raw_data_202402020653_part2.xlsx` (33,6 megabyte) — hai phần này là một tệp sao kê hợp đồng 117,2 megabyte tách ra để mỗi tệp dưới trần dung lượng của kho mã, `kpi_asm_data_202305.xlsx` (0,03 megabyte, chỉ tiêu từng giám đốc vùng).
- **Xử lý** (điều phối bằng `ingestion/run_all.py`, chạy tuần tự và dừng ngay nếu một task thất bại):
  - `01_load_dim_param_area.py`: bóc sheet tham số, dựng `dim_param_area` — 64 tỉnh thành quy về 8 vùng từ `A` đến `H`.
  - `02_load_stg_asm_target.py`: chuyển bảng ngang thành bảng dọc, mỗi giám đốc mỗi tháng thành một dòng (84 giám đốc nhân 5 tháng bằng 420 dòng). Danh mục giám đốc vùng `dim_asm` **không còn được tạo ở đây nữa** (từ ngày 2026-10-31), chỉ một tệp `sql/dim/dim_asm.sql` chịu trách nhiệm.
  - `03_load_stg_fact_txn_month.py`: đọc thô từng trang XML bên trong tệp sổ cái bằng `zipfile` cộng `xml.etree` (không dùng bảng tính thông thường vì tệp nặng và khai sai kích thước vùng dữ liệu), sinh sẵn cột tháng và cột tỉnh để câu ghép ở bước sau chạy nhanh.
  - `04_load_stg_fact_kpi_month.py`: cùng kỹ thuật đọc thô cho sao kê hợp đồng, duyệt lần lượt hai tệp phần và tự liệt kê sheet có trong từng tệp nên không phụ thuộc số sheet, kèm chuẩn hóa tên tỉnh.
  - Mỗi task ghi tệp trung gian vào `.staging/` và nối thêm vào `.staging/ingestion_log.txt`.
  - **Quy ước chủ bảng**: tệp nào dựng bảng thì tệp đó tạo luôn chỉ mục phục vụ thủ tục, ngay sau lệnh chép dữ liệu. Bốn tệp 01 đến 04 sinh năm chỉ mục `idx_param_city_norm`, `idx_asm_month_area`, `idx_txn_month_prov`, `idx_txn_month_acc`, `idx_kpi_month_norm`.
- **Hiệu năng**: cả bốn task chạy hết khoảng 4 phút; phần lớn thời gian nằm ở task 04 vì nguồn có gần ba triệu dòng.
- **Đầu ra**: `dim_param_area` 64 dòng, `stg_asm_target` 420 dòng, `stg_fact_txn_month` 63.134 dòng (62.953 dòng gán nhãn đơn vị kinh doanh cộng 181 dòng hội sở), `stg_fact_kpi_month` 2.932.922 dòng. Bảng điều khiển `log_data_fingerprint` 15 dòng (ba nguồn nhân năm tháng, dùng để phát hiện dữ liệu mới) do `run_report.py` dựng khi chạy báo cáo; tên cũ của bảng là `stg_fingerprint`, đổi ngày 2026-10-31 vì bảng này không chứa dữ liệu nạp thô.

### Bước 2: `sql/dim/` — Dựng Bảng Danh Mục
- **Đầu vào**: các bảng staging do Bước 1 tạo ra; chạy trong DBeaver sau khi đặt `SET search_path TO banking_project, public;`.
- **Xử lý** (3 tệp, tổng 277 dòng mã — mỗi bảng đúng một chủ, kiểm lại ngày 2026-10-31):
  - `dim_month_headcount.sql` (130 dòng, tên cũ `DIM_DATE_PNL_ASM.sql` — đổi ngày 2026-10-31 vì tệp không còn đối tượng lãi lỗ hay ASM nào): dựng hai trục thời gian (tháng và ngày) và bảng số nhân sự, kết thúc bằng `CALL sp_load_dim();`. `dim_month` giữ **đúng hạt tháng**, mỗi dòng mang theo `ngay_dau_thang`, `ngay_cuoi_thang` (ngày chốt số của tháng) và `so_ngay_trong_thang`; các ngày này **tính tự động** từ `nam` và `thang` bằng `make_date` trong `sp_load_dim()`, không nhập tay, thêm tháng mới chỉ cần đưa mã tháng vào danh sách. Danh sách tháng chỉ ghi một chỗ. Lệnh `DROP TABLE IF EXISTS dim_asm CASCADE;` từng có trong tệp này đã gỡ ngày 2026-10-31: nó là nguyên nhân làm mất `v_xephang_asm`, `v_xephang_asm_vnd` và khóa ngoại `fk_fct_asm_dim_asm` mỗi khi chạy lại riêng lớp dim (xem `docs/LOI_THUONG_GAP.md` mục 42).
  - `dim_date` cùng tệp (151 dòng, thêm ngày 2026-10-31): **một dòng một ngày**, `date_key` dạng 20230115, kèm `ngay` (duy nhất), `nam`, `thang`, `ngay_trong_thang`, `month_key`, `so_thu` theo chuẩn ISO (1 là thứ hai, 7 là chủ nhật), `ten_thu` và `la_ngay_cuoi_thang`. Dòng ngày sinh bằng `generate_series(ngay_dau_thang, ngay_cuoi_thang, INTERVAL '1 day')` chạy trên từng dòng `dim_month` ngay trong `sp_load_dim()`, nên không có ngày nào nhập tay và tháng 2 năm nhuận tự ra 29 dòng. **Không dàn ngày vào `dim_month`**: ba quan hệ `month_key` một-nhiều trong mô hình Power BI (hai view báo cáo và `dim_sm_headcount`) đều trỏ vào `dim_month`; bảng thành nhiều dòng một tháng sẽ gãy cả ba quan hệ và nhân đôi số. `dim_date` cũng không khai báo khoá ngoại sang `dim_month` — chỉ có index `idx_dim_date_month` — để kho giữ đúng quy ước một khoá ngoại thật.
  - `dim_asm.sql` (48 dòng): **chủ duy nhất** của `dim_asm` — dựng bảng từ `stg_asm_target`, cấp `asm_id` theo thứ tự mã vùng rồi thư điện tử, có khóa chính, khóa duy nhất trên thư điện tử và chỉ mục theo mã vùng. Chạy lại nhiều lần không sinh dòng trùng nhờ mệnh đề `ON CONFLICT (email) DO UPDATE`.
  - `dim_report_detail.sql` (99 dòng): dựng cây chỉ tiêu `dim_report_detail`, nút gốc mang `parent_id = -1`, gồm 28 chỉ tiêu lãi lỗ và 22 chỉ tiêu xếp hạng, mỗi chỉ tiêu kèm đơn vị và thứ tự hiển thị.
- **Kiểm chứng**: `dim_month` 5 dòng và ngày chốt số đúng từng tháng (31 · 28 · 31 · 30 · 31 ngày, tháng 2 năm 2023 không nhuận), `dim_date` 151 dòng chia đúng 31 · 28 · 31 · 30 · 31 theo `month_key`, `date_key` duy nhất, không dòng nào có `month_key` mồ côi, `la_ngay_cuoi_thang` đúng 5 dòng và trùng `ngay_cuoi_thang` của `dim_month`, đủ 7 thứ trong tuần (22 · 22 · 22 · 21 · 21 · 21 · 22), `dim_sm_headcount` 35 dòng, `dim_asm` 84 dòng, `dim_report_detail` 50 dòng, `dim_param_area` 64 dòng. Chạy tệp hai lần liên tiếp vẫn 151 dòng.
- **Đầu ra**: 6 bảng `dim_` dùng chung cho nhánh tính toán ở Bước 3 và cho lớp trình bày ở Bước 4. `dim_date` hiện **chưa được nạp vào mô hình Power BI** (mô hình chỉ nạp bốn bảng từ kho; ba bảng ngày trong mô hình là bảng ẩn do tính năng tự động ngày giờ dựng, không phải `dim_date`); muốn dùng ngày theo nghiệp vụ thì nạp thêm bảng này và tạo quan hệ `dim_date[month_key]` nhiều-một sang `dim_month[month_key]`.

### Bước 3: `sql/tmp/` và `sql/fct/` — Tính Phân Bổ Và Xếp Hạng
- **Đầu vào**: bảng staging (Bước 1) cộng bảng danh mục (Bước 2).
- **Xử lý phần cấu trúc** — hai tệp trong `sql/tmp/` (tổng 131 dòng) khai báo sáu bảng tạm. Phần khai báo này đã dời ra khỏi thân thủ tục từ ngày 2026-10-30, vì vậy **phải chạy trước lệnh gọi thủ tục**:
  - `tmp_pnl_step.sql` (60 dòng): `tmp_pnl_step1_driver`, `tmp_pnl_step2_ratio`, `tmp_pnl_step3_gl_split`, mỗi bảng kèm một chỉ mục theo tháng.
  - `tmp_xh_step.sql` (71 dòng): `tmp_xh_step1_asm_avg`, `tmp_xh_step2_npl_area`, `tmp_xh_step3_fin_area`, cũng kèm chỉ mục theo tháng.
  - Quy ước đánh số: **STEP1 đến STEP3 ghi bảng tạm, STEP4 trở đi ghi bảng sự kiện**; cả sáu bảng tạm đều dạng dọc với bốn cột `month_key`, đối tượng, `report_id`, `value`. Số liệu sai ở bước nào thì truy vấn đúng bảng của bước đó, không cần đọc mã thủ tục.
- **Xử lý phần tính toán** — hai tệp trong `sql/fct/` (tổng 826 dòng):
  - `fct_pnl_allocation.sql` (493 dòng): tạo bảng `log_proc_run` để theo dõi từng bước chạy, bảng sự kiện `fct_pnl_value`, và thủ tục `sp_baocao_tonghop(p_month)` gồm 6 bước (xóa dữ liệu tháng, gom 9 chỉ số dẫn xuất, lập 16 tỉ lệ phân bổ, tách sổ cái thành phần gán thẳng và quỹ hội sở, cộng hai quy tắc thành từng chỉ tiêu, chốt các chỉ số tổng hợp).
  - `fct_xephang_asm.sql` (333 dòng): tạo bảng sự kiện `fct_asm_value` và thủ tục `sp_xephang_asm(p_month)` gồm 7 bước (xóa dữ liệu tháng, tính bình quân lũy kế từng giám đốc, tính nợ xấu theo vùng, tính bốn chỉ số tài chính cùng hạng của bảy vùng, xếp hạng trụ phát triển quy mô, cộng trụ hiệu quả tài chính và rủi ro, chốt điểm tổng và hạng chung cuộc).
  - Gọi thủ tục cho từng tháng theo thứ tự từ nhỏ đến lớn vì mọi số là lũy kế: `sp_baocao_tonghop` cho `202301` đến `202305`, sau đó `sp_xephang_asm` cho `202301` đến `202305` vì bảng xếp hạng đọc số liệu từ nhánh lãi lỗ.
- **Kiểm chứng** (số liệu tra trực tiếp ngày 2026-10-31):

  | Bảng | Dòng | Chi tiết |
  |---|---|---|
  | `tmp_pnl_step1_driver` | 315 | 7 vùng nhân 5 tháng nhân 9 chỉ số dẫn xuất |
  | `tmp_pnl_step2_ratio` | 560 | 7 vùng nhân 5 tháng nhân 16 tỉ lệ, mỗi chỉ tiêu có tổng tỉ lệ bằng 1 |
  | `tmp_pnl_step3_gl_split` | 535 | 16 mã sổ cái quỹ hội sở cộng 13 mã gán thẳng theo vùng, nhân 5 tháng |
  | `fct_pnl_value` | 1.115 | 223 dòng mỗi tháng (7 vùng nhân 28 chỉ tiêu cộng quỹ hội sở 27 chỉ tiêu) |
  | `tmp_xh_step1_asm_avg` | 1.164 | bình quân lũy kế từng giám đốc theo 3 chỉ số dẫn xuất |
  | `tmp_xh_step2_npl_area` | 105 | 7 vùng nhân 5 tháng nhân 3 mã (204 tỉ lệ phần trăm, 231 tử số, 232 mẫu số) |
  | `tmp_xh_step3_fin_area` | 315 | 7 vùng nhân 5 tháng nhân 9 mã từ 211 đến 219 |
  | `fct_asm_value` | 8.536 | 1.628 · 1.628 · 1.672 · 1.760 · 1.848 dòng theo tháng |
  | `log_proc_run` | 65 | 10 dòng khởi đầu cộng 55 dòng thành công, không có dòng thất bại |

- **Số đối chiếu cố định**: tổng chỉ tiêu A (mã 70, cột `lntt_trieu_dong` của view) của bảy vùng bằng **92.226,35 triệu đồng** ở tháng `202302` và **250.450,06 triệu đồng** ở tháng `202305`; người giữ hạng nhất là **Hoàng Văn Nam** với **34 điểm** ở tháng `202302` và **36 điểm** ở tháng `202305`.

### Bước 4: `sql/rpt/` — Bốn View Và Hai Đường Trình Bày
- **Đầu vào**: hai bảng sự kiện và bảng danh mục. **Bắt buộc chạy sau cùng** vì Bước 3 xóa bảng sự kiện bằng lệnh `DROP TABLE ... CASCADE`, kéo theo xóa mọi view phụ thuộc.
- **Xử lý** (2 tệp, tổng 187 dòng):
  - `rpt_pnl_view.sql` (101 dòng): tạo `v_baocao_tonghop` (31 cột, lọc `area_code <> '00'` để không cộng trùng quỹ hội sở) và `v_baocao_tonghop_vnd` (32 cột, số đồng gốc, tên cột khớp bảng ngang cũ để xuất Excel không phải đổi công thức).
  - `rpt_xephang_view.sql` (86 dòng): tạo `v_xephang_asm` (27 cột, có tên giám đốc vùng) và `v_xephang_asm_vnd` (27 cột, số đồng gốc).
  - View phân tích nguyên nhân từng tồn tại đã bị xóa khỏi cơ sở dữ liệu ngày 2026-10-30; bốn view là toàn bộ lớp trình bày. Lưu ý thêm: `v_asm_ltn_thang` **không tồn tại**, muốn xem chỉ tiêu tăng mới trong tháng thì truy vấn trực tiếp `stg_asm_target`.
- **Hiệu năng**: bốn view trả 35 · 35 · 388 · 388 dòng đúng như số đã ghi ở mục trên; mô hình Power BI đang mở đọc `v_baocao_tonghop` 32 cột và `v_xephang_asm` 28 cột, chênh lệch một cột ở mỗi bảng là cột số dòng do Power BI tự thêm khi nạp, không phải lệch cấu trúc.
- **Đầu ra và hai đường dùng số**:
  - **Đường Excel**: `py ingestion/run_report.py` đọc `log_data_fingerprint` để tự phát hiện tháng mới, gọi lại hai thủ tục theo lũy kế từ tháng thay đổi đến tháng gần nhất, rồi xuất `output/BC_PNL_YTD_202305.xlsx` (124.428 byte) gồm sheet lãi lỗ, sheet xếp hạng, sheet `KPI_ASM_DATA`, sheet `ThamSo`; ba sheet tài liệu lấy nguyên văn từ tệp mẫu.
  - **Đường Power BI**: `output/Bao cao quan tri va phan tich (Ngan Hang).pbix` (2.944.418 byte, bản người dùng lưu lúc 15:30 ngày 2026-10-31) dùng chế độ **Import**, không phải truy vấn trực tiếp. Mô hình có **9 bảng**: bốn bảng nạp từ kho là `v_baocao_tonghop`, `v_xephang_asm`, `dim_month`, `dim_sm_headcount`, cộng hai bảng nội bộ do DAX dựng — `LAI LO (Visuals & DAX)` (71 measure) và `Data Glossary` (một measure) — cộng **ba bảng ẩn do tính năng tự động ngày giờ của phần mềm dựng** (một `DateTableTemplate` và hai `LocalDateTable`), chi tiết ở mục 49 của `docs/LOI_THUONG_GAP.md`. Tổng **72 measure** và **5 trang**: TỔNG QUAN BÁO CÁO (1920 × 1755), TỪ ĐIỂN DỮ LIỆU (1920 × 1080), KẾT QUẢ KINH DOANH (3000 × 1900), XẾP HẠNG QUẢN LÝ VÙNG (2300 × 1700), PHÂN TÍCH CHUYÊN SÂU VÀ ĐƯA RA KẾT LUẬN (1920 × 1500). Con số 73 measure hay gặp ở các bản tài liệu cũ là do đếm cả `__Default measure` — đối tượng engine tự thêm, không phải measure nghiệp vụ. Vì là Import nên số đã nằm trong bộ nhớ mô hình, xoay lựa chọn tháng ra số ngay; khi cơ sở dữ liệu có tháng mới phải bấm **Refresh** trong Power BI Desktop. Bốn bảng vừa được Refresh lúc **13:04 ngày 31-10-2026**, nên `dim_month` trong mô hình **đã có đủ ba cột ngày** và `so_ngay_trong_thang` trả 31 · 28 · 31 · 30 · 31 theo tháng; `dim_date` của kho **vẫn chưa nạp**, muốn kiểm soát ngày theo nghiệp vụ thì nạp bảng này và tạo quan hệ `dim_date[month_key]` nhiều-một sang `dim_month[month_key]`, đồng thời tắt tính năng tự động ngày giờ để bỏ ba bảng ẩn.

---

## 3. Hướng Dẫn Vận Hành

Môi trường kiểm chứng: Python 3.10.11 (`psycopg2-binary` 2.9.13, `openpyxl` 3.1.5) và PostgreSQL 16.14.

### 3.1. Chạy Luồng Đầy Đủ (Mặc Định)
```bash
pip install -r requirements.txt
py ingestion/run_all.py
```
Tiếp đó dựng mã SQL trong DBeaver **theo đúng thứ tự**: `sql/dim/` (ba tệp) → `sql/tmp/` (hai tệp) → `sql/fct/fct_pnl_allocation.sql` rồi gọi `sp_baocao_tonghop` cho từng tháng từ 202301 đến 202305 → `sql/fct/fct_xephang_asm.sql` rồi gọi `sp_xephang_asm` cho từng tháng (bảng xếp hạng đọc số từ nhánh lãi lỗ nên chạy sau) → cuối cùng `sql/rpt/` (hai tệp). Thứ tự này là bắt buộc vì đảo chỗ sẽ vỡ ở một trong ba điểm: `dim_asm.sql` cần bảng staging đã có dữ liệu, lệnh gọi thủ tục cần sáu bảng tạm đã khai báo cấu trúc, `sql/rpt/` cần bảng sự kiện vừa tạo lại xong. Mỗi tệp `sql/` đã có sẵn `SET search_path TO banking_project, public;`; viết script gọi thủ tục riêng thì phải đặt lại dòng đó, vì thân thủ tục tham chiếu bảng không kèm tên lược đồ.
```bash
py ingestion/run_report.py
```
Trên Windows, `ingestion/run_pipeline.bat` chạy đúng `run_all.py` kèm dừng màn hình để xem log. Số kiểm sau khi chạy không lặp lại ở đây mà ghi trong `docs/HIEN_TRANG_HE_THONG.md`: số dòng 19 bảng, lợi nhuận trước thuế toàn hàng tháng 202302 bằng 92.226,347 triệu đồng và người giữ hạng nhất bảng xếp hạng ở mục **Dữ liệu trong kho**; bốn view 35 · 35 · 388 · 388 ở mục **Stack và kết nối**; các truy vấn kiểm ở mục **Cách chạy**.

### 3.2. Ba Đường Gọn Khi Không Phải Chạy Toàn Bộ
- **Tính lại một tháng:** `CALL sp_baocao_tonghop(202305);` rồi `CALL sp_xephang_asm(202305);` — hai thủ tục tự xóa dữ liệu tháng đó trước khi ghi nên không ảnh hưởng tháng khác, nhưng vẫn phải gọi lãi lỗ trước, xếp hạng sau.
- **Chỉ xuất báo cáo cho một tháng đã có số:** chạy `py ingestion/run_report.py` rồi nhập tháng tại dòng hỏi, phím Enter lấy tháng gần nhất.
- **Đối soát Power BI với kho:** mở tệp `.pbix` trong Power BI Desktop, lấy cổng dịch vụ `msmdsrv` từ Task Manager, chạy `powershell -File ingestion/export_pbi.ps1 -Port <cổng> -Catalog <mã database>` rồi `python ingestion/audit_pbi_vs_db.py`; tệp thứ hai in bảng `chỉ tiêu | Power BI | SQL | lệch`, dung sai 0,02 triệu đồng cho giá trị tiền và 1e-4 cho tỉ lệ.

> **Ba thứ nằm ngoài kho mã:** `.staging/` (CSV trung gian, log nạp liệu và CSV đối soát — pipeline tự sinh, đã chặn trong `.gitignore`, xóa cũng được vì chạy lại sẽ tạo tiếp); mật khẩu kết nối chỉ nằm trong `ingestion/db_config.py`, khi bàn giao chỉ giao kèm `ingestion/db_config.example.py`; và tệp sao kê hợp đồng gốc 117,2 megabyte đã tách thành hai phần dưới trần dung lượng của GitHub, dữ liệu từng sheet giữ nguyên từng byte — chuyện dung lượng lưu trữ, không phải bản quyền (kể ở `input/README.md` và mục 41 của `docs/LOI_THUONG_GAP.md`).
