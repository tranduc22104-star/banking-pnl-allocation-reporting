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

1. [🏢 Bối Cảnh Và Bài Toán Ban Lãnh Đạo Đặt Ra](#1--bối-cảnh-và-bài-toán-ban-lãnh-đạo-đặt-ra)
2. [🎯 Định Hình "Đầu Ra" Của Hệ Thống Báo Cáo](#2--định-hình-đầu-ra-của-hệ-thống-báo-cáo)
3. [🔍 Khảo Sát, Thu Thập Và Đánh Giá Dữ Liệu "Đầu Vào"](#3--khảo-sát-thu-thập-và-đánh-giá-dữ-liệu-đầu-vào)
4. [🧮 Xây Dựng Quy Trình Xử Lý Và Thiết Kế Công Thức Tính Toán](#4--xây-dựng-quy-trình-xử-lý-và-thiết-kế-công-thức-tính-toán)
5. [🖥️ Trực Quan Hoá Báo Cáo Và Đánh Giá Mức Độ Đáp Ứng Bài Toán](#5-️-trực-quan-hoá-báo-cáo-và-đánh-giá-mức-độ-đáp-ứng-bài-toán)
6. [📊 Nhận Xét Dữ Liệu Sau Trực Quan Và Đề Xuất Quản Trị](#6--nhận-xét-dữ-liệu-sau-trực-quan-và-đề-xuất-quản-trị)
7. [📚 Kinh Nghiệm Triển Khai Thực Chiến](#7--kinh-nghiệm-triển-khai-thực-chiến)
8. [🗄️ Cấu Trúc Kho Dữ Liệu](#8-️-cấu-trúc-kho-dữ-liệu)
9. [🛠️ Công Cụ Và Công Nghệ Sử Dụng](#9-️-công-cụ-và-công-nghệ-sử-dụng)
10. [📂 Cấu Trúc Dự Án](#10--cấu-trúc-dự-án)
11. [🔒 Nguồn Dữ Liệu Và Quyền Sử Dụng](#11--nguồn-dữ-liệu-và-quyền-sử-dụng)
12. [📖 Tài Liệu Bàn Giao](#12--tài-liệu-bàn-giao)
13. [💼 Kỹ Năng Áp Dụng Trong Dự Án](#13--kỹ-năng-áp-dụng-trong-dự-án)
14. [👤 Tác Giả](#14--tác-giả)

---

## 1. 🏢 Bối Cảnh Và Bài Toán Ban Lãnh Đạo Đặt Ra

Trong hoạt động kinh doanh thẻ tín dụng (vận hành trên **7 vùng kinh doanh** với đội ngũ từ **74 đến 84 quản lý vùng - ASM**), Ban Lãnh Đạo cần một bảng báo cáo phản ánh đúng thực tế kết quả kinh doanh cũng như là năng lực của các quản lý vùng. Do đó, Ban Lãnh Đạo giao cho Khối Phân tích Dữ liệu đề bài xây dựng hệ thống báo cáo quản trị hàng tháng với **2 yêu cầu trọng tâm**:

1. **Đo lường lãi lỗ thực chất cho 7 vùng kinh doanh:**
   Phần lớn doanh thu (lãi vay, phí thẻ) được ghi nhận tại các vùng, nhưng các khoản chi phí lớn nhất (chi phí vốn huy động, tiếp thị, công nghệ, lương thưởng khối hỗ trợ) lại hạch toán tập trung tại Hội sở. Khối Phân tích Dữ liệu cần xây dựng cơ chế phân bổ toàn bộ chi phí và thu nhập Hội sở về 7 vùng theo các tiêu thức kinh tế hợp lý, minh bạch, giúp Ban Lãnh Đạo nhìn rõ vùng nào thực lãi và vùng nào thực chất đang lỗ.

2. **Xây dựng thẻ điểm xếp hạng công bằng cho đội ngũ quản lý vùng:**
   Bỏ cơ chế đánh giá thuần tuý theo doanh số phát hành thẻ mới — vốn tạo động cơ nới lỏng thẩm định tín dụng khiến nợ xấu và chi phí dự phòng rủi ro phình to sau đó. Ban Lãnh Đạo yêu cầu thiết kế bộ chỉ số xếp hạng cân bằng giữa **Quy mô kinh doanh** (50%) và **Kỷ luật kiểm soát rủi ro, hiệu quả tài chính** (50%).

---

## 2. 🎯 Định Hình "Đầu Ra" Của Hệ Thống Báo Cáo

Khi tiếp nhận đề bài từ Ban Lãnh Đạo, khó khăn lớn nhất là yêu cầu chỉ dừng ở mục tiêu định hướng quản trị mà không có sẵn biểu mẫu hay đặc tả kỹ thuật chi tiết. Do đó, bước đi đầu tiên là áp dụng tư duy **Output-First (thiết kế ngược từ nhu cầu ra quyết định)**: tự đặt câu hỏi Ban Lãnh Đạo cần nhìn thấy những thông tin cốt lõi nào để điều hành, từ đó tự phác thảo cấu trúc "đầu ra" mong đợi trước khi đi tìm dữ liệu.

Cấu trúc đầu ra được định hình gồm hai trụ cột báo cáo phục vụ trực tiếp cho 2 yêu cầu của bài toán, cùng công cụ phân phối đa đối tượng:

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                                 ĐẦU RA MONG ĐỢI CỦA BÀI TOÁN                           │
├────────────────────────────────────────┬───────────────────────────────────────────────┤
│ BÁO CÁO P&L QUẢN TRỊ 7 VÙNG            │ THẺ ĐIỂM XẾP HẠNG QUẢN LÝ VÙNG (ASM)          │
│ • Tách bạch số trực tiếp và phân bổ    │ • Đánh giá độc lập 2 trụ cột: Quy mô &        │
│ • Bóc tách 6 cấu phần thu - chi        │   Hiệu quả tài chính / Kỷ luật rủi ro         │
│ • Tính toán số lũy kế và dòng chảy     │ • Tránh việc nới lỏng nợ xấu để chạy doanh số │
│ • Tổng 7 vùng khớp tuyệt đối sổ cái    │ • Xếp hạng công bằng cho 74 - 84 quản lý      │
├────────────────────────────────────────┴───────────────────────────────────────────────┤
│ CÔNG CỤ TRÌNH BÀY ĐA ĐỐI TƯỢNG                                                        │
│ • Dashboard tương tác Power BI: Cho Ban Lãnh Đạo theo dõi tức thì và chẩn đoán biến động│
│ • File Excel mẫu chuẩn: Cho Phòng Kế toán / Tài chính đối soát công thức chi tiết      │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

### Các chỉ tiêu đầu ra cụ thể:
1. **Bảng phân rã dòng chảy lợi nhuận hàng tháng:** Tách biệt số lũy kế năm (YTD) thành số phát sinh riêng từng tháng, phân rã chi tiết thành 6 cấu phần: Thu nhập thẻ gộp, Chi phí vốn, Chi phí kinh doanh khác, Chi phí hoạt động, Chi phí dự phòng rủi ro và Chênh lệch làm tròn.
2. **Ma trận Lợi nhuận – Rủi ro (Quadrant Matrix):** Định vị 7 vùng vào 4 kịch bản quản trị dựa trên 2 trục: Lợi nhuận phát sinh trong tháng và Tỷ lệ nợ xấu.
3. **Bảng xếp hạng quản lý vùng đa chiều:** Chấm điểm dựa trên 8 chỉ số kết hợp giữa cá nhân quản lý (doanh số cho vay mới, thẻ hoạt động, tỷ lệ duyệt hồ sơ) và tập thể địa bàn (tỷ lệ nợ xấu vùng, CIR, Margin, hiệu quả vốn, lợi nhuận bình quân).

---

## 3. 🔍 Khảo Sát, Thu Thập Và Đánh Giá Dữ Liệu "Đầu Vào"

Ngân hàng không có sẵn một kho dữ liệu tập trung hay một bảng số liệu duy nhất đáp ứng ngay các yêu cầu đầu ra ở trên. Sau khi đã định hình rõ bức tranh đầu ra cần đạt được, bước tiếp theo là chủ động đi khảo sát, tìm kiếm nguồn dữ liệu từ nhiều phòng ban nghiệp vụ khác nhau để thu thập từng mảnh ghép thông tin:

| Phòng ban cung cấp | Nguồn dữ liệu | Quy mô | Vai trò đáp ứng đầu ra |
|---|---|---:|---|
| **Khối Kế toán & Tài chính** | Sổ cái tài khoản kế toán (`fact_txn_month`) | **63.134** bút toán | Ghi nhận chi tiết từng bút toán thu - chi; gồm 62.953 dòng gắn mã tỉnh thành cụ thể và 181 dòng hạch toán tập trung tại Hội sở (mã tỉnh `'00'`). |
| **Khối Vận hành Thẻ** | Sao kê hợp đồng thẻ tín dụng (`fact_kpi_month`) | **2.932.914** dòng | Cung cấp toàn bộ dư nợ theo 5 nhóm nợ, nợ đã xử lý rủi ro (write-off) và doanh số từng hợp đồng qua 5 tháng; làm căn cứ tính tỷ lệ nợ xấu và tạo tiêu thức phân bổ chi phí Hội sở. |
| **Khối Quản lý Mạng lưới** | Bảng chỉ tiêu kinh doanh (`kpi_asm_data`) | **420** dòng | Cung cấp kết quả kinh doanh cá nhân: doanh số giải ngân mới, số thẻ hoạt động và tỷ lệ duyệt hồ sơ của từng quản lý vùng theo tháng để phục vụ xếp hạng. |
| **Phòng Kế hoạch & Quản trị Dữ liệu** | Bảng tham số địa bàn và biểu mẫu đối chiếu | **64** tỉnh thành | Bảng quy đổi 64 tỉnh thành về 8 vùng địa lý (Hội sở `'A'` và 7 vùng kinh doanh `'B'..'H'`) kèm mẫu biểu báo cáo tài chính. |

### Đánh giá khoảng cách dữ liệu (Gap Analysis)
Khi đối chiếu dữ liệu thu thập được từ các phòng ban với bộ chỉ tiêu đầu ra mong đợi, nhận thấy dữ liệu thô **chưa thể đưa vào tính toán ngay** do vấp phải ba rào cản kỹ thuật:
1. **Dữ liệu sao kê hợp đồng thẻ vượt quá giới hạn Excel:** Tệp dữ liệu có gần 3 triệu dòng, nặng 117,2 MB khiến các công cụ xử lý bảng tính thông thường bị treo hoặc tràn bộ nhớ.
2. **Dữ liệu chỉ tiêu tổ chức theo dạng ngang (Wide):** Bảng chỉ tiêu quản lý vùng trải dài các cột tháng sang ngang, không thể nạp trực tiếp vào cơ sở dữ liệu quan hệ để join với các bảng sự kiện khác.
3. **Bất đồng bộ trong dữ liệu danh mục:** Tên địa danh giữa các phòng ban bị lệch chuẩn ký tự (ví dụ: sao kê ghi "Bà Rịa - Vũng Tàu" nhưng bảng tham số viết "Vũng Tàu"), nếu ghép trực tiếp sẽ làm mất hơn 36.000 hợp đồng thẻ khi tính toán tỷ lệ nợ xấu của vùng Đông Nam Bộ.

---

## 4. 🧮 Xây Dựng Quy Trình Xử Lý Và Thiết Kế Công Thức Tính Toán

### 4.1. Thiết kế luồng xử lý tự động 4 giai đoạn
Để thay thế hoàn toàn các thao tác thủ công, một luồng xử lý tự động khép kín 4 giai đoạn được thiết kế từ tệp Excel thô đến kho dữ liệu và báo cáo:

<div align="center">

![Quy trình xử lý kỹ thuật — 4 giai đoạn](images/quy-trinh.png)

</div>

- **Giai đoạn 1 (Thu thập dữ liệu):** Tiếp nhận 3 tệp dữ liệu phát sinh và 1 tệp tham số quy đổi.
- **Giai đoạn 2 (Làm sạch và nạp liệu bằng Python):** Sử dụng `openpyxl` và luồng đọc XML (`zipfile` + `xml.etree`) để đọc trực tiếp dữ liệu thô gần 3 triệu dòng mà không tốn RAM; chuẩn hoá chuỗi ký tự tên tỉnh thành (`pos_city_norm`); xoay bảng chỉ tiêu từ ngang sang dọc và nạp vào 3 bảng `staging` (`stg_fact_kpi_month`, `stg_fact_txn_month`, `stg_asm_target`) cùng 2 bảng danh mục vùng (`dim_area`, `dim_param_area`).
- **Giai đoạn 3 (Tính toán phân bổ và chấm điểm bằng PostgreSQL):** Hệ thống 9 `stored procedure` thực thi các bước phân bổ chi phí và thuật toán xếp hạng, lưu kết quả trung gian vào 6 bảng tạm `tmp_` và ghi nhận kết quả chính thức vào 2 bảng `fact` (`fct_pnl_value`, `fct_asm_value`).
- **Giai đoạn 4 (Báo cáo và kiểm soát):** Dựng Dashboard Power BI (Import mode, 72 `measure` DAX) và tự động xuất file Excel hoàn chỉnh qua tập lệnh `run_report.py`.

### 4.2. Thiết kế công thức phân bổ chi phí Hội sở (Bài toán P&L)
Hai quy tắc kế toán quản trị được thiết kế để phân bổ 63.134 bút toán sổ cái:
- **Quy tắc 1 (Gán trực tiếp):** Bút toán nào có mã tỉnh cụ thể thì tính 100% thu/chi cho vùng quản lý địa bàn đó.
- **Quy tắc 2 (Phân bổ theo tiêu thức):** Bút toán tại Hội sở (mã tỉnh `'00'`, vùng `'A'`) được chia về 7 vùng dựa trên tỷ lệ thực tế của từng tiêu thức:

$$\text{Tỷ lệ phân bổ vùng } i = \frac{\text{Giá trị tiêu thức của vùng } i}{\sum_{k=1}^7 \text{Giá trị tiêu thức của vùng } k}$$

*Tiêu thức tương ứng:* Chi phí vốn phân bổ theo Dư nợ nhóm 1; Chi phí dự phòng chung phân bổ theo Dư nợ nhóm 2 đến 5 và nợ đã xử lý rủi ro; Chi phí vận hành và quản lý phân bổ theo số lượng quản lý vùng hoặc số thẻ hoạt động.

### 4.3. Thiết kế công thức đánh giá năng lực quản lý vùng (Thẻ điểm ASM)
Để đảm bảo công bằng giữa các địa bàn lớn và nhỏ, công thức xếp hạng đánh giá 8 chỉ số trên **2 trụ cột độc lập**:

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

Do các chỉ số có đơn vị khác nhau (triệu đồng, số thẻ, phần trăm), hệ thống sử dụng thuật toán **Xếp hạng từng chỉ số trước (Rank 1 là tốt nhất), sau đó cộng tổng thứ hạng để tính điểm**:
$$\text{Điểm tổng} = \text{Điểm Quy mô } (diem\_qm) + \text{Điểm Tài chính } (diem\_fin)$$
*Điểm tổng càng thấp, thứ hạng chung cuộc của quản lý vùng trên toàn ngân hàng càng cao.*

---

## 5. 🖥️ Trực Quan Hoá Báo Cáo Và Đánh Giá Mức Độ Đáp Ứng Bài Toán

### Mô hình báo cáo trực quan Power BI
Báo cáo Power BI được xây dựng với **5 trang phân tích chuyên sâu**, vận hành ở chế độ `Import` nạp 4 bảng dữ liệu và 72 `measure` DAX:
1. **Tổng quan báo cáo:** Cung cấp bức tranh toàn cảnh về tiến độ hoàn thành các chỉ tiêu kinh doanh.
2. **Từ điển dữ liệu:** Chuẩn hoá định nghĩa và công thức tính của toàn bộ các chỉ số quản trị.
3. **Kết quả kinh doanh (P&L 7 vùng):** Trình bày chi tiết bảng lãi lỗ sau phân bổ và bảng bóc tách biến động thu – chi hàng tháng.
4. **Bảng xếp hạng quản lý vùng:** Thể hiện chi tiết thứ hạng, điểm số của 84 quản lý vùng và biến động thứ hạng so với kỳ trước.
5. **Phân tích chuyên sâu & Chẩn đoán:** Tích hợp ma trận nhiệt (Heatmap) và ma trận Lợi nhuận – Rủi ro (Quadrant Scatter Plot) giúp lãnh đạo nhận diện ngay các bất thường.

### Đánh giá mức độ đáp ứng bài toán ban đầu
Hệ thống giải quyết trọn vẹn các yêu cầu ban đầu của Ban Lãnh Đạo:
- **Độ tin cậy số liệu đạt mức tuyệt đối:** Thiết lập 4 lớp kiểm soát độc lập, thực hiện 91 phép đối soát chéo tự động giữa Power BI và PostgreSQL với sai số bằng 0. Tổng 7 vùng sau phân bổ khớp 100% với số liệu sổ cái gốc.
- **Tính công bằng trong đánh giá:** Việc đưa chỉ tiêu Tỷ lệ nợ xấu vào trụ cột Quy mô đã ngăn chặn triệt để tình trạng chạy theo số lượng thẻ mà bỏ quên chất lượng tín dụng.
- **Phục vụ đúng thói quen người dùng:** Cung cấp cả giao diện trực quan cho Lãnh đạo lẫn tệp Excel giữ nguyên 100% công thức định dạng chuẩn cho Kế toán.

---

## 6. 📊 Nhận Xét Dữ Liệu Sau Trực Quan Và Đề Xuất Quản Trị

Tính đến hết tháng 5/2023, lợi nhuận trước thuế lũy kế toàn khối thẻ đạt **250.450,06 triệu đồng**, riêng tháng 5 tăng thêm **+4.390,9 triệu đồng (+8,4%)** so với tháng 4. Tuy nhiên, phân tích sâu dữ liệu trực quan chỉ ra nhiều điểm đáng chú ý:

| Số vùng kinh doanh | Đội ngũ quản lý vùng (tháng 5) | Chuỗi thời gian phân tích | Quy mô dữ liệu xử lý | Lợi nhuận lũy kế 5 tháng | Biến động lợi nhuận tháng 5 so với tháng 4 |
| :---: | :---: | :---: | :---: | :---: | :---: |
| **7 vùng** | **84 người** | **5 tháng** (tháng 1 – tháng 5/2023) | **2.996.476 dòng** | **250.450,06 triệu đồng** | **+4.390,9 triệu đồng (+8,4%)** |

### Những phát hiện quan trọng từ dữ liệu
1. **Mức tăng trưởng +8,4% của toàn ngân hàng không đến từ mở rộng kinh doanh cốt lõi:**
   Có tới **97,2%** mức tăng lợi nhuận tháng 5 tập trung tại một vùng duy nhất là **Tây Nam Bộ** (+4.267,8 triệu đồng). Tuy nhiên, thu nhập thuần từ thẻ của vùng chỉ tăng nhẹ +16,3 triệu đồng, trong khi chi phí hoạt động tăng làm giảm lợi nhuận −195,9 triệu đồng. Toàn bộ mức tăng lợi nhuận thực chất đến từ việc **chi phí trích lập dự phòng giảm +4.447,3 triệu đồng**. Đáng lưu ý, Tây Nam Bộ lại có **tỷ lệ nợ xấu cao nhất hệ thống (21,99%)** và không có bất kỳ quản lý vùng nào lọt vào top 25 toàn hàng.
2. **Đông Nam Bộ ghi nhận lỗ do chi phí dự phòng nợ xấu tăng cao:**
   Vùng Đông Nam Bộ lỗ **−8.787,4 triệu đồng** trong tháng. Bóc tách dữ liệu cho thấy hoạt động bán hàng tại đây vẫn rất tích cực khi **thu nhập thuần tăng tới +3.210,7 triệu đồng**, nhưng mức tăng này bị xoá sạch bởi **chi phí dự phòng rủi ro tăng thêm −3.234,2 triệu đồng**, khiến 16/19 quản lý vùng rơi xuống nhóm cuối bảng. Vấn đề của vùng nằm ở chất lượng tín dụng chứ không phải năng lực bán hàng.
3. **Hiện tượng giảm thu nhập thuần bị che khuất tại Đồng bằng Sông Hồng:**
   Lợi nhuận tháng 5 của vùng tăng +1.310,9 triệu đồng hoàn toàn nhờ chi phí dự phòng giảm +1.455,8 triệu đồng, trong khi thu nhập thuần thực tế giảm −232,2 triệu đồng, báo hiệu đà tăng trưởng doanh thu thẻ tại thị trường lớn nhất đang chậm lại.
4. **Mô hình điểm về hiệu quả và chất lượng tại Nam Trung Bộ:**
   Mặc dù quy mô nhỏ (chỉ 5 quản lý vùng), Nam Trung Bộ duy trì tỷ lệ nợ xấu thấp nhất ngân hàng (**11,24%**) và có **4/5 quản lý vùng** nằm trong nhóm 25 vị trí dẫn đầu toàn quốc.

### Năm đề xuất hành động cụ thể gửi Ban Lãnh Đạo
Từ kết quả phân tích thực tế, 5 nội dung hành động quản trị cụ thể được đề xuất gắn rõ trách nhiệm và thời hạn:

| # | Đề xuất quản trị | Căn cứ số liệu tháng 5/2023 | Đơn vị phụ trách · Thời hạn |
|:---:|:---|:---|:---|
| 01 | Tách riêng dòng trích lập dự phòng mới và hoàn nhập dự phòng theo vùng; bổ sung chỉ tiêu lợi nhuận loại trừ hoàn nhập | Báo cáo hiện tại chỉ có một dòng dự phòng ròng, che khuất biến động kinh doanh thực chất | Khối Quản lý rủi ro · Tháng 6 |
| 02 | Rà soát danh mục hồ sơ phát sinh chuyển nhóm nợ xấu tại Đông Nam Bộ, Đông Bắc Bộ và Tây Bắc Bộ | Chi phí dự phòng tại 3 vùng này tăng thêm **6.035,1 triệu đồng** trong tháng | Quản lý vùng + Quản lý rủi ro · 30 ngày |
| 03 | Kiểm tra thực địa quy trình cấp tín dụng thẻ và thu hồi nợ tại Tây Nam Bộ | Nợ xấu chiếm **21,99%** (cao nhất hệ thống) nhưng vùng lại chiếm **97,2%** mức tăng lợi nhuận | Khối Kinh doanh + Quản lý rủi ro · Tháng 7 |
| 04 | Thử nghiệm có kiểm soát quy trình sàng lọc và thẩm định hồ sơ của Nam Trung Bộ | Tỷ lệ nợ xấu thấp nhất (**11,24%**) và 4/5 quản lý vùng đạt top 25 | Khối Kinh doanh · Đánh giá sau 2 tháng |
| 05 | Điều chỉnh cơ chế khen thưởng: Kết hợp đồng thời chỉ tiêu thu nhập thuần và tỷ lệ nợ xấu thay vì chỉ dùng lợi nhuận đơn lẻ | Tránh việc khen thưởng nhầm cho các vùng có lợi nhuận tăng đột biến nhờ giảm trích lập dự phòng | Ban điều hành · Áp dụng ngay |

---

## 7. 📚 Kinh Nghiệm Triển Khai Thực Chiến

1. **Tư duy định hình "Đầu ra" trước khi bắt tay vào dữ liệu:** Việc phác thảo cấu trúc báo cáo quản trị và các câu hỏi điều hành ngay từ đầu giúp xác định chính xác những trường thông tin cần lấy từ các phòng ban, tránh tình trạng thu thập dàn trải nhưng thiếu các chỉ số cốt lõi.
2. **Hiểu bản chất kế toán quản trị và dòng tiền trước khi viết code:** Trong hệ thống ngân hàng, việc hiểu rõ tại sao chi phí vốn mang dấu âm, vì sao chi phí Hội sở mang mã tỉnh `'00'` và vùng `'A'` là điều kiện tiên quyết để xây dựng câu lệnh SQL phân bổ chính xác.
3. **Làm sạch dữ liệu danh mục là yếu tố bảo vệ tính đúng đắn của báo cáo:** Phát hiện sự sai lệch giữa chuỗi ký tự "Bà Rịa - Vũng Tàu" và "Vũng Tàu" trong quá trình tiền xử lý đã giữ lại trọn vẹn hơn 36.000 hợp đồng thẻ, ngăn chặn sai lệch nghiêm trọng đối với tỷ lệ nợ xấu của vùng Đông Nam Bộ.
4. **Không bao giờ đánh giá hiệu quả kinh doanh qua một con số tổng duy nhất:** Một con số lợi nhuận dương đẹp mắt có thể che giấu sự suy giảm của hoạt động kinh doanh cốt lõi hoặc sự bùng nổ của nợ xấu tiềm ẩn. Phân rã cấu phần và so sánh đa chiều là chìa khoá của phân tích dữ liệu chuyên nghiệp.

---

## 8. 🗄️ Cấu Trúc Kho Dữ Liệu

Kho dữ liệu được xây dựng theo mô hình `Star Schema` trong schema `banking_project` gồm **19 bảng và 4 `view`**, tổ chức thành các lớp rõ ràng:

| Phân lớp | Số lượng | Danh sách bảng và số dòng | Vai trò quản trị |
|---|---:|---|---|
| **Bảng danh mục (`dim_`)** | 7 | `dim_area` (8) · `dim_param_area` (64) · `dim_asm` (84) · `dim_month` (5) · `dim_date` (151) · `dim_report_detail` (50) · `dim_sm_headcount` (35) | Đóng vai trò danh mục chuẩn: quản lý danh sách vùng, ánh xạ tỉnh về vùng, danh sách quản lý, trục thời gian ngày/tháng và cây 50 chỉ tiêu báo cáo. |
| **Bảng tiếp nhận (`stg_`)** | 3 | `stg_fact_kpi_month` (2.932.922) · `stg_fact_txn_month` (63.134) · `stg_asm_target` (420) | Lưu trữ nguyên vẹn dữ liệu gốc từ các phòng ban để phục vụ kiểm toán và đối soát. |
| **Bảng trung gian (`tmp_`)** | 6 | `tmp_pnl_step1_driver` (315) · `tmp_pnl_step2_ratio` (560) · `tmp_pnl_step3_gl_split` (535) · `tmp_xh_step1_asm_avg` (1.164) · `tmp_xh_step2_npl_area` (105) · `tmp_xh_step3_fin_area` (315) | Lưu dấu vết số liệu của từng bước tính toán phân bổ và xếp hạng; giúp cô lập lỗi nhanh chóng khi kiểm tra trên DBeaver. |
| **Bảng kết quả (`fct_`)** | 2 | `fct_pnl_value` (1.115) · `fct_asm_value` (8.536) | Lưu trữ kết quả chính thức theo cấu trúc dọc (Tall), giúp hệ thống dễ dàng mở rộng thêm chỉ tiêu mới mà không cần đổi schema. |
| **Bảng nhật ký (`log_`)** | 1 | `log_proc_run` (95) | Giám sát lịch sử, trạng thái chạy và kiểm soát an toàn giao dịch của từng thủ tục. |
| **Khung nhìn (`v_`)** | 4 | `v_baocao_tonghop` (35) · `v_baocao_tonghop_vnd` (35) · `v_xephang_asm` (388) · `v_xephang_asm_vnd` (388) | Xoay dữ liệu từ dạng dọc sang dạng ngang thân thiện cho Power BI và xuất báo cáo Excel. |

<div align="center">

![Sơ đồ quan hệ giữa các bảng trong lược đồ banking_project](images/thiet-ke-schema.png)

</div>

---

## 9. 🛠️ Công Cụ Và Công Nghệ Sử Dụng

| Nhiệm vụ kỹ thuật | Công cụ lựa chọn | Lý do lựa chọn phù hợp thực tế |
|---|---|---|
| Đọc tệp Excel gần 3 triệu dòng, xoay bảng chỉ tiêu và chuẩn hoá tên địa bàn | Python 3.10 (`openpyxl`, `psycopg2`, XML streaming) | Đọc trực tiếp luồng dữ liệu XML không tốn RAM; nạp dữ liệu tốc độ cao vào PostgreSQL bằng lệnh `COPY`. |
| Lưu trữ tập trung, xử lý phân bổ chi phí 2 quy tắc và thuật toán xếp hạng đa bước | PostgreSQL 16, PL/pgSQL (`stored procedure`) | Hỗ trợ mạnh mẽ `Window Function` (`RANK()`), `CTE` (`WITH`), quản lý giao dịch an toàn không có `COMMIT` lửng. |
| Quản lý lược đồ, thiết kế quan hệ và kiểm tra dữ liệu trung gian | DBeaver | Trực quan hoá 23 đối tượng với 9 `Virtual Foreign Keys`, hỗ trợ query nhanh các bảng `tmp_`. |
| Trình bày báo cáo tương tác và tích hợp câu chuyện phân tích chuyên sâu | Power BI Desktop (chế độ `Import`), 72 `measure` DAX | Tối ưu hóa tốc độ lọc theo tháng; hiển thị linh hoạt ma trận nhiệt và biểu đồ phân tán. |

<div align="center">

<p>
  <img src="https://img.shields.io/badge/PostgreSQL-Kho%20d%E1%BB%AF%20li%E1%BB%87u-4169E1?style=flat-square&logo=postgresql&logoColor=white">
  <img src="https://img.shields.io/badge/Python-N%E1%BA%A1p%20d%E1%BB%AF%20li%E1%BB%87u-3776AB?style=flat-square&logo=python&logoColor=white">
  <img src="https://img.shields.io/badge/DBeaver-Ki%E1%BB%83m%20s%E1%BB%91-000B19?style=flat-square&logo=dbeaver&logoColor=white">
  <img src="https://img.shields.io/badge/Power%20BI-Tr%E1%BB%B1c%20quan-F2C811?style=flat-square&logo=powerbi&logoColor=black">
  <img src="https://img.shields.io/badge/Excel-M%E1%BA%ABu%20b%C3%A1o%20c%C3%A1o-217346?style=flat-square&logo=microsoftexcel&logoColor=white">
</p>

</div>

---

## 10. 📂 Cấu Trúc Dự Án

```text
.
├── input/              # Chứa tệp tham số và mẫu báo cáo; 3 nguồn dữ liệu thô vượt trần dung lượng GitHub được quản lý cục bộ
│   └── Tham so va mau doi chieu.xlsx  # Bảng tham số 64 tỉnh thành, quy đổi tài khoản và biểu mẫu chuẩn 2 báo cáo
├── ingestion/          # Các chương trình Python bóc tách Excel, làm sạch dữ liệu và xuất báo cáo tự động
│                       # db_config.example.py — tệp mẫu cấu hình kết nối database
│                       # run_all.py điều phối 4 bước nạp · run_report.py xuất báo cáo Excel hoàn chỉnh
├── sql/                # Toàn bộ mã nguồn SQL phân lớp khoa học:
│   ├── dim/            #   dim_month_headcount (trục thời gian + nhân sự), dim_asm, dim_report_detail (cây 50 chỉ tiêu)
│   ├── tmp/            #   tmp_pnl_step, tmp_xh_step — 6 bảng tạm trung gian kèm 6 stored procedure nạp từng bước
│   ├── fct/            #   fct_pnl_allocation (Rule 1 & 2), fct_xephang_asm (2 trụ cột) — 2 bảng fact và 2 stored procedure điều phối
│   └── rpt/            #   rpt_pnl_view, rpt_xephang_view — 4 view xoay bảng ngang cho Power BI và Excel
├── output/             # Sản phẩm bàn giao: Báo cáo Excel lũy kế và Dashboard Power BI (.pbix)
├── images/             # Sơ đồ quy trình kỹ thuật, kiến trúc kho dữ liệu và ảnh chụp các trang dashboard
├── docs/               # Bộ tài liệu vận hành chi tiết: HIEN_TRANG_HE_THONG, PIPELINE, NHAT_KY_CONG_VIEC, LOI_THUONG_GAP
├── requirements.txt    # Khai báo các thư viện Python: psycopg2-binary và openpyxl
├── README.md           # Tài liệu dự án bằng tiếng Việt (mặc định)
└── README_eng.md       # Tài liệu dự án bằng tiếng Anh
```

---

## 11. 🔒 Nguồn Dữ Liệu Và Quyền Sử Dụng

- Dữ liệu sử dụng trong dự án là **dữ liệu nghiệp vụ thực tế do đơn vị cung cấp và cho phép sử dụng** nhằm mục đích nghiên cứu và xây dựng giải pháp báo cáo quản trị.
- **Quy định quản lý tệp trên kho mã:** Do chính sách giới hạn dung lượng của GitHub (100 MB/tệp), tệp sao kê hợp đồng thẻ gốc nặng **117,2 MB** được lưu trữ cục bộ cùng hai tệp dữ liệu thô khác. Kho mã lưu trữ tệp **`Tham so va mau doi chieu.xlsx`** (127.976 byte) nhằm đảm bảo người đọc có thể tái hiện toàn bộ mã nguồn, logic tính toán và xem trước các sản phẩm báo cáo đầu ra.

---

## 12. 📖 Tài Liệu Bàn Giao

Hệ thống được tài liệu hoá đầy đủ trong thư mục `docs/`:
- [`docs/HIEN_TRANG_HE_THONG.md`](docs/HIEN_TRANG_HE_THONG.md) — Chi tiết hiện trạng kho dữ liệu, số dòng của 19 bảng và 4 `view`, phân quyền quản lý từng bảng và các mốc đối soát chuẩn.
- [`docs/PIPELINE.md`](docs/PIPELINE.md) — Hướng dẫn kiến trúc luồng dữ liệu 4 bước và các kịch bản thực thi trong thực tế.
- [`docs/NHAT_KY_CONG_VIEC.md`](docs/NHAT_KY_CONG_VIEC.md) — Nhật ký ghi nhận toàn bộ quá trình phát triển, kiểm thử và tối ưu hóa hệ thống.
- [`docs/LOI_THUONG_GAP.md`](docs/LOI_THUONG_GAP.md) — Sổ tay xử lý sự cố đúc kết **58 tình huống lỗi thực chiến** từ dữ liệu nguồn, cú pháp SQL, logic Python đến DAX.

---

## 13. 💼 Kỹ Năng Áp Dụng Trong Dự Án

<div align="center">

`Phân tích bài toán kinh doanh` · `Tư duy thiết kế Output-First` · `Kế toán quản trị ngân hàng` ·  
`Phân bổ chi phí đa tiêu thức` · `Phân rã biến động lợi nhuận` · `Thiết kế Star Schema` ·  
`SQL & PL/pgSQL nâng cao (Stored Procedure, Window Function)` · `Xử lý dữ liệu lớn với Python` ·  
`Power BI (Import Mode) & DAX chuyên sâu` · `Kiểm soát & Đối soát toàn vẹn dữ liệu`

</div>

---

## 14. 👤 Tác Giả

<div align="center">

**Trần Ngọc Đức** · Data Analyst · Business Intelligence · Data Science · Management Information Systems · Operations

*Giải quyết bài toán tài chính quản trị · Thiết kế hệ thống đo lường hiệu suất · Kiểm chứng và đối soát dữ liệu*

[📧 tranduc22104@gmail.com](mailto:tranduc22104@gmail.com) · [💼 LinkedIn](https://www.linkedin.com/in/tr%E1%BA%A7n-ng%E1%BB%8Dc-%C4%91%E1%BB%A9c-48b3a7439/)

</div>
