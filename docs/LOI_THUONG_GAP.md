# LỖI THƯỜNG GẶP & CÁCH XỬ LÝ

1. **`log_proc_run does not exist` khi CALL từ Python**
   - Do `INSERT INTO log_proc_run` thiếu schema trong khi `search_path` khác DBeaver.
   - Fix: qualify `banking_project.log_proc_run` mọi chỗ trong procedure.

2. **CALL treo >120s / bảng trắng sau DROP**
   - Do `TO_CHAR(date)` + `LOWER(TRIM())` + `OR` alias trên 2.9M dòng, không index.
   - Fix: sinh `txn_month/prov/pos_city_norm` lúc nạp + index đúng cột JOIN.
   - Bảng trắng sau chạy full file là đúng (đầu file có `DROP`); `CALL` lại các tháng + F5 DBeaver.

3. **`CALL(null)` ra 0 dòng**
   - `WHERE month_key = NULL` luôn false. Muốn nhiều tháng thì `CALL` từng tháng 202301–202305.

4. **Chi phí ra dương / tỉ số ra 0**
   - `amount` đã mang dấu sẵn (D âm/C dương) — dùng nguyên, không đảo dấu lần 2.
   - `UPDATE` gộp: mọi vế phải nhìn giá trị cũ → tách tính tổng và tính tỉ số ra 2 câu riêng.
   - Chia nguyên `INT/INT` (8/73=0) → ép `::NUMERIC` tử số.

5. **NPL khớp sai / vùng H thiếu số**
   - WO chỉ cộng từ đầu năm (đừng lấy lịch sử 2022) — check `write_off_month` min.
   - Tên tỉnh viết lệch (`Bà Rịa - Vũng Tàu`) rớt khỏi vùng → chuẩn hóa + alias lúc nạp, đếm `UNKNOWN` sau nạp.

6. **Thiếu cột sau nâng ingestion (`pos_city_norm`, `txn_month`...)**
   - `CREATE TABLE IF NOT EXISTS` không tự thêm cột vào bảng cũ → `ALTER ... ADD COLUMN IF NOT EXISTS` hoặc DROP schema chạy lại từ đầu.

7. **Mẫu Excel ghi trùng số 2 ASM `tranvan`**
   - Lỗi phía mẫu, code tính đúng theo input — lệch rank dây chuyền ±1 là đã rõ nguyên nhân, không fix code.

8. **Hợp đồng chưa gắn bucket (`max_bucket` NULL) rớt khỏi driver nhóm nợ**
   - 249.709 HĐ (~1.591 tỷ) không vào nhóm nào → B2/B4 lệch phân bổ ±5–75tr/vùng mà tổng vẫn khớp nên khó phát hiện.
   - Fix: nhóm 1 gồm bucket 1 + `''` (no đủ tiêu chuẩn); kiểm chứng bằng tổng trị tuyệt đối chênh lệch T2 về 0.

9. **Viết lại cả measure DAX dễ typo (`_cur`/`_prev`) mà state vẫn Ready**
   - Model không báo lỗi dù sai tháng → sau mỗi lần Update phải `EVALUATE` lại và đối chiếu số tay (Postgres/view) mới tin được.

10. **CALL từ Python báo `procedure ... does not exist` / `relation "tmp_pnl_step2_ratio" does not exist`**
    - File SQL có `SET search_path TO banking_project` nhưng phiên psycopg2 không có → cả procedure lẫn bảng unqualified đều không tìm thấy.
    - Fix: sau khi connect chạy `SET search_path TO banking_project, public` VÀ gọi `CALL banking_project.sp_xxx(...)` (schema-qualified cho chắc).

11. **Chạy pipe (`"" | py ...`) bị `EOFError` ở `input()`**
    - `input()` hết stdin → traceback. Bắt `EOFError` trong khối input rồi mặc định tháng gần nhất — test không interactivity cũng chạy được.

12. **psycopg2: `LIKE '85%'` trong câu có params → `IndexError: tuple index out of range`**
    - psycopg2 coi `%` là placeholder; `'%'` làm parser lệch (thông thường báo `unsupported format character`, bản này IndexError khó hiểu).
    - Fix: escape thành `LIKE '85%%'` khi `execute(sql, params)`; query không truyền params thì chạy bình thường.

13. **Excel xuất ra số gấp 1.000.000 lần (đơn vị sai)**
    - `fct_pnl_value` + pool HEAD `'00'` lưu **VND**, file mẫu ghi "ĐVT : Triệu đồng" → mọi value ghi vào `BaocaoTonghop` (đọc qua view `v_baocao_tonghop_vnd`) phải `/1e6`.
    - Riêng `KPI_ASM_DATA`, `ltn_avg`/`hsbq_nhan_su` của Xếp hạng là VND → giữ nguyên như mẫu.
    - openpyxl không tính công thức → verify phải **cộng từ ô lá** rồi đối chiếu `SUM(a_lntt)/1e6`, không đọc ô tổng được.

14. **Verify in "FAIL" dù message ra đúng giá trị: so `Decimal` với `float`**
    - psycopg2 trả `NUMERIC`/`ROUND()` là `Decimal`; `Decimal('92226.35') == 92226.35` → `False` (float 92226.35 thực ra 92226.34999...).
    - Fix: ép `float(value) == ...` (hoặc so `Decimal(str(...))`) — đọc kỹ trước khi kết luận fail.

15. **`banking_project.information_schema.tables` báo `cross-database references are not implemented`**
    - `information_schema` là catalog cấp **database**, không thuộc schema của bạn — tuyệt đối không nối `banking_project.` phía trước.
    - Fix: `SELECT ... FROM information_schema.tables WHERE table_schema = 'banking_project'` (chỉ filter bằng `table_schema`).
    - Kết hợp mục 12: câu có `LIKE 'calc_%'` mà truyền params thì phải escape `%%`.

16. **Tổng nhóm lệch 0.01 so với golden: `ROUND(Σ thô, 2)` ≠ `Σ ROUND(lá, 2)`**
    - Wide cũ ghi đè tổng từ **các lá đã lưu 2 số lẻ** (`f_tong = f1+f2+f3+f4`); code mới tính lại từ expression rồi `ROUND` 1 lần → lệch đúng 0.01, lan sang downstream (`a_lntt` rồi `hsbq_nhan_su` XH).
    - Fix: bước tổng phải cộng đúng theo con đường dữ liệu cũ (cộng row đã lưu), không "tối ưu" sang ROUND tổng thô.
    - Kiểm pct cũng vậy: `SUM(pct_nhom1)` có thể ra `1.00000001` (mỗi % làm tròn 8 số lẻ) — verify dùng `abs(x-1) <= 1e-6`, không so `== 1`.

17. **Cột npl trong view v_xephang_asm vốn đã được nhân 100 sẵn**
    - Triệu chứng: Khi viết measure `AVERAGE(v_xephang_asm[npl]) * 100`, tỷ lệ nợ xấu bị phóng đại 100 lần (21.99% biến thành 2198.61%).
    - Nguyên nhân: Trong procedure `sp_xephang_asm`, report_id 204 được tính bằng `(num / den) * 100` để ra số phần trăm trực tiếp.
    - Khắc phục: Dùng trực tiếp `AVERAGE('banking_project v_xephang_asm'[npl])`, không nhân thêm 100.

18. **Nhầm lẫn tên cột trong view v_baocao_tonghop (cp_hd_khac vs tong_chiphi vs tong_thunhap)**
    - Triệu chứng: Khoản mục D ra số lẻ không khớp, Khoản mục E và F bị lệch số nghiêm trọng.
    - Nguyên nhân: Trong view wide `v_baocao_tonghop`:
      + Cột `cp_hd_khac_trieu_dong` tương ứng `report_id = 34` (Khoản mục D: Chi phí hoạt động khác / KD khác), không phải F.
      + Cột `tong_chiphi_trieu_dong` tương ứng `report_id = 56` (Khoản mục F: Tổng chi phí hoạt động OPEX).
      + Cột `tong_thunhap_trieu_dong` tương ứng `report_id = 40` (Khoản mục E: Thu nhập thuần = B + C + D).
      + Cột `tong_dt_trieu_dong` tương ứng `report_id = 80` (Khoản mục H).
    - Khắc phục: Phải tra cứu đúng view definition và `report_id` trong `dim_report_detail` trước khi bind cột vào measure DAX.

19. **Lỗi "The syntax for 'style' is incorrect" và lỗi font Mojibake khi nạp DAX HTML qua PowerShell**
    - Triệu chứng:
      + Power BI báo lỗi: `The syntax for 'style' is incorrect`.
      + Chữ tiếng Việt bị vỡ thành ký tự loằng ngoằng: `THáº¤P`, `MÃ´ hÃ¬nh tÄƒng trÆ°á»Ÿng`, `Æ¯U TIÃŠN`...
    - Nguyên nhân:
      + Cú pháp DAX: Dùng chuỗi `@""...""@` trong PowerShell làm nhân đôi dấu nháy kép thành `""<div...""`, DAX hiểu `""` là chuỗi rỗng và parse `style` như một identifier không hợp lệ.
      + Font chữ: PowerShell đọc file script `.ps1` không có BOM bằng code page ANSI/Windows-1252 làm sai lệch encoding UTF-8 tiếng Việt.
    - Khắc phục:
      + Dùng chuỗi verbatim `@'...'@` trong PowerShell để giữ nguyên đúng 1 dấu nháy kép `"<div..."`.
      + Luôn lưu file script PowerShell với encoding **UTF-8 with BOM (`utf-8-sig`)** và khai báo `[Console]::OutputEncoding = [System.Text.Encoding]::UTF8`.

