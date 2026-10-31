# Export kết quả DAX từ Power BI Desktop ra CSV để đối soát với PostgreSQL.
# Yêu cầu: Power BI Desktop đang mở file .pbix (model chạy local qua msmdsrv).
#
# Cách dùng:
#   powershell -File ingestion/export_pbi.ps1 -Port 53546 -Catalog <database-id>
#   (lấy Port trong Task Manager → msmdsrv.exe; Catalog = tên database trong DAX Studio / Tabular Editor)
#   Có thể đặt biến môi trường PBI_PORT / PBI_CATALOG thay cho tham số.
#   Kết quả: .staging/audit/pbi_pnl.csv và pbi_asm.csv (đổi chỗ bằng -OutDir hoặc AUDIT_DATA_DIR).

param(
    [int]$Port = $(if ($env:PBI_PORT) { [int]$env:PBI_PORT } else { 53546 }),
    [string]$Catalog = $env:PBI_CATALOG,
    [string]$OutDir = $(if ($env:AUDIT_DATA_DIR) { $env:AUDIT_DATA_DIR } else { Join-Path (Split-Path $PSScriptRoot -Parent) ".staging\audit" })
)

$ErrorActionPreference = "Stop"
$bin = "C:\Program Files\Microsoft Power BI Desktop\bin"
[void][System.Reflection.Assembly]::LoadFrom((Join-Path $bin "Microsoft.PowerBI.AdomdClient.dll"))

$conn = New-Object Microsoft.AnalysisServices.AdomdClient.AdomdConnection(
    "Data Source=localhost:$Port;Initial Catalog=$Catalog")
$conn.Open()

if (-not (Test-Path -LiteralPath $OutDir)) {
    New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
    "created $OutDir"
}

function Export-Dax($query, $path) {
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $query
    $rd = $cmd.ExecuteReader()

    $sb = New-Object System.Text.StringBuilder
    $hdr = @()
    for ($i = 0; $i -lt $rd.FieldCount; $i++) { $hdr += $rd.GetName($i) }
    [void]$sb.AppendLine(($hdr -join ","))

    while ($rd.Read()) {
        $vals = @()
        for ($i = 0; $i -lt $rd.FieldCount; $i++) {
            $v = $rd.GetValue($i)
            if ($v -is [System.DBNull]) { $vals += "" }
            elseif ($v -is [double] -or $v -is [decimal]) {
                $vals += ([double]$v).ToString("G17", [System.Globalization.CultureInfo]::InvariantCulture)
            }
            else { $vals += ([string]$v).Replace(",", " ") }
        }
        [void]$sb.AppendLine(($vals -join ","))
    }
    $rd.Close()

    [System.IO.File]::WriteAllText($path, $sb.ToString(), (New-Object System.Text.UTF8Encoding($false)))
    "wrote $path"
}

$q1 = @'
EVALUATE
ADDCOLUMNS (
    VALUES ( 'banking_project v_baocao_tonghop'[area_code] ),
    "@flow",    CALCULATE ( [Page3_Flow_LNTT] ),
    "@delta",   CALCULATE ( [Page3_MoM_Delta_LNTT] ),
    "@tn_gop",  CALCULATE ( [Page3_MoM_ThuNhap_B] ),
    "@cpvon",   CALCULATE ( [Page3_MoM_CP_Von_C] ),
    "@cpkd",    CALCULATE ( [Page3_MoM_CP_KD_D] ),
    "@tnthuan", CALCULATE ( [Page3_MoM_ThuNhapThuan_E] ),
    "@opex",    CALCULATE ( [Page3_MoM_OPEX_F] ),
    "@dp",      CALCULATE ( [Page3_MoM_DuPhong_G] )
)
'@

$q2 = @'
DEFINE
VAR vM = MAX ( 'banking_project dim_month'[month_key] )
EVALUATE
ADDCOLUMNS (
    VALUES ( 'banking_project v_xephang_asm'[area_code] ),
    "@total",   CALCULATE ( [Page3_ASM_Total], 'banking_project v_xephang_asm'[month_key] = vM ),
    "@top25",   CALCULATE ( [Page3_ASM_Top25_Count], 'banking_project v_xephang_asm'[month_key] = vM ),
    "@bot24",   CALCULATE ( [Page3_ASM_Bot24_Count], 'banking_project v_xephang_asm'[month_key] = vM ),
    "@npl",     CALCULATE ( [Page3_Area_NPL], 'banking_project v_xephang_asm'[month_key] = vM ),
    "@ltn_ytd", CALCULATE ( SUM ( 'banking_project v_xephang_asm'[ltn_trieu_dong] ), 'banking_project v_xephang_asm'[month_key] = vM )
)
'@

Export-Dax $q1 (Join-Path $OutDir "pbi_pnl.csv")
Export-Dax $q2 (Join-Path $OutDir "pbi_asm.csv")

$conn.Close()
