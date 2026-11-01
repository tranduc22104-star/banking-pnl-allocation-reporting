<div align="center">

# Theo Dõi Các Chỉ Số Kinh Doanh Và Đánh Giá Hiệu Suất Đội Ngũ Kinh Doanh Thẻ Tín Dụng

**Ngôn ngữ / Language**: **Tiếng Việt** · [English](README_eng.md)

**Trần Ngọc Đức** · Data Analyst · Business Intelligence · Data Science · Management Information Systems · Operations · [Email](mailto:tranduc22104@gmail.com) · [LinkedIn](https://www.linkedin.com/in/tr%E1%BA%A7n-ng%E1%BB%8Dc-%C4%91%E1%BB%A9c-48b3a7439/)

<p>
  <img src="https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white">
  <img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white">
  <img src="https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black">
  <img src="https://img.shields.io/badge/Excel-217346?style=for-the-badge&logo=microsoftexcel&logoColor=white">
</p>

<p>
  Trong hoạt động quản trị kinh doanh thẻ tín dụng, doanh thu thường được ghi nhận tại các vùng kinh doanh,
  trong khi một phần đáng kể chi phí vận hành và chi phí vốn được hạch toán tập trung tại Hội sở.
  Điều này gây khó khăn khi đánh giá hiệu quả kinh doanh thực tế của từng vùng nếu chưa thực hiện phân bổ chi phí phù hợp.
  Dự án tập trung xây dựng hệ thống phân bổ thu nhập, chi phí và đánh giá hiệu quả kinh doanh cũng như nhân sự của <strong>7 vùng</strong>
  từ <strong>2.996.476 dòng dữ liệu</strong> sổ cái kế toán, sao kê hợp đồng thẻ và bảng chỉ tiêu kinh doanh.
</p>

</div>

## 📑 Mục Lục

1. [📌 Bài Toán Của Doanh Nghiệp](#-bài-toán-của-doanh-nghiệp)
2. [🔍 Phân Tích Biến Động Lợi Nhuận](#-phân-tích-biến-động-lợi-nhuận)
3. [🧭 Kết Quả Phân Tích Và Đề Xuất Quản Trị](#-kết-quả-phân-tích-và-đề-xuất-quản-trị)
4. [🧮 Phương Pháp Phân Bổ Chi Phí Và Đánh Giá Nhân Sự](#-phương-pháp-phân-bổ-chi-phí-và-đánh-giá-nhân-sự)
5. [🔄 Quy Trình Xử Lý Dữ Liệu Tự Động](#-quy-trình-xử-lý-dữ-liệu-tự-động)
6. [🗄️ Thiết Kế Kho Dữ Liệu](#-thiết-kế-kho-dữ-liệu)
7. [🧪 Kiểm Tra Và Đối Soát Dữ Liệu](#-kiểm-tra-và-đối-soát-dữ-liệu)
8. [🛠️ Công Cụ Và Công Nghệ Sử Dụng](#-công-cụ-và-công-nghệ-sử-dụng)
9. [📂 Cấu Trúc Dự Án](#-cấu-trúc-dự-án)
10. [🔒 Nguồn Dữ Liệu Và Quyền Sử Dụng](#-nguồn-dữ-liệu-và-quyền-sử-dụng)
11. [📚 Kinh Nghiệm Triển Khai Dự Án](#-kinh-nghiệm-triển-khai-dự-án)
12. [📖 Tài Liệu Bàn Giao](#-tài-liệu-bàn-giao)
13. [💼 Kỹ Năng Áp Dụng Trong Dự Án](#-kỹ-năng-áp-dụng-trong-dự-án)
14. [👤 Tác Giả](#-tác-giả)

---

## 📌 Bài Toán Của Doanh Nghiệp

### 🏢 Vấn Đề Trong Quản Trị Thực Tế

Khối thẻ tín dụng của ngân hàng hoạt động trên **7 vùng kinh doanh** với đội ngũ từ **74 đến 84 quản lý vùng** tuỳ từng tháng. Trong quá trình theo dõi kết quả hoạt động hàng tháng, công tác báo cáo quản trị gặp ba vấn đề chính:

1. **Chưa phản ánh đầy đủ lãi lỗ sau phân bổ của từng vùng:** Trên sổ cái kế toán, các vùng trực tiếp ghi nhận thu nhập lãi và phí thẻ, trong khi các khoản chi phí chung như chi phí vốn huy động, chi phí hệ thống công nghệ, chi phí tiếp thị toàn hàng và lương bộ phận hỗ trợ được hạch toán tại quỹ Hội sở. Khi chưa phân bổ các khoản chi phí này về từng vùng theo mức độ sử dụng nguồn lực, báo cáo khó phản ánh chính xác hiệu quả thực tế của từng địa bàn.
2. **Đánh giá hiệu suất nhân sự cần kết hợp giữa quy mô và chất lượng tín dụng:** Việc đánh giá quản lý vùng nếu chỉ dựa trên doanh số giải ngân mới hoặc lợi nhuận trước phân bổ dễ dẫn đến xu hướng mở rộng dư nợ nhanh kèm theo rủi ro nợ xấu tăng ở các kỳ sau.
3. **Dữ liệu nguồn phân tán và khối lượng lớn:** Số liệu nằm ở ba nguồn khác nhau gồm sổ cái kế toán (**63.134 bút toán**), tệp sao kê hợp đồng thẻ (**2.932.914 dòng**, vượt giới hạn dòng của một trang tính Excel thông thường) và bảng chỉ tiêu bán hàng thiết kế dạng ngang theo tháng. Tổng hợp thủ công mất nhiều thời gian và khó kiểm tra nguyên nhân khi số liệu biến động giữa các kỳ.

### 🎯 Bốn Câu Hỏi Cần Trả Lời Mỗi Tháng

| Vấn đề quản trị | Câu hỏi phân tích | Phương pháp thực hiện |
|---|---|---|
| **Hiệu quả thực tế theo vùng** | Sau khi phân bổ chi phí Hội sở, kết quả lãi lỗ của từng vùng như thế nào? | Tách khoản phát sinh trực tiếp tại vùng và phân bổ khoản chung tại Hội sở theo tiêu thức tương ứng; kiểm tra tổng 7 vùng khớp với sổ cái toàn ngân hàng |
| **Nguyên nhân biến động lợi nhuận** | Lợi nhuận tháng này thay đổi do hoạt động kinh doanh cốt lõi hay do biến động chi phí dự phòng? | Tách số phát sinh riêng từng tháng từ số lũy kế đầu năm và phân rã mức chênh lệch theo 6 cấu phần thu – chi |
| **Đánh giá đội ngũ quản lý** | Quản lý vùng nào duy trì đồng thời tốc độ phát triển quy mô, chất lượng nợ và hiệu quả tài chính? | Xây dựng bảng xếp hạng 8 chỉ số chia thành 2 trụ cột: **Phát triển quy mô** (bao gồm chỉ số kiểm soát nợ xấu) và **Hiệu quả tài chính** |
| **Độ chính xác của số liệu** | Số liệu trên báo cáo có khớp với sổ cái gốc và biểu mẫu kế toán không? | Thiết lập 4 bước kiểm tra dữ liệu và đối soát tự động 91 chỉ số giữa báo cáo Power BI và cơ sở dữ liệu PostgreSQL |

---

## 🔍 Phân Tích Biến Động Lợi Nhuận

Tính đến cuối tháng 5/2023, lợi nhuận trước thuế lũy kế của toàn mảng thẻ đạt **250.450,06 triệu đồng**. Riêng lợi nhuận phát sinh trong tháng 5 tăng thêm **+4.390,9 triệu đồng** so với tháng 4 (tương đương **+8,4%**).

Khi bóc tách số liệu phát sinh theo từng vùng và từng cấu phần thu – chi, dữ liệu cho thấy sự phân hoá rõ rệt giữa các địa bàn:

| Số vùng kinh doanh | Đội ngũ quản lý vùng (tháng 5) | Chuỗi thời gian phân tích | Quy mô dữ liệu xử lý | Lợi nhuận lũy kế 5 tháng | Biến động lợi nhuận tháng 5 so với tháng 4 |
| :---: | :---: | :---: | :---: | :---: | :---: |
| **7 vùng** | **84 người** | **5 tháng** (tháng 1 – tháng 5/2023) | **2.996.476 dòng** | **250.450,06 triệu đồng** | **+4.390,9 triệu đồng (+8,4%)** |

### Những phát hiện chính từ dữ liệu

**01. Lợi nhuận toàn hệ thống tăng 8,4% trong tháng 5, chủ yếu nhờ chi phí dự phòng giảm; thu nhập thuần từ hoạt động thẻ gần như không thay đổi.**
Khoảng **97,2%** mức tăng lợi nhuận của toàn hệ thống trong tháng 5 tập trung tại vùng **Tây Nam Bộ** (**+4.267,8 triệu đồng**). Phân rã theo cấu phần cho thấy thu nhập thuần từ hoạt động thẻ của vùng này chỉ tăng **+16,3 triệu đồng**, chi phí hoạt động tăng làm giảm lợi nhuận **−195,9 triệu đồng**, trong khi **chi phí dự phòng rủi ro giảm đóng góp +4.447,3 triệu đồng**. Bên cạnh đó, Tây Nam Bộ đang có **tỷ lệ nợ xấu ở mức 21,99%** (cao nhất trong 7 vùng) và có **0 trên 16 quản lý vùng** nằm trong nhóm 25 vị trí dẫn đầu toàn ngân hàng.

**02. Kết quả lỗ tại Đông Nam Bộ xuất phát từ chi phí dự phòng rủi ro tăng cao, trong khi thu nhập thuần vẫn tăng trưởng tốt.**
**Đông Nam Bộ** là vùng duy nhất ghi nhận lợi nhuận âm trong tháng (**−8.787,4 triệu đồng**), giảm thêm **−322,2 triệu đồng** so với tháng 4. Xét riêng hoạt động kinh doanh cốt lõi, **thu nhập thuần của vùng tăng +3.210,7 triệu đồng**, nhưng mức tăng của **chi phí dự phòng rủi ro (−3.234,2 triệu đồng)** đã làm lợi nhuận trước thuế tiếp tục âm và khiến **16 trên 19 quản lý vùng** xếp ở nhóm 24 vị trí cuối bảng. Trọng tâm cần rà soát tại Đông Nam Bộ là chất lượng thẩm định tín dụng và thu hồi nợ.

**03. Lợi nhuận tháng 5 tại Đồng bằng Sông Hồng tăng nhờ giảm chi phí dự phòng, trong khi thu nhập thuần thực tế giảm nhẹ.**
Tại **Đồng bằng Sông Hồng** (vùng có quy mô nhân sự lớn nhất với 23 quản lý vùng), lợi nhuận phát sinh tháng 5 tăng **+1.310,9 triệu đồng**. Tuy nhiên, **thu nhập thuần thực tế giảm −232,2 triệu đồng** so với tháng 4; mức tăng lợi nhuận trước thuế chủ yếu nhờ chi phí dự phòng giảm **+1.455,8 triệu đồng**. Số liệu này cho thấy tốc độ tăng thu phí và lãi thẻ tại địa bàn trọng điểm đang có dấu hiệu chững lại.

**04. Nam Trung Bộ có quy mô nhỏ nhưng duy trì tỷ lệ nợ xấu thấp nhất và hiệu suất nhân sự đồng đều.**
**Nam Trung Bộ** chỉ có 5 quản lý vùng nên quy mô lợi nhuận tuyệt đối không lớn, nhưng tỷ lệ nợ xấu được duy trì ở mức thấp nhất hệ thống (**11,24%**) và có **4 trên 5 quản lý vùng** nằm trong nhóm 25 người dẫn đầu toàn hàng. Kết hợp đánh giá theo cả quy mô và hiệu quả giúp ghi nhận đúng kết quả của các vùng quy mô nhỏ nhưng kiểm soát chất lượng tín dụng tốt.

---

## 🧭 Kết Quả Phân Tích Và Đề Xuất Quản Trị

Dự án tổng hợp kết quả phân tích thông qua ba bảng theo dõi: **Bảng phân rã biến động lợi nhuận**, **Ma trận Lợi nhuận – Rủi ro**, và **Danh mục đề xuất quản trị theo đơn vị phụ trách**.

### 1. Tách số phát sinh trong tháng từ số liệu lũy kế

Do báo cáo tài chính gốc được ghi nhận lũy kế từ đầu năm, hệ thống thực hiện tách riêng **lợi nhuận phát sinh trong tháng** và **mức chênh lệch so với tháng liền trước**:

```text
Lợi nhuận phát sinh riêng tháng t      = Lợi nhuận lũy kế (tháng t) − Lợi nhuận lũy kế (tháng t − 1)
Mức thay đổi so với tháng liền trước   = Dòng chảy (tháng t)        − Dòng chảy (tháng t − 1)
```

| Vùng kinh doanh | Tổng thay đổi lợi nhuận | Đóng góp từ Thu nhập thuần | Đóng góp từ Chi phí dự phòng | Nhận định từ số liệu |
| :--- | :---: | :---: | :---: | :--- |
| **Tây Nam Bộ** | **+4.267,8** | +16,3 | **+4.447,3** | Lợi nhuận tăng nhờ giảm chi phí dự phòng, thu nhập thuần đi ngang |
| **Đông Nam Bộ** | **−322,2** | **+3.210,7** | **−3.234,2** | Thu nhập thuần tăng tốt nhưng chi phí dự phòng rủi ro tăng cao hơn |
| **Đồng bằng Sông Hồng** | **+1.310,9** | **−232,2** | **+1.455,8** | Lợi nhuận tăng nhờ giảm dự phòng, thu nhập thuần giảm nhẹ so với tháng trước |

*Đơn vị: triệu đồng. Tổng mức thay đổi lợi nhuận được cấu thành từ 6 khoản mục trên báo cáo lãi lỗ (thu nhập thẻ gộp, chi phí vốn, chi phí kinh doanh khác, chi phí hoạt động quản lý, chi phí dự phòng rủi ro và phần chênh lệch làm tròn).*

### 2. Phân nhóm 7 vùng trên ma trận Lợi nhuận và Rủi ro

Các vùng được phân nhóm dựa trên 2 chỉ tiêu **Lợi nhuận phát sinh trong tháng** và **Tỷ lệ nợ xấu** để xác định hướng xử lý phù hợp:

| Nhóm vùng | Đặc điểm dữ liệu | Định hướng quản trị |
| :--- | :--- | :--- |
| **Lợi nhuận cao – Nợ xấu thấp** | Thu nhập tăng trưởng ổn định, tỷ lệ nợ xấu trong ngưỡng kiểm soát | Duy trì cơ chế vận hành hiện tại, tổng hợp quy trình thẩm định để tham khảo |
| **Lợi nhuận cao – Nợ xấu cao** | Lợi nhuận tăng nhờ giảm hoặc hoàn nhập dự phòng, tỷ lệ nợ xấu vẫn ở mức cao | Rà soát chi tiết cơ cấu chi phí dự phòng trước khi đánh giá khen thưởng |
| **Bị lỗ – Nợ xấu cao** | Nợ xấu phát sinh làm tăng chi phí dự phòng, ảnh hưởng lớn đến lợi nhuận | Kiểm tra chất lượng danh mục hồ sơ giải ngân mới và quy trình thẩm định |
| **Bị lỗ – Nợ xấu thấp** | Chất lượng tín dụng tốt nhưng quy mô doanh thu chưa bù đắp đủ chi phí phân bổ | Rà soát cơ cấu chi phí hoạt động và hỗ trợ mở rộng quy mô khách hàng |

### 3. Tổng hợp xếp hạng nhân sự và tỷ lệ nợ xấu theo vùng

| Vùng trọng điểm | Tổng số quản lý vùng (tháng 5) | Số người trong nhóm 25 dẫn đầu | Số người trong nhóm 24 cuối bảng | Tỷ lệ nợ xấu toàn vùng |
| :--- | :---: | :---: | :---: | :---: |
| **Tây Nam Bộ** | 16 | **0 người** | 4 người | **21,99%** (cao nhất) |
| **Đông Nam Bộ** | 19 | 1 người | **16 người** | 19,86% |
| **Nam Trung Bộ** | 5 | **4 người** | 0 người | **11,24%** (thấp nhất) |
| **Đồng bằng Sông Hồng** | 23 | 10 người | 2 người | 13,91% |

### 4. Năm đề xuất quản trị theo đơn vị phụ trách

Trên trang tổng hợp của báo cáo, kết quả phân tích được cụ thể hoá thành **5 đề xuất quản trị** gồm: **Nội dung công việc + Căn cứ số liệu (cập nhật động theo tháng được chọn) + Đơn vị phối hợp + Thời hạn**:

| # | Đề xuất thực hiện | Căn cứ từ số liệu tháng 5/2023 | Đơn vị phụ trách · Thời hạn |
| :---: | :--- | :--- | :--- |
| 01 | Tách riêng khoản trích lập dự phòng mới và khoản hoàn nhập dự phòng theo vùng; bổ sung chỉ tiêu lợi nhuận trước thuế chưa gồm hoàn nhập | Báo cáo hiện tại chỉ có một dòng dự phòng ròng, gây khó khăn khi tách biến động kinh doanh cốt lõi | Khối Quản lý rủi ro · tháng 6 |
| 02 | Rà soát danh mục hồ sơ mới phát sinh chuyển nhóm nợ tại Đông Nam Bộ, Đông Bắc Bộ và Tây Bắc Bộ | Chi phí dự phòng của 3 vùng này tăng thêm **6.035,1 triệu đồng** trong tháng 5 | Quản lý vùng + Khối Quản lý rủi ro · trong 30 ngày |
| 03 | Kiểm tra quy trình thẩm định cấp thẻ và công tác thu hồi nợ tại vùng Tây Nam Bộ | Tỷ lệ nợ xấu ở mức **21,99%** (cao nhất hệ thống) trong khi vùng chiếm **97,2%** mức tăng lợi nhuận toàn hàng | Khối Kinh doanh + Khối Quản lý rủi ro · tháng 7 |
| 04 | Nghiên cứu và thử nghiệm có kiểm soát quy trình sàng lọc khách hàng của Nam Trung Bộ kèm tiêu chí đo lường cụ thể | Có **4 trong 5** quản lý vùng thuộc nhóm 25 vị trí dẫn đầu và tỷ lệ nợ xấu thấp nhất (**11,24%**) | Khối Kinh doanh · đánh giá sau 2 tháng |
| 05 | Kết hợp chỉ tiêu thu nhập thuần và tỷ lệ nợ xấu thay vì chỉ dùng lợi nhuận phát sinh đơn lẻ khi đánh giá kết quả tháng | Lợi nhuận phát sinh một tháng chịu ảnh hưởng lớn từ biến động trích lập dự phòng | Ban điều hành · áp dụng ngay |

---

## 🧮 Phương Pháp Phân Bổ Chi Phí Và Đánh Giá Nhân Sự

Hệ thống tính toán được xây dựng trong PostgreSQL nhằm đảm bảo quy tắc phân bổ chi phí và chấm điểm nhân sự được thực hiện thống nhất giữa các tháng và có thể kiểm tra lại ở từng bước.

### Bài toán 1: Phân bổ thu nhập và chi phí Hội sở về 7 vùng

Hệ thống áp dụng 2 quy tắc kế toán quản trị để xử lý 63.134 bút toán trên sổ cái:

| Quy tắc | Cách thức xử lý | Ý nghĩa nghiệp vụ |
|---|---|---|
| **Quy tắc 1 — Gán trực tiếp theo mã tỉnh** | Các bút toán trên sổ cái có mã tỉnh thành cụ thể được ghi nhận 100% vào vùng quản lý tỉnh thành đó | Phản ánh đúng phần thu nhập lãi, thu phí và chi phí phát sinh trực tiếp tại từng địa bàn |
| **Quy tắc 2 — Phân bổ phần Hội sở theo tiêu thức** | Các khoản hạch toán tập trung tại Hội sở (mã tỉnh `'00'` trên sổ cái, ánh xạ về mã vùng `'A'` trong `dim_area`) được phân bổ về 7 vùng theo tỷ lệ đóng góp của từng vùng trên tiêu thức tương ứng: dư nợ nhóm 1, dư nợ nhóm 2, dư nợ nhóm 2 đến 5 (trước và sau xoá nợ), số lượng thẻ phát sinh dư nợ, số lượng nhân sự quản lý, hoặc tổng dư nợ | Phân bổ chi phí vốn theo quy mô sử dụng vốn, chi phí quản lý chung theo quy mô nhân sự, và chi phí dự phòng chung theo quy mô dư nợ xấu của từng vùng |

Trong `stored procedure` điều phối `sp_baocao_tonghop`, quy trình tính lãi lỗ được tách thành **5 bước tuần tự qua 3 `stored procedure` bước trung gian**:

```text
Bước 1  sp_pnl_step1: Tính 9 tiêu thức phân bổ của từng vùng                  → tmp_pnl_step1_driver    315 dòng
Bước 2  sp_pnl_step2: Tính tỷ lệ phân bổ, kiểm tra tổng tỷ lệ 7 vùng = 1      → tmp_pnl_step2_ratio     560 dòng
Bước 3  sp_pnl_step3: Tách sổ cái thành phần Hội sở ('A') và phần gán thẳng   → tmp_pnl_step3_gl_split  535 dòng
Bước 4  sp_baocao_tonghop: Cộng phần gán thẳng với phần Hội sở nhân tỷ lệ     → fct_pnl_value         1.115 dòng
Bước 5  sp_baocao_tonghop: Tính dòng tổng hợp (E, F, H, A) và 4 tỷ số quản trị → fct_pnl_value
```

### Bài toán 2: Đánh giá quản lý vùng theo 2 trụ cột Quy mô và Hiệu quả tài chính

Bảng xếp hạng đánh giá quản lý vùng dựa trên 8 chỉ số thuộc **2 trụ cột**:

| Trụ cột | Các chỉ số cấu thành | Chiều đánh giá | Mục đích trong công thức đánh giá |
| :--- | :--- | :---: | :--- |
| **1. Phát triển quy mô (`diem_qm`)** | Doanh số cho vay mới bình quân lũy kế, số thẻ phát sinh dư nợ bình quân lũy kế, tỷ lệ duyệt hồ sơ bình quân | Cao là tốt | Đo lường kết quả mở rộng thị trường và chất lượng hồ sơ đầu vào của từng quản lý vùng (chỉ tính trung bình trên số tháng nhân sự thực tế làm việc) |
| **1. Phát triển quy mô (`diem_qm`)** | Tỷ lệ nợ xấu của vùng (dư nợ nhóm 3 đến 5 cộng nợ đã xoá trong năm chia cho tổng dư nợ trước xoá nợ) | Thấp là tốt | Kết hợp chỉ tiêu kiểm soát rủi ro vào trụ cột quy mô để hạn chế việc tăng doanh số nhưng làm tăng nợ xấu |
| **2. Hiệu quả tài chính (`diem_fin`)** | Tỷ lệ chi phí trên thu nhập (`CIR`), biên lợi nhuận (`Margin`), hệ số hiệu quả vốn, lợi nhuận bình quân trên một quản lý | `CIR` thấp là tốt; 3 chỉ số còn lại cao là tốt | Gắn kết quả đánh giá của quản lý vùng với hiệu quả tài chính của toàn vùng sau khi đã phân bổ chi phí Hội sở |

Do 8 chỉ số có đơn vị tính khác nhau (triệu đồng, số thẻ, phần trăm), hệ thống thực hiện **xếp hạng từng chỉ số (hạng 1 là cao nhất) rồi cộng các thứ hạng thành điểm tổng** — tổng điểm càng nhỏ thì thứ hạng chung cuộc càng cao. Quy trình tính điểm trong `stored procedure` điều phối `sp_xephang_asm` gồm **6 bước qua 3 `stored procedure` bước trung gian**:

```text
Bước 1  sp_xh_step1: Tính trung bình lũy kế 3 chỉ số bán hàng từng quản lý   → tmp_xh_step1_asm_avg    1.164 dòng
Bước 2  sp_xh_step2: Tính tỷ lệ nợ xấu từng vùng, lưu cả tử số và mẫu số     → tmp_xh_step2_npl_area     105 dòng
Bước 3  sp_xh_step3: Đọc 4 chỉ số tài chính từ báo cáo lãi lỗ và xếp hạng    → tmp_xh_step3_fin_area     315 dòng
Bước 4  sp_xephang_asm: Xếp hạng 4 chỉ số quy mô, tính điểm và hạng quy mô   → fct_asm_value      10 dòng/người
Bước 5  sp_xephang_asm: Ghép bộ điểm tài chính của vùng sang từng quản lý    → fct_asm_value       9 dòng/người
Bước 6  sp_xephang_asm: Cộng điểm hai trụ cột, xếp hạng chung cuộc toàn hàng → fct_asm_value       3 dòng/người
```

---

## 🔄 Quy Trình Xử Lý Dữ Liệu Tự Động

Hệ thống được tổ chức thành **luồng xử lý tự động 4 giai đoạn**, kết nối từ các tệp Excel đầu vào đến cơ sở dữ liệu PostgreSQL, báo cáo Power BI và tệp Excel xuất tự động:

<div align="center">

![Quy trình xử lý kỹ thuật — 4 giai đoạn](images/quy-trinh.png)

</div>

| # | Giai đoạn | Nội dung xử lý | Công cụ thực hiện | Kết quả đầu ra |
|---|---|---|---|---|
| 1 | **Dữ liệu đầu vào (Excel)** | Tập hợp 3 nguồn số liệu thô (sao kê hợp đồng 2,93 triệu dòng, sổ cái 63 nghìn dòng, bảng chỉ tiêu 84 quản lý vùng) và 1 tệp tham số & biểu mẫu đối chiếu | Excel | 3 tệp dữ liệu thô và 1 tệp tham số (2,99 triệu dòng) |
| 2 | **Nạp và làm sạch (Python)** | Đọc tệp sao kê dung lượng lớn; chuyển bảng chỉ tiêu quản lý vùng từ dạng ngang sang dạng dọc; chuẩn hoá tên tỉnh thành (ví dụ “Bà Rịa - Vũng Tàu” và “Vũng Tàu”) để khớp với bảng tham số vùng | Python (`openpyxl`, `psycopg2`), `run_all.py` điều phối 4 bước nạp | **5 bảng** trong kho: 2 bảng `dimension` (`dim_area` 8, `dim_param_area` 64) và 3 bảng `staging` (`stg_asm_target` 420, `stg_fact_txn_month` 63.134, `stg_fact_kpi_month` 2.932.922) |
| 3 | **Kho chứa và tính toán (PostgreSQL + DBeaver)** | Thực thi phân bổ chi phí và tính điểm xếp hạng theo từng tháng, lưu kết quả trung gian từng bước và ghi nhận lịch sử chạy | PostgreSQL, DBeaver thực thi **9 `stored procedure`** (`sp_load_dim`, `sp_baocao_tonghop`, `sp_xephang_asm` và 6 `stored procedure` bước) | **14 bảng** (5 bảng `dimension`, 6 bảng tạm `tmp_` theo bước, 2 bảng `fact` kết quả, 1 bảng `log_proc_run`) và **4 `view`** |
| 4 | **Vẽ và xuất báo cáo (Power BI + Python)** | Xây dựng bảng điều khiển tương tác phục vụ phân tích quản trị và xuất tệp báo cáo Excel giữ nguyên công thức theo biểu mẫu của đơn vị | Power BI Desktop (chế độ `Import` nạp 4 bảng), tập lệnh `run_report.py` | **5 trang báo cáo Power BI** (**72 `measure` DAX**) và tệp báo cáo Excel chuẩn mẫu ngân hàng |

**Các đặc điểm kỹ thuật trong vận hành:**
- **Đọc tệp Excel gần 3 triệu dòng bằng luồng XML:** Chương trình Python đọc trực tiếp luồng dữ liệu XML bên trong tệp nén `.xlsx`, xử lý theo từng dòng và nạp vào PostgreSQL bằng lệnh `COPY` để tiết kiệm bộ nhớ.
- **Tự động phát hiện tháng mới và xuất báo cáo (`run_report.py`):** Tập lệnh đối chiếu danh sách tháng đã có trong tầng `staging` với các tháng đã tính trong bảng `fct_pnl_value`, tự động gọi các `stored procedure` tính toán cho các tháng còn thiếu, sau đó đọc 2 `view` đơn vị đồng (`v_baocao_tonghop_vnd`, `v_xephang_asm_vnd`) để điền số liệu vào tệp báo cáo Excel.
- **Quản lý giao dịch (transaction) theo từng tháng:** Sáu `stored procedure` bước trung gian (`sp_pnl_step1..3`, `sp_xh_step1..3`) không đặt lệnh `COMMIT` giữa chừng; nếu phát sinh lỗi dữ liệu ở bất kỳ bước nào, toàn bộ dữ liệu của tháng đang chạy sẽ được hoàn tác (`ROLLBACK`) và ghi nhận trạng thái vào bảng `log_proc_run`.

---

## 🗄️ Thiết Kế Kho Dữ Liệu

Kho dữ liệu được thiết kế theo mô hình `Star Schema` trong lược đồ `banking_project` gồm **19 bảng và 4 `view`**, đáp ứng nhu cầu tra cứu số liệu trung gian và mở rộng chỉ tiêu báo cáo:

| Nhóm đối tượng | Số lượng | Các bảng cụ thể và số dòng | Vai trò trong hệ thống |
|---|---:|---|---|
| **Bảng `dimension` (`dim_`)** | 7 | `dim_area` 8 · `dim_param_area` 64 · `dim_asm` 84 · `dim_month` 5 · `dim_date` 151 · `dim_report_detail` 50 · `dim_sm_headcount` 35 | Quản lý danh sách vùng (`dim_area` là bảng duy nhất lưu `area_name`), ánh xạ tỉnh thành về vùng, danh sách quản lý vùng, lịch ngày chốt số từng tháng, số lượng nhân sự quản lý và danh mục 50 chỉ tiêu báo cáo |
| **Bảng `staging` (`stg_`)** | 3 | `stg_fact_kpi_month` 2.932.922 · `stg_fact_txn_month` 63.134 · `stg_asm_target` 420 | Lưu trữ dữ liệu gốc từ các tệp Excel đầu vào để phục vụ đối chiếu khi cần thiết |
| **Bảng trung gian (`tmp_`)** | 6 | `tmp_pnl_step1_driver` 315 · `tmp_pnl_step2_ratio` 560 · `tmp_pnl_step3_gl_split` 535 · `tmp_xh_step1_asm_avg` 1.164 · `tmp_xh_step2_npl_area` 105 · `tmp_xh_step3_fin_area` 315 | Lưu kết quả của từng bước tính toán trung gian, hỗ trợ việc kiểm tra số liệu của từng bước trong DBeaver |
| **Bảng `fact` kết quả (`fct_`)** | 2 | `fct_pnl_value` 1.115 (223 dòng/tháng) · `fct_asm_value` 8.536 (22 dòng/người/tháng) | Lưu kết quả theo cấu trúc dọc (mỗi dòng ứng với 1 tháng × 1 vùng hoặc 1 quản lý vùng × 1 mã chỉ tiêu), cho phép thêm chỉ tiêu mới vào `dim_report_detail` mà không cần thay đổi cấu trúc bảng |
| **Bảng theo dõi (`log_`)** | 1 | `log_proc_run` 95 | Ghi lại thời gian và trạng thái thực thi của từng bước trong các `stored procedure` |
| **`View` báo cáo (`v_`)** | 4 | `v_baocao_tonghop` 35 · `v_baocao_tonghop_vnd` 35 · `v_xephang_asm` 388 · `v_xephang_asm_vnd` 388 | Xoay dữ liệu từ cấu trúc dọc sang cấu trúc bảng ngang phục vụ Power BI và xuất Excel; kết nối `dim_area` để lấy tên vùng và lọc bỏ dòng Hội sở `'A'` |

<div align="center">

![Sơ đồ quan hệ giữa các bảng trong lược đồ banking_project](images/thiet-ke-schema.png)

</div>

**Một số quy ước thiết kế trong kho dữ liệu:**
- **Phân định rõ tệp quản lý từng bảng:** Mỗi bảng chỉ do một tệp mã nguồn chịu trách nhiệm khởi tạo cấu trúc, nạp dữ liệu và tạo chỉ mục (`index`), giúp việc tra cứu và bảo trì mã nguồn thuận tiện hơn.
- **Sử dụng 9 `Virtual Foreign Keys` (khoá ngoại ảo):** Do các bảng `dimension` và `staging` được làm mới độc lập bằng lệnh `TRUNCATE` trong quá trình nạp dữ liệu, hệ thống không đặt ràng buộc khoá ngoại vật lý để tránh xung đột khi làm mới từng bảng. Toàn vẹn tham chiếu được kiểm tra bằng truy vấn SQL và thể hiện trên sơ đồ DBeaver thông qua **9 `Virtual Foreign Keys`** nối về 3 bảng chiều chính (`dim_area`, `dim_month`, `dim_asm`).

---

## 🧪 Kiểm Tra Và Đối Soát Dữ Liệu

Để đảm bảo độ chính xác của số liệu trước khi đưa lên báo cáo, dự án thực hiện **4 bước kiểm tra và đối soát**:

| Bước kiểm tra | Nội dung thực hiện | Kết quả đối chiếu |
| :--- | :--- | :---: |
| **1. Đối chiếu với tệp biểu mẫu của đơn vị** | So sánh từng chỉ tiêu với tệp mẫu do đơn vị cung cấp tại các mốc kiểm tra: tổng lợi nhuận trước thuế lũy kế tháng 2 (**92.226,35 triệu đồng**), tháng 5 (**250.450,06 triệu đồng**) và vị trí dẫn đầu bảng xếp hạng (**Hoàng Văn Nam — 34 điểm** ở tháng 2, **36 điểm** ở tháng 5) | Khớp toàn bộ các chỉ tiêu tổng hợp và chi tiết |
| **2. Kiểm tra tính bảo toàn trong SQL** | Kiểm tra tổng tỷ lệ phân bổ của 7 vùng ở mọi tiêu thức bằng 1,000000 (sai số cho phép ≤ 1e-6); tổng tiền gán trực tiếp cộng tiền phân bổ từ Hội sở bằng tổng số tiền trên sổ cái gốc; 0 dòng dữ liệu mồ côi | Đạt trên cả 5 tháng dữ liệu |
| **3. Đối soát tự động giữa Power BI và PostgreSQL** | Sử dụng tập lệnh `export_pbi.ps1` và `audit_pbi_vs_db.py` để trích xuất kết quả các `measure` DAX từ Power BI và so sánh với câu truy vấn SQL độc lập trên **91 phép đo** (8 chỉ tiêu lãi lỗ × 7 vùng + 5 chỉ tiêu nhân sự và rủi ro × 7 vùng) | **91/91 phép đối chiếu khớp, 0 sai lệch** (dung sai tiền ≤ 0,02 triệu đồng, tỷ lệ ≤ 1e-4) |
| **4. Cộng kiểm tra trực tiếp trên tệp Excel gốc** | Đọc trực tiếp 1.124.553 dòng hợp đồng gốc của 2 tháng đầu năm từ tệp Excel bằng Python để tính tổng dư nợ từng vùng độc lập với cơ sở dữ liệu | **Chênh lệch 0 đồng** trên cả 7/7 vùng kinh doanh |

### Những giới hạn trong phạm vi phân tích

Dựa trên cấu trúc và độ chi tiết của dữ liệu nguồn hiện có, báo cáo xác định rõ những nội dung đủ cơ sở kết luận và những nội dung cần thêm dữ liệu chi tiết hơn:

| Những kết luận chưa đủ cơ sở từ dữ liệu | Nguyên nhân về mặt dữ liệu và nghiệp vụ | Cách diễn giải đúng trong báo cáo |
| :--- | :--- | :--- |
| “Quản lý vùng A bị giảm thứ hạng do tỷ lệ nợ xấu cá nhân tăng cao” | Tỷ lệ nợ xấu và 4 chỉ số tài chính được tính ở **cấp độ toàn vùng**; các quản lý vùng thuộc cùng một vùng nhận chung kết quả của vùng đó | “Chỉ số nợ xấu và tài chính phản ánh kết quả chung của địa bàn, dùng để gắn trách nhiệm chung của đội ngũ quản lý trong vùng” |
| “Chi phí dự phòng tháng 5 giảm mạnh chứng tỏ khách hàng trả nợ tốt hơn” | Sổ cái hiện tại chỉ ghi nhận một dòng chi phí dự phòng ròng, chưa tách riêng phần trích lập dự phòng mới và phần hoàn nhập dự phòng | “Cần tách riêng số trích lập mới và số hoàn nhập dự phòng từ dữ liệu của Khối Quản lý rủi ro trước khi đánh giá biến động chất lượng tín dụng” |
| “Doanh số giải ngân mới trong tháng 5 cao là nguyên nhân trực tiếp làm tăng lợi nhuận tháng 5” | Dư nợ thẻ giải ngân mới trong kỳ thường cần thời gian để tạo ra thu nhập lãi đáng kể ở các kỳ tiếp theo | “Doanh số giải ngân mới phản ánh tốc độ mở rộng quy mô khách hàng, chưa phải là yếu tố chính tạo ra biến động lợi nhuận ngay trong tháng đó” |
| “Áp dụng ngay mô hình của Nam Trung Bộ cho cả 6 vùng còn lại” | Vùng có quy mô nhân sự nhỏ (5 quản lý vùng) và chuỗi dữ liệu hiện tại mới quan sát trong 5 tháng | “Nam Trung Bộ là trường hợp có kết quả tốt để nghiên cứu và thử nghiệm có kiểm soát trước khi xem xét áp dụng rộng hơn” |

---

## 🛠️ Công Cụ Và Công Nghệ Sử Dụng

Các công cụ trong dự án được lựa chọn dựa trên yêu cầu xử lý dữ liệu và trình bày báo cáo:

| Yêu cầu kỹ thuật | Công cụ sử dụng | Vai trò trong dự án |
|---|---|---|
| Đọc tệp Excel gần 3 triệu dòng bị thiếu thông tin kích thước vùng dữ liệu (`dimension`) và chuẩn hoá tên tỉnh thành | Python 3.10.11 (`openpyxl`, `psycopg2`, đọc luồng XML) | Đọc dữ liệu theo luồng không gây quá tải bộ nhớ, chuyển bảng ngang thành dọc và nạp dữ liệu vào kho qua lệnh `TRUNCATE` + `COPY` |
| Lưu trữ dữ liệu tập trung, thực thi quy tắc phân bổ 2 chiều và thuật toán xếp hạng nhiều bước | PostgreSQL 16, PL/pgSQL (`stored procedure`) | Thực hiện tính toán bằng `Window Function` (`RANK()`), `CTE` (`WITH`), kiểm soát giao dịch an toàn và ghi nhật ký từng bước |
| Kiểm tra dữ liệu trung gian và quản lý sơ đồ cơ sở dữ liệu | DBeaver | Hiển thị sơ đồ 23 đối tượng cùng 9 `Virtual Foreign Keys` và hỗ trợ kiểm tra nhanh các bảng tạm (`tmp_`) sau mỗi bước tính toán |
| Xây dựng báo cáo tương tác và tính toán các chỉ tiêu phân tích biến động theo tháng | Power BI Desktop (chế độ `Import`), 72 `measure` DAX | Cập nhật ma trận nhiệt, biểu đồ phân tán và nội dung nhận định tương ứng với tháng được chọn trên `slicer` |

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

## 📂 Cấu Trúc Dự Án

```text
.
├── input/              # Lưu tệp tham số và mẫu báo cáo; 3 nguồn dữ liệu thô vượt trần dung lượng GitHub nên quản lý riêng
│   └── Tham so va mau doi chieu.xlsx  # Quy đổi 64 tỉnh thành về 8 vùng, ánh xạ tài khoản sổ cái, biểu mẫu chuẩn của 2 báo cáo
├── ingestion/          # Các chương trình Python đọc dữ liệu Excel, chuẩn hoá dữ liệu, nạp vào kho và xuất báo cáo
│                       # db_config.example.py — tệp mẫu cấu hình kết nối cơ sở dữ liệu
│                       # run_all.py điều phối chạy 4 bước nạp · run_report.py tự động kiểm tra số mới và xuất báo cáo Excel
├── sql/                # Mã nguồn SQL được tổ chức theo 4 lớp xử lý:
│   ├── dim/            #   dim_month_headcount (trục tháng, trục ngày + nhân sự), dim_asm, dim_report_detail (cây 50 chỉ tiêu)
│   ├── tmp/            #   tmp_pnl_step, tmp_xh_step — 6 bảng tạm lưu kết quả từng bước kèm 6 stored procedure bước
│   ├── fct/            #   fct_pnl_allocation (quy tắc 1 & 2), fct_xephang_asm (2 trụ cột) — bảng kết quả và 2 stored procedure điều phối
│   └── rpt/            #   rpt_pnl_view, rpt_xephang_view — 4 view xoay bảng ngang cho Power BI và Excel
├── output/             # Sản phẩm đầu ra: tệp báo cáo Excel lũy kế và tệp báo cáo Power BI (.pbix)
├── images/             # Hình ảnh sơ đồ quy trình và lược đồ kho dữ liệu minh hoạ trong tài liệu
├── docs/               # 4 tài liệu vận hành: HIEN_TRANG_HE_THONG, PIPELINE, NHAT_KY_CONG_VIEC, LOI_THUONG_GAP (58 mục lỗi)
├── requirements.txt    # Khai báo 2 thư viện Python sử dụng: psycopg2-binary và openpyxl
├── README.md           # Tài liệu giới thiệu dự án bằng tiếng Việt (trang mặc định)
└── README_eng.md       # Tài liệu giới thiệu dự án bằng tiếng Anh
```

---

## 🔒 Nguồn Dữ Liệu Và Quyền Sử Dụng

- Bốn nguồn dữ liệu Excel sử dụng trong dự án là **dữ liệu nghiệp vụ thực tế do đơn vị cung cấp và cho phép sử dụng** trong khuôn khổ dự án cuối khoá cũng như để trình bày phương pháp thực hiện dự án phân tích dữ liệu.
- **Lý do thư mục `input/` trên kho mã chỉ lưu giữ 1 tệp:** GitHub giới hạn dung lượng tối đa 100 megabyte cho mỗi tệp đẩy lên (và dự án duy trì ngưỡng dưới 25 megabyte cho mỗi tệp để thuận tiện tải qua trình duyệt web). Tệp sao kê hợp đồng thẻ gốc có dung lượng **117,2 megabyte** nên không đẩy lên kho mã công khai; hai tệp dữ liệu phát sinh còn lại (sổ cái 1,95 megabyte và chỉ tiêu quản lý vùng 26 kilobyte) được lưu cùng bộ dữ liệu gốc. Kho mã giữ lại tệp **`Tham so va mau doi chieu.xlsx`** (127.976 byte) chứa bảng tham số quy đổi 64 tỉnh thành và biểu mẫu định dạng của hai báo cáo. Người xem có thể kiểm tra đầy đủ mã nguồn, logic tính toán, tệp `.pbix` và tệp báo cáo Excel đầu ra; trường hợp cần chạy nạp lại dữ liệu từ đầu có thể liên hệ để nhận thêm ba tệp dữ liệu thô.
- Để đọc tệp sao kê hợp đồng 117,2 megabyte ổn định trong Python, tệp nén ban đầu được tách thành hai phần (`part1` nặng 83,6 megabyte và `part2` nặng 33,6 megabyte) ở tầng cấu trúc tệp nén mà không làm thay đổi nội dung dữ liệu bên trong; tổng số dòng nạp vào kho khớp **2.932.922 bản ghi**.


---

## 📚 Kinh Nghiệm Triển Khai Dự Án

1. **Nắm vững quy ước hạch toán và dấu của số liệu trước khi viết câu lệnh tính toán:** Trong dữ liệu sổ cái, các khoản chi phí vốn và chi phí hoạt động được ghi nhận mang dấu âm, đồng thời các bút toán tập trung tại Hội sở mang mã tỉnh `'00'` trên sổ cái và ánh xạ về mã vùng `'A'` trong bảng `dim_area`. Việc xác định rõ quy ước dấu và mã định danh ngay từ đầu giúp tránh sai sót khi tổng hợp các chỉ tiêu tài chính.
2. **Chuẩn hoá dữ liệu danh mục giúp tránh thất thoát bản ghi khi kết nối các bảng:** Trong quá trình kiểm tra dữ liệu gốc, tên tỉnh “Bà Rịa - Vũng Tàu” trên tệp sao kê hợp đồng được viết khác với “Vũng Tàu” trong bảng tham số. Bước chuẩn hoá chuỗi ký tự tỉnh thành (`pos_city_norm`) đã giúp giữ lại đầy đủ **36.043 dòng hợp đồng** của vùng Đông Nam Bộ khi tính tỷ lệ nợ xấu và tiêu thức phân bổ.
3. **Cần phân rã số liệu tổng hợp thành các cấu phần chi tiết để xác định đúng nguyên nhân biến động:** Nếu chỉ quan sát con số tổng hợp của tháng 5, lợi nhuận toàn hệ thống tăng +8,4%. Việc tách số lũy kế thành dòng chảy phát sinh riêng từng tháng và đối chiếu với tỷ lệ nợ xấu giúp nhận diện rõ mức tăng lợi nhuận tại Tây Nam Bộ và Đồng bằng Sông Hồng chủ yếu đến từ việc giảm chi phí dự phòng.

---

## 📖 Tài Liệu Bàn Giao

Bốn tài liệu trong thư mục `docs/` mô tả chi tiết hiện trạng hệ thống, quy trình vận hành và các lỗi đã xử lý:

- [`docs/HIEN_TRANG_HE_THONG.md`](docs/HIEN_TRANG_HE_THONG.md) — Hiện trạng kho dữ liệu, số dòng của 19 bảng và 4 `view`, bảng phân quyền tệp quản lý và các mốc số liệu đối chiếu.
- [`docs/PIPELINE.md`](docs/PIPELINE.md) — Kiến trúc chi tiết của luồng xử lý 4 giai đoạn và hướng dẫn câu lệnh chạy hệ thống.
- [`docs/NHAT_KY_CONG_VIEC.md`](docs/NHAT_KY_CONG_VIEC.md) — Nhật ký ghi nhận các bước triển khai và kết quả kiểm tra qua từng giai đoạn.
- [`docs/LOI_THUONG_GAP.md`](docs/LOI_THUONG_GAP.md) — Tài liệu tổng hợp **58 tình huống lỗi thực tế** (dữ liệu thô, SQL, Python, Power BI DAX) kèm nguyên nhân và cách khắc phục.

---

## 💼 Kỹ Năng Áp Dụng Trong Dự Án

<div align="center">

`Phân tích dữ liệu kinh doanh` · `Kế toán quản trị ngân hàng` · `Phân bổ chi phí đa tiêu thức` · `Phân rã biến động lợi nhuận` ·  
`Thiết kế Star Schema` · `SQL & PL/pgSQL (stored procedure, view)` · `Kiểm tra toàn vẹn dữ liệu` ·  
`Tự động hoá quy trình với Python` · `Làm sạch dữ liệu lớn` ·  
`Power BI (Import mode) & DAX` · `Đối soát dữ liệu tự động` · `Xây dựng báo cáo quản trị`

</div>

---

## 👤 Tác Giả

<div align="center">

**Trần Ngọc Đức** · Data Analyst · Business Intelligence · Data Science · Management Information Systems · Operations

*Phân tích dữ liệu tài chính ngân hàng · Thiết kế hệ thống báo cáo quản trị · Kiểm tra và đối soát dữ liệu*

[📧 tranduc22104@gmail.com](mailto:tranduc22104@gmail.com) · [💼 LinkedIn](https://www.linkedin.com/in/tr%E1%BA%A7n-ng%E1%BB%8Dc-%C4%91%E1%BB%A9c-48b3a7439/)

</div>