20. **Không đổi được culture model sang `vi-VN` sau khi đã tạo object**
    - **Triệu chứng:** `Update` model trả `Culture and Collation properties of the Model object may be changed only before any other object has been created.`
    - **Hệ quả:** `FORMAT()` luôn theo `en-US` → `56,797.5` / `83.8%` thay vì `56.797,5` / `83,8%` như file HTML.
    - **Cách xử lý:** bọc tại chỗ: `SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(FORMAT(x,fmt),",","§"),".",","),"§",".")` (dùng ký tự tạm `§` để hoán đổi 2 dấu). Không áp lên toàn chuỗi HTML vì sẽ phá CSS (`rgba(37,99,235,0.2)`, `1.35`...).

21. **`TREATAS({202305}, dim_month[month_key])` không lọc được view `v_asm_attainment_deepdive`**
    - **Triệu chứng:** measure trả số toàn hệ thống/toàn kỳ (VD 345.188,0 thay vì 109.480,2) dù đã TREATAS tháng.
    - **Nguyên nhân:** view không có quan hệ với `dim_month`; TREATAS chỉ tác động lên cột đích khi có relationship.
    - **Cách xử lý:** filter trực tiếp cột của view: `'banking_project v_asm_attainment_deepdive'[month_key] = vM` (+ `area_code`), và `REMOVEFILTERS('banking_project dim_month')` nếu cần.

22. **`RANKX` trả 1 cho mọi vùng khi xếp hạng theo chiều**
    - **Nguyên nhân:** dùng `VALUES(area_code)` / `ADDCOLUMNS` trong ngữ cảnh filter hiện tại → bảng chỉ còn 1 dòng.
    - **Cách xử lý:** `RANKX(ALL('view'[area_code]), CALCULATE(AVERAGE('view'[diem_fin])), , ASC, DENSE)`; `ADDCOLUMNS` trong `RANKX` dễ gây SemanticError, tránh dùng.

23. **Tỷ lệ nợ xấu bị nhân 100 lần (`1124,00%` thay vì `11,24%`)**
    - **Nguyên nhân:** `Page3_Area_NPL` trả về đơn vị "điểm phần trăm" (11,24 nghĩa là 11,24%), nhưng measure HTML dùng `FORMAT(v_NPL, "0.00%")` → FORMAT nhân thêm 100.
    - **Cách xử lý:** `FORMAT(v_NPL, "0.00") & "%"` (kèm bọc `SUBSTITUTE` để ra dấu phẩy thập phân). Chỉ dùng `"0.00%"` khi giá trị là tỷ lệ 0–1.

24. **Measure trong `01. Dung De Tinh Toan` không tự lọc tháng → số bị gộp toàn kỳ**
    - **Triệu chứng:** trong measure HTML không có slicer, `Page3_Area_NPL` ra 10,87% (bình quân 5 tháng) thay vì 11,24%; `Page3_ASM_Total` ra 84 thay vì 19; `Page3_ASM_Bot24_Count` ra 63 thay vì 16.
    - **Nguyên nhân:** các measure này chỉ `AVERAGE`/`COUNTROWS` trên view, không tự gán tháng; chúng dựa vào filter context của visual.
    - **Cách xử lý:** thêm `VAR v_CurMonth = SELECTEDVALUE('banking_project dim_month'[month_key], MAX('banking_project dim_month'[month_key]))` rồi `CALCULATE(..., 'banking_project v_xephang_asm'[month_key] = v_CurMonth)` tại chỗ gọi trong measure HTML.

25. **Muốn biết measure nào "chết" (không dùng) mà MCP không đọc được layout report**
    - **Cách làm:** `.pbix` là file zip. Copy ra temp rồi mở bằng `System.IO.Compression.ZipFile`, lấy các entry `Report/definition/pages/**/visual.json` (định dạng PBIR) — mỗi visual 1 file JSON. Quét `"Property":"<tên measure>"` hoặc tìm chuỗi tên measure trong toàn bộ file để biết visual nào đang bind.
    - **Đừng quên phụ thuộc:** measure tính toán trung gian không xuất hiện trong visual nhưng vẫn "sống" nếu measure khác tham chiếu. Xuất TMDL (`database_operations` → `ExportToTmdlFolder`) rồi dựng đồ thị `[Tên]` / `'Tên'` để tìm ai dùng ai.
    - **Lưu ý:** measure chưa gắn visual nhưng nằm trong kế hoạch dựng trang mới **không được xoá**; xoá bằng `shouldCascadeDelete: false` để tránh SSAS xoá lan sang measure phụ thuộc.

26. **Sửa expression measure dài (10–25 KB) mà không phải dán cả chuỗi qua MCP**
    - **Cách làm:** Power BI Desktop có sẵn TOM trong thư mục cài đặt — load `Microsoft.AnalysisServices.Server.Tabular.dll` (namespace vẫn là `Microsoft.AnalysisServices.Tabular`), kèm `...Tabular.Json.dll`, `...Server.Core.dll`, `...MInterop.dll`; sau đó:
      ```powershell
      $srv = New-Object Microsoft.AnalysisServices.Tabular.Server
      $srv.Connect("localhost:<port msmdsrv>")
      $m = $srv.Databases[0].Model.Tables["LAI LO (Visuals & DAX)"].Measures["Page3_Heatmap_Table_HTML"]
      $m.Expression = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
      $srv.Databases[0].Model.SaveChanges()
      ```
    - **Lợi ích:** sinh file `.txt` bằng Python (patch chuỗi có assert `count == 1`) rồi nạp thẳng — tránh lỗi JSON escape và tiết kiệm token. Nhớ ghi file bằng `UTF8Encoding($false)` (không BOM) và `newline="\n"`.
    - **Bẫy:** đừng khai báo trùng `VAR v_CurMonth` (bản live đã có `SELECTEDVALUE(...)`); `VAR` phải khai báo **trước** khi được tham chiếu (ví dụ `v_Ref_LNTT` phải nằm sau `v_F_LNTT`/`v_D_LNTT`).

27. **Câu chữ trong measure HTML bị sai dấu khi đổi tháng ("cải thiện -94,8", "tăng thêm -4.965,4")**
    - **Nguyên nhân:** câu văn viết cho tháng tham chiếu (T5) nhưng số lấy trực tiếp `FORMAT(v, "+#,##0.0")` → tháng khác dấu âm thì câu vô nghĩa.
    - **Cách xử lý:** tách động từ khỏi số: `IF(v_G_Delta >= 0, "cải thiện ", "giảm ") & FORMAT(ABS(v_G_Delta), "#,##0.0")`; tương tự cho "lớn hơn/nhỏ hơn", "tăng/giảm", "làm giảm/làm tăng". Tháng tham chiếu vẫn ra đúng nguyên văn file HTML.

28. **Chữ trong visual HTML Content quá nhỏ khi xem cả trang (canvas 1920×1300)**
    - **Nguyên nhân:** cỡ chữ nằm **cứng trong measure** (`font-size:8,4–10,5px`), visual HTML Content **không tự co giãn chữ** theo container — kéo to visual thì chữ vẫn vậy, thu nhỏ trang (Fit to page) thì chữ càng nhỏ.
    - **Cách xử lý (đã áp dụng task 78):** nhân toàn bộ `font-size` trong 8 measure ×1,45 bằng regex `font-size:([\d.]+)px` (Python patch file `.txt` → TOM `SaveChanges`), đồng thời **nới canvas** 1920×1300 → 1920×1760 và tăng H từng khối (Heatmap/Quadrant 420→540, 04/PHẦN 4 330→430, Diagnosis 180→330) để không phải cắt nội dung.
    - **Kèm theo:** `Page3_Headline_HTML` cột trái `flex:0 0 240px` → `330px` (số lớn 18→26,1px không còn xuống dòng xấu); header row heatmap `height:24px` → `34px`.
    - **Lưu ý khi xem:** dùng zoom **100%** (fit-to-width, cuộn dọc) hoặc **Focus mode** từng khối; *Fit to page* sẽ thu nhỏ lại và mất toàn bộ lợi ích. Nếu vẫn cần "một màn hình nhìn hết" thì phải tách trang (mỗi khối to gấp đôi) — không thể vừa giữ đủ nội dung vừa đọc to trên một trang.

