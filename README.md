<div align="center">

# Xây Dựng Báo Cáo Quản Trị Kết Quả Kinh Doanh Thẻ Tín Dụng Và Xếp Hạng Năng Lực Kinh Doanh Của Quản Lý Vùng

**Ngôn ngữ / Language**: **Tiếng Việt** · [English](README_eng.md)

[Email](mailto:tranduc22104@gmail.com) · [LinkedIn](https://www.linkedin.com/in/tr%E1%BA%A7n-ng%E1%BB%8Dc-%C4%91%E1%BB%A9c-48b3a7439/)

<p>
  <img src="https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white">
  <img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white">
  <img src="https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black">
  <img src="https://img.shields.io/badge/Excel-217346?style=for-the-badge&logo=microsoftexcel&logoColor=white">
</p>

</div>

## 📑 Mục Lục

1. [🏢 Bối Cảnh Kinh Doanh Và Yêu Cầu Quản Trị](#1--bối-cảnh-kinh-doanh-và-yêu-cầu-quản-trị)
2. [🎯 Phân Tích Yêu Cầu Và Thiết Kế Đầu Ra Báo Cáo](#2--phân-tích-yêu-cầu-và-thiết-kế-đầu-ra-báo-cáo)
3. [🔍 Khảo Sát Nguồn Dữ Liệu Và Đánh Giá Mức Độ Đáp Ứng](#3--khảo-sát-nguồn-dữ-liệu-và-đánh-giá-mức-độ-đáp-ứng)
4. [🔄 Thiết Kế Quy Trình Xử Lý Và Kho Dữ Liệu](#4--thiết-kế-quy-trình-xử-lý-và-kho-dữ-liệu)
5. [🧮 Xây Dựng Logic Tính Toán Và Chỉ Tiêu Quản Trị](#5--xây-dựng-logic-tính-toán-và-chỉ-tiêu-quản-trị)
6. [🧪 Kiểm Tra Và Đối Soát Dữ Liệu](#6--kiểm-tra-và-đối-soát-dữ-liệu)
7. [🖥️ Thiết Kế Và Trực Quan Hóa Báo Cáo Trên Power BI](#7-️-thiết-kế-và-trực-quan-hóa-báo-cáo-trên-power-bi)
8. [📊 Kết Quả Phân Tích Và Đề Xuất Quản Trị](#8--kết-quả-phân-tích-và-đề-xuất-quản-trị)
9. [📚 Kinh Nghiệm Triển Khai Thực Chiến](#9--kinh-nghiệm-triển-khai-thực-chiến)
10. [🛠️ Công Nghệ Sử Dụng](#10-️-công-nghệ-sử-dụng)
11. [📂 Cấu Trúc Thư Mục Dự Án](#11--cấu-trúc-thư-mục-dự-án)
12. [🔒 Nguồn Dữ Liệu Và Quyền Sử Dụng](#12--nguồn-dữ-liệu-và-quyền-sử-dụng)
13. [📖 Tài Liệu Bàn Giao](#13--tài-liệu-bàn-giao)
14. [👤 Tác Giả](#14--tác-giả)

---

## 1. 🏢 Bối Cảnh Kinh Doanh Và Yêu Cầu Quản Trị

Trong hoạt động kinh doanh thẻ tín dụng của ngân hàng, mạng lưới phân phối được tổ chức thành **7 vùng kinh doanh**, vận hành dưới sự quản lý trực tiếp của đội ngũ từ **74 đến 84 quản lý vùng (Area Sales Manager - ASM)** tuỳ từng thời kỳ. Trong công tác điều hành định kỳ, Ban Lãnh Đạo luôn phải đối mặt với những vấn đề quản trị nan giải phát sinh từ phương pháp tổng hợp và báo cáo truyền thống:

1. **Hiệu quả tài chính thực chất bị che mờ:**
   Trên hệ thống sổ cái kế toán, các vùng kinh doanh trực tiếp ghi nhận thu nhập từ lãi vay và phí mở thẻ. Tuy nhiên, các khoản chi phí lớn nhất cấu thành hoạt động như chi phí vốn huy động, chi phí tiếp thị toàn ngân hàng, chi phí công nghệ lõi và lương thưởng của các phòng ban hỗ trợ lại được hạch toán tập trung tại quỹ Hội sở. Khi chưa có phương pháp phân bổ chi phí hợp lý, báo cáo bề nổi luôn cho thấy tất cả các vùng đều có lãi, dẫn đến nguy cơ che giấu những vùng thực tế đang hoạt động kém hiệu quả và ăn mòn lợi nhuận chung.

2. **Cơ chế đánh giá năng lực đội ngũ quản lý vùng tiềm ẩn rủi ro tín dụng:**
   Nếu chỉ dựa trên chỉ tiêu doanh số giải ngân mới hoặc số lượng thẻ phát hành, các quản lý vùng sẽ có xu hướng nới lỏng khẩu vị rủi ro và tiêu chuẩn thẩm định tín dụng để đạt số lượng ngắn hạn. Hậu quả là doanh số tăng trưởng nhanh trong vài tháng đầu, nhưng tỷ lệ nợ xấu và chi phí trích lập dự phòng sẽ phình to ở các kỳ tiếp theo.

3. **Hạn chế của phương pháp báo cáo hiện tại:**
   Báo cáo kế toán truyền thống chỉ cung cấp số lũy kế năm (YTD) dạng tĩnh, thiếu khả năng phân rã biến động theo từng tháng, không phân biệt được lợi nhuận tăng do kinh doanh cốt lõi khởi sắc hay do biến động trích lập dự phòng rủi ro.

Từ bối cảnh đó, Ban Lãnh Đạo đặt ra 5 câu hỏi quản trị trọng tâm cần được giải quyết:

| Vấn đề quản trị | Câu hỏi cần trả lời | Mục tiêu cần đạt |
|---|---|---|
| **Hiệu quả kinh doanh** | Vùng nào đang thực sự có lợi nhuận sau khi gánh vác chi phí chung? | Xác định chính xác lãi lỗ 7 vùng sau phân bổ Hội sở |
| **Biến động lợi nhuận** | Nguyên nhân tăng giảm lợi nhuận hàng tháng đến từ đâu? | Bóc tách dòng chảy lợi nhuận thành các cấu phần thu – chi |
| **Chất lượng tín dụng** | Vùng nào đang có rủi ro nợ xấu cao đe dọa an toàn vốn? | Giám sát dư nợ theo 5 nhóm nợ và tỷ lệ nợ xấu từng vùng |
| **Hiệu quả quản lý vùng** | Quản lý vùng nào có kết quả kinh doanh và năng lực quản trị rủi ro tốt? | Xây dựng hệ thống xếp hạng cân bằng đa chiều cho 74 - 84 nhân sự |
| **Công tác điều hành** | Cần theo dõi thông tin theo hình thức nào để ra quyết định kịp thời? | Xây dựng hệ thống dashboard quản trị trực quan và tệp đối soát chuẩn |

---

## 2. 🎯 Phân Tích Yêu Cầu Và Thiết Kế Đầu Ra Báo Cáo

Khi tiếp nhận đề bài từ Ban Lãnh Đạo, khó khăn lớn nhất là yêu cầu chỉ dừng ở mục tiêu định hướng quản trị mà không có sẵn biểu mẫu hay đặc tả kỹ thuật chi tiết. Do đó, bước đi đầu tiên là áp dụng tư duy **Output-First (thiết kế ngược từ nhu cầu ra quyết định)**: tự đặt câu hỏi Ban Lãnh Đạo cần nhìn thấy những thông tin cốt lõi nào để điều hành, từ đó xác định cấu trúc "đầu ra" dữ liệu cụ thể trước khi đi tìm nguồn dữ liệu.

### Bảng chuyển giao từ yêu cầu quản trị sang đầu ra báo cáo:

| Yêu cầu quản trị | Đầu ra cần xây dựng | Các thông tin cần hiển thị |
|---|---|---|
| **Theo dõi lãi lỗ thực chất** | Báo cáo kết quả kinh doanh 7 vùng | Thu nhập thẻ thuần, chi phí vốn, chi phí hoạt động, chi phí dự phòng, lợi nhuận trước thuế (PBT) |
| **Phân tích biến động** | Báo cáo dòng chảy lợi nhuận từng tháng | Chênh lệch tháng (MoM), bóc tách 6 cấu phần đóng góp vào mức tăng/giảm lợi nhuận |
| **Theo dõi rủi ro tín dụng** | Ma trận Lợi nhuận – Rủi ro (Quadrant Matrix) | Phân loại 7 vùng vào 4 kịch bản quản trị theo 2 trục: Lợi nhuận phát sinh và Tỷ lệ nợ xấu |
| **Đánh giá quản lý vùng** | Bảng xếp hạng quản lý vùng (ASM Scorecard) | Đánh giá 8 chỉ số trên 2 trụ cột (Quy mô kinh doanh và Hiệu quả tài chính/Kiểm soát rủi ro) |
| **Hỗ trợ điều hành đa cấp** | Hệ sinh thái báo cáo tích hợp | Dashboard Power BI tương tác tức thì cho lãnh đạo; tệp Excel chuẩn đối soát cho kế toán |

### Sơ đồ luồng tư duy từ yêu cầu quản trị đến hệ thống báo cáo:

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                                YÊU CẦU CỦA BAN LÃNH ĐẠO                                │
│   1. Đo lường lãi lỗ thực chất 7 vùng    │   2. Đánh giá công bằng năng lực quản lý ASM│
└───────────────────────────────────┬────────────────────────────────────────────────────┘
                                    │ (Tư duy thiết kế Output-First)
                                    ▼
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                              CÁC NHÓM ĐẦU RA DỮ LIỆU CẦN THIẾT                         │
├────────────────────────────────────────┬───────────────────────────────────────────────┤
│ NHÓM 1: QUẢN TRỊ KẾT QUẢ KINH DOANH    │ NHÓM 2: ĐÁNH GIÁ NĂNG LỰC QUẢN LÝ VÙNG        │
│ • Thu nhập gộp, chi phí vốn, chi phí   │ • Chỉ tiêu bán hàng cá nhân: Cho vay mới, thẻ │
│   hoạt động, trích lập dự phòng        │   phát sinh dư nợ, tỷ lệ duyệt hồ sơ          │
│ • Phân bổ chi phí Hội sở theo tiêu thức│ • Trách nhiệm địa bàn: Tỷ lệ nợ xấu vùng,     │
│ • Phân rã biến động lợi nhuận từng tháng│   CIR vùng, Margin, Lợi nhuận bình quân/ASM   │
└───────────────────────────────────┬────────────────────────────────────────────────────┘
                                    │ (Chuyển hoá thành giao diện trực quan)
                                    ▼
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                         HỆ THỐNG BÁO CÁO QUẢN TRỊ POWER BI (5 TRANG)                   │
│ • Trang 1: Tổng quan báo cáo           │ • Trang 4: Bảng xếp hạng quản lý vùng (ASM)   │
│ • Trang 2: Từ điển dữ liệu quản trị    │ • Trang 5: Phân tích chuyên sâu & Chẩn đoán   │
│ • Trang 3: Kết quả kinh doanh lãi lỗ   │ + Báo cáo Excel 7 sheet đối soát kế toán      │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

### Phân định vai trò hai nhóm chỉ tiêu:
- **Nhóm chỉ tiêu theo dõi kết quả kinh doanh (P&L, NPL vùng, CIR, Margin):** Phản ánh sức khỏe tài chính tổng thể của từng vùng địa lý sau khi đã hấp thụ đầy đủ chi phí gián tiếp từ Hội sở, phục vụ quyết định phân bổ nguồn vốn và hạn mức tín dụng.
- **Nhóm chỉ tiêu đánh giá quản lý vùng (8 chỉ số xếp hạng ASM):** Kết hợp giữa kết quả bán hàng cá nhân và kỷ luật kiểm soát rủi ro địa bàn nhằm tạo động lực thi đua lành mạnh, triệt tiêu động cơ nới lỏng tiêu chuẩn phê duyệt để chạy theo số lượng ngắn hạn.

---

## 3. 🔍 Khảo Sát Nguồn Dữ Liệu Và Đánh Giá Mức Độ Đáp Ứng

Ngân hàng không có sẵn một kho dữ liệu tập trung hay một bảng số liệu duy nhất đáp ứng ngay các yêu cầu đầu ra đã thiết kế. Sau khi đã định hình rõ bức tranh đầu ra cần đạt được, bước tiếp theo là chủ động đi khảo sát, tìm kiếm nguồn dữ liệu từ nhiều phòng ban nghiệp vụ khác nhau để thu thập từng mảnh ghép thông tin:

| Phòng ban cung cấp | Nguồn dữ liệu | Quy mô | Vai trò đáp ứng đầu ra |
|---|---|---:|---|
| **Khối Kế toán & Tài chính** | Sổ cái tài khoản kế toán (`fact_txn_month`) | **63.134** bút toán | Cung cấp số liệu thu - chi thực tế; gồm 62.953 dòng gắn mã tỉnh thành (gán trực tiếp cho vùng) và 181 dòng chi phí chung hạch toán tại Hội sở (mã tỉnh `'00'`, cần phân bổ). |
| **Khối Vận hành Thẻ** | Sao kê hợp đồng thẻ tín dụng (`fact_kpi_month`) | **2.932.914** dòng | Cung cấp toàn bộ dư nợ theo 5 nhóm nợ, nợ đã xử lý rủi ro (write-off) và doanh số từng hợp đồng qua 5 tháng; làm căn cứ tính tỷ lệ nợ xấu và tạo tiêu thức phân bổ chi phí Hội sở. |
| **Khối Quản lý Mạng lưới** | Bảng chỉ tiêu kinh doanh (`kpi_asm_data`) | **420** dòng | Cung cấp kết quả kinh doanh cá nhân: doanh số giải ngân mới, số thẻ hoạt động và tỷ lệ duyệt hồ sơ của 74 đến 84 quản lý vùng theo tháng để phục vụ xếp hạng. |
| **Phòng Kế hoạch & Quản trị Dữ liệu** | Bảng tham số địa bàn và biểu mẫu đối chiếu | **64** tỉnh thành | Cung cấp quy tắc quy đổi 64 tỉnh thành về 8 vùng địa lý (Hội sở `'A'` và 7 vùng kinh doanh `'B'..'H'`) kèm mẫu biểu định dạng báo cáo. |

### Đánh giá mức độ đáp ứng của dữ liệu (Gap Analysis):

| Đầu ra cần xây dựng | Dữ liệu yêu cầu | Dữ liệu hiện có | Đánh giá mức độ đáp ứng |
|---|---|---|---|
| **Báo cáo lãi lỗ 7 vùng** | Thu nhập, chi phí chi tiết, mã tỉnh, mã tài khoản kế toán | Sổ cái kế toán và Bảng tham số vùng | **Đáp ứng tốt**, nhưng 181 dòng chi phí Hội sở cần thuật toán phân bổ gián tiếp |
| **Báo cáo nợ xấu & rủi ro** | Dư nợ phân loại theo 5 nhóm nợ, nợ write-off | Sao kê hợp đồng thẻ 2,93 triệu dòng | **Đáp ứng tốt** ở cấp độ toàn vùng qua 5 tháng |
| **Xếp hạng quản lý vùng** | Chỉ tiêu kinh doanh cá nhân và nhân sự | Bảng chỉ tiêu kinh doanh ASM | **Đáp ứng đầy đủ** cho 8 chỉ số theo thiết kế |
| **Đánh giá nợ xấu từng cá nhân ASM** | Dư nợ xấu gắn trực tiếp theo mã nhân sự ASM | Dữ liệu thẻ chỉ có mã chi nhánh, không có mã ASM | **Chưa đáp ứng chi tiết**: Nợ xấu và chỉ số tài chính tính ở cấp vùng và dùng chung cho các ASM cùng vùng |

### Nhận diện ba rào cản kỹ thuật của dữ liệu thô:
1. **Dữ liệu sao kê hợp đồng thẻ vượt quá giới hạn Excel:** Tệp dữ liệu có gần 3 triệu dòng, nặng **117,2 MB** khiến các công cụ xử lý bảng tính thông thường bị treo hoặc tràn bộ nhớ.
2. **Dữ liệu chỉ tiêu tổ chức theo dạng ngang (Wide):** Bảng chỉ tiêu quản lý vùng trải dài các cột tháng sang ngang, không thể nạp trực tiếp vào cơ sở dữ liệu quan hệ để join với các bảng sự kiện khác.
3. **Bất đồng bộ trong dữ liệu danh mục:** Tên địa danh giữa các phòng ban bị lệch chuẩn ký tự (ví dụ: sao kê ghi "Bà Rịa - Vũng Tàu" nhưng bảng tham số viết "Vũng Tàu"), nếu ghép trực tiếp sẽ làm mất hơn **36.000 hợp đồng thẻ** khi tính toán tỷ lệ nợ xấu của vùng Đông Nam Bộ.

---

## 4. 🔄 Thiết Kế Quy Trình Xử Lý Và Kho Dữ Liệu

Để chuyển hoá dữ liệu thô từ nhiều nguồn thành hệ thống báo cáo hoàn chỉnh, một quy trình xử lý tự động khép kín qua 4 giai đoạn được thiết kế và triển khai:

<div align="center">

![Quy trình xử lý kỹ thuật — 4 giai đoạn](images/quy-trinh.png)

</div>

### Chi tiết 4 bước kỹ thuật trong pipeline:

- **Bước 1 – Data Ingestion (Thu thập và trích xuất bằng Python):**
  Sử dụng thư viện Python chuyên dụng (`openpyxl` kết hợp xử lý luồng `zipfile` + `xml.etree`) để đọc trực tiếp tệp sao kê hợp đồng thẻ nặng **117,2 MB** với gần 3 triệu dòng mà không làm tràn bộ nhớ RAM. Thực hiện unpivot bảng chỉ tiêu kinh doanh ASM từ dạng ngang (Wide) thành dạng dọc (Tall) chuẩn quan hệ.

- **Bước 2 – Data Cleaning (Làm sạch và chuẩn hoá dữ liệu):**
  Kiểm tra và ép kiểu dữ liệu nghiêm ngặt; xử lý các bản ghi NULL; áp dụng hàm chuẩn hoá chuỗi tiếng Việt không dấu (`pos_city_norm`) để đồng nhất tên địa danh giữa sao kê thẻ và bảng tham số, giải quyết triệt để rủi ro mất 36.000 hợp đồng thẻ. Nạp dữ liệu sạch vào 3 bảng `staging` (`stg_fact_kpi_month`, `stg_fact_txn_month`, `stg_asm_target`) và 2 bảng danh mục vùng (`dim_area`, `dim_param_area`).

- **Bước 3 – Data Warehouse Design (Mô hình Star Schema trong PostgreSQL):**
  Kho dữ liệu được tổ chức chuẩn mực theo phương pháp Kimball trong schema `banking_project` gồm **19 bảng và 4 `view`**:
  - **7 bảng chiều (`dim_`):** `dim_area` (8 vùng), `dim_param_area` (64 tỉnh thành), `dim_month` (5 tháng), `dim_asm` (84 nhân sự), `dim_report_detail` (50 chỉ tiêu), `dim_month_headcount` (35 dòng), `dim_sm_headcount` (35 dòng).
  - **3 bảng nạp thô (`stg_`):** `stg_fact_kpi_month` (2.932.922 dòng), `stg_fact_txn_month` (63.134 dòng), `stg_asm_target` (420 dòng).
  - **6 bảng tạm tính toán (`tmp_`):** Cùng cấu trúc dọc (`month_key`, `area_code`, `report_id`, `value`) phục vụ tính trung gian cho P&L (`tmp_pnl_step1..3`) và Xếp hạng (`tmp_xh_step1..3`).
  - **2 bảng sự kiện cốt lõi (`fct_`):** `fct_pnl_value` (1.115 dòng) lưu kết quả tài chính 7 vùng và `fct_asm_value` (8.536 dòng) lưu thứ hạng chi tiết từng quản lý vùng qua 5 tháng.
  - **1 bảng điều khiển (`log_`):** `log_proc_run` ghi nhận lịch sử thực thi thủ tục (65 bản ghi `START` và `OK`, 0 bản ghi `FAIL`).
  - **9 `Virtual Foreign Keys` (Khoá ngoại ảo):** Duy trì toàn vẹn tham chiếu trên giao diện DBeaver mà không làm chậm tốc độ nạp dữ liệu định kỳ.

<div align="center">

![Mô hình kho dữ liệu Star Schema](images/thiet-ke-schema.png)

</div>

- **Bước 4 – Data Processing (Tính toán tự động bằng Stored Procedure):**
  Hệ thống 9 `stored procedure` thực thi tuần tự các bước phân bổ chi phí và thuật toán xếp hạng. Toàn bộ logic được bao bọc trong transaction chặt chẽ, kiểm soát lỗi và rollback tự động nếu phát sinh sai lệch.

---

## 5. 🧮 Xây Dựng Logic Tính Toán Và Chỉ Tiêu Quản Trị

### 5.1. Bài toán A – Tính toán kết quả kinh doanh 7 vùng (P&L Allocation)

Hệ thống phân bổ 63.134 bút toán sổ cái theo 2 quy tắc kế toán quản trị minh bạch:

- **Quy tắc 1 (Gán trực tiếp):** Bút toán nào có mã tỉnh thành chi nhánh cụ thể (62.953 dòng) được ghi nhận 100% doanh thu hoặc chi phí cho vùng kinh doanh tương ứng.
- **Quy tắc 2 (Phân bổ gián tiếp):** Bút toán tại Hội sở (181 dòng chi phí chung, mã tỉnh `'00'`, vùng `'A'`) được chia về 7 vùng dựa trên tỷ lệ thực tế của từng tiêu thức kinh tế tương ứng:

$$	ext{Tỷ lệ phân bổ vùng } i = rac{	ext{Giá trị tiêu thức của vùng } i}{\sum_{k=1}^7 	ext{Giá trị tiêu thức của vùng } k}$$

$$	ext{Chi phí phân bổ về vùng } i = 	ext{Chi phí Hội sở} 	imes 	ext{Tỷ lệ phân bổ vùng } i$$

*Tiêu thức phân bổ được lựa chọn phù hợp với bản chất từng loại chi phí:*
- **Chi phí vốn huy động:** Phân bổ theo Dư nợ cho vay nhóm 1 (phản ánh vùng nào sử dụng nhiều vốn huy động thì phải gánh chi phí vốn tương ứng).
- **Chi phí dự phòng rủi ro tín dụng:** Phân bổ theo Dư nợ nhóm 2 đến nhóm 5 cộng với Nợ đã xử lý rủi ro ngoại bảng (write-off).
- **Chi phí vận hành và quản lý chung:** Phân bổ theo Số lượng quản lý vùng (headcount) hoặc Số lượng thẻ phát sinh dư nợ.

*Chuyển đổi số lũy kế (YTD) sang số phát sinh tháng:*
Dữ liệu sổ cái tích lũy từ đầu năm được chuyển đổi thành dòng tiền phát sinh riêng từng tháng:
$$V_{	ext{tháng } M} = V_{	ext{lũy kế } M} - V_{	ext{lũy kế } (M-1)}$$
Từ đó phân rã biến động Lợi nhuận trước thuế (PBT) thành 6 cấu phần thu – chi cụ thể.

### 5.2. Bài toán B – Đánh giá và xếp hạng năng lực quản lý vùng (ASM Scorecard)

Để đảm bảo tính công bằng và triệt tiêu động cơ nới lỏng kiểm soát rủi ro, hệ thống đánh giá 8 chỉ số trên **2 trụ cột độc lập**:

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                             HỆ THỐNG ĐÁNH GIÁ QUẢN LÝ VÙNG                             │
├──────────────────────────────────────────┬─────────────────────────────────────────────┤
│ TRỤ CỘT 1: PHÁT TRIỂN QUY MÔ (diem_qm)    │ TRỤ CỘT 2: HIỆU QUẢ TÀI CHÍNH (diem_fin)    │
│ • Doanh số cho vay mới bình quân (Cao tốt)│ • Tỷ lệ chi phí / thu nhập - CIR (Thấp tốt) │
│ • Số thẻ phát sinh dư nợ bình quân (Cao) │ • Biên lợi nhuận - Margin (Cao tốt)         │
│ • Tỷ lệ duyệt hồ sơ bình quân (Cao tốt)  │ • Hệ số hiệu quả vốn (Cao tốt)              │
│ • TỶ LỆ NỢ XẤU TOÀN VÙNG (Thấp là tốt)   │ • Lợi nhuận bình quân / Quản lý (Cao tốt)   │
│   (Đóng vai trò phanh hãm rủi ro)        │   (Gắn trách nhiệm quản lý với kết quả vùng)│
└──────────────────────────────────────────┴─────────────────────────────────────────────┘
```

*Thuật toán xếp hạng từng chỉ số trước khi tính điểm tổng:*
Do các chỉ số có đơn vị đo lường khác nhau (triệu đồng, số thẻ, tỷ lệ phần trăm), việc cộng gộp số thô là phi thực tế. Hệ thống sử dụng thuật toán **Xếp hạng từng chỉ số trước (thứ hạng 1 là tốt nhất), sau đó cộng tổng thứ hạng để tính điểm**:
$$	ext{Điểm tổng} = 	ext{Điểm Quy mô } (diem\_qm) + 	ext{Điểm Tài chính } (diem\_fin)$$
*Điểm tổng càng thấp, thứ hạng chung cuộc của quản lý vùng trên toàn ngân hàng càng cao.*

*Giới hạn nghiệp vụ cần lưu ý:* Do dữ liệu nợ xấu và sổ cái chỉ theo dõi đến cấp chi nhánh/vùng, các chỉ số thuộc Trụ cột 2 và tỷ lệ nợ xấu vùng được tính chung cho toàn vùng rồi áp dụng cho các ASM trong cùng địa bàn. Hệ thống phản ánh kết quả kinh doanh và hiệu quả quản lý theo bộ tiêu chí hiện có, không phải phép đo toàn diện năng lực cá nhân riêng lẻ.

---

## 6. 🧪 Kiểm Tra Và Đối Soát Dữ Liệu

Để đảm bảo số liệu tính toán đạt độ tin cậy tuyệt đối trước khi báo cáo Ban Lãnh Đạo, hệ thống thực hiện 4 phương pháp kiểm tra đối soát chéo độc lập:

1. **Đối chiếu kết quả với biểu mẫu chuẩn của ngân hàng:**
   Kết quả tính toán được so khớp từng ô với biểu mẫu kiểm tra tài chính trong tệp `input/Tham so va mau doi chieu.xlsx`. Mọi chỉ tiêu LNTT tháng 2/2023 (**92.226,35 triệu đồng**) và tháng 5/2023 (**250.450,06 triệu đồng**) cùng vị trí Top 1 của ASM `nam.hoangvan` (**34 điểm**) đều khớp chính xác từng chữ số.

2. **Kiểm tra tính bảo toàn dòng tiền phân bổ:**
   Tổng chi phí phân bổ về 7 vùng phải bằng đúng 100% chi phí hạch toán tại quỹ Hội sở:
   $$\left| \sum_{k=1}^7 	ext{Chi phí phân bổ vùng } k - 	ext{Chi phí Hội sở} ight| \le 10^{-6}$$
   Không có bất kỳ đồng chi phí nào bị mất đi hoặc phát sinh thêm ngoài sổ cái.

3. **Đối soát độc lập giữa cơ sở dữ liệu PostgreSQL và Power BI:**
   Thực hiện đối soát độc lập **91 ô dữ liệu** (gồm 13 chỉ tiêu tài chính cốt lõi $	imes$ 7 vùng kinh doanh tại tháng 5/2023) giữa câu lệnh truy vấn SQL trên PostgreSQL và các measure DAX trên Power BI. Kết quả ghi nhận **chênh lệch bằng đúng 0 trên toàn bộ 91 ô**.

4. **Kiểm tra ngược trên dữ liệu Excel gốc:**
   Kiểm tra tính toàn vẹn của dữ liệu nạp vào kho: tổng số dòng sao kê hợp đồng thẻ đạt đúng **2.932.922 bản ghi**, số bút toán sổ cái đạt đúng **63.134 dòng**, không có dòng dữ liệu nào bị thất lạc.

---

## 7. 🖥️ Thiết Kế Và Trực Quan Hóa Báo Cáo Trên Power BI

Hệ thống báo cáo quản trị trên Power BI gồm **5 trang dashboard**, được kết nối ở chế độ `Import` tối ưu hoá hiệu năng với **72 measure DAX**, phục vụ theo dõi đa chiều từ toàn hệ thống xuống từng nhân sự:

### Trang 1: Tổng Quan Báo Cáo (Executive Overview)
- **Mục đích thiết kế:** Cung cấp cho Ban Lãnh Đạo góc nhìn điều hành cấp cao về tiến độ hoàn thành các chỉ tiêu kinh doanh trọng yếu, tình hình phân bổ nhân sự và hiệu suất tổng thể của 7 vùng kinh doanh.
- **Nội dung hiển thị:** 4 thẻ KPI động (Lợi nhuận trước thuế, Tổng thu nhập hoạt động, Tỷ lệ CIR, Lợi nhuận bình quân/ASM kèm màu sắc và tỷ lệ tăng giảm MoM); Biểu đồ cơ cấu dư nợ và số lượng thẻ hoạt động theo vùng; Bộ lọc đa chiều theo tháng và vùng.
- **Khả năng hỗ trợ phân tích:** Giúp lãnh đạo nắm bắt ngay sức khỏe kinh doanh tổng quan mà không phải đọc qua các bảng biểu chi tiết, phát hiện nhanh các vùng có dấu hiệu suy giảm hiệu suất.

<div align="center">

![Trang 1 — Tổng Quan Báo Cáo](images/tong-quan.png)

</div>

### Trang 2: Từ Điển Dữ Liệu Quản Trị (Data Glossary)
- **Mục đích thiết kế:** Chuẩn hoá ngôn ngữ quản trị chung cho toàn ngân hàng, đảm bảo Ban Lãnh Đạo, Khối Kinh doanh, Khối Rủi ro và Phòng Kế toán cùng hiểu thống nhất về định nghĩa và công thức của 50 chỉ tiêu báo cáo.
- **Nội dung hiển thị:** Bảng ma trận tra cứu từ điển dữ liệu phân loại theo 6 nhóm chỉ tiêu (Thu nhập, Chi phí vốn, Chi phí hoạt động, Dự phòng rủi ro, Chỉ tiêu quy mô thẻ, Chỉ tiêu tài chính vùng); Cột diễn giải công thức SQL và nguồn dữ liệu tương ứng.
- **Khả năng hỗ trợ phân tích:** Giải quyết triệt để sự tranh luận về mặt số liệu giữa các đơn vị khi đối soát kết quả kinh doanh và xếp hạng thi đua.

<div align="center">

![Trang 2 — Từ Điển Dữ Liệu Quản Trị](images/tu-dien.png)

</div>

### Trang 3: Báo Cáo Kết Quả Kinh Doanh Lãi Lỗ 7 Vùng (Regional P&L)
- **Mục đích thiết kế:** Trả lời câu hỏi trọng tâm của Ban Lãnh Đạo: "Sau khi phân bổ đầy đủ chi phí gián tiếp từ Hội sở, vùng nào thực sự có lãi và cấu phần nào đóng góp lớn nhất vào lợi nhuận?".
- **Nội dung hiển thị:** Bảng kết quả kinh doanh chi tiết theo 7 vùng với đầy đủ các khoản mục thu – chi; Biểu đồ phân rã biến động lợi nhuận (Waterfall) bóc tách 6 cấu phần; Thẻ đo lường biên lợi nhuận (Margin) và hệ số CIR từng vùng.
- **Khả năng hỗ trợ phân tích:** Giúp lãnh đạo bóc tách rõ nguyên nhân tăng/giảm lợi nhuận giữa các tháng đến từ hoạt động bán hàng thực chất hay do biến động trích lập dự phòng nợ xấu.

<div align="center">

![Trang 3 — Báo Cáo Kết Quả Kinh Doanh Lãi Lỗ 7 Vùng](images/ket-qua-lai-lo.png)

</div>

### Trang 4: Bảng Xếp Hạng Quản Lý Vùng (ASM Scorecard)
- **Mục đích thiết kế:** Đánh giá và xếp hạng công bằng năng lực của toàn bộ đội ngũ từ 74 đến 84 quản lý vùng (ASM) trên cả nước dựa trên sự cân bằng giữa phát triển quy mô và kiểm soát rủi ro.
- **Nội dung hiển thị:** Bảng xếp hạng chi tiết từng quản lý vùng với Điểm Quy mô, Điểm Tài chính và Thứ hạng chung cuộc; Biểu đồ phân phối thứ hạng theo vùng; Thẻ tìm kiếm thông tin chi tiết từng nhân sự.
- **Khả năng hỗ trợ phân tích:** Giúp nhận diện những quản lý vùng xuất sắc toàn diện, đồng thời cảnh báo các trường hợp có doanh số mở thẻ cao nhưng nợ xấu địa bàn vượt ngưỡng an toàn.

<div align="center">

![Trang 4 — Bảng Xếp Hạng Quản Lý Vùng](images/xep-hang.png)

</div>

### Trang 5: Phân Tích Chuyên Sâu & Chẩn Đoán Quản Trị (Diagnosis & Root Cause)
- **Mục đích thiết kế:** Cung cấp công cụ chẩn đoán nguyên nhân gốc rễ (Root Cause Analysis) và đưa ra các khuyến nghị hành động cụ thể cho Ban Lãnh Đạo.
- **Nội dung hiển thị:** Ma trận 4 góc Lợi nhuận – Rủi ro (Quadrant Matrix) định vị 7 vùng theo 2 trục Lợi nhuận và Nợ xấu; Khung hành động chẩn đoán 3 cột (Hiện tượng quan sát $ightarrow$ Nguyên nhân dữ liệu $ightarrow$ Đề xuất hành động kèm đơn vị phụ trách và thời hạn).
- **Khả năng hỗ trợ phân tích:** Giúp Ban Lãnh Đạo ra các quyết định điều hành can thiệp có căn cứ số liệu, ví dụ siết tín dụng tại các vùng tăng trưởng nóng hoặc điều chỉnh cơ chế giao chỉ tiêu KPI.

<div align="center">

![Trang 5 — Phân Tích Chuyên Sâu & Chẩn Đoán Quản Trị](images/ket-luan.png)

</div>

---

## 8. 📊 Kết Quả Phân Tích Và Đề Xuất Quản Trị

### Phần A – Đánh giá mức độ đáp ứng yêu cầu ban đầu:

| Yêu cầu ban đầu của Ban Lãnh Đạo | Sản phẩm đầu ra xây dựng | Kết quả đánh giá mức độ đáp ứng |
|---|---|---|
| **Đo lường lãi lỗ thực chất 7 vùng** | Báo cáo P&L phân bổ chi phí Hội sở | **Đáp ứng 100%**: 7 vùng được phân bổ đầy đủ chi phí gián tiếp, bảo toàn tuyệt đối dòng tiền sổ cái. |
| **Phân tích biến động hàng tháng** | Biểu đồ thác nước Waterfall 6 cấu phần | **Đáp ứng 100%**: Tách bạch rõ ràng số phát sinh từng tháng, chỉ rõ nguyên nhân tăng giảm lợi nhuận. |
| **Theo dõi chất lượng tín dụng** | Ma trận Lợi nhuận – Rủi ro & Tỷ lệ nợ xấu | **Đáp ứng tốt**: Định vị chính xác các vùng có nợ xấu cao để cảnh báo sớm rủi ro tín dụng. |
| **Xếp hạng công bằng quản lý vùng** | Bảng xếp hạng 2 trụ cột độc lập | **Đáp ứng tốt**: Kết hợp hài hoà giữa quy mô và kiểm soát rủi ro cho toàn bộ 74 - 84 nhân sự. |
| **Hệ thống điều hành trực quan** | Dashboard Power BI 5 trang & Excel đối chiếu | **Đáp ứng 100%**: Cung cấp công cụ phân tích tương tác tức thì cho lãnh đạo và tệp chi tiết cho kế toán. |

### Phần B – Phân tích các phát hiện chính từ số liệu tháng 5/2023:

1. **Tây Nam Bộ – Tăng trưởng lợi nhuận không đến từ kinh doanh cốt lõi:**
   - *Hiện tượng quan sát:* Lợi nhuận trước thuế của vùng tăng vọt **+4.267,8 triệu đồng**, đóng góp tới **97,2%** mức tăng lợi nhuận của toàn hệ thống trong tháng 5.
   - *Số liệu minh chứng:* Thu nhập thuần từ thẻ của vùng chỉ tăng nhẹ +16,3 triệu đồng, chi phí hoạt động tăng làm giảm lợi nhuận −195,9 triệu đồng. Toàn bộ mức tăng lợi nhuận thực chất đến từ việc **chi phí trích lập dự phòng giảm +4.447,3 triệu đồng**.
   - *Nguyên nhân từ dữ liệu:* Chi phí dự phòng giảm có thể do hoàn nhập dự phòng hoặc chính sách giãn nợ kỹ thuật chứ không phản ánh sự khởi sắc của hoạt động bán hàng.
   - *Vấn đề quản trị:* Vùng Tây Nam Bộ đang có **tỷ lệ nợ xấu cao nhất hệ thống (21,99%)** và không có bất kỳ quản lý vùng nào lọt vào nhóm 25 vị trí dẫn đầu toàn quốc.
   - *Đề xuất xử lý:* Tạm dừng khen thưởng dựa trên lợi nhuận đơn lẻ; yêu cầu Khối Quản lý rủi ro kiểm tra thực địa chất lượng thu hồi nợ tại Tây Nam Bộ trong tháng 7.

2. **Đông Nam Bộ – Kết quả lợi nhuận âm do áp lực dự phòng nợ xấu:**
   - *Hiện tượng quan sát:* Vùng Đông Nam Bộ ghi nhận mức lỗ trước thuế **−8.787,4 triệu đồng** trong tháng.
   - *Số liệu minh chứng:* Hoạt động kinh doanh thực tế diễn ra rất tích cực khi **thu nhập thuần tăng tới +3.210,7 triệu đồng**, nhưng mức tăng này bị xóa sạch bởi **chi phí trích lập dự phòng tăng thêm −3.234,2 triệu đồng**.
   - *Nguyên nhân từ dữ liệu:* Tỷ lệ chuyển nhóm nợ xấu của các hợp đồng phát hành trong giai đoạn trước bắt đầu phát tác, đòi hỏi trích lập dự phòng bổ sung lớn.
   - *Vấn đề quản trị:* Khiến **16 trong số 19 quản lý vùng** rơi xuống nửa cuối bảng xếp hạng toàn quốc dù doanh số bán hàng mới của họ vẫn thuộc nhóm cao.
   - *Đề xuất xử lý:* Rà soát danh mục hợp đồng chuyển nhóm nợ xấu tại Đông Nam Bộ trong vòng 30 ngày để tái cơ cấu quy trình thẩm định.

3. **Đồng bằng Sông Hồng – Thu nhập cốt lõi giảm bị che khuất bởi hoàn nhập:**
   - *Hiện tượng quan sát:* Lợi nhuận của vùng tăng thêm **+1.310,9 triệu đồng** so với tháng trước.
   - *Số liệu minh chứng:* Thu nhập thuần từ thẻ thực tế giảm **−232,2 triệu đồng**, nhưng con số lợi nhuận dương đạt được là nhờ chi phí dự phòng giảm **+1.455,8 triệu đồng**.
   - *Vấn đề quản trị:* Báo cáo bề nổi cho thấy vùng vẫn tăng trưởng lợi nhuận, che giấu dấu hiệu suy giảm đà kinh doanh tại thị trường lớn nhất của ngân hàng.

4. **Nam Trung Bộ – Mô hình điểm về hiệu quả và chất lượng tín dụng:**
   - *Hiện tượng quan sát:* Quy mô địa bàn nhỏ (chỉ có 5 quản lý vùng) nhưng đạt hiệu quả hoạt động đồng đều và bền vững nhất toàn hàng.
   - *Số liệu minh chứng:* Tỷ lệ nợ xấu thấp nhất ngân hàng (**11,24%**) và có tới **4 trong số 5 quản lý vùng** nằm trong nhóm 25 vị trí dẫn đầu cả nước.
   - *Đề xuất xử lý:* Đúc kết quy trình sàng lọc và thẩm định hồ sơ của Nam Trung Bộ để thí điểm nhân rộng sang các địa bàn khác.

### Năm đề xuất hành động cụ thể gửi Ban Lãnh Đạo:

| # | Đề xuất quản trị | Căn cứ số liệu thực tế | Đơn vị phụ trách · Thời hạn |
|:---:|:---|:---|:---|
| 01 | **Bổ sung chỉ tiêu lợi nhuận loại trừ hoàn nhập:** Tách riêng dòng trích lập dự phòng mới và hoàn nhập dự phòng để phản ánh đúng lợi nhuận kinh doanh cốt lõi. | Báo cáo hiện tại chỉ có một dòng dự phòng ròng, che khuất biến động thực chất | Khối Quản lý rủi ro · Tháng 6 |
| 02 | **Rà soát danh mục nợ xấu tại 3 vùng trọng điểm:** Kiểm tra các hợp đồng phát sinh nợ quá hạn tại Đông Nam Bộ, Đông Bắc Bộ và Tây Bắc Bộ. | Tổng chi phí dự phòng tại 3 vùng này tăng thêm **6.035,1 triệu đồng** trong tháng | Quản lý vùng + Quản lý rủi ro · 30 ngày |
| 03 | **Kiểm tra thực địa quy trình cấp tín dụng tại Tây Nam Bộ:** Thẩm định lại chất lượng hồ sơ và hiệu quả thu hồi nợ. | Nợ xấu chiếm **21,99%** (cao nhất hệ thống) nhưng vùng lại chiếm **97,2%** mức tăng lợi nhuận | Khối Kinh doanh + Quản lý rủi ro · Tháng 7 |
| 04 | **Thí điểm chuẩn hoá quy trình thẩm định theo Nam Trung Bộ:** Nhân rộng phương pháp sàng lọc khách hàng chất lượng cao. | Tỷ lệ nợ xấu thấp nhất (**11,24%**) và 4/5 quản lý vùng đạt top 25 | Khối Kinh doanh · Đánh giá sau 2 tháng |
| 05 | **Điều chỉnh cơ chế đãi ngộ:** Kết hợp đồng thời chỉ tiêu thu nhập thuần và tỷ lệ nợ xấu thay vì chỉ dùng một con số lợi nhuận tổng. | Tránh việc khen thưởng nhầm cho các vùng có lợi nhuận tăng ảo nhờ giảm trích lập dự phòng | Ban điều hành · Áp dụng ngay |

---

## 9. 📚 Kinh Nghiệm Triển Khai Thực Chiến

1. **Hiểu sâu bản chất nghiệp vụ ngân hàng trước khi viết code:**
   Trong hệ thống dữ liệu tài chính, việc hiểu rõ tại sao chi phí vốn mang dấu âm, vì sao chi phí Hội sở mang mã tỉnh `'00'` và vùng `'A'` là điều kiện tiên quyết để xây dựng câu lệnh SQL phân bổ chính xác. Không thể giải quyết bài toán dữ liệu ngân hàng nếu chỉ tiếp cận thuần tuý dưới góc độ công nghệ.

2. **Làm sạch dữ liệu danh mục là điều kiện sống còn của báo cáo:**
   Phát hiện sự sai lệch giữa chuỗi ký tự "Bà Rịa - Vũng Tàu" và "Vũng Tàu" trong quá trình tiền xử lý đã giữ lại trọn vẹn hơn **36.000 hợp đồng thẻ**, ngăn chặn sai lệch nghiêm trọng đối với tỷ lệ nợ xấu của vùng Đông Nam Bộ.

3. **Kiểm soát tính toàn vẹn và giao dịch trong quy trình ETL:**
   Việc thiết kế 6 bảng tạm trung gian cùng cấu trúc dọc và quản lý transaction chặt chẽ trong các Stored Procedure giúp hệ thống có khả năng truy vết lỗi (audit trail) ở từng bước tính toán và rollback an toàn nếu phát sinh sự cố.

4. **Không bao giờ đánh giá hiệu quả kinh doanh qua một con số tổng duy nhất:**
   Một con số lợi nhuận dương đẹp mắt có thể che giấu sự suy giảm của hoạt động kinh doanh cốt lõi hoặc sự bùng nổ của nợ xấu tiềm ẩn. Phân rã cấu phần và so sánh đa chiều là nguyên tắc cốt lõi của phân tích dữ liệu quản trị.

5. **Nhận thức rõ giới hạn của dữ liệu để tránh kết luận sai lầm:**
   Khi dữ liệu nợ xấu chỉ dừng ở cấp vùng chứ chưa chi tiết đến từng hợp đồng của từng quản lý vùng, báo cáo phải ghi nhận rõ ràng giới hạn này để Ban Lãnh Đạo sử dụng số liệu đúng phạm vi, không suy diễn vượt quá bằng chứng thực tế.

---

## 10. 🛠️ Công Nghệ Sử Dụng

Các công cụ được lựa chọn dựa trên sự phù hợp với yêu cầu thực tế của từng giai đoạn trong dự án:

| Công nghệ | Thành phần | Vai trò kỹ thuật trong dự án | Lý do lựa chọn |
|---|---|---|---|
| **Python 3.10** | `openpyxl`, `zipfile`, `xml.etree` | Đọc dữ liệu Excel thô gần 3 triệu dòng, chuẩn hoá ký tự và nạp dữ liệu vào kho | Xử lý streaming tệp lớn 117,2 MB mà không làm tràn bộ nhớ RAM |
| **PostgreSQL 15** | PL/pgSQL, Stored Procedure | Lưu trữ kho dữ liệu Star Schema (19 bảng, 4 `view`), thực thi logic phân bổ chi phí và xếp hạng | Khả năng xử lý tập dữ liệu lớn với độ chính xác cao và kiểm soát transaction chặt chẽ |
| **Power BI Desktop** | Import Mode, 72 Measure DAX | Dựng 5 trang dashboard phân tích trực quan, tương tác đa chiều | Cung cấp trải nghiệm theo dõi trực quan tức thì và chẩn đoán dữ liệu cho Ban Lãnh Đạo |
| **Microsoft Excel** | XLSX, Advanced Formulas | Xuất báo cáo quản trị 7 sheet tự động qua tập lệnh Python | Phục vụ thói quen đối soát công thức chi tiết từng ô của Phòng Kế toán - Tài chính |

---

## 11. 📂 Cấu Trúc Thư Mục Dự Án

Cấu trúc dự án được chuẩn hoá thành 6 thư mục nghiệp vụ rõ ràng:

```text
.
├── input/              # Lưu tệp tham số và mẫu báo cáo; 3 nguồn dữ liệu thô vượt trần dung lượng GitHub nên quản lý riêng
│   └── Tham so va mau doi chieu.xlsx  # Quy đổi 64 tỉnh thành về 8 vùng, đối chiếu tài khoản sổ cái, biểu mẫu chuẩn của 2 báo cáo
├── ingestion/          # Các chương trình Python đọc dữ liệu Excel, chuẩn hoá dữ liệu, nạp vào kho và xuất báo cáo
│                       # db_config.example.py — tệp mẫu cấu hình kết nối cơ sở dữ liệu
│                       # run_all.py điều phối chạy 4 bước nạp · run_report.py tự động kiểm tra số mới và xuất báo cáo Excel
├── sql/                # Mã nguồn SQL tạo bảng, bảng tạm, thủ tục lưu trữ và khung nhìn báo cáo
│   ├── dim/            # Bảng danh mục: dim_month_headcount, dim_asm, dim_report_detail
│   ├── tmp/            # Bảng tạm và thủ tục tính trung gian cho P&L (step 1-3) và Xếp hạng ASM (step 1-3)
│   ├── fct/            # Bảng sự kiện chính và thủ tục điều phối: fct_pnl_allocation, fct_xephang_asm
│   └── rpt/            # Khung nhìn báo cáo: rpt_pnl_view, rpt_xephang_view
├── images/             # Sơ đồ quy trình kỹ thuật, kiến trúc kho dữ liệu và ảnh chụp các trang dashboard
├── docs/               # Bộ tài liệu vận hành chi tiết: HIEN_TRANG_HE_THONG, PIPELINE, NHAT_KY_CONG_VIEC, LOI_THUONG_GAP
├── output/             # Sản phẩm đầu ra: Báo cáo quản trị Power BI (.pbix) và báo cáo Excel
├── requirements.txt    # Khai báo các thư viện Python: psycopg2-binary và openpyxl
├── README.md           # Tài liệu dự án bằng tiếng Việt (mặc định)
└── README_eng.md       # Tài liệu dự án bằng tiếng Anh
```

---

## 12. 🔒 Nguồn Dữ Liệu Và Quyền Sử Dụng

- Dữ liệu sử dụng trong dự án là **dữ liệu nghiệp vụ thực tế do đơn vị cung cấp và cho phép sử dụng** nhằm mục đích nghiên cứu và xây dựng giải pháp báo cáo quản trị.
- **Quy định quản lý tệp trên kho mã:** Do chính sách giới hạn dung lượng của GitHub (100 MB/tệp), tệp sao kê hợp đồng thẻ gốc nặng **117,2 MB** được lưu trữ cục bộ cùng hai tệp dữ liệu thô khác. Kho mã lưu trữ tệp **`Tham so va mau doi chieu.xlsx`** (127.976 byte) nhằm đảm bảo người đọc có thể tái hiện toàn bộ mã nguồn, logic tính toán và xem trước các sản phẩm báo cáo đầu ra.

---

## 13. 📖 Tài Liệu Bàn Giao

Hệ thống được tài liệu hoá đầy đủ trong thư mục `docs/`:
- [`docs/HIEN_TRANG_HE_THONG.md`](docs/HIEN_TRANG_HE_THONG.md) — Chi tiết hiện trạng kho dữ liệu, số dòng của 19 bảng và 4 `view`, phân quyền quản lý từng bảng và các mốc đối soát chuẩn.
- [`docs/PIPELINE.md`](docs/PIPELINE.md) — Kiến trúc luồng xử lý 4 giai đoạn và hướng dẫn chạy kiểm tra dữ liệu.
- [`docs/NHAT_KY_CONG_VIEC.md`](docs/NHAT_KY_CONG_VIEC.md) — Nhật ký chi tiết các hạng mục công việc đã thực hiện qua từng giai đoạn phát triển.
- [`docs/LOI_THUONG_GAP.md`](docs/LOI_THUONG_GAP.md) — Sổ tay xử lý sự cố tổng hợp **58 tình huống lỗi thực tế** từ dữ liệu nguồn, SQL, Python đến DAX.

---

## 14. 👤 Tác Giả

<div align="center">

**Trần Ngọc Đức** · Data Analyst · Business Intelligence · Data Science · Management Information Systems · Operations

[Email](mailto:tranduc22104@gmail.com) · [LinkedIn](https://www.linkedin.com/in/tr%E1%BA%A7n-ng%E1%BB%8Dc-%C4%91%E1%BB%A9c-48b3a7439/)

</div>
