<div align="center">

# Xây Dựng Báo Cáo Quản Trị Kết Quả Kinh Doanh Thẻ Tín Dụng Và Đánh Giá Hiệu Quả Hoạt Động Của Quản Lý Vùng (ASM)

**Ngôn ngữ / Language**: **Tiếng Việt** · [English](README_eng.md)

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
7. [📊 Kết Quả Phân Tích Và Đề Xuất Quản Trị](#7--kết-quả-phân-tích-và-đề-xuất-quản-trị)
8. [📚 Kinh Nghiệm Triển Khai Thực Chiến](#8--kinh-nghiệm-triển-khai-thực-chiến)
9. [🛠️ Công Nghệ Sử Dụng](#9--công-nghệ-sử-dụng)
10. [📂 Cấu Trúc Thư Mục Dự Án](#10--cấu-trúc-thư-mục-dự-án)
11. [📖 Tài Liệu Bàn Giao](#11--tài-liệu-bàn-giao)
12. [👤 Tác Giả](#12--tác-giả)

---

## 1. 🏢 Bối Cảnh Kinh Doanh Và Yêu Cầu Quản Trị

### Bối cảnh hoạt động kinh doanh thẻ tín dụng
Hoạt động kinh doanh thẻ tín dụng được triển khai tại **7 vùng kinh doanh** trên toàn quốc. Mỗi vùng do đội ngũ quản lý vùng phụ trách, với tổng số nhân sự quản lý dao động từ **74 đến 84 quản lý vùng (Area Sales Manager - ASM)** tùy từng thời kỳ.

### Trạng thái 1 – Yêu cầu ban đầu ở mức độ tổng quát (Initial Business Request)
Ban Lãnh Đạo đưa ra yêu cầu chung:
> *Cần xây dựng hệ thống báo cáo quản trị để theo dõi kết quả kinh doanh thẻ tín dụng tại các vùng kinh doanh và đánh giá hiệu quả hoạt động của đội ngũ quản lý vùng (ASM).*

Tại thời điểm tiếp nhận, yêu cầu này **chưa được làm rõ** các chi tiết cụ thể:
- Chưa có phương pháp xác định lợi nhuận thực tế của từng vùng.
- Chưa có nguyên tắc phân bổ các khoản chi phí hạch toán tập trung tại Hội sở.
- Chưa xác định bộ chỉ tiêu đo lường hiệu quả kinh doanh và rủi ro tín dụng.
- Chưa có tiêu chí đánh giá năng lực của quản lý vùng.
- Chưa có công thức tính điểm, cơ chế xếp hạng hay cấu trúc biểu mẫu báo cáo.

### Nhận diện các điểm chưa rõ và vấn đề quản trị phát sinh
Khi xem xét cách tổng hợp báo cáo hiện tại, có thể thấy ba vấn đề cần giải quyết:

1. **Chưa phản ánh đầy đủ hiệu quả tài chính:**
   Trên hệ thống sổ cái kế toán, các chi nhánh ghi nhận doanh thu từ lãi vay và phí mở thẻ. Tuy nhiên, các chi phí chính như chi phí vốn, tiếp thị, công nghệ và chi phí phòng ban hỗ trợ lại được ghi nhận tập trung tại Hội sở. Khi chưa phân bổ chi phí, báo cáo hiện tại cho thấy tất cả các vùng đều có lãi, làm khó nhận diện những vùng đang hoạt động kém hiệu quả.

2. **Đánh giá quản lý vùng tiềm ẩn rủi ro tín dụng:**
   Nếu chỉ dựa trên doanh số giải ngân hoặc số lượng thẻ mới, đội ngũ quản lý có thể nới lỏng điều kiện phê duyệt để đạt chỉ tiêu trước mắt. Điều này có thể giúp tăng trưởng nhanh trong ngắn hạn nhưng làm tăng nợ xấu và chi phí dự phòng trong các kỳ sau.

3. **Hạn chế của báo cáo kế toán tĩnh:**
   Báo cáo hiện tại chỉ cung cấp số liệu lũy kế từ đầu năm, chưa tách riêng biến động từng tháng và chưa phân biệt được lợi nhuận tăng do kinh doanh cốt lõi hay do biến động của chi phí dự phòng.

Từ bối cảnh đó, 5 câu hỏi quản trị trọng tâm được xác định cần giải quyết:

| Vấn đề quản trị | Câu hỏi cần giải quyết | Mục tiêu quản trị cần đạt |
|---|---|---|
| **Hiệu quả kinh doanh** | Vùng nào đang thực sự có lợi nhuận sau khi tính chi phí chung? | Xác định chính xác lãi lỗ 7 vùng sau phân bổ Hội sở |
| **Biến động lợi nhuận** | Nguyên nhân tăng giảm lợi nhuận hàng tháng đến từ đâu? | Bóc tách dòng chảy lợi nhuận thành các cấu phần thu – chi |
| **Chất lượng tín dụng** | Vùng nào đang có rủi ro nợ xấu cao đe dọa an toàn vốn? | Giám sát dư nợ theo 5 nhóm nợ và tỷ lệ nợ xấu từng vùng |
| **Hiệu quả quản lý vùng** | Quản lý vùng nào có kết quả kinh doanh và quản trị rủi ro tốt? | Xây dựng hệ thống xếp hạng cân bằng đa chiều cho 74 - 84 nhân sự |
| **Công tác điều hành** | Cần theo dõi thông tin theo hình thức nào để ra quyết định kịp thời? | Xây dựng hệ thống dashboard trực quan và tệp đối soát chuẩn |

---

## 2. 🎯 Phân Tích Yêu Cầu Và Thiết Kế Đầu Ra Báo Cáo

### Trạng thái 2 – Làm rõ yêu cầu thông qua phân tích nghiệp vụ (Refined Business Requirements)
Từ yêu cầu ban đầu, cần xác định báo cáo phải cung cấp những thông tin gì để Ban lãnh đạo theo dõi kết quả kinh doanh và đánh giá đội ngũ quản lý vùng (ASM). Vì vậy, các đầu ra báo cáo được phác thảo trước (Output-First), sau đó tiếp tục điều chỉnh dựa trên kết quả khảo sát dữ liệu.

### Bảng phân tích làm rõ nghiệp vụ và xác định đầu ra:

| Yêu cầu ban đầu | Nội dung cần làm rõ | Kết quả phân tích nghiệp vụ | Yêu cầu đầu ra cần xây dựng |
|---|---|---|---|
| **Theo dõi kết quả kinh doanh** | Lãi lỗ từng vùng có tính chi phí Hội sở không? Phân bổ theo nguyên tắc nào? | Phải tính đầy đủ chi phí gián tiếp (vốn, vận hành, dự phòng) về 7 vùng theo tiêu thức kinh tế hợp lý | **Báo cáo P&L quản trị 7 vùng**: Thu nhập thuần, chi phí vốn, chi phí hoạt động, dự phòng rủi ro, lợi nhuận trước thuế (PBT) |
| **Theo dõi biến động kinh doanh** | Lợi nhuận tăng/giảm do hoạt động bán hàng hay do biến động trích lập dự phòng? | Cần phân rã số lũy kế thành số phát sinh riêng từng tháng và bóc tách các cấu phần thu – chi | **Báo cáo dòng chảy lợi nhuận (Waterfall)**: Chênh lệch tháng (MoM), bóc tách mức đóng góp của 6 cấu phần |
| **Theo dõi chất lượng tín dụng** | Làm sao phát hiện sớm rủi ro nợ xấu đe dọa an toàn vốn tại từng vùng? | Cần đối chiếu tương quan giữa tăng trưởng lợi nhuận và tỷ lệ nợ xấu trên cùng một mặt bằng | **Ma trận Lợi nhuận – Rủi ro (Quadrant Matrix)**: Phân loại 7 vùng vào 4 kịch bản quản trị |
| **Đánh giá hiệu quả quản lý vùng** | Hiệu quả của quản lý vùng (ASM) cần được đo lường bằng những yếu tố nào để tránh chạy theo số lượng? | Cần kết hợp giữa chỉ tiêu Quy mô kinh doanh (50%) và Kỷ luật tài chính / Rủi ro (50%) | **Thẻ điểm và Bảng xếp hạng Quản lý vùng (Scorecard)**: Đánh giá 8 chỉ số trên 2 trụ cột độc lập |
| **Hỗ trợ công tác điều hành** | Cần theo dõi thông tin theo hình thức nào để phục vụ đa dạng nhu cầu? | Lãnh đạo cần dashboard tương tác trực quan tức thì; Kế toán cần file Excel công thức đối soát | **Hệ thống báo cáo tích hợp**: Dashboard Power BI 5 trang và tệp Excel 7 sheet đối soát |

### Sơ đồ luồng tư duy từ yêu cầu quản trị đến hệ thống báo cáo:

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                          YÊU CẦU BAN ĐẦU TỔNG QUÁT CỦA BAN LÃNH ĐẠO                    │
│   1. Báo cáo kết quả kinh doanh thẻ theo vùng    │   2. Đánh giá hiệu quả quản lý vùng (ASM)   │
└───────────────────────────────────┬────────────────────────────────────────────────────┘
                                    │ (Phân tích nghiệp vụ & Làm rõ yêu cầu)
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

### Vai trò của hai nhóm chỉ tiêu:
- **Nhóm chỉ tiêu kết quả kinh doanh (P&L, NPL vùng, CIR, Margin):** Phản ánh sức khỏe tài chính của từng vùng sau khi tính đầy đủ chi phí từ Hội sở, giúp Ban lãnh đạo đưa ra quyết định phân bổ vốn và hạn mức tín dụng.
- **Nhóm chỉ tiêu đánh giá quản lý vùng (8 chỉ số xếp hạng quản lý vùng - ASM):** Kết hợp kết quả bán hàng cá nhân và chất lượng tín dụng địa bàn nhằm tạo động lực thi đua lành mạnh, hạn chế việc chạy theo doanh số ngắn hạn mà bỏ qua rủi ro tín dụng.

---

## 3. 🔍 Khảo Sát Nguồn Dữ Liệu Và Đánh Giá Mức Độ Đáp Ứng

### Khảo sát dữ liệu gắn liền với yêu cầu đầu ra
Ngân hàng không có sẵn kho dữ liệu tập trung hay một bảng số liệu duy nhất đáp ứng ngay các yêu cầu đầu ra đã thiết kế. Việc tìm kiếm dữ liệu phải gắn chặt với từng chỉ tiêu cụ thể:

| Phòng ban cung cấp | Nguồn dữ liệu | Quy mô | Vai trò đáp ứng đầu ra và Khóa kết nối |
|---|---|---:|---|
| **Khối Kế toán & Tài chính** | Sổ cái tài khoản kế toán (`fact_txn_month`) | **63.134** bút toán | Cung cấp số liệu thu - chi thực tế; gồm 62.953 dòng gắn mã tỉnh thành (gán trực tiếp cho vùng) và 181 dòng chi phí chung hạch toán tại Hội sở (mã tỉnh `'00'`, cần phân bổ). Khóa liên kết: `city_code`, `account_code`. |
| **Khối Vận hành Thẻ** | Sao kê hợp đồng thẻ tín dụng (`fact_kpi_month`) | **2.932.922** dòng | Cung cấp toàn bộ dư nợ theo 5 nhóm nợ, nợ đã xử lý rủi ro (write-off) và doanh số từng hợp đồng qua 5 tháng; làm căn cứ tính tỷ lệ nợ xấu và tạo tiêu thức phân bổ chi phí Hội sở. Khóa liên kết: `branch_code`, `month_key`. |
| **Khối Quản lý Mạng lưới** | Bảng chỉ tiêu kinh doanh (`kpi_asm_data`) | **420** dòng | Cung cấp kết quả kinh doanh cá nhân: doanh số giải ngân mới, số thẻ hoạt động và tỷ lệ duyệt hồ sơ của 74 đến 84 quản lý vùng theo tháng để phục vụ xếp hạng. Khóa liên kết: `asm_id`, `month_key`. |
| **Phòng Kế hoạch & Quản trị Dữ liệu** | Bảng tham số địa bàn và biểu mẫu đối chiếu | **64** tỉnh thành | Cung cấp quy tắc quy đổi 64 tỉnh thành về 8 vùng địa lý (Hội sở `'A'` và 7 vùng kinh doanh `'B'..'H'`) kèm mẫu biểu định dạng báo cáo. Khóa liên kết: `city_code`, `area_code`. |

### Đánh giá tính khả thi và khoảng cách dữ liệu (Gap Analysis):

| Đầu ra cần xây dựng | Trường dữ liệu yêu cầu | Nguồn dữ liệu hiện có | Đánh giá tính khả thi và độ chi tiết (Granularity) |
|---|---|---|---|
| **Báo cáo lãi lỗ 7 vùng** | Thu nhập, chi phí chi tiết, mã tỉnh, mã tài khoản | Sổ cái kế toán (`fact_txn_month`) & Bảng tham số | **Khả thi**: 62.953 dòng có mã tỉnh để gán trực tiếp; 181 dòng chi phí Hội sở (mã `'00'`) cần thuật toán phân bổ gián tiếp theo tiêu thức |
| **Báo cáo nợ xấu & rủi ro vùng** | Dư nợ 5 nhóm nợ, nợ write-off theo chi nhánh | Sao kê hợp đồng thẻ (`fact_kpi_month`) | **Khả thi ở cấp vùng**: Dữ liệu có mã chi nhánh, tổng hợp được dư nợ và nợ xấu cho 7 vùng qua 5 tháng |
| **Xếp hạng quản lý vùng** | Chỉ tiêu kinh doanh cá nhân và nhân sự | Bảng chỉ tiêu kinh doanh ASM (`kpi_asm_data`) | **Khả thi**: Dữ liệu theo dõi chi tiết từng tháng cho 74 đến 84 quản lý vùng |
| **Đánh giá nợ xấu từng cá nhân ASM** | Dư nợ xấu gắn trực tiếp theo mã nhân sự ASM | Dữ liệu hợp đồng thẻ chỉ gắn mã chi nhánh, không có mã ASM | **Chưa đáp ứng chi tiết**: Không thể phân chia nợ xấu riêng lẻ từng người; chỉ số nợ xấu và tài chính phải tính chung cấp vùng và áp dụng đồng nhất cho các ASM trong vùng |

### Nhận diện ba vấn đề của dữ liệu thô:
1. **Dữ liệu sao kê thẻ vượt giới hạn bảng tính thông thường:** Tệp dữ liệu có gần 3 triệu dòng, nặng **117,2 MB** khiến các công cụ xử lý bảng tính thông thường bị quá tải bộ nhớ.
2. **Dữ liệu chỉ tiêu tổ chức theo dạng ngang (Wide):** Bảng chỉ tiêu quản lý vùng trải dài các cột tháng sang ngang, cần chuyển đổi sang dạng dọc (Tall) để nạp vào cơ sở dữ liệu quan hệ.
3. **Lệch chuẩn trong dữ liệu danh mục:** Tên địa danh giữa các phòng ban bị lệch chuẩn ký tự (ví dụ: sao kê ghi "Bà Rịa - Vũng Tàu" nhưng bảng tham số viết "Vũng Tàu"), nếu ghép trực tiếp sẽ làm mất hơn **36.000 hợp đồng thẻ** khi tính toán tỷ lệ nợ xấu của vùng Đông Nam Bộ.

---

## 4. 🔄 Thiết Kế Quy Trình Xử Lý Và Kho Dữ Liệu

Để xử lý dữ liệu từ nhiều nguồn thành hệ thống báo cáo hoàn chỉnh, quy trình được chia thành 4 bước kỹ thuật:

<div align="center">

![Quy trình xử lý kỹ thuật — 4 giai đoạn](images/quy-trinh.png)

</div>

### Chi tiết 4 bước kỹ thuật trong pipeline:

- **Bước 1 – Data Ingestion (Thu thập và trích xuất bằng Python):**
  Sử dụng thư viện Python chuyên dụng (`openpyxl` kết hợp xử lý luồng `zipfile` + `xml.etree`) để đọc trực tiếp tệp sao kê hợp đồng thẻ nặng **117,2 MB** với gần 3 triệu dòng mà không làm tràn bộ nhớ RAM. Chuyển đổi bảng chỉ tiêu kinh doanh ASM từ dạng ngang (Wide) thành cấu trúc dữ liệu dạng dọc (Tall).

- **Bước 2 – Data Cleaning (Làm sạch và chuẩn hoá dữ liệu):**
  Kiểm tra và ép kiểu dữ liệu; xử lý các bản ghi NULL; áp dụng hàm chuẩn hoá chuỗi tiếng Việt không dấu (`pos_city_norm`) để đồng nhất tên địa danh giữa sao kê thẻ và bảng tham số, xử lý dứt điểm nguy cơ mất 36.000 hợp đồng thẻ. Nạp dữ liệu sạch vào 3 bảng `staging` (`stg_fact_kpi_month`, `stg_fact_txn_month`, `stg_asm_target`) và 2 bảng danh mục vùng (`dim_area`, `dim_param_area`).

- **Bước 3 – Data Warehouse Design (Mô hình Star Schema trong PostgreSQL):**
  Kho dữ liệu được tổ chức theo phương pháp Kimball trong schema `banking_project` gồm **19 bảng và 4 `view`**:
  - **7 bảng chiều (`dim_`):** `dim_area` (8 vùng), `dim_param_area` (64 tỉnh thành), `dim_month` (5 tháng), `dim_asm` (84 nhân sự), `dim_report_detail` (50 chỉ tiêu), `dim_month_headcount` (35 dòng), `dim_sm_headcount` (35 dòng).
  - **3 bảng nạp thô (`stg_`):** `stg_fact_kpi_month` (2.932.922 dòng), `stg_fact_txn_month` (63.134 dòng), `stg_asm_target` (420 dòng).
  - **6 bảng tạm tính toán (`tmp_`):** Cùng cấu trúc dữ liệu dạng dọc (`month_key`, `area_code`, `report_id`, `value`) phục vụ tính trung gian cho P&L (`tmp_pnl_step1..3`) và Xếp hạng (`tmp_xh_step1..3`).
  - **2 bảng sự kiện cốt lõi (`fct_`):** `fct_pnl_value` (1.115 dòng) lưu kết quả tài chính 7 vùng và `fct_asm_value` (8.536 dòng) lưu thứ hạng chi tiết từng quản lý vùng qua 5 tháng.
  - **1 bảng điều khiển (`log_`):** `log_proc_run` ghi nhận lịch sử thực thi thủ tục (65 bản ghi `START` và `OK`, 0 bản ghi `FAIL`).
  - **9 `Virtual Foreign Keys` (Khoá ngoại ảo):** Duy trì toàn vẹn tham chiếu trên giao diện DBeaver mà không làm chậm tốc độ nạp dữ liệu định kỳ.

<div align="center">

![Mô hình kho dữ liệu Star Schema](images/thiet-ke-schema.png)

</div>

- **Bước 4 – Data Processing (Tính toán tự động bằng Stored Procedure):**
  Hệ thống 9 `stored procedure` thực thi tuần tự các bước phân bổ chi phí và thuật toán xếp hạng. Toàn bộ logic được bao bọc trong transaction chặt chẽ, kiểm soát lỗi và rollback an toàn nếu phát sinh sự cố.

---

## 5. 🧮 Xây Dựng Logic Tính Toán Và Chỉ Tiêu Quản Trị

**Bối cảnh nghiệp vụ thực tế:** Trong thực tế, Ban Lãnh đạo chỉ đưa ra yêu cầu chung chứ không có sẵn công thức tính toán, bảng điểm KPI hay số liệu mẫu để đối chiếu. Toàn bộ phương pháp tính toán được xây dựng độc lập dựa trên bản chất dòng tiền và nguyên tắc kế toán quản trị.

### 5.1. Xây dựng logic phân bổ thu nhập và chi phí (P&L Allocation Framework)

Bài toán cốt lõi đặt ra: *Làm thế nào để xác định kết quả kinh doanh thực tế của từng vùng khi một phần thu nhập và chi phí lớn nhất được ghi nhận tập trung tại Hội sở?*

Quy trình giải quyết được triển khai theo 9 bước kế toán quản trị:
1. Phân tích toàn bộ 63.134 bút toán trên sổ cái kế toán (GL).
2. Xác định các khoản mục có mã tỉnh thành chi nhánh cụ thể để gán trực tiếp (Direct Cost Tracing).
3. Phân loại các khoản chi phí hạch toán tập trung tại Hội sở (mã tỉnh `'00'`, vùng `'A'`).
4. Phân tích nguyên nhân kinh tế phát sinh từng khoản chi phí.
5. Xác định nhân tố phản ánh mức độ sử dụng nguồn lực hoặc nguyên nhân phát sinh chi phí (Cost Driver).
6. Đánh giá tính khả thi và độ đầy đủ của dữ liệu nguồn hiện có để tính toán driver.
7. Lựa chọn phương pháp phân bổ gián tiếp phù hợp (Driver-Based Cost Allocation).
8. Xây dựng công thức toán học và triển khai bằng Stored Procedure trên PostgreSQL.
9. Kiểm tra tính hợp lý kinh tế và khả năng bảo toàn tổng số tiền.

**Hai nguyên tắc phân bổ chi phí cốt lõi:**
- **Quy tắc 1 – Gán trực tiếp (Direct Cost Tracing):** 62.953 bút toán phát sinh tại các chi nhánh cơ sở được ghi nhận 100% doanh thu (lãi thẻ, phí thường niên) và chi phí trực tiếp cho đúng vùng kinh doanh quản lý chi nhánh đó.
- **Quy tắc 2 – Phân bổ gián tiếp theo Cost Driver (Driver-Based Cost Allocation):** 181 bút toán chi phí Hội sở dùng chung được chia về 7 vùng dựa trên tỷ trọng của từng tiêu thức kinh tế tương ứng:

$$\text{Tỷ lệ phân bổ vùng } i = \frac{\text{Giá trị tiêu thức của vùng } i}{\sum_{k=1}^7 \text{Giá trị tiêu thức của vùng } k}$$

$$\text{Chi phí phân bổ về vùng } i = \text{Chi phí Hội sở} \times \text{Tỷ lệ phân bổ vùng } i$$

*Cơ sở kinh tế lựa chọn tiêu thức phân bổ cho từng nhóm chi phí Hội sở:*
- **Chi phí vốn huy động (Treasury Cost):** Bản chất là chi phí ngân hàng huy động vốn từ thị trường để tài trợ cho danh mục cho vay thẻ. Nguyên nhân phát sinh trực tiếp từ quy mô tín dụng $\rightarrow$ Phân bổ theo **Dư nợ cho vay bình quân nhóm 1**. Vùng nào nắm giữ quy mô dư nợ lớn hơn thì sử dụng nhiều vốn điều chuyển nội bộ hơn và gánh chịu chi phí vốn tương ứng.
- **Chi phí dự phòng rủi ro tín dụng (Credit Provisioning):** Bản chất là khoản trích lập phòng ngừa tổn thất tín dụng tiềm tàng. Phân bổ theo **Dư nợ nhóm 2 đến nhóm 5 cộng với Nợ đã xử lý rủi ro ngoại bảng (write-off)** (`d25_sau` hoặc `dtruoc`). Tiêu thức này phản ánh mức độ phơi nhiễm rủi ro của từng vùng; đây là tiêu thức phân bổ quản trị gián tiếp trong điều kiện sổ cái (GL) chỉ ghi nhận khoản mục tập trung tại quỹ Hội sở, không phải phép truy nguyên chính xác chi phí dự phòng phát sinh của từng hợp đồng đơn lẻ.
- **Chi phí công nghệ và vận hành thẻ (IT & Operations):** Chi phí duy trì hệ thống Core thẻ, hạ tầng viễn thông và máy chủ $\rightarrow$ Phân bổ theo **Số hợp đồng phát sinh dư nợ bình quân** (`psdn`). Tiêu thức này được sử dụng làm đại diện cho quy mô danh mục thẻ đang hoạt động và mức độ phục vụ của hệ thống, không khẳng định phản ánh trực tiếp tần suất giao dịch của từng chủ thẻ.
- **Chi phí vận hành và quản trị khối hỗ trợ (General Overhead):** Chi phí lương thưởng, phúc lợi của các phòng ban Hội sở phục vụ mạng lưới $\rightarrow$ Phân bổ theo **Định biên nhân sự (Headcount)** của từng vùng.
- *Giả định và giới hạn:* Phương pháp giả định mối quan hệ phân bổ là tuyến tính và mức độ tiêu hao tài nguyên bình quân trên mỗi đơn vị driver giữa các vùng là đồng nhất; chưa bóc tách riêng lẻ các chiến dịch tiếp thị mang tính đặc thù cho từng địa phương.

*Chuyển đổi số lũy kế (YTD) sang số phát sinh tháng:*
Dữ liệu sổ cái tích lũy từ đầu năm được chuyển đổi thành dòng tiền phát sinh riêng từng tháng:
$$V_{\text{tháng } M} = V_{\text{lũy kế } M} - V_{\text{lũy kế } (M-1)}$$
Từ đó phân rã biến động Lợi nhuận trước thuế (PBT) thành 6 cấu phần thu – chi cụ thể.

### 5.2. Xây dựng bộ chỉ tiêu đánh giá hiệu quả hoạt động quản lý vùng (Multi-dimensional ASM Scorecard)

Câu hỏi nghiệp vụ đặt ra: *Nếu chỉ sử dụng doanh số phát hành thẻ để đánh giá quản lý vùng (ASM), liệu kết quả có phản ánh đầy đủ hiệu quả hoạt động và kiểm soát rủi ro không?*

**Bộ chỉ tiêu kết hợp kết quả kinh doanh với trách nhiệm địa bàn:**
Bộ chỉ tiêu được xây dựng để kết hợp kết quả kinh doanh của từng quản lý vùng (ASM) với tình hình tài chính và chất lượng tín dụng tại địa bàn phụ trách. Cách đánh giá này giúp hạn chế việc chỉ tập trung vào doanh số mà bỏ qua rủi ro tín dụng. Tuy nhiên, do một số chỉ tiêu chỉ có dữ liệu ở cấp vùng, kết quả xếp hạng không phản ánh đầy đủ năng lực riêng của từng cá nhân.

Hệ thống thiết lập bộ thẻ điểm gồm 8 chỉ tiêu phân bổ đều trên 2 trụ cột độc lập, cân bằng về số lượng chỉ tiêu (mỗi trụ cột 4 chỉ tiêu, mỗi chỉ tiêu đóng góp một thứ hạng vào điểm tổng từ 1 đến $N$, không mặc định là trọng số kinh tế 50% hiệu chỉnh bằng mô hình định lượng):
- **Trụ cột 1: Kết quả kinh doanh và kiểm soát chất lượng tăng trưởng (`diem_qm`):** Gồm 3 chỉ tiêu bán hàng cá nhân (Doanh số cho vay mới, Số thẻ phát sinh dư nợ bình quân, Tỷ lệ duyệt hồ sơ) cùng 1 chỉ tiêu kiểm soát chất lượng tín dụng địa bàn (Tỷ lệ rủi ro tín dụng mở rộng toàn vùng). Cần lưu ý rằng **tỷ lệ phê duyệt hồ sơ càng cao chưa chắc đã tốt**: tỷ lệ duyệt cao có thể do khả năng khai thác khách hàng tốt nhưng cũng có thể do nới lỏng tiêu chuẩn thẩm định tín dụng. Do đó, chỉ tiêu này bắt buộc phải được đánh giá song hành cùng tỷ lệ rủi ro nợ xấu địa bàn.
- **Trụ cột 2: Hiệu quả tài chính (`diem_fin`):** Gồm 4 chỉ tiêu cấp vùng (Hệ số CIR, Biên lợi nhuận Margin, Hệ số hiệu quả vốn, Lợi nhuận bình quân/ASM). Do hợp đồng thẻ không gắn mã định danh cá nhân từng ASM (chỉ quản lý theo chi nhánh/vùng), việc gắn kết quả tài chính và rủi ro địa bàn vào thẻ điểm cá nhân là giải pháp cần thiết để ràng buộc trách nhiệm quản trị chung, hạn chế việc chạy theo doanh số ngắn hạn bỏ mặc chất lượng tài sản.

**Làm rõ bản chất Tỷ lệ rủi ro tín dụng mở rộng (bao gồm nợ đã xử lý rủi ro):**
Trong thủ tục Stored Procedure SQL (`report_id = 204`), chỉ tiêu được triển khai là:

$$\text{Tỷ lệ rủi ro tín dụng mở rộng} = \frac{\text{Dư nợ nhóm 3–5} + \text{Write-off lũy kế}}{\text{Tổng dư nợ} + \text{Write-off lũy kế}} \times 100$$

Khác với tỷ lệ NPL thông thường (chỉ tính nợ nhóm 3–5 nội bảng trên tổng dư nợ), đây là **chỉ tiêu quản trị tự xây dựng** được kiểm chứng qua tệp tham chiếu `input/Tham so va mau doi chieu.xlsx` (đóng vai trò nguồn tham chiếu xác nhận hướng đi đúng). Khoản xử lý rủi ro (write-off) được cộng dồn theo giá trị lũy kế từ đầu năm nhằm tránh hiện tượng nợ xấu nội bảng giảm cơ học sau các đợt xóa nợ kỹ thuật. *Giới hạn nghiệp vụ cần lưu ý:* Chỉ tiêu này phản ánh cả lịch sử tổn thất tích lũy chứ không thuần túy là chất lượng danh mục hiện tại. Những vùng có danh mục thẻ lâu năm có thể tích lũy lượng nợ write-off lớn hơn vùng mới mở rộng, do đó cần được xem xét thận trọng khi so sánh trực tiếp giữa các vùng có tuổi đời danh mục khác biệt.

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│          BỘ CHỈ TIÊU ĐÁNH GIÁ HIỆU QUẢ HOẠT ĐỘNG QUẢN LÝ VÙNG (SCORECARD)              │
├──────────────────────────────────────────┬─────────────────────────────────────────────┤
│ TRỤ CỘT 1: KẾT QUẢ KINH DOANH & KIỂM SOÁT│ TRỤ CỘT 2: HIỆU QUẢ TÀI CHÍNH (diem_fin)    │
│ CHẤT LƯỢNG TĂNG TRƯỞNG (diem_qm)         │                                             │
│ • Doanh số cho vay mới bình quân (Cao tốt)│ • Tỷ lệ chi phí / thu nhập - CIR (Thấp tốt) │
│ • Số thẻ phát sinh dư nợ bình quân (Cao) │ • Biên lợi nhuận - Margin (Cao tốt)         │
│ • Tỷ lệ duyệt hồ sơ bình quân (Đánh giá) │ • Hệ số hiệu quả vốn (Cao tốt)              │
│ • TỶ LỆ RỦI RO TÍN DỤNG MỞ RỘNG (Thấp)   │ • Lợi nhuận bình quân / Quản lý (Cao tốt)   │
│   (Bao gồm nợ đã xử lý rủi ro ngoại bảng)│   (Gắn trách nhiệm quản trị với địa bàn)    │
└──────────────────────────────────────────┴─────────────────────────────────────────────┘
```

**Bảng chi tiết 8 chỉ tiêu đánh giá quản lý vùng (ASM):**

| Chỉ tiêu | Khía cạnh đo lường | Tại sao cần thiết? | Nguồn dữ liệu | Chiều đánh giá | Cấp độ hạt | Giới hạn cần lưu ý |
|---|---|---|---|---|---|---|
| **Doanh số giải ngân mới** | Năng lực bán hàng trực tiếp | Phản ánh tốc độ mở rộng thị trường | Bảng chỉ tiêu KPI | Càng cao càng tốt | Cá nhân ASM | Chưa tính đến tỷ lệ hủy thẻ sau phát hành |
| **Số thẻ active bình quân** | Mức độ thâm nhập khách hàng | Đo lường khách hàng thực sự sử dụng thẻ | Sao kê hợp đồng | Càng cao càng tốt | Cá nhân ASM | Cần duy trì chi phí kích hoạt thẻ |
| **Tỷ lệ phê duyệt hồ sơ** | Năng lực sàng lọc hồ sơ | Đánh giá chất lượng hồ sơ nộp lên | Bảng chỉ tiêu KPI | Càng cao càng tốt | Cá nhân ASM | Nguy cơ nới lỏng thẩm định nếu duyệt quá cao |
| **Tỷ lệ nợ xấu vùng (NPL)** | Kỷ luật kiểm soát rủi ro tín dụng | Hạn chế động cơ nới lỏng rủi ro | Sao kê hợp đồng | Càng thấp càng tốt | Cấp vùng | Hợp đồng thẻ không ghi mã ASM, tính chung vùng |
| **Hệ số CIR vùng** | Hiệu quả quản trị chi phí | Đo lường mức độ tiêu hao chi phí hoạt động | Sổ cái kế toán | Càng thấp càng tốt | Cấp vùng | Phụ thuộc vào chi phí phân bổ từ Hội sở |
| **Biên lợi nhuận (Margin)** | Chất lượng sinh lời dòng tiền | Đảm bảo tăng trưởng gắn liền biên lợi nhuận | Sổ cái kế toán | Càng cao càng tốt | Cấp vùng | Nhạy cảm với biến động lãi suất vốn điều chuyển |
| **Hệ số hiệu quả vốn** | Năng suất sử dụng tài sản | Đo lường lợi nhuận tạo ra trên dư nợ | Sổ cái & Sao kê | Càng cao càng tốt | Cấp vùng | Phản ánh hiệu quả tổng hợp toàn địa bàn |
| **Lợi nhuận bình quân/ASM** | Trách nhiệm đóng góp tài chính | Gắn quyền lợi người quản lý với lợi nhuận | Sổ cái & Headcount| Càng cao càng tốt | Cấp vùng | Chia đều theo định biên nhân sự quản lý vùng |

*Phương pháp tổng hợp điểm và xử lý chỉ tiêu khác đơn vị đo lường:*
Do các chỉ số có đơn vị đo lường khác nhau (triệu đồng, số lượng thẻ, tỷ lệ phần trăm), không thể cộng trực tiếp các giá trị thô. Hệ thống áp dụng phương pháp **Xếp hạng phân vị độc lập từng chỉ số (Rank Scaling)**:
- Mỗi chỉ tiêu được xếp hạng từ 1 đến $N$ trong toàn ngân hàng (thứ hạng 1 đại diện cho thành tích tốt nhất).
- Với các chỉ tiêu "càng thấp càng tốt" (tỷ lệ nợ xấu, hệ số CIR), thuật toán đảo chiều xếp hạng để giá trị thấp nhất đạt thứ hạng 1.
- Điểm tổng kết quả là tổng thứ hạng của 2 trụ cột:
$$\text{Điểm tổng} = \text{Điểm Quy mô } (diem\_qm) + \text{Điểm Tài chính } (diem\_fin)$$
- Quản lý vùng nào có **Điểm tổng càng thấp thì thứ hạng chung cuộc trên bảng xếp hạng toàn quốc càng cao**. Thang đo áp dụng cho đội ngũ từ 74 đến 84 quản lý vùng qua các tháng.

---

## 6. 🧪 Kiểm Tra Và Đối Soát Dữ Liệu

**Bối cảnh kiểm chứng độc lập:** Trong thực tế triển khai, không có sẵn bảng kết quả mẫu để đối chiếu từng con số. Do đó, hệ thống kiểm tra được thiết kế gồm 5 lớp kiểm soát độc lập, giúp tự kiểm tra tính nhất quán và độ chính xác của toàn bộ quy trình xử lý.

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                      HỆ THỐNG KIỂM SOÁT VÀ ĐỐI SOÁT DỮ LIỆU 5 LỚP                      │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ Lớp 1: ĐỐI SOÁT BẢO TOÀN DÒNG TIỀN (GL Reconciliation: Tổng vùng = Tổng toàn hàng)    │
│ Lớp 2: RÀNG BUỘC TOÁN HỌC BẤT BIẾN (Mathematical Invariants: Sum(Ratio) = 1.0)        │
│ Lớp 3: KIỂM SOÁT TOÀN VẸN VÀ CHẤT LƯỢNG DỮ LIỆU (Data Quality & Referential Integrity) │
│ Lớp 4: KIỂM TRA TÍNH HỢP LÝ NGHIỆP VỤ (Business Sanity Checks & Red Flags)            │
│ Lớp 5: TÍNH TOÁN LẠI ĐỐI SOÁT HỆ THỐNG (Independent Recalculation & Cross-Audit)       │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

### Lớp 1 – Đối soát bảo toàn số liệu (GL Reconciliation)
- **Rủi ro kiểm soát:** Thất thoát dòng tiền hoặc nhân đôi chi phí khi thực hiện phân bổ 181 bút toán Hội sở về các vùng.
- **Nguyên tắc kiểm soát:** Tổng chi phí và thu nhập sau phân bổ của 7 vùng cộng với phần Hội sở còn lại phải khớp chính xác 100% tổng phát sinh trên sổ cái kế toán toàn ngân hàng:
$$\left| \sum_{k=1}^7 \text{Chi phí phân bổ vùng } k - \text{Chi phí Hội sở} \right| \le 10^{-6}$$
- **Cách thức triển khai:** Chạy truy vấn SQL tổng hợp đối chiếu chênh lệch giữa bảng dữ liệu thô `stg_fact_txn_month` và bảng dữ liệu sau phân bổ `fct_pnl_allocation`.
- **Kết quả thực tế:** Sai lệch bằng đúng $0,00$ VNĐ trên toàn bộ 63.134 dòng bút toán sổ cái của cả 5 tháng phân tích.
- **Giới hạn còn tồn tại:** Nguyên tắc bảo toàn chỉ kiểm tra tính toàn vẹn của phép tính phân bổ, không phát hiện được sai sót nếu bản thân bút toán gốc trên sổ cái GL bị hạch toán sai tài khoản.

### Lớp 2 – Kiểm tra tính đúng đắn của công thức (Mathematical Invariants)
- **Rủi ro kiểm soát:** Lỗi chia cho 0 khi mẫu số bằng 0, tỷ trọng phân bổ không trọn vẹn gây hao hụt chi phí, hoặc sai quy tắc dấu của các khoản mục chi phí âm/dương.
- **Nguyên tắc kiểm soát:** Tổng tỷ trọng phân bổ của từng tiêu thức kinh tế phải bằng chính xác 1:
$$\sum_{i=1}^7 w_i = 1,000000 \quad (\text{với mọi tiêu thức phân bổ})$$
Mọi phép chia đều phải được bọc qua điều kiện kiểm tra mẫu số an toàn `NULLIF(denominator, 0)`.
- **Cách thức triển khai:** Chạy các câu lệnh kiểm tra tự động quét bảng tạm phân bổ `tmp_pnl_step2_head_alloc_ratio` để kiểm tra tổng trọng số của 9 tiêu thức kinh tế.
- **Kết quả thực tế:** $100\%$ các tiêu thức phân bổ có tổng tỷ lệ đạt đúng 1; không phát sinh bất kỳ lỗi chia cho 0 hay giá trị vô định (`NaN`/`Infinity`).
- **Giới hạn còn tồn tại:** Giả định tỷ trọng phân bổ là tuyến tính bậc nhất theo quy mô driver, chưa xét đến các mô hình chi phí phi tuyến tính hoặc chi phí biên.

### Lớp 3 – Kiểm soát chất lượng dữ liệu (Data Quality Checks)
- **Rủi ro kiểm soát:** Bản ghi bị trùng lặp khi nạp file Excel, rơi rụng dòng dữ liệu khi kết nối khóa ngoại, hoặc mã chi nhánh không ánh xạ được vào 7 vùng.
- **Nguyên tắc kiểm soát:** Toàn vẹn tham chiếu khóa ngoại (*Referential Integrity*) và tính duy nhất của dữ liệu (*Uniqueness*).
- **Cách thức triển khai:** Kiểm tra đếm dòng trước và sau câu lệnh `JOIN`; quét các bản ghi mang mã tỉnh không nằm trong danh mục `dim_param_area`.
- **Kết quả thực tế:** Toàn bộ 2.932.922 dòng sao kê hợp đồng thẻ và 63.134 dòng bút toán sổ cái được nạp đầy đủ; không phát sinh bản ghi mồ côi (*orphan records*). 181 dòng bút toán Hội sở mang mã tỉnh `'00'` được chuyển hướng xử lý thành công qua luồng phân bổ gián tiếp.
- **Giới hạn còn tồn tại:** Trường hợp khách hàng thay đổi địa chỉ cư trú giữa các tháng nhưng chi nhánh mở thẻ không đổi thì hợp đồng vẫn được tính cho vùng của chi nhánh mở ban đầu.

### Lớp 4 – Kiểm tra tính hợp lý nghiệp vụ (Business Sanity Checks)
- **Rủi ro kiểm soát:** Kết quả tính toán vi phạm các giới hạn lý thuyết kinh tế hoặc biến động bất thường mà không có nguyên nhân nghiệp vụ giải thích.
- **Nguyên tắc kiểm soát:** Thiết lập các biên độ giá trị tài chính hợp lý:
  - Tỷ lệ nợ xấu vùng $NPL \in [0\%, 100\%]$; Dư nợ, số thẻ, định biên nhân sự $\ge 0$.
  - Chi phí trích lập dự phòng phải đồng biến với tốc độ dịch chuyển của nợ xấu nhóm 3 đến nhóm 5.
  - Cảnh báo cờ đỏ (*Red Flag*) đối với các khoản mục chi phí có mức biến động tháng $MoM > \pm 50\%$.
- **Cách thức triển khai:** Thực hiện các truy vấn kiểm tra miền giá trị trên bảng sự kiện và phân tích độ nhạy xu hướng theo chuỗi thời gian từ tháng 1 đến tháng 5/2023.
- **Kết quả thực tế:** Tỷ lệ nợ xấu 7 vùng dao động thực tế trong biên độ từ 10,11% đến 21,99% xuyên suốt 5 tháng (riêng tháng 5/2023 từ 11,24% đến 21,99%). Phát hiện và giải thích thỏa đáng việc chi phí dự phòng tháng 5/2023 tăng đột biến là do trích lập nợ nhóm 3 đến nhóm 5 phát sinh từ đợt mở rộng tín dụng quý trước đó.
- **Giới hạn còn tồn tại:** Phương pháp kiểm tra ngưỡng biến động không phân biệt được biến động do hoạt động kinh doanh tự nhiên với các điều chỉnh chính sách kế toán hồi tố nếu phòng kế toán không cung cấp thuyết minh đi kèm.

### Lớp 5 – Tính toán lại độc lập và đối soát hệ thống (Independent Recalculation & Cross-Audit)
- **Rủi ro kiểm soát:** Sai lệch logic ẩn trong quá trình chuyển đổi giữa cơ sở dữ liệu PostgreSQL và tầng trình diễn Power BI.
- **Nguyên tắc kiểm soát:** Kiểm toán chéo trên mẫu đơn lẻ (*Single-Case Reverse Audit*) và đối soát toàn diện giữa các hệ thống độc lập.
- **Cách thức triển khai:**
  1. *Kiểm toán ngược trên mẫu:* Chọn ngẫu nhiên 3 trường hợp đại diện (Vùng Đông Nam Bộ, Vùng Tây Bắc Bộ và 1 quản lý vùng (ASM) cụ thể), tự tính toán lại bằng công thức nháp ngoài hệ thống SQL và so sánh kết quả.
  2. *Đối soát hệ thống chéo:* Thực hiện kiểm tra toàn diện **91 ô dữ liệu** (13 chỉ tiêu tài chính cốt lõi $\times$ 7 vùng tại tháng 5/2023) giữa câu lệnh truy vấn PostgreSQL và 72 measure DAX trên Power BI.
  3. *Đối chiếu tệp tham số và mẫu đối chứng lịch sử:* So sánh kết quả với `input/Tham so va mau doi chieu.xlsx` (cung cấp bảng tham số ánh xạ tại sheet Param, quy cách biểu mẫu báo cáo tại sheet BaoCaoTongHop và XepHang, cùng các mốc kiểm chứng lịch sử: LNTT tháng 2/2023 đạt 92.226,35 triệu đồng, tháng 5/2023 đạt 250.450,06 triệu đồng, Top 1 quản lý vùng (ASM) toàn quốc thuộc về nhân sự nam.hoangvan với 34 điểm). Khung kiểm chứng 5 lớp vận hành độc lập, coi tệp này là nguồn tham chiếu lịch sử chứ không phụ thuộc thụ động vào tệp ngoài.
- **Kết quả thực tế:**
  - Kết quả tính toán tay độc lập trùng khớp tuyệt đối với kết quả xuất ra từ hệ thống Stored Procedure SQL.
  - Toàn bộ **91 ô dữ liệu đối soát giữa PostgreSQL và Power BI ghi nhận mức chênh lệch bằng đúng 0**.
  - Khớp chuẩn xác từng chữ số với nguồn đối chứng: LNTT tháng 2/2023 đạt **92.226,35 triệu đồng**, tháng 5/2023 đạt **250.450,06 triệu đồng**, Top 1 quản lý vùng (ASM) toàn quốc thuộc về nhân sự `nam.hoangvan` với **34 điểm**.
- **Giới hạn còn tồn tại:** Phép tính toán lại thủ công chỉ áp dụng được trên mẫu kiểm toán đại diện, việc kiểm soát toàn bộ hàng triệu giao dịch phụ thuộc vào 4 lớp kiểm tra tự động trước đó.

---

## 7. 📊 Kết Quả Phân Tích Và Đề Xuất Quản Trị

### Phần A – Đánh giá mức độ đáp ứng yêu cầu ban đầu:

| Yêu cầu ban đầu của Ban Lãnh Đạo | Sản phẩm đầu ra xây dựng | Kết quả đánh giá mức độ đáp ứng |
|---|---|---|
| **Đo lường lãi lỗ thực chất 7 vùng** | Báo cáo P&L phân bổ chi phí Hội sở | **Đáp ứng 100%**: 7 vùng được phân bổ đầy đủ chi phí gián tiếp, bảo toàn tuyệt đối dòng tiền sổ cái. |
| **Phân tích biến động hàng tháng** | Biểu đồ thác nước Waterfall 6 cấu phần | **Đáp ứng 100%**: Tách bạch rõ ràng số phát sinh từng tháng, chỉ rõ nguyên nhân tăng giảm lợi nhuận. |
| **Theo dõi chất lượng tín dụng** | Ma trận Lợi nhuận – Rủi ro & Tỷ lệ nợ xấu | **Đáp ứng tốt**: Định vị chính xác các vùng có nợ xấu cao để cảnh báo sớm rủi ro tín dụng. |
| **Xếp hạng công bằng quản lý vùng** | Bảng xếp hạng 2 trụ cột độc lập | **Đáp ứng tốt**: Kết hợp giữa quy mô bán hàng và kiểm soát rủi ro cho toàn bộ 74 - 84 nhân sự. |
| **Hệ thống điều hành trực quan** | Dashboard Power BI 5 trang & Excel đối chiếu | **Đáp ứng 100%**: Cung cấp công cụ phân tích tương tác tức thì cho lãnh đạo và tệp chi tiết cho kế toán. |

### Phần B – Phân tích các phát hiện chính từ số liệu tháng 5/2023:

1. **Tây Nam Bộ – Lợi nhuận tăng chủ yếu nhờ chi phí dự phòng ròng giảm:**
   - *Dữ kiện quan sát được (Observed Facts):* Lợi nhuận trước thuế của vùng tăng vọt **+4.267,8 triệu đồng**, đóng góp tới **97,2%** mức tăng lợi nhuận toàn hệ thống trong tháng 5. Tuy nhiên, thu nhập thuần từ thẻ chỉ tăng nhẹ +16,3 triệu đồng, chi phí hoạt động làm giảm lợi nhuận −195,9 triệu đồng, trong khi **chi phí trích lập dự phòng ròng giảm +4.447,3 triệu đồng**. Vùng ghi nhận **tỷ lệ rủi ro nợ xấu mở rộng cao nhất hệ thống (21,99%)** và không có quản lý vùng (ASM) nào lọt vào nhóm 25 vị trí dẫn đầu.
   - *Nhận định nghiệp vụ (Business Inferences):* Lợi nhuận tháng 5 tăng chủ yếu nhờ chi phí dự phòng ròng giảm. Thu nhập thuần từ hoạt động thẻ chỉ tăng 16,3 triệu đồng so với tháng trước, gần như không thay đổi, chưa cho thấy sự cải thiện đáng kể về nguồn thu kinh doanh cốt lõi trong kỳ.
   - *Nội dung cần xác minh thêm (Hypotheses Requiring Further Verification):* Cần xác minh xem chi phí dự phòng giảm có thực chất đến từ thu hồi nợ xấu hay do điều chỉnh kỹ thuật giãn nợ; đề xuất kiểm tra thực địa chất lượng thu hồi nợ trong tháng 7.

2. **Đông Nam Bộ – Thu nhập thuần tăng nhưng lợi nhuận vẫn âm do áp lực chi phí dự phòng:**
   - *Dữ kiện quan sát được (Observed Facts):* Vùng ghi nhận mức lỗ trước thuế **−8.787,4 triệu đồng** trong tháng. Hoạt động bán hàng tăng trưởng mạnh khi **thu nhập thuần tăng tới +3.210,7 triệu đồng**, nhưng bị bù trừ bởi **chi phí trích lập dự phòng tăng thêm −3.234,2 triệu đồng**, khiến **16 trong số 19 quản lý vùng** rơi xuống nửa cuối bảng xếp hạng dù doanh số cao.
   - *Nhận định nghiệp vụ (Business Inferences):* Lợi nhuận âm là kết quả ghi nhận thực tế khi chi phí trích lập dự phòng rủi ro tín dụng phát sinh trong kỳ vượt quá mức tăng thu nhập thuần tạo ra từ hoạt động kinh doanh mới.
   - *Nội dung cần xác minh thêm (Hypotheses Requiring Further Verification):* Cần thực hiện phân tích vintage/cohort để kiểm chứng xem các khoản cho vay tăng trưởng nhanh trong quá khứ có đang chuyển nhóm nợ quá hạn hay không; rà soát danh mục hợp đồng nợ xấu tại Đông Nam Bộ trong 30 ngày để đánh giá tốc độ dịch chuyển nợ và điều chỉnh tiêu chí phê duyệt.

3. **Đồng bằng Sông Hồng – Lợi nhuận tăng nhờ chi phí dự phòng ròng giảm:**
   - *Dữ kiện quan sát được (Observed Facts):* Lợi nhuận trước thuế của vùng tăng thêm **+1.310,9 triệu đồng** so với tháng trước, trong khi thu nhập thuần từ thẻ thực tế giảm **−232,2 triệu đồng** và chi phí dự phòng ròng ghi nhận giảm **+1.455,8 triệu đồng**.
   - *Nhận định nghiệp vụ (Business Inferences):* Thu nhập thuần giảm trong tháng 5 là dấu hiệu cần theo dõi thêm ở các kỳ tiếp theo, đặc biệt trong bối cảnh lợi nhuận tổng vẫn tăng nhờ chi phí dự phòng ròng giảm.
   - *Nội dung cần xác minh thêm (Hypotheses Requiring Further Verification):* Khi sổ sách chưa bóc tách dòng trích lập dự phòng mới và hoàn nhập, cần kiểm toán nội bộ số liệu dự phòng chi tiết để phân biệt giữa suy giảm rủi ro tự nhiên và điều chỉnh kế toán kỹ thuật trước khi kết luận về xu hướng dài hạn.

4. **Nam Trung Bộ – Kết quả xếp hạng tốt đi cùng tỷ lệ nợ xấu thấp:**
   - *Dữ kiện quan sát được (Observed Facts):* Địa bàn quy mô 5 quản lý vùng duy trì tỷ lệ rủi ro nợ xấu mở rộng thấp nhất toàn ngân hàng (**11,24%**) và có tới **4 trong số 5 quản lý vùng** nằm trong nhóm 25 vị trí dẫn đầu cả nước.
   - *Nhận định nghiệp vụ (Business Inferences):* Kết quả này cho thấy Nam Trung Bộ là địa bàn đáng được nghiên cứu thêm về phương pháp phát triển khách hàng và kiểm soát chất lượng tín dụng.
   - *Nội dung cần xác minh thêm (Hypotheses Requiring Further Verification):* Do quy mô địa bàn nhỏ (5 quản lý vùng), cần khảo sát chi tiết quy trình thẩm định và sàng lọc khách hàng thực địa của Nam Trung Bộ để đánh giá tính khả thi trước khi xem xét thí điểm nhân rộng có kiểm soát sang các vùng khác.

### Năm đề xuất hành động cụ thể gửi Ban Lãnh Đạo:

| # | Đề xuất quản trị | Căn cứ số liệu thực tế | Đơn vị phụ trách · Thời hạn |
|:---:|:---|:---|:---|
| 01 | **Bổ sung chỉ tiêu lợi nhuận loại trừ biến động dự phòng:** Yêu cầu phân tách rõ trích lập dự phòng mới và hoàn nhập dự phòng để phản ánh đúng lợi nhuận kinh doanh cốt lõi. | Báo cáo hiện tại chỉ có một dòng dự phòng ròng, che khuất biến động thực chất | Khối Quản lý rủi ro · Tháng 6 |
| 02 | **Rà soát danh mục nợ xấu tại 3 vùng trọng điểm:** Kiểm tra các hợp đồng phát sinh nợ quá hạn tại Đông Nam Bộ, Đông Bắc Bộ và Tây Bắc Bộ. | Tổng chi phí dự phòng tại 3 vùng này tăng thêm **6.035,1 triệu đồng** trong tháng | Quản lý vùng + Quản lý rủi ro · 30 ngày |
| 03 | **Kiểm tra thực địa quy trình cấp tín dụng và thu hồi nợ tại Tây Nam Bộ:** Thẩm định lại chất lượng hồ sơ và hiệu quả thu hồi nợ. | Nợ xấu chiếm **21,99%** (cao nhất hệ thống) nhưng vùng lại chiếm **97,2%** mức tăng lợi nhuận | Khối Kinh doanh + Quản lý rủi ro · Tháng 7 |
| 04 | **Nghiên cứu và thí điểm có kiểm soát phương pháp của Nam Trung Bộ:** Khảo sát quy trình thẩm định và sàng lọc khách hàng trước khi xem xét mở rộng. | Tỷ lệ nợ xấu thấp nhất (**11,24%**) và 4/5 quản lý vùng đạt top 25 | Khối Kinh doanh · Đánh giá sau 2 tháng |
| 05 | **Rà soát tiêu chí đánh giá và cơ chế xét thưởng:** Không dùng riêng lợi nhuận tháng để khen thưởng hay kỷ luật; kết hợp kết quả bán hàng, chất lượng tín dụng, hiệu quả tài chính và thời gian quản lý địa bàn. | Tránh việc đánh giá lệch cho các vùng có lợi nhuận tăng do giảm trích lập dự phòng | Ban điều hành · Áp dụng ngay |

---

## 8. 📚 Kinh Nghiệm Triển Khai Thực Chiến

1. **Hiểu rõ bản chất nghiệp vụ trước khi viết code:**
   Trong hệ thống dữ liệu tài chính, việc hiểu rõ tại sao chi phí vốn mang dấu âm, vì sao chi phí Hội sở mang mã tỉnh `'00'` và vùng `'A'` là điều kiện tiên quyết để xây dựng câu lệnh SQL phân bổ chính xác. Không thể giải quyết bài toán dữ liệu ngân hàng nếu chỉ tiếp cận thuần tuý dưới góc độ công nghệ.

2. **Làm sạch dữ liệu danh mục là điều kiện sống còn của báo cáo:**
   Phát hiện sự sai lệch giữa chuỗi ký tự "Bà Rịa - Vũng Tàu" và "Vũng Tàu" trong quá trình tiền xử lý đã giữ lại trọn vẹn hơn **36.000 hợp đồng thẻ**, ngăn chặn sai lệch nghiêm trọng đối với tỷ lệ nợ xấu của vùng Đông Nam Bộ.

3. **Kiểm soát tính toàn vẹn và giao dịch trong quy trình ETL:**
   Việc thiết kế 6 bảng tạm trung gian cùng cấu trúc dữ liệu dạng dọc và quản lý transaction chặt chẽ trong các Stored Procedure giúp hệ thống có khả năng truy vết lỗi (audit trail) ở từng bước tính toán và rollback an toàn nếu phát sinh sự cố.

4. **Không đánh giá hiệu quả kinh doanh qua một con số tổng duy nhất:**
   Một con số lợi nhuận dương có thể che giấu sự suy giảm của hoạt động kinh doanh cốt lõi hoặc sự gia tăng của nợ xấu tiềm ẩn. Phân rã cấu phần và so sánh đa chiều là nguyên tắc cốt lõi của phân tích dữ liệu quản trị.

5. **Nhận thức rõ giới hạn của dữ liệu để tránh kết luận vội vã:**
   Khi dữ liệu nợ xấu chỉ dừng ở cấp vùng chứ chưa chi tiết đến từng hợp đồng của từng quản lý vùng, báo cáo phải nêu rõ giới hạn này để Ban Lãnh Đạo sử dụng số liệu đúng phạm vi, không suy diễn vượt quá bằng chứng thực tế.

---

## 9. 🛠️ Công Nghệ Sử Dụng

Các công cụ được lựa chọn dựa trên sự phù hợp với yêu cầu thực tế của từng giai đoạn trong dự án:

| Công nghệ | Thành phần | Vai trò kỹ thuật trong dự án | Lý do lựa chọn |
|---|---|---|---|
| **Python 3.10** | `openpyxl`, `zipfile`, `xml.etree` | Đọc dữ liệu Excel thô gần 3 triệu dòng, chuẩn hoá ký tự và nạp dữ liệu vào kho | Xử lý streaming tệp lớn 117,2 MB mà không làm tràn bộ nhớ RAM |
| **PostgreSQL 15** | PL/pgSQL, Stored Procedure | Lưu trữ kho dữ liệu Star Schema (19 bảng, 4 `view`), thực thi logic phân bổ chi phí và xếp hạng | Khả năng xử lý tập dữ liệu lớn với độ chính xác cao và kiểm soát transaction chặt chẽ |
| **Power BI Desktop** | Import Mode, 72 Measure DAX | Dựng 5 trang dashboard phân tích trực quan, tương tác đa chiều | Cung cấp trải nghiệm theo dõi trực quan tức thì và chẩn đoán dữ liệu cho Ban Lãnh Đạo |
| **Microsoft Excel** | XLSX, Advanced Formulas | Xuất báo cáo quản trị 7 sheet tự động qua tập lệnh Python | Phục vụ thói quen đối soát công thức chi tiết từng ô của Phòng Kế toán - Tài chính |

---

## 10. 📂 Cấu Trúc Thư Mục Dự Án

Cấu trúc dự án được chuẩn hoá thành 6 thư mục nghiệp vụ rõ ràng:

```text
.
├── input/              # Lưu tệp tham số và mẫu báo cáo; 3 nguồn dữ liệu thô vượt trần dung lượng GitHub nên quản lý riêng
│   └── Tham so va mau doi chieu.xlsx  # Quy đổi 64 tỉnh thành về 8 vùng, đối chiếu tài khoản sổ cái, biểu mẫu chuẩn của 2 báo cáo
├── ingestion/          # Các chương trình Python đọc dữ liệu Excel, chuẩn hoá dữ liệu, nạp vào kho và xuất báo cáo
│                       # run_all.py điều phối chạy 4 bước nạp · run_report.py tự động kiểm tra số mới và xuất báo cáo Excel
├── sql/                # Mã nguồn SQL tạo bảng, bảng tạm, thủ tục lưu trữ và khung nhìn báo cáo
│   ├── dim/            # Bảng danh mục: dim_month_headcount, dim_asm, dim_report_detail
│   ├── tmp/            # Bảng tạm và thủ tục tính trung gian cho P&L (step 1-3) và Xếp hạng ASM (step 1-3)
│   ├── fct/            # Bảng sự kiện chính và thủ tục điều phối: fct_pnl_allocation, fct_xephang_asm
│   └── rpt/            # Khung nhìn báo cáo: rpt_pnl_view, rpt_xephang_view
├── images/             # Sơ đồ quy trình kỹ thuật, kiến trúc kho dữ liệu và ảnh chụp các trang dashboard
├── docs/               # Bộ tài liệu vận hành chi tiết: HIEN_TRANG_HE_THONG, PIPELINE, NHAT_KY_CONG_VIEC, LOI_THUONG_GAP
├── output/             # Sản phẩm đầu ra: Báo cáo quản trị Power BI (.pbix) và báo cáo Excel
├── README.md           # Tài liệu dự án bằng tiếng Việt (mặc định)
└── README_eng.md       # Tài liệu dự án bằng tiếng Anh
```

---

## 11. 📖 Tài Liệu Bàn Giao

Hệ thống được tài liệu hoá đầy đủ trong thư mục `docs/`:
- [`docs/HIEN_TRANG_HE_THONG.md`](docs/HIEN_TRANG_HE_THONG.md) — Chi tiết hiện trạng kho dữ liệu, số dòng của 19 bảng và 4 `view`, phân quyền quản lý từng bảng và các mốc đối soát chuẩn.
- [`docs/PIPELINE.md`](docs/PIPELINE.md) — Kiến trúc luồng xử lý 4 giai đoạn và hướng dẫn chạy kiểm tra dữ liệu.
- [`docs/NHAT_KY_CONG_VIEC.md`](docs/NHAT_KY_CONG_VIEC.md) — Nhật ký chi tiết các hạng mục công việc đã thực hiện qua từng giai đoạn phát triển.
- [`docs/LOI_THUONG_GAP.md`](docs/LOI_THUONG_GAP.md) — Sổ tay xử lý sự cố tổng hợp **58 tình huống lỗi thực tế** từ dữ liệu nguồn, SQL, Python đến DAX.

---

## 12. 👤 Tác Giả

<div align="center">

**Trần Ngọc Đức** · Data Analyst · Business Intelligence · Data Science · Management Information Systems · Operations

[Email](mailto:tranduc22104@gmail.com) · [LinkedIn](https://www.linkedin.com/in/tr%E1%BA%A7n-ng%E1%BB%8Dc-%C4%91%E1%BB%A9c-48b3a7439/)

</div>