29. **`CALCULATE(COUNTROWS(...))` trả BLANK → chuỗi HTML in ra `/16` thay vì `0/16`**
    - **Nguyên nhân:** khi filter không khớp dòng nào, `CALCULATE` trả BLANK chứ không trả 0; nối chuỗi thì BLANK thành rỗng.
    - **Cách xử lý:** thêm `+ 0` ngay sau `CALCULATE` cho **mọi** count dùng trong nối chuỗi (`CALCULATE([Page3_ASM_Top25_Count], ...) + 0`). Đã áp cho `v_G_Top`, `v_G_Bot`, `v_F_Top` trong `Page3_Diagnosis_Framework_HTML` (task 80).
    - **Kiểm tra:** render rồi tìm các mẫu `/1[0-9]` đứng đầu câu — nếu thiếu số tử là còn sót BLANK.

30. **Không thêm được bảng import mới vào model đang mở (refresh treo vô hạn)**
    - **Triệu chứng:** tạo bảng từ `PostgreSQL.Database` navigation → `The key didn't match any rows in the table` (cache schema cũ); dùng `Value.NativeQuery` → `SaveChanges` treo mãi và giữ write-lock.
    - **Cách xử lý:** gửi TMSL `{"cancel":{"object":{...}}}` qua `$srv.Execute($json)` để giải phóng lock, rồi **bỏ bảng khỏi model**. Không cố refresh lại trong phiên Desktop đang mở.
    - **Giải pháp thay thế:** dùng dữ liệu đã có trong model (ví dụ thay `ltn_thang` bằng `asm_count`) và tra số còn thiếu trực tiếp trong DBeaver từ `stg_asm_target` (`SELECT area_code, SUM(ltn_amount)/1e6 ... GROUP BY 1`). View `v_asm_ltn_thang` từng dựng cho việc này đã xoá (task 85).
    - **Khi nào thử lại:** sau khi lưu `.pbix`, đóng và mở lại Desktop (cache schema được làm mới), hoặc dựng bảng bằng MCP `table_operations` với `mExpression` tường minh thay vì navigation.

31. **ADOMD đặt tên cột kết quả DAX có ngoặc vuông (`[@flow]`)**
    - **Triệu chứng:** export DAX ra CSV rồi đọc bằng `csv.DictReader` → `row["@flow"]` trả `None`, toàn bộ so sánh ra 0.
    - **Cách xử lý:** chuẩn hoá tên cột khi load: `kk.replace("[","").replace("]","")`; hoặc đặt alias không có `@` (`"flow", [Page3_Flow_LNTT]`).
    - **Kèm theo:** ADOMD cũng dùng tên cột làm tên file nếu ghi `render_$name.html` → file thành `render_[header].html`.

32. **Diff template mentor vs output: 7 ô lệch ở dòng 28 "Chi phí dự phòng"**
    - **Triệu chứng:** so `output/BC_PNL_YTD_202302.xlsx` với `report_xep_hang_kinh_doanh_monthly.xlsx` (sheet `BaocaoTonghop_T2`): 220/227 ô khớp, 7 ô lệch đúng dòng 28, max 26,27 trđ, tổng lệch ≈ 0.
    - **Nguyên nhân:** dòng 28 trong template là **dòng duy nhất hard-code** (các dòng 3/22/23/31–34 đều là công thức), nên không có công thức để đọc. `B28` = `-4.776,00116` trđ = đúng pool HEAD (`prov='00'`) của ta → chỉ khác **tỉ lệ chia pool** (pool = 1,44% tổng dự phòng). Driver hiện tại là dư nợ nhóm 2–5 trước WO bình quân YTD.
    - **Cách xử lý:** **không sửa** — đã thử 20+ driver (nhóm 2–5/3–5/4–5/5/toàn bộ; `os` vs `os+wo`; YTD vs tháng 2; wo trong năm; tỉ lệ dự phòng direct; hồi quy rate theo nhóm) đều không tái lập được tỉ lệ của mentor. Công bố sai số 0,008% trong mục "Hạn chế" thay vì ép số.
    - **Đã loại trừ lỗi nạp liệu:** đọc trực tiếp file input (1.124.553 dòng, 2 tháng) và tự tính lại `dtruoc`/`dtot` theo vùng → khớp **0 đồng** với `stg_fact_kpi_month` (7/7 vùng). Thử thêm mốc tháng 1→5 và YTD 1-2…1-5 → vẫn không khớp tỉ lệ template. Nghi vấn còn lại: mentor dùng số dư cuối 2022 (input không có).
    - **Lưu ý khi đọc file raw:** `openpyxl` read-only đọc file này ra `max_row=1, max_col=1` (file thiếu thẻ `<dimension>`) → phải gọi `ws.reset_dimensions()` trước khi `iter_rows`, nếu không chỉ nhận được cột `kpi_month`.
    - **Lưu ý về city mapping:** raw ghi `Bà Rịa - Vũng Tàu`, `dim_param_area` ghi `Vũng Tàu`; ingestion chuẩn hoá thành `pos_city_norm = 'vũng tàu'`. Khi tính lại bằng Python phải map qua `stg.pos_city → pos_city_norm`, map trực tiếp `pos_city → city_name` sẽ mất 36.043 dòng của vùng H.
    - **Lưu ý khi diff:** ô công thức trong output do `openpyxl` ghi **không có cached value** (`None`) → chỉ so được các dòng nhập liệu; muốn so dòng công thức phải mở bằng Excel hoặc tính lại thủ công.

33. **`rank_final` của ASM bị trùng hạng / đảo thứ tự so với template**
    - **Triệu chứng:** diff sheet `BaocaoXepHangASM_T2` thấy 880 ô lệch nhưng phần lớn là **thứ tự dòng**, không phải giá trị: `mai.nguyenthi` (56 điểm) và `khanh.nguyenvan` (58 điểm) — template xếp 3 và 4, ta trả **cả hai `rank_final = 3`**.
    - **Nguyên nhân:** `RANKX` mặc định trả hạng bằng nhau khi điểm bằng nhau và không có tie-break tất định; ngoài ra thứ tự xuất dòng không có `ORDER BY` ổn định.
    - **Cách xử lý (chưa áp dụng):** thêm tie-break tất định — trong `sql/fct/fct_xephang_asm.sql` dùng `ROW_NUMBER() OVER (ORDER BY tong_diem, email)`; trong DAX dùng `RANKX` trên khoá ghép `[Tổng điểm] * 1e6 + X` (X = hạng phụ theo email) để không còn hạng trùng.

34. **Guard "đủ 7 vùng" tính cả pool `'00'` nên vẫn lọt khi tháng chưa chạy Tổng hợp**
    - **Triệu chứng:** `sp_xephang_asm` chạy xong, `log_proc_run` toàn OK, nhưng `fct_asm_value` không có 9 dòng tài chính (report_id 211–219) của ASM nào.
    - **Nguyên nhân:** `v_nth := COUNT(DISTINCT area_code)` đọc từ `fct_pnl_value` **không loại `'00'`** → tháng chỉ có dòng Hội sở vẫn ra 8 (≥ 7) nên điều kiện guard đúng, trong khi phần tính FIN lọc `area_code <> '00'` thì được 0 dòng.
    - **Cách xử lý:** đếm phải cùng bộ lọc với chỗ tính (`AND area_code <> '00' AND report_id = 70`), guard yêu cầu đúng 7. Kiểm nhanh (bảng STEP3 đã chuyển sang tall nên phải lọc thêm `report_id`): `SELECT COUNT(*) FROM tmp_xh_step3_fin_area WHERE month_key = 202305 AND report_id = 219;` phải = 7.

35. **PostgreSQL không cho dùng bí danh `SELECT` trong `HAVING` (`column "s" does not exist`)**
    - **Triệu chứng:** câu kiểm bất biến viết `SELECT SUM(value) AS s FROM tmp_pnl_step2_ratio GROUP BY report_id HAVING ABS(s - 1) > 1e-6` báo lỗi không tìm thấy cột.
    - **Nguyên nhân:** `HAVING` chạy trước `SELECT`, chưa có bí danh (SQL Server/BigQuery cho, PostgreSQL không).
    - **Cách xử lý:** lặp lại biểu thức trong `HAVING` (`HAVING ABS(SUM(value) - 1) > 1e-6`) hoặc bọc thêm một lớp `SELECT` con rồi lọc ở lớp ngoài.

36. **Đổi tên bảng tạm bằng `DROP/CREATE` tên mới để lại bảng cũ mồ côi trong DB**
    - **Triệu chứng:** `information_schema.tables` có 10 bảng `tmp_` trong khi tài liệu ghi 6; số liệu vẫn đúng vì procedure chỉ đọc tên mới.
    - **Nguyên nhân:** file SQL đổi tên `tmp_pnl_step1_kpi_driver`/`step2_psdn_sm`/`step3_ratio`/`step4_gl_split` thành `step1_driver`/`step2_ratio`/`step3_gl_split` nhưng chỉ `DROP` tên mới — 4 bảng cũ vẫn nằm nguyên trong schema.
    - **Cách xử lý:** chạy `DROP TABLE IF EXISTS <tên cũ> CASCADE;` một lần cho 4 bảng, rồi kiểm `SELECT table_name FROM information_schema.tables WHERE table_schema='banking_project' AND table_name LIKE 'tmp%'` phải ra đúng 6. Trước khi drop nhớ grep tên cũ trong `sql/`, `ingestion/`, `docs/` để chắc không còn chỗ nào tham chiếu.

37. **TOM: `$db.SaveChanges()` không tồn tại → `MethodNotFound`, measure không được ghi vào model**
    - **Triệu chứng:** script PowerShell gán `$found.Expression = ...` xong gọi `$db.SaveChanges()` thì nhận `InvalidOperation: MethodNotFound`; mở Power BI Desktop thấy measure vẫn là expression cũ.
    - **Nguyên nhân:** `Microsoft.AnalysisServices.Tabular.Database` **không có** method `SaveChanges` — API này nằm trên `Model`. reflection cho thấy `$db.Model.GetType()` mới liệt kê `SaveChanges`.
    - **Cách xử lý:** gọi `$db.Model.SaveChanges()` (trả về `ObjectImpact`, in ra là dấu hiệu ghi thành công). Lưu ý thêm: SaveChanges chỉ sửa **live model** của phiên Desktop đang mở, **không tự ghi file** → phải Ctrl+S trong Power BI Desktop để `.pbix` lưu thay đổi.

38. **`run_report.py` trỏ tệp mẫu Excel ra gốc dự án — chỉ lộ ra khi dọn lại thư mục**
    - **Triệu chứng:** trước khi tái cấu trúc ngày 2026-10-30, `TEMPLATE_XLSX = os.path.join(BASE_DIR, "report_xep_hang_kinh_doanh_monthly.xlsx")` trong khi tệp mẫu thật nằm ở `pbi/`. Bước `[3/3] XUẤT BÁO CÁO` sẽ chết ở `openpyxl.load_workbook(TEMPLATE_XLSX)` với `FileNotFoundError`.
    - **Nguyên nhân:** đường dẫn cứng tới tệp dữ liệu ghi rải rác, không đọc từ `db_config.INPUT_DATA_DIR`; tệp mẫu bị dời sang thư mục khác khi làm báo cáo mà không ai cập nhật chỗ trỏ. Hai bước đầu của workflow không đụng tới tệp mẫu nên lỗi nằm im.
    - **Cách xử lý:** `TEMPLATE_XLSX` nay trỏ `input/report_xep_hang_kinh_doanh_monthly.xlsx` — đúng chỗ task 01 đọc sheet `Param`. Kiểm chứng bằng cách chạy thật `py ingestion/run_report.py` (không chỉ `py_compile`): xuất `output/BC_PNL_YTD_202305.xlsx`, 124.428 bytes. Bài học: sau mỗi lần đổi cấu trúc thư mục phải chạy trọn luồng một lần, vì `py_compile` không phát hiện được đường dẫn tệp sai.

39. **Tài liệu ghi cột `pct` nhưng bảng tạm lưu tỉ lệ ở cột `value`**
    - **Triệu chứng:** chép câu kiểm trong `docs/HIEN_TRANG_HE_THONG.md` và tệp trình bày cấu trúc SQL (đang nằm ngoài kho mã) — `SUM(pct) = 1` theo `report_id` ở `tmp_pnl_step2_ratio` — PostgreSQL báo `ERROR: column "pct" does not exist`; chạy thủ tục vẫn ra số đúng.
    - **Nguyên nhân:** khi dồn các bước P&L thành bảng tạm dạng dọc (đợt refactor 2026-10-30), cột tỉ lệ đổi tên thành `value` cho thống nhất với các bảng tạm khác, nhưng mô tả trong tài liệu không đổi theo. Tài liệu là bản viết trước khi sửa code nên lệch nằm im cho tới lần đối chiếu sau.
    - **Cách xử lý:** tra `information_schema.columns` rồi sửa tài liệu theo tên thật; câu kiểm đúng là `SELECT report_id, SUM(value) FROM tmp_pnl_step2_ratio WHERE month_key = 202302 GROUP BY report_id;` (mỗi chỉ tiêu tổng bằng 1, sai số làm tròn tháng `202303` là 1.00000001). Bài học: sau khi đổi tên cột, grep tên cũ trong toàn bộ `docs/` trước khi coi là hoàn tất — `py_compile` và chạy thủ tục không phát hiện được tài liệu nói sai.

40. **Hai đề mục cùng tên trong `README.md` — biểu hiện "lỗi gù" khi xem bảng mục lục**
    - **Triệu chứng:** bảng mục lục và trình duyệt hiển thị hai dòng "Xếp hạng giám đốc vùng" liền nhau, người đọc không phân biệt được chỗ nào nói SQL, chỗ nào nói trang báo cáo.
    - **Nguyên nhân:** `README.md` viết mục "Cách tính xếp hạng..." ở phần nghiệp vụ và phần ảnh dashboard sau này cũng lấy tiêu đề gần giống; cả hai đều ở mức `###` nên anchor sinh ra trùng nhau.
    - **Cách xử lý:** đặt tên khác nhau ngay cả khi chủ đề trùng — hiện là `### Cách tính xếp hạng giám đốc vùng trong SQL` và `### Xếp hạng giám đốc vùng trên trang báo cáo`. Bảng mục lục chỉ neo ở mức `##` nên đổi tên `###` không làm gãy link.

41. **Tệp nguồn 117,2 MB vượt trần dung lượng — tách thành hai phần mà không sửa một dòng dữ liệu nào**
    - **Triệu chứng:** `input/fact_kpi_month_raw_data_202402020653.xlsx` (122.843.542 byte) vượt trần 100 MB cho mỗi tệp của GitHub nên không đẩy lên kho được; bước 04 chỉ chạy trên máy có tệp này, người nhận kho mã không tái tạo được bảng `stg_fact_kpi_month`. (Lúc đó tệp bị chặn bằng `.gitignore`; từ 2026-10-31 cả thư mục `input/` đứng ngoài kho mã và tệp chặn đã gỡ, xem mục 53.)
    - **Nguyên nhân sâu:** ba sheet bên trong tệp nén chiếm lần lượt 43,7 · 44,0 · 35,2 megabyte sau nén, cộng lại vượt trần dù từng sheet thì không. Mở bằng `openpyxl` rồi lưu lại sẽ dựng lại toàn bộ XML, đổi cả những dòng không đụng tới, không thể coi là bản tách nguyên vẹn.
    - **Cách xử lý:** làm việc ở tầng tệp nén. Hai workbook mới được ghép bằng cách chép nguyên xi các phần dùng chung (`_rels/.rels`, `docProps/`, `xl/sharedStrings.xml`, `xl/styles.xml`) và hai hoặc một phần sheet, chỉ viết lại ba phần cấu trúc `[Content_Types].xml`, `xl/workbook.xml`, `xl/_rels/workbook.xml.rels` cho khớp số sheet còn lại. Kết quả 83,6 MB (hai sheet) và 33,6 MB (một sheet).
    - **Cách kiểm:** so mã CRC và kích thước giải nén của từng sheet giữa tệp gốc và tệp tách — khớp từng byte; sau đó bóc lại CSV và đối chiếu với mốc đang nằm trong database (2.932.922 dòng, tổng dư nợ 47.055.450.472.633,00, 2.285.977 dòng có nhóm nợ, đủ năm tháng). Không cần tin lời script tự in ra số dòng.
    - **Lưu ý khi sửa script nạp liệu:** thay vì gõ cứng danh sách `xl/worksheets/sheetN.xml`, hãy liệt kê phần worksheet có trong từng tệp (`z.namelist()`) rồi duyệt; như vậy số phần và số sheet của nguồn không còn là ràng buộc của code.

42. **Chạy lại riêng lớp `sql/dim/` làm mất hai view xếp hạng và một khóa ngoại mà không báo lỗi**
    - **Triệu chứng:** sau khi chỉ chạy `sql/dim/DIM_DATE_PNL_ASM.sql` rồi `sql/dim/dim_asm.sql` và `sql/dim/dim_report_detail.sql`, câu `SELECT COUNT(*) FROM banking_project.v_xephang_asm` báo `relation ... does not exist`; `pg_constraint` lọc `contype='f'` trả tập rỗng dù tài liệu ghi `fct_asm_value` có khóa ngoại sang `dim_asm`. Mọi lệnh gọi thủ tục vẫn chạy êm, số ra đúng.
    - **Nguyên nhân:** tệp dim kết thúc bằng `DROP TABLE IF EXISTS dim_pnl_line_item CASCADE; DROP TABLE IF EXISTS dim_asm CASCADE;`. Vì `dim_asm` là bảng thứ nguyên nên có hai thứ phụ thuộc: `v_xephang_asm` và `v_xephang_asm_vnd`, cộng khóa ngoại `fk_fct_asm_dim_asm` trên `fct_asm_value`. `CASCADE` xoá dây chuyền cả ba mà PostgreSQL không cảnh báo.
    - **Cách xử lý:** đừng chữa từng chỗ. Chạy đủ thứ tự tài liệu ghi ở `docs/HIEN_TRANG_HE_THONG.md` mục 2: `sql/dim/` (ba tệp) → `sql/tmp/` → `sql/fct/fct_xephang_asm.sql` (dựng lại `fct_asm_value` kèm ràng buộc, nên phải gọi lại `sp_xephang_asm` đủ năm tháng) → `sql/rpt/`. Nếu vì gấp gáp đã chạy tắt, khôi phục tối thiểu bằng `ALTER TABLE banking_project.fct_asm_value ADD CONSTRAINT fk_fct_asm_dim_asm FOREIGN KEY (asm_id) REFERENCES dim_asm(asm_id);` rồi kiểm lại bốn view.
    - **Bài học:** trong kho này `CASCADE` là mặc định ở lớp dim và lớp fct, nên "chạy lại một tệp cho nhanh" không phải phép thử an toàn. Sau mọi lần chạy SQL lẻ, kiểm ba thứ: `information_schema.views` (đủ 4), `pg_constraint WHERE contype='f'` (đúng 1), số dòng bốn view (35 · 35 · 388 · 388).
    - **Đã gỡ nguyên nhân ngày 2026-10-31 (task 118):** lệnh `DROP TABLE IF EXISTS dim_asm CASCADE;` bị xoá khỏi tệp dim (nay tên `sql/dim/dim_month_headcount.sql`), `dim_asm` chỉ còn `sql/dim/dim_asm.sql` tạo và nạp. Chạy lại riêng lớp dim từ ngày đó không còn làm mất view hay khóa ngoại; ba mệnh đề `DROP ... CASCADE` còn lại đều ở lớp fct, dựng lại chính bảng mà view đọc, nên vẫn phải chạy `sql/rpt/` sau cùng. Mục này giữ nguyên để ai làm việc trên bản mã cũ còn tra được.

43. **Hạ `dim_month` xuống hạt ngày để "có yếu tố ngày" — gãy ba quan hệ và nhân đôi số**
    - **Triệu chứng dự kiến:** bảng trục thời gian mỗi tháng thành 28 đến 31 dòng; trong Power BI, ba quan hệ `month_key` một-nhiều (`v_baocao_tonghop`, `v_xephang_asm`, `dim_sm_headcount` trỏ vào `dim_month`) mất phía "một", nên slicer tháng trả nhiều bản ghi trùng nhau và mọi số cộng theo tháng bị nhân lên đúng số ngày.
    - **Nguyên nhân:** `dim_month` đang là phía "một" của mô hình, không phải bảng ngày. Kiểm bằng cách đọc danh sách quan hệ của mô hình đang mở, không đoán từ tên bảng.
    - **Cách xử lý:** giữ `dim_month` nguyên hạt tháng, dựng bảng ngày riêng `dim_date` (một dòng một ngày, sinh bằng `generate_series` từ `dim_month`) và nối `dim_date[month_key]` nhiều-một lên `dim_month[month_key]` nếu cần lọc ngày. Muốn dùng ngày trong Power BI thì nạp thêm `dim_date` rồi tạo quan hệ theo chiều đó; **không** nối `dim_date` trực tiếp vào bảng sự kiện vì bảng sự kiện chỉ có `month_key`.
    - **Bài học:** bảng trục thời gian nào đang giữ phía "một" của quan hệ thì không được đổi hạt; nhu cầu chi tiết hơn luôn giải quyết bằng bảng mới ở hạt nhỏ hơn, nối lên bảng cũ.

44. **Ảnh minh hoạ trong README giữ số cũ sau khi đổi cấu trúc kho**
    - **Triệu chứng:** `README.md` ghi giai đoạn 2 tạo 5 bảng và giai đoạn 3 tạo 14 bảng, nhưng ảnh `images/quy-trinh.png` đặt ngay trên vẫn ghi 6 bảng và 11 bảng; ảnh `images/thiet-ke-schema.png` từng vẫn ghi tên cũ `stg_fingerprint` sau khi bảng đổi thành `log_data_fingerprint`.
    - **Nguyên nhân:** hai ảnh là tệp nhị phân xuất từ Power BI và DBeaver nên không đổi tên hay sửa số bằng lệnh tìm kiếm thay thế; code và tài liệu Markdown thì đổi hết.
    - **Cách xử lý:** sau mọi lần thêm hoặc chuyển chủ sở hữu bảng, mở lại hai ảnh và đọc từng chữ trong card, đối chiếu ba chỗ: số bảng từng giai đoạn, tổng số đối tượng, tên bảng đã đổi. Ảnh sơ đồ thì xuất lại từ DBeaver (chuột phải lược đồ `banking_project` → View Diagram → Export); ảnh quy trình sửa chữ trong visual rồi chụp lại. Trong lúc chờ, đặt một dòng ghi chú dưới ảnh nói rõ số nào lệch — người đọc phải biết ảnh đang ở trạng thái nào.
    - **Bài học:** tài liệu đếm số bằng lời (`19 bảng`, `23 đối tượng`) tự sửa được bằng tìm kiếm; số nằm trong ảnh thì không. Vì vậy mỗi con số quan trọng phải có mặt ở cả phần chữ, đừng để nó chỉ tồn tại trong ảnh.

45. **Power BI tự nối hai bảng sự kiện qua cột không phải khoá — qua mắt được ở năm tháng đầu**
   - **Triệu chứng:** mở mô hình thấy 5 quan hệ trong khi thiết kế chỉ có 3 quan hệ `month_key` trỏ vào `dim_month`. Hai quan hệ thừa: `v_xephang_asm[cir]` nhiều-một sang `v_baocao_tonghop[cir]`, và `v_baocao_tonghop[area_code]` nhiều-nhiều với `v_xephang_asm[area_code]`.
   - **Nguyên nhân:** khi người dùng thêm bảng hoặc sửa quan hệ, Power BI tự dò các cột trùng tên và dựng quan hệ mà không hỏi. Cột `cir` của view lãi lỗ hiện có 35 dòng với 35 giá trị khác nhau nên phần mềm nhận là phía "một" và cho qua; đó là trùng hợp của năm tháng dữ liệu, không phải ràng buộc khoá.
   - **Cách xử lý:** kiểm bằng truy vấn trên kho trước khi tin một quan hệ: `SELECT COUNT(*), COUNT(DISTINCT cir) FROM v_baocao_tonghop` — hai số bằng nhau mới là phía "một" có thể dựng được, và vẫn chưa đủ điều kiện để quan hệ có nghĩa nghiệp vụ. Xoá hai quan hệ tự nối trong Manage Relationships; muốn đối chiếu theo vùng thì dựng `dim_area` riêng rồi cho hai bảng sự kiện cùng nối vào.
   - **Bài học:** số quan hệ trong mô hình là một con số phải kiểm như mọi con số khác. Sau mỗi lần sửa mô hình, liệt kê lại danh sách quan hệ và đối chiếu với danh sách trong `docs/HIEN_TRANG_HE_THONG.md`; nếu một quan hệ dựa trên cột tỉ lệ hoặc cột mã vùng lặp lại thì nó chỉ chạy được cho tới khi dữ liệu dày hơn.
   - **Đã gỡ ngày 2026-10-31:** người dùng xoá cả hai quan hệ trong Manage Relationships và lưu tệp lúc 15:30. Kiểm 72 biểu thức measure thì không có `USERELATIONSHIP`, `TREATAS` hay `CROSSFILTER`, nên số không đổi — đối soát lại ra 91 phép so sánh, 0 lệch. Sau khi xoá, mô hình còn 5 quan hệ nhưng hai trong số đó là quan hệ ngày mới do phần mềm tự dựng (xem mục 49).

46. **DAX CALCULATE tính tháng trước bị kẹt Filter Context từ Slicer dim_month**
    - Triệu chứng: Measure tính chênh lệch MoM hoặc số phát sinh tháng luôn trả về BLANK hoặc trả về chính số lũy kế YTD của tháng hiện tại.
    - Nguyên nhân: Visual hoặc Slicer đang giữ context dim_month[month_key] = 202305. Khi gọi CALCULATE(SUM(...), month_key = 202304), nếu không gỡ bỏ filter của bảng ngày tháng thì hai điều kiện giao nhau ra tập rỗng.
    - Khắc phục: Luôn khai báo REMOVEFILTERS('banking_project dim_month') bên trong CALCULATE:
      CALCULATE(SUM(...), REMOVEFILTERS('banking_project dim_month'), 'banking_project v_baocao_tonghop'[month_key] = _prev).

47. **Hardcode số liệu tĩnh vào chuỗi measure HTML khiến visual không tự động theo slicer tháng**
    - **Nguyên nhân:** Khi copy từ file HTML prototype, vô tình giữ nguyên các con số tĩnh (+4.391 trđ, 56.797,5 trđ, 16/19 ASM...) vào chuỗi text string DAX khiến visual trở thành văn bản chết, không phản ánh đúng tháng được chọn trên Power BI.
    - **Cách xử lý:**
      + Tách bạch tuyệt đối: Phần chữ tĩnh (tiêu đề, nhãn thẻ, mô tả, giải thích) giữ nguyên cố định 100%.
      + Mọi con số/chỉ số PHẢI dùng biến `VAR` tính toán và hàm `FORMAT([Measure_Name], ...)` nối chuỗi động.
      + Verify tính động bằng cách đánh giá truy vấn DAX ở hai tháng khác nhau (ví dụ tháng 4 so với tháng 5) để xác nhận số liệu thay đổi chính xác.

48. **Visual "HTML Content (Secure)" (Daniel Marsh-Patrick) render khác file HTML**
    - **Nguyên nhân:** mỗi visual là **một iframe riêng** và sanitizer chặn tài nguyên ngoài → Google Fonts (`Inter`, `JetBrains Mono`) không load (rơi về Segoe UI), thẻ `<style>` / `class` / `:root` / `@media` / `<script>` / `<svg>` bị bỏ.
    - **Cách xử lý:** toàn bộ CSS phải **inline `style='...'`** trên từng thẻ; root dùng `width:100%;height:100%;box-sizing:border-box`; bảng dùng `table-layout:fixed` + `width:%` trên `<th>`; layout dùng grid `1fr` để co giãn; không đặt `width/height` px cố định. Muốn kiểm tra: kéo giãn visual và xem có scrollbar/tràn viền không.
49. **Bấm Refresh xong Power BI âm thầm dựng thêm ba bảng ngày ẩn và hai quan hệ, tài liệu đếm bảng lệch ngay**
   - **Triệu chứng:** mô hình trước đó có 6 bảng, sau khi bấm Refresh và `dim_month` xuất hiện thêm cột `ngay_dau_thang` kiểu ngày thì danh sách bảng thành **9** (thêm `DateTableTemplate_…` và hai `LocalDateTable_…`, mỗi bảng 8 cột `Date` · `Year` · `MonthNo` · `Month` · `QuarterNo` · `Quarter` · `Day`), số quan hệ vẫn là 5 nhưng thành phần đã đổi: hai quan hệ `dim_month[ngay_dau_thang]` và `dim_month[ngay_cuoi_thang]` nối xuống `Date` của hai bảng ẩn. Ba bảng mới đều `hidden=True` nên **không hiện trong danh sách bảng**, chỉ thấy khi đọc mô hình bằng chương trình hoặc bật "Smart multi-row cards" trong Model view. Dung lượng `.pbix` tăng 22.441 byte.
   - **Nguyên nhân:** mặc định **Auto date/time** của Power BI bật ở mức tệp. Mỗi cột kiểu ngày trong mô hình Import sẽ bị gắn một bảng ngày riêng để phục vụ "Date hierarchy"; `dim_month` có hai cột ngày nên sinh hai `LocalDateTable`, cộng một `DateTableTemplate`.
   - **Cách xử lý:** File → Options and settings → Options → **Current file → Data Load → Auto date/time → Off**, rồi kiểm lại danh sách bảng và danh sách quan hệ; xoá hai quan hệ ngày nếu phần mềm để lại. Muốn có ngày thật theo nghiệp vụ thì nạp `dim_date` (151 dòng, một dòng một ngày, đã có sẵn trong `banking_project`) và nối `dim_date[month_key]` nhiều-một lên `dim_month[month_key]` — bảng này có `so_thu`, `ten_thu`, `la_ngay_cuoi_thang` là những cột báo cáo cần mà bảng ẩn không có.
   - **Bài học:** số bảng và số quan hệ của mô hình là đầu ra **của phần mềm**, không phải của thiết kế, nên phải đọc lại bằng chương trình sau mỗi lần Refresh chứ không suy ra từ lần đọc trước. Tài liệu ghi "mô hình có N bảng" mà không ghi cổng và giờ đọc thì sau một lần Refresh sẽ thành sai mà không ai biết sai từ bao giờ.

50. **`ingestion/export_pbi.ps1` chết vì thư mục `.staging/audit/` không tồn tại trên bản sạch**
   - **Triệu chứng:** chạy đúng lệnh tài liệu ghi (`powershell -File ingestion/export_pbi.ps1 -Port <cổng> -Catalog <mã database>`) thì nhận `DirectoryNotFoundException` ngay ở `WriteAllText`; truy vấn DAX đã chạy xong, kết quả lấy được nhưng không ghi ra tệp, nên `ingestion/audit_pbi_vs_db.py` báo `FileNotFoundError: pbi_pnl.csv` và người chạy tưởng model có lỗi.
   - **Nguyên nhân:** script mặc định ghi vào `.stagingudit` nhưng chỉ tạo tệp, không tạo thư mục. Pipeline Python có tự tạo `.staging/`, còn thư mục con `audit/` thì không, nên trên bản clone sạch hoặc sau khi dọn `.staging/` là vỡ.
   - **Cách xử lý:** script nay tự `New-Item -ItemType Directory -Force` trước khi ghi và in dòng `created <đường dẫn>`. Kiểm bằng cách xoá hẳn `.staging/audit/` rồi chạy lại từ đầu: hai CSV `pbi_pnl.csv` và `pbi_asm.csv` được tạo, `python ingestion/audit_pbi_vs_db.py` in "so phep so sanh: 91 | so lech: 0".
   - **Bài học:** mọi đường dẫn đầu ra trong script vận hành phải tự tạo thư mục cha, vì thứ dễ mất nhất khi chuyển máy là thư mục rỗng — Git không lưu thư mục rỗng nên nó biến mất ngay cả khi `.gitignore` không chặn.
   - **Lưu ý thêm (2026-11-01):** người dùng đã đưa hai script đối soát ra khỏi kho mã vì chúng không nằm trên đường chạy lại dự án (xem `docs/HIEN_TRANG_HE_THONG.md`, mục "Những tệp không đưa lên GitHub"). Mục này giữ nguyên làm ghi chú lịch sử; cần sửa tiếp thì làm trực tiếp trên máy làm dự án, nơi hai tệp vẫn còn.

51. **Hồ sơ LaTeX tràn sang trang ba khi thêm mục dự án — phải đo ngân sách dòng trước khi viết**
   - **Triệu chứng:** `cv_tran_ngoc_duc.tex` đang cân khớp 2 trang; vừa chèn thêm một mục dự án theo khuôn bốn nhãn (Objective · Output · Steps · Gained Value, 12 gạch đầu dòng) thì `pdflatex` in `Output written on ... (3 pages`, **không có dòng lỗi nào** (`! `). Khối mới chỉ dài thêm 28 dòng mã nguồn nhưng xô nguyên mục Skills (bảng `tabularx` ba cột) sang trang 3.
   - **Nguyên nhân:** trang cuối của hồ sơ đã gần đầy, mà LaTeX không giãn chữ để nhét thêm — nó đẩy cả khối không cắt được (bảng, khối sau `
ewpage`) sang trang mới. Nên "thêm bao nhiêu chữ" không quyết định có tràn trang hay không; **chỗ trống còn lại của trang quyết định**.
   - **Cách xử lý:** đo chỗ trống thật rồi mới viết nội dung. Chèn một chuỗi dòng văn bản trắng (`filler line 1`, `filler line 2`, ...) đúng vào vị trí sẽ đặt khối mới, rồi tìm nhị phân số dòng còn nhận thêm được mà không tràn: ở tệp này **trang 2 còn 12 dòng**, **trang 1 còn 0 dòng** (vì vậy không dời mục Skills lên trang 1 để lấy chỗ được). Sau đó biên dịch nhiều phương án cắt và chọn phương án vừa; mỗi phương án chỉ cần chạy `pdflatex` **một lần** vì bố cục không phụ thuộc tệp `.aux`.
   - **Kết quả đo được:** bản 4 gạch một nhãn (Objective + `Highlights`) và bản 4 gạch ba nhãn (Objective + Output + Steps) đều vừa 2 trang; chỉ cần thêm nhãn **Gained Value** thứ tư — dù vẫn chỉ 4 gạch — là tràn sang trang 3. Bản cuối bỏ hẳn nhãn Gained Value (kỹ năng đã có mục Skills riêng) và xuống 16 dòng mã nguồn.
   - **Đo bổ sung (lần sửa sau):** hai đòn giải phóng chỗ đã đo bằng cùng phương pháp chèn dòng trắng: **nén khoảng cách toàn bài** (`\parskip` từ 2,5pt xuống 0,5pt, `\titlespacing*{\section}` từ 11/6 xuống 6/3, `itemsep` và `topsep` của `enumitem` về 0) cho thêm **7 dòng**; **cắt nội dung mục dự án cũ** (gộp hai gạch chỉ chứa liên kết thành một, bỏ một đến hai gạch dài) **không đủ** kéo bản đủ nội dung về 2 trang. Ngân sách mỗi trang là số đo, không phải cảm giác: trước khi viết thêm chữ vào hồ sơ, đo chỗ trống còn lại rồi hãy quyết định viết bao nhiêu.
   - **Bài học:** (1) ràng buộc khổ trang phải đo bằng số dòng còn thừa, không đoán từ độ dài tệp nguồn; (2) nhãn đề mục và `space` cũng ăn dòng như nội dung; (3) sau khi cắt phải đối chiếu **văn bản trích từ PDF** (`pdftotext -raw`) với từng cụm từ trong nguồn, vì LaTeX có thể bỏ chữ mà không báo lỗi — ở đây dấu `%` trong hai URL `\href` vẫn giữ nguyên trong PDF (4 liên kết URI còn đủ), và các từ lệch duy nhất là do ligature `fi`/`fl` khi trích chứ không phải khi in (`Profit` trích ra `Prot`).

52. **Quy Tắc Chặn Theo Đuôi Tệp Lọt Sản Phẩm Phụ Mới Của LaTeX — Chặn Cả Thư Mục Bền Hơn**
   - **Triệu chứng:** `.staging/push_check.py` báo bộ đẩy tăng từ 46 lên **47 tệp** dù không ai thêm tệp nguồn nào; thủ phạm là `CV/cv_tran_ngoc_duc.synctex.gz` (24.548 byte). `.gitignore` đã ghi `cv_*.aux`, `cv_*.out`, `cv_*.synctex(busy)` nhưng bản biên dịch thật trên máy sinh ra đuôi `.synctex.gz`, khác hẳn tên đã chặn.
   - **Nguyên nhân:** LaTeX đặt tên sản phẩm phụ theo phiên bản và theo cách gọi lệnh — `--synctex=1` sinh `.synctex.gz`, lệnh dọn dẹp sinh `.synctex(busy)`, ngoài ra còn `.blg`, `.toc`, `.fls`. Viết quy tắc theo từng đuôi thì danh sách luôn đi sau thực tế một bước.
   - **Cách xử lý:** trước mắt thêm `cv_*.synctex.gz` và chặn nguyên thư mục `CV/` (toàn bộ nội dung trong đó là hồ sơ cá nhân), cập nhật bộ loại trừ của `.staging/push_check.py` cho khớp, chạy lại về **46 tệp**. Cuối ngày 2026-10-31 người dùng bỏ hẳn tệp `.gitignore` (xem mục 53), nên ranh giới đẩy chỉ còn sống trong `.staging/push_check.py`: `SKIP_DIRS = {'.staging', '__pycache__', '.git', 'input', 'CV'}` cộng `NEVER_PUSH = {'ingestion/db_config.py'}` tại thời điểm đó và hai quy tắc theo tên `cv_*` / `avatar_*`.
   - **Kiểm nội dung trước khi kết luận:** giải nén tệp `.synctex.gz` (104.738 ký tự) rồi quét — không tìm thấy dãy nào giống số điện thoại, nhưng có chuỗi đường dẫn tuyệt đối `C:\Users\This PC\...`, vậy vẫn lộ tên máy và vị trí thư mục. Đủ lý do để không đưa vào kho mã.
   - **Bài học:** với thư mục chỉ chứa tệp cá nhân, loại cả thư mục bền hơn loại theo tên và đuôi; mỗi lần bộ kiểm đếm lệch so với lần trước phải truy ra tệp nào mới xuất hiện hoặc biến mất, không chấp nhận con số mới.

53. **Bỏ `.gitignore` Thì `git add .` Thành Cái Bẫy — Phải Gõ Đích Danh Tệp**
   - **Bối cảnh:** người dùng không muốn có tệp chặn trong dự án và cũng không đẩy thư mục `input/`, nên `.gitignore` bị gỡ ngày 2026-10-31 (bản cuối lưu ở `ARCHIVE_LESSON_11_1_20261030/gitignore_ban_cuoi_cung_truoc_khi_goi_20261031.txt`).
   - **Rủi ro sinh ra ngay khi bỏ tệp đó:** `git add .` hoặc `git add -A` sẽ nhặt theo `ingestion/db_config.py` (mật khẩu kết nối PostgreSQL), `input/` (119,25 megabyte dữ liệu ngân hàng thật, gồm họ tên và email giám đốc vùng) và `CV/` (hồ sơ có số điện thoại, nơi ở, ảnh thẻ). Đẩy một lần là lộ vĩnh viễn, vì lịch sử commit không xóa bằng cách xóa tệp về sau.
   - **Cách xử lý:** cấm `git add .` trong `AGENTS.md` mục 7. Lưu ý lệnh an toàn **đổi theo phạm vi đẩy**: bản ngày 2026-10-31 là `git add AGENTS.md README.md docs images ingestion output requirements.txt sql`, nhưng từ 2026-11-01 `ingestion/` chứa tới ba tệp đứng ngoài kho (`db_config.py`, `export_pbi.ps1`, `audit_pbi_vs_db.py`) nên gọi theo thư mục sẽ nạp cả ba; cũng từ ngày đó `docs/` chứa một tệp đứng ngoài kho (`SESSION_PROMPT_LOG.md`) nên **lệnh `git add docs` cũng thành bẫy như `git add ingestion`**. `push_check.py` vì vậy không in lệnh theo hai thư mục đó nữa mà **in đích danh từng tệp được phép**, kèm danh sách 33 tệp sẽ đẩy. Nguyên tắc chung: đổi phạm vi đẩy thì chạy lại bộ kiểm rồi lấy lệnh nó in ra, đừng nhớ lệnh cũ.
   - **Lưu ý khi dựng kho:** một quy tắc từng bị hiểu sai là "không có `.gitignore` thì mất hết lớp chặn". Thật ra `.gitignore` **không cần được commit** để có hiệu lực trên máy người làm (phép thử dựng kho tạm trong thư mục Temp cho thấy `git status` vẫn bỏ đúng 12 đường dẫn khi tệp chưa hề được add). Người dùng chọn bỏ vì không muốn nó xuất hiện trong kho của người khác, không phải vì nó vô dụng.
   - **Bài học:** an toàn của kho không có `.gitignore` nằm ở **thói quen gõ đích danh** và ở **bộ kiểm in ra lệnh add**, không nằm ở một tệp cấu hình; trước lần đẩy đầu tiên phải chạy `git status` và đọc kỹ danh sách tệp được chọn.

54. **Tách DDL Ra Khỏi Thân Thủ Procedure Mà Quên Phần Tính — Tệp Khai Báo Mất Quyền "Chủ Bảng"**
   - **Triệu chứng:** sau lần dọn `sql/` thành bốn nhóm ngày 2026-10-30, `sql/tmp/` chỉ còn sáu lệnh `CREATE TABLE`, còn toàn bộ lệnh `INSERT` vào sáu bảng tạm vẫn nằm trong thân `sp_baocao_tonghop` và `sp_xephang_asm` ở `sql/fct/`. Người đọc mở tệp khai báo bảng tạm thì thấy cấu trúc rỗng, muốn biết bảng được nạp thế nào buộc phải mở tệp của bảng sự kiện — vi phạm chính quy tắc "mỗi bảng đúng một chủ" mà `AGENTS.md` mục 4 đặt ra.
   - **Nguyên nhân:** phép refactor trước chỉ dời phần *khai báo* vì mục tiêu lúc đó là "thứ tự chạy được kiểm soát", còn phần *tính* bị coi là nội dung của thủ tục điều phối. Kết quả là chủ bảng bị tách đôi: một tệp sở hữu cấu trúc, một tệp sở hữu số.
   - **Bốn ràng buộc phải đo trước khi tách (thực hiện trong schema tạm `probe_split`, đã dọn sạch ngày 2026-10-31):**
     - **plpgsql giải tên bảng lúc chạy**, không lúc tạo thủ tục — bằng chứng: tạo thủ tục ghi vào bảng chưa tồn tại rồi gọi sau khi bảng ra đời vẫn `THANH CONG`. Vì vậy sáu thủ tục bước nằm trong `sql/tmp/` vẫn ghi được `log_proc_run` (bảng do `sql/fct/` tạo) mà **không phải đảo thứ tự tệp**.
     - **`CALL` lồng `CALL` hoạt động** — thủ tục điều phối gọi được từng thủ tục bước, mỗi thủ tục ghi log dưới tên riêng.
     - **một `CALL` thất bại thì huỷ toàn bộ write trong nó**, kể cả khi kết nối để autocommit — sau lệnh hỏng, bảng còn **0 dòng** cho tháng đó, không có trạng thái "ghi nửa tháng".
     - **`COMMIT` lồng trong thủ tục được gọi không bị từ chối** trên bản PostgreSQL 16.14 của máy này (ngoài dự đoán thông thường). Đây là cái bẫy lớn nhất: nếu thủ tục bước giữ `COMMIT`, mỗi bước tự đóng dấu và tháng bị cắt thành mảnh.
   - **Cách xử lý:** sáu thủ tục bước `sp_pnl_step1_driver` / `sp_pnl_step2_ratio` / `sp_pnl_step3_gl_split` / `sp_xh_step1_asm_avg` / `sp_xh_step2_npl_area` / `sp_xh_step3_fin_area`, mỗi thủ tục nằm trong đúng tệp khai báo bảng tạm của nó, theo khuôn: ghi `START`, xoá dòng của đúng tháng trên đúng bảng, ghi số, rồi ghi `OK`; nhánh `EXCEPTION` ghi `FAIL` kèm `SQLERRM` rồi `RAISE` lại. **Không thủ tục bước nào có `COMMIT`.** Thủ tục điều phối chỉ còn xoá số tháng, gọi ba thủ tục bước và ghi bảng sự kiện.
   - **Chỗ gãy nằm ngoài hai tệp SQL:** `ingestion/run_report.py` bắt lỗi bằng truy vấn `log_proc_run WHERE proc_name = 'sp_baocao_tonghop' AND status = 'FAIL'`. Đổi quy tắc ghi log sang tên thủ tục bước làm truy vấn đó **luôn trả rỗng** khi thủ tục bước hỏng, in ra `FAIL tai ?: ...` thay vì tên bước — lỗi hiển thị chứ không lỗi số, và chỉ lộ ra khi đọc lại mã tiêu thụ bảng nhật ký. Đã sửa: lọc theo `month_key`, in cả `proc_name` lẫn `step_name`; thêm hai dòng dò `sp_pnl_step1_driver` và `sp_xh_step1_asm_avg` trong khối kiểm trước khi chạy để báo đúng tệp `sql/tmp/` cần chạy.
   - **Bài học:** (1) tách một lớp khỏi thân thủ tục phải tách **cả cấu trúc lẫn phần nạp**, nếu không quy tắc chủ bảng chỉ đúng trên giấy; (2) ràng buộc của engine (binding lúc chạy, `COMMIT` lồng, phạm vi huỷ của một `CALL` hỏng) phải **đo bằng phép thử thật** chứ không suy từ tài liệu, vì kết quả đo được ở đây ngược với kỳ vọng phổ biến về `COMMIT`; (3) chứng minh refactor không đổi số bằng **dấu vết hai lần chụp rồi diff** — 10.238 dòng dữ liệu giống hệt từng ký tự, khác biệt duy nhất nằm ở `log_proc_run` (13 nhóm lên 19 nhóm, 65 lên 95 dòng) và đó đúng là thay đổi chủ đích duy nhất; "chạy không báo lỗi" không phải bằng chứng.

55. **Ba Bảng Staging Là UNLOGGED — PostgreSQL Khởi Động Lại Là Sạch Dữ Liệu, Còn Mọi Lệnh `CALL` Vẫn Báo OK**
   - **Triệu chứng:** ngày 2026-10-31, sau khi dịch vụ PostgreSQL khởi động lại lúc 20:40, chạy trọn chuỗi `sql/` theo đúng thứ tự chuẩn: các lệnh `CALL` đều in `OK` nhưng mỗi lệnh chỉ mất 0,0 giây; sáu bảng tạm ra **0 dòng**, `fct_pnl_value` chỉ còn 135 dòng thay vì 1.115, rồi thủ tục `sp_xh_step3_fin_area` chặn và báo "chưa có `fct_pnl_value` đủ 7 vùng cho tháng 202301". Cùng ngày, trước giờ khởi động lại, chính chuỗi đó chạy 27,7 giây và cho đủ mọi số dòng.
   - **Nguyên nhân:** ba bảng `stg_asm_target`, `stg_fact_txn_month`, `stg_fact_kpi_month` do `ingestion/02_load_stg_asm_target.py`, `ingestion/03_load_stg_fact_txn_month.py`, `ingestion/04_load_stg_fact_kpi_month.py` dựng bằng lệnh `CREATE UNLOGGED TABLE`. Bảng kiểu này **không được ghi vào nhật ký trước ghi (WAL)**, nên khi dịch vụ khởi động lại, PostgreSQL tự làm rỗng toàn bộ nội dung — đó là hành vi đúng thiết kế, không phải lỗi hỏng số liệu. Ba truy vấn hệ thống đã dùng để kết luận: `SELECT relname, relpersistence FROM pg_class WHERE relname LIKE 'stg%'` trả `u`; `SELECT pg_postmaster_start_time()` trả đúng giờ khởi động; `pg_stat_user_tables.n_tup_ins` bằng 0 dù log nạp liệu vẫn ghi rõ đã chép hàng triệu dòng.
   - **Cách xử lý:** chạy `python ingestion/run_all.py` để nạp lại ba bảng staging (113,5 giây trên máy này), rồi chạy lại bốn lớp `sql/` và hai thủ tục điều phối cho `202301` đến `202305`. Không sửa một dòng mã SQL nào — bằng chứng: bộ so sánh mã thuần `.staging/ma_khong_doi.py` báo phần mã của 9 tệp `sql/` **giống hệt từng ký tự** so với mốc chụp trước khi viết lại chú thích.
   - **Bài học:** (1) khi số liệu biến mất mà mã không đổi, ba truy vấn hệ thống ở trên kết luận nhanh và chắc hơn nhiều so với đoán nguyên nhân trong thân thủ tục; (2) "mọi `CALL` báo `OK`" không phải bằng chứng số liệu đúng — lệnh chỉ báo thủ tục không chết giữa đường, còn bảng nguồn rỗng thì thủ tục vẫn ghi `OK` với 0 dòng; (3) chọn UNLOGGED để nạp nhanh chỉ hợp khi dữ liệu **tái tạo được từ tệp nguồn**, và phải nhớ mỗi lần khởi động dịch vụ là một lần phải chạy lại bước nạp; nếu muốn dữ liệu bền qua lần khởi động thì đổi ba bảng đó sang bảng thường.

56. **Liên Kết Markdown Tới Tệp Đứng Ngoài Kho Mã Không Bao Giờ Báo Gãy Trên Máy Người Làm**
   - **Triệu chứng:** ngày 2026-11-01, ngay sau khi gỡ `docs/SESSION_PROMPT_LOG.md` khỏi bộ đẩy, `README.md` vẫn để nguyên dòng `- [\`docs/SESSION_PROMPT_LOG.md\`](docs/SESSION_PROMPT_LOG.md) — nhật ký yêu cầu…`. Bộ kiểm `.staging/push_check.py` quét liên kết gãy lúc đó in `lien ket gay : [('docs/NHAT_KY_CONG_VIEC.md', 'README_eng.md')]` — tức là **không báo gì về liên kết vừa thành vô nghĩa**, vì nó kiểm bằng `os.path.exists`, mà tệp vẫn nằm trên đĩa. Người duy nhất nhìn thấy lỗi là người clone kho về.
   - **Nguyên nhân:** ba điều kiện phải đồng thời đúng thì lớp lỗi này mới ẩn: (1) kho không có `.gitignore`, phạm vi đẩy nằm trong một danh sách Python riêng; (2) phép thử liên kết dùng trạng thái đĩa chứ dùng danh sách đẩy; (3) tệp bị gỡ vẫn còn trên máy người làm nên phép thử đĩa luôn trả "tồn tại". Đây là lỗi cấu trúc của bộ kiểm, không phải lỗi gõ thiếu ký tự, nên sửa một dòng trong `README.md` không làm nó biến mất ở lần gỡ tệp kế tiếp.
   - **Cách xử lý:** thêm phép thử thứ hai vào `push_check.py` — với mỗi liên kết nội bộ trỏ tới một **tệp**, chuẩn hoá đường dẫn rồi đối chiếu với `push_set` (chính là danh sách đã ghi ra `.staging/push_list.txt`); nếu tệp có trên đĩa nhưng không nằm trong bộ đẩy thì in vào dòng `lien ket ra ngoai kho`. Chạy lại: phép thử mới bắt đúng và chỉ đúng một chỗ `('README.md', 'docs/SESSION_PROMPT_LOG.md')`, xác nhận chẩn đoán trước khi sửa. Sau khi bỏ liên kết ở `README.md` (mục **📖 Tài Liệu** viết lại thành câu chữ thường, cây thư mục đổi `docs/` thành 4 tệp) thì `lien ket ra ngoai kho` báo `khong co`. **Phát sinh thứ hai cùng ngày:** hai tệp `docs/LOI_THUONG_GAP.md` và `docs/NHAT_KY_CONG_VIEC.md` — là tệp **được đẩy** — bị báo "liên kết gãy" chỉ vì chúng *chép lại nguyên văn* dòng Markdown vừa gỡ trong code nội dòng; phép thử cũ không phân biệt được liên kết thật với liên kết được trích dẫn. Cách sửa: bóc khối mã ba nháy và code nội dòng khỏi Markdown trước khi quét liên kết. Kết quả đo lại: cả `lien ket gay` và `lien ket ra ngoai kho` đều `khong co`, và chuỗi `[Tiếng Anh](README_eng.md)` trong nhật ký công việc — chỗ bị báo oan suốt nhiều lượt — không còn xuất hiện.
   - **Bài học:** (1) khi một quyết định "tệp nào được đẩy" sống ngoài công cụ dựng trang, mọi phép kiểm tính đúng/sai phải lấy cùng nguồn quyết định đó, không lấy trạng thái đĩa — nếu không bộ kiểm tự tạo cảm giác an toàn giả đúng vào chỗ dễ sai nhất; (2) gỡ một tệp khỏi kho là **thay đổi với người đọc**, không phải thay đổi với máy mình, nên bước kiểm bắt buộc là chạy bộ kiểm trên danh sách đẩy, không phải mở tệp trên máy; (3) thêm lớp kiểm mới rồi thì phải dùng nó để chứng minh nó bắt được lỗi thật, ở đây là đúng một phát hiện duy nhất, rồi mới tới bước xoá lỗi; (4) một phép kiểm vừa siết chặt vừa phải được kiểm ngược xem nó **báo oan bao nhiêu** — lớp kiểm mới làm lộ ngay chỗ cũ từng báo oan, vì hai chiều sai lệch đó sửa bằng nhau nhưng hậu quả khác nhau.
