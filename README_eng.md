<div align="center">

# Tracking Business Metrics And Evaluating Credit Card Sales Team Performance

**Ngôn ngữ / Language**: [Tiếng Việt](README.md) · **English**

**Tran Ngoc Duc** · Data Analyst · Business Intelligence · Data Science · Management Information Systems · Operations · [Email](mailto:tranduc22104@gmail.com) · [LinkedIn](https://www.linkedin.com/in/tr%E1%BA%A7n-ng%E1%BB%8Dc-%C4%91%E1%BB%A9c-48b3a7439/)

<p>
  <img src="https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white">
  <img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white">
  <img src="https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black">
  <img src="https://img.shields.io/badge/Excel-217346?style=for-the-badge&logo=microsoftexcel&logoColor=white">
</p>

<p>
  In credit card business management, revenue is typically booked at the business regions,
  while a significant share of operating expenses and funding costs is recorded centrally at Head Office.
  This creates difficulties in evaluating the actual profitability of each region without an appropriate cost allocation mechanism.
  This project builds an income and expense allocation system and evaluates the performance of <strong>7 regions</strong>
  using <strong>2,996,476 data rows</strong> from the general ledger, card contract statements, and monthly sales target sheets.
</p>

</div>

## 📑 Table Of Contents

1. [📌 The Business Problem](#-the-business-problem)
2. [🔍 Profit Variance Analysis](#-profit-variance-analysis)
3. [🧭 Analytical Findings And Management Recommendations](#-analytical-findings-and-management-recommendations)
4. [🧮 Cost Allocation And Personnel Evaluation Methodology](#-cost-allocation-and-personnel-evaluation-methodology)
5. [🔄 Automated Data Processing Pipeline](#-automated-data-processing-pipeline)
6. [🗄️ Data Warehouse Design](#-data-warehouse-design)
7. [🧪 Data Verification And Reconciliation](#-data-verification-and-reconciliation)
8. [🛠️ Tools And Technologies Used](#-tools-and-technologies-used)
9. [📂 Project Structure](#-project-structure)
10. [🔒 Data Provenance And Usage Rights](#-data-provenance-and-usage-rights)
11. [📚 Project Implementation Experience](#-project-implementation-experience)
12. [📖 Handover Documentation](#-handover-documentation)
13. [💼 Applied Project Skills](#-applied-project-skills)
14. [👤 Author](#-author)

---

## 📌 The Business Problem

### 🏢 Practical Management Challenges

The bank's credit card division operates across **7 business regions** with a sales management team of **74 to 84 Area Sales Managers (ASMs)** depending on the month. In monthly performance tracking, management reporting faces three main challenges:

1. **Incomplete post-allocation P&L visibility by region:** In the general ledger, regions directly record card interest and fee income, whereas shared costs such as funding costs, technology infrastructure, bank-wide marketing, and support staff payroll are booked under the Head Office pool. Without allocating these costs to each region based on resource usage, reports do not accurately reflect the actual profitability of each territory.
2. **Personnel evaluation requires balancing volume growth and credit quality:** Evaluating Area Sales Managers solely on new loan disbursements or pre-allocation profit can encourage rapid balance growth accompanied by higher non-performing loan risks in subsequent periods.
3. **Dispersed and high-volume source data:** Data resides across three separate sources consisting of the general ledger (**63,134 journal entries**), the card contract statement file (**2,932,914 rows**, exceeding the row limit of a standard Excel worksheet), and sales target sheets structured horizontally by month. Manual consolidation is time-consuming and makes it difficult to trace the causes of period-over-period fluctuations.

### 🎯 Four Questions To Answer Every Month

| Management Area | Analytical Question | Implementation Method |
|---|---|---|
| **Actual Regional Performance** | After allocating Head Office costs, what is the net profit or loss of each region? | Separate direct regional entries and allocate shared Head Office entries by corresponding cost drivers; verify that the sum of the 7 regions matches the bank-wide general ledger |
| **Drivers of Profit Variance** | Did monthly profit change due to core business operations or changes in risk provisioning? | Isolate standalone monthly flows from year-to-date balances and decompose the variance across 6 revenue and expense components |
| **Management Team Evaluation** | Which Area Sales Managers maintain scale expansion, credit quality, and financial efficiency simultaneously? | Build an 8-metric ranking scorecard divided into 2 pillars: **Scale Expansion** (including the non-performing loan ratio) and **Financial Efficiency** |
| **Data Accuracy** | Do the figures on the dashboard match the raw general ledger and accounting templates? | Establish 4 data verification steps and automatically reconcile 91 metrics between the Power BI report and the PostgreSQL database |

---

## 🔍 Profit Variance Analysis

As of the end of May 2023 (5/2023), cumulative year-to-date profit before tax for the credit card division reached **250,450.06 million VND**. Standalone profit generated in month 5 increased by **+4,390.9 million VND** compared to month 4 (equivalent to **+8.4%**).

When decomposing monthly flows by region and by individual revenue and expense components, the data shows clear divergence across territories:

| Business Regions | ASM Team Size (Month 5) | Analysis Horizon | Processed Data Scale | 5-Month Cumulative Profit | Month 5 vs. Month 4 Profit Variance |
| :---: | :---: | :---: | :---: | :---: | :---: |
| **7 regions** | **84 managers** | **5 months** (month 1 – month 5/2023) | **2,996,476 rows** | **250,450.06 million VND** | **+4,390.9 million VND (+8.4%)** |

### Key findings from the data

**01. System-wide profit rose 8.4% in month 5, primarily driven by lower risk provision expenses, while net operating income from card activities remained nearly unchanged.**
Approximately **97.2%** of the system-wide monthly profit increase in month 5 was concentrated in the **Southwest** region (**+4,267.8 million VND**). Component decomposition shows that net operating income from card activities in this region rose by **+16.3 million VND**, operating expenses increased and reduced profit by **−195.9 million VND**, while **lower risk provision expenses contributed +4,447.3 million VND**. At the same time, Southwest recorded a **non-performing loan ratio of 21.99%** (the highest among the 7 regions) and had **0 out of 16 Area Sales Managers** in the top 25 positions bank-wide.

**02. The loss in the Southeast region stemmed from higher risk provision expenses, even though net operating income continued to grow.**
**Southeast** was the only region recording negative monthly profit (**−8,787.4 million VND**), decreasing by another **−322.2 million VND** compared to month 4. In terms of core commercial activity, **regional net operating income increased by +3,210.7 million VND**, but the increase in **risk provision expenses (−3,234.2 million VND)** kept pre-tax profit negative and placed **16 out of 19 Area Sales Managers** in the bottom 24 positions bank-wide. The primary area requiring review in Southeast is credit underwriting quality and debt collection.

**03. Month 5 profit in the Red River Delta increased due to lower provision expenses, while actual net operating income declined slightly.**
In the **Red River Delta** (the largest region by headcount with 23 Area Sales Managers), standalone profit in month 5 rose by **+1,310.9 million VND**. However, **actual net operating income decreased by −232.2 million VND** compared to month 4; the pre-tax profit increase resulted mainly from risk provision expenses decreasing by **+1,455.8 million VND**. These figures indicate that fee and interest income growth in this key market is slowing down.

**04. South Central Coast operates on a small scale but maintains the lowest non-performing loan ratio and consistent personnel performance.**
**South Central Coast** has only 5 Area Sales Managers so its absolute profit volume is modest, but its non-performing loan ratio remained the lowest in the system (**11.24%**) and **4 out of 5 Area Sales Managers** ranked in the top 25 bank-wide. Combining scale and efficiency metrics helps properly recognize smaller regions that maintain solid credit quality.

---

## 🧭 Analytical Findings And Management Recommendations

The project summarizes analytical results through three tracking views: the **Profit Variance Decomposition Table**, the **Profit–Risk Matrix**, and the **Management Recommendation List by Responsible Unit**.

### 1. Isolating standalone monthly flows from cumulative balances

Because raw accounting reports record cumulative year-to-date figures from the start of the year, the system isolates **standalone monthly profit** and **month-over-month variance**:

```text
Standalone Monthly Flow (month t)   = Cumulative Balance (month t) − Cumulative Balance (month t − 1)
Month-over-Month Variance           = Monthly Flow (month t)       − Monthly Flow (month t − 1)
```

| Business Region | Total Profit Change | Net Operating Income Contribution | Risk Provision Contribution | Data Observation |
| :--- | :---: | :---: | :---: | :--- |
| **Southwest** | **+4,267.8** | +16.3 | **+4,447.3** | Profit increased due to lower provision expenses; net income was flat |
| **Southeast** | **−322.2** | **+3,210.7** | **−3,234.2** | Net operating income grew well, but risk provision expenses rose faster |
| **Red River Delta** | **+1,310.9** | **−232.2** | **+1,455.8** | Profit increased due to lower provisions; net income declined slightly |

*Unit: million VND. Total profit variance is composed of 6 items on the P&L statement (gross card income, funding cost, other business expense, operating management expense, risk provision expense, and rounding residual).*

### 2. Grouping the 7 regions on the Profit and Risk matrix

Regions are grouped based on **Standalone Monthly Profit** and **Non-Performing Loan (NPL) Ratio** to determine appropriate management actions:

| Regional Group | Data Characteristics | Management Orientation |
| :--- | :--- | :--- |
| **High Profit – Low NPL** | Stable revenue growth with non-performing loans within target thresholds | Maintain current operating mechanisms and document underwriting practices for reference |
| **High Profit – High NPL** | Profit increased due to lower or reversed provisions while the NPL ratio remains high | Review the detailed breakdown of provision expenses before evaluating performance rewards |
| **Loss-Making – High NPL** | Rising bad debt increases provision expenses, significantly impacting profit | Inspect the quality of newly disbursed loan cohorts and credit appraisal procedures |
| **Loss-Making – Low NPL** | Good credit quality, but revenue scale is not yet sufficient to cover allocated costs | Review operating cost structure and support customer scale expansion |

### 3. Summary of personnel rankings and regional NPL ratios

| Key Region | Total ASMs (Month 5) | Managers in Top 25 | Managers in Bottom 24 | Regional NPL Ratio |
| :--- | :---: | :---: | :---: | :---: |
| **Southwest** | 16 | **0 managers** | 4 managers | **21.99%** (highest) |
| **Southeast** | 19 | 1 manager | **16 managers** | 19.86% |
| **South Central Coast** | 5 | **4 managers** | 0 managers | **11.24%** (lowest) |
| **Red River Delta** | 23 | 10 managers | 2 managers | 13.91% |

### 4. Five management recommendations by responsible unit

On the summary page of the report, analytical findings are organized into **5 management recommendations** consisting of: **Action Item + Data Basis (dynamically updated by selected month) + Coordinating Unit + Timeline**:

| # | Recommended Action | Data Basis from May 2023 (5/2023) | Responsible Unit · Timeline |
| :---: | :--- | :--- | :--- |
| 01 | Separate new provision charges from provision reversals by region; add a pre-tax profit excluding reversals metric | Current reporting shows only a single net provision line, making it difficult to isolate core business changes | Risk Management Division · month 6 |
| 02 | Review newly originated loan cohorts migrating across delinquency buckets in Southeast, Northeast, and Northwest | Provision expenses across these 3 regions increased by **6,035.1 million VND** in month 5 | Regional ASMs + Risk Management · within 30 days |
| 03 | Inspect card underwriting procedures and debt collection operations in the Southwest region | The NPL ratio reached **21.99%** (highest in the system) while the region accounted for **97.2%** of bank-wide profit growth | Sales Division + Risk Management · month 7 |
| 04 | Study and conduct a controlled pilot of South Central Coast's customer screening process with specific measurement criteria | Placed **4 out of 5** ASMs in the top 25 positions with the lowest NPL ratio (**11.24%**) | Sales Division · review after 2 months |
| 05 | Combine net operating income and NPL ratio metrics instead of relying solely on single-month profit flow in monthly evaluations | Single-month profit flow is heavily influenced by fluctuations in risk provisioning | Executive Board · immediate |

---

## 🧮 Cost Allocation And Personnel Evaluation Methodology

The calculation system is built in PostgreSQL to ensure cost allocation and personnel scoring rules are applied consistently across months and can be audited at each step.

### Problem 1: Allocating Head Office income and expenses across 7 regions

The system applies 2 management accounting rules to process 63,134 general ledger entries:

| Rule | Processing Method | Business Meaning |
|---|---|---|
| **Rule 1 — Direct assignment by province code** | General ledger entries carrying a specific province code are recorded 100% under the region managing that province | Accurately reflects interest income, fee income, and expenses incurred directly within each territory |
| **Rule 2 — Driver-based Head Office allocation** | Entries booked centrally at Head Office (province code `'00'` in the general ledger, mapped to region code `'A'` in `dim_area`) are allocated across the 7 regions according to each region's share of the corresponding driver: Group 1 balance, Group 2 balance, Groups 2 to 5 balance (pre- and post-write-off), active card count, sales manager headcount, or total loan balance | Allocates funding costs by capital usage scale, shared administrative costs by personnel headcount, and shared provision expenses by delinquent loan balance |

Inside the orchestrator `stored procedure` `sp_baocao_tonghop`, the P&L calculation is divided into **5 sequential steps across 3 intermediate step `stored procedures`**:

```text
Step 1  sp_pnl_step1: Calculate 9 allocation drivers per region               → tmp_pnl_step1_driver    315 rows
Step 2  sp_pnl_step2: Calculate allocation ratios, verify 7-region sum = 1    → tmp_pnl_step2_ratio     560 rows
Step 3  sp_pnl_step3: Split GL into Head Office ('A') and direct regional     → tmp_pnl_step3_gl_split  535 rows
Step 4  sp_baocao_tonghop: Add direct amount + Head Office amount × ratio     → fct_pnl_value         1,115 rows
Step 5  sp_baocao_tonghop: Compute summary lines (E, F, H, A) and 4 ratios    → fct_pnl_value
```

### Problem 2: Evaluating Area Sales Managers across Scale and Financial Efficiency pillars

The ranking scorecard evaluates Area Sales Managers across 8 metrics grouped into **2 pillars**:

| Pillar | Component Metrics | Evaluation Direction | Purpose in the Scoring Formula |
| :--- | :--- | :---: | :--- |
| **1. Scale Expansion (`diem_qm`)** | Cumulative average new loan sales, cumulative average active cards, cumulative average application approval rate | Higher is better | Measures market expansion results and application screening quality for each Area Sales Manager (averaged over actual active working months) |
| **1. Scale Expansion (`diem_qm`)** | Regional non-performing loan ratio (Groups 3 to 5 balance plus yearly write-offs divided by total pre-write-off balance) | Lower is better | Incorporates credit risk control into the scale pillar to limit volume expansion that increases bad debt |
| **2. Financial Efficiency (`diem_fin`)** | Cost-to-Income Ratio (`CIR`), Profit `Margin`, Return on Capital Efficiency, Profit per Sales Manager | Lower is better for `CIR`; higher is better for the other 3 metrics | Connects each Area Sales Manager's evaluation with the financial performance of their entire region after Head Office cost allocation |

Because the 8 metrics have different units (million VND, card count, percentage), the system **ranks each metric individually (rank 1 is highest) and sums the ranks into a total score** — a lower total score corresponds to a higher overall ranking. The scoring workflow in the orchestrator `stored procedure` `sp_xephang_asm` consists of **6 steps across 3 intermediate step `stored procedures`**:

```text
Step 1  sp_xh_step1: Compute cumulative average of 3 sales KPIs per manager   → tmp_xh_step1_asm_avg    1,164 rows
Step 2  sp_xh_step2: Compute regional NPL ratio, storing numerator/denominator→ tmp_xh_step2_npl_area     105 rows
Step 3  sp_xh_step3: Read 4 financial KPIs from P&L report and rank 7 regions → tmp_xh_step3_fin_area     315 rows
Step 4  sp_xephang_asm: Rank 4 scale metrics, calculate scale score and rank  → fct_asm_value      10 rows/manager
Step 5  sp_xephang_asm: Join regional financial scores to each manager        → fct_asm_value       9 rows/manager
Step 6  sp_xephang_asm: Sum both pillar scores, rank managers bank-wide       → fct_asm_value       3 rows/manager
```

---

## 🔄 Automated Data Processing Pipeline

The system is organized into an **automated 4-stage processing pipeline**, connecting input Excel files to the PostgreSQL database, Power BI dashboard, and automated Excel report output:

<div align="center">

![Technical processing pipeline — 4 stages](images/quy-trinh.png)

</div>

| # | Stage | Processing Tasks | Tools Used | Output |
|---|---|---|---|---|
| 1 | **Input Data (Excel)** | Consolidate 3 raw data sources (2.93 million contract rows, 63 thousand GL rows, 84-ASM target sheet) and 1 parameter & benchmark template workbook | Excel | 3 raw data files and 1 parameter workbook (2.99 million rows) |
| 2 | **Ingestion & Cleansing (Python)** | Read the large contract statement file; unpivot the ASM target sheet from wide to vertical format; standardize province names (for example “Bà Rịa - Vũng Tàu” and “Vũng Tàu”) to match the regional parameter table | Python (`openpyxl`, `psycopg2`), `run_all.py` orchestrating 4 load steps | **5 tables** in the warehouse: 2 `dimension` tables (`dim_area` 8, `dim_param_area` 64) and 3 `staging` tables (`stg_asm_target` 420, `stg_fact_txn_month` 63,134, `stg_fact_kpi_month` 2,932,922) |
| 3 | **Warehouse & Calculation (PostgreSQL + DBeaver)** | Execute monthly cost allocation and ranking calculations, store intermediate step results, and log execution history | PostgreSQL, DBeaver executing **9 `stored procedures`** (`sp_load_dim`, `sp_baocao_tonghop`, `sp_xephang_asm` and 6 step `stored procedures`) | **14 tables** (5 `dimension` tables, 6 step `tmp_` tables, 2 result `fact` tables, 1 `log_proc_run` table) and **4 `views`** |
| 4 | **Visualization & Reporting (Power BI + Python)** | Build interactive dashboards for management analysis and export the Excel report preserving formulas according to the unit's template | Power BI Desktop (`Import` mode loading 4 tables), `run_report.py` script | **5 Power BI report pages** (**72 DAX `measures`**) and bank-standard Excel report |

**Technical characteristics in operation:**
- **XML streaming for the nearly 3-million-row Excel file:** The Python script reads the XML data stream directly inside the `.xlsx` zip container, processes records row by row, and loads them into PostgreSQL via `COPY` to reduce memory usage.
- **Automatic detection of new months and report export (`run_report.py`):** The script compares months available in the `staging` layer with months already calculated in `fct_pnl_value`, invokes the calculation `stored procedures` for any missing months, and reads the 2 full-VND `views` (`v_baocao_tonghop_vnd`, `v_xephang_asm_vnd`) to populate the Excel report.
- **Monthly transaction management:** The 6 intermediate step `stored procedures` (`sp_pnl_step1..3`, `sp_xh_step1..3`) do not issue intermediate `COMMIT` statements; if a data error occurs at any step, the entire month being processed rolls back (`ROLLBACK`) and logs the status in `log_proc_run`.

---

## 🗄️ Data Warehouse Design

The data warehouse is designed following a `Star Schema` model within the `banking_project` schema consisting of **19 tables and 4 `views`**, supporting intermediate data inspection and report metric expansion:

| Object Layer | Count | Specific Objects and Row Counts | Role in the System |
|---|---:|---|---|
| **`Dimension` tables (`dim_`)** | 7 | `dim_area` 8 · `dim_param_area` 64 · `dim_asm` 84 · `dim_month` 5 · `dim_date` 151 · `dim_report_detail` 50 · `dim_sm_headcount` 35 | Manage the region list (`dim_area` is the sole table storing `area_name`), province-to-region mapping, ASM roster, monthly snapshot dates, regional manager headcount, and the 50-item report catalog |
| **`Staging` tables (`stg_`)** | 3 | `stg_fact_kpi_month` 2,932,922 · `stg_fact_txn_month` 63,134 · `stg_asm_target` 420 | Store raw data from the input Excel files for reconciliation when needed |
| **Intermediate tables (`tmp_`)** | 6 | `tmp_pnl_step1_driver` 315 · `tmp_pnl_step2_ratio` 560 · `tmp_pnl_step3_gl_split` 535 · `tmp_xh_step1_asm_avg` 1,164 · `tmp_xh_step2_npl_area` 105 · `tmp_xh_step3_fin_area` 315 | Store intermediate calculation results by step, supporting step-by-step data inspection in DBeaver |
| **Result `fact` tables (`fct_`)** | 2 | `fct_pnl_value` 1,115 (223 rows/month) · `fct_asm_value` 8,536 (22 rows/manager/month) | Store results in a vertical structure (each row corresponds to 1 month × 1 region or 1 manager × 1 metric ID), allowing new metrics to be added to `dim_report_detail` without altering table structures |
| **Audit log table (`log_`)** | 1 | `log_proc_run` 95 | Record execution timestamps and statuses for each step across the `stored procedures` |
| **Reporting `views` (`v_`)** | 4 | `v_baocao_tonghop` 35 · `v_baocao_tonghop_vnd` 35 · `v_xephang_asm` 388 · `v_xephang_asm_vnd` 388 | Pivot data from vertical tables into wide layouts for Power BI and Excel export; join `dim_area` to retrieve region names and filter out the Head Office `'A'` row |

<div align="center">

![Entity relationship diagram of the banking_project schema](images/thiet-ke-schema.png)

</div>

**Design conventions in the data warehouse:**
- **Clear file ownership per table:** Each table is managed by a single source file responsible for schema creation, data loading, and `index` creation, making code lookup and maintenance simpler.
- **Using 9 `Virtual Foreign Keys`:** Because `dimension` and `staging` tables are independently refreshed using `TRUNCATE` during data loading, the system avoids physical foreign key constraints that would block table refreshes. Referential integrity is verified through SQL queries (confirming 0 orphan rows) and represented on the DBeaver diagram via **9 `Virtual Foreign Keys`** linked to the 3 core dimensions (`dim_area`, `dim_month`, `dim_asm`).

---

## 🧪 Data Verification And Reconciliation

To verify data accuracy prior to reporting, the project performs **4 verification and reconciliation steps**:

| Verification Step | Audit Performed | Reconciliation Result |
| :--- | :--- | :---: |
| **1. Reconciliation with the unit's benchmark template** | Compare every metric against the reference workbook provided by the unit at key checkpoints: cumulative pre-tax profit in month 2 (**92,226.35 million VND**), month 5 (**250,450.06 million VND**), and the top-ranked ASM (**Hoang Van Nam — 34 points** in month 2, **36 points** in month 5) | Matches across all summary and detailed metrics |
| **2. Accounting conservation checks in SQL** | Verify that allocation ratios across the 7 regions sum to 1.000000 for every driver (allowed tolerance ≤ 1e-6); direct regional amounts plus allocated Head Office amounts equal the raw general ledger total; 0 orphan data rows | Passed across all 5 reporting months |
| **3. Automated cross-reconciliation between Power BI and PostgreSQL** | Use `export_pbi.ps1` and `audit_pbi_vs_db.py` to extract DAX `measure` results from Power BI and compare them against independent SQL queries across **91 data points** (8 P&L metrics × 7 regions + 5 headcount and risk metrics × 7 regions) | **91/91 comparisons matched, 0 discrepancies** (currency tolerance ≤ 0.02 million VND, ratio ≤ 1e-4) |
| **4. Direct back-verification against raw Excel files** | Read 1,124,553 raw contract rows for the first 2 months directly from the source Excel files in Python to sum regional loan balances independently of the database | **0 VND difference** across all 7/7 business regions |

### Limitations in analytical scope

Based on the structure and granularity of the available source data, the report distinguishes between conclusions supported by data and areas requiring more granular records:

| Conclusions Not Yet Supported by Data | Data and Business Reason | Accurate Interpretation in the Report |
| :--- | :--- | :--- |
| “ASM A dropped in rank due to a high personal non-performing loan ratio” | The NPL ratio and the 4 financial metrics are calculated at the **regional level**; all managers in the same region receive the same regional figures | “NPL and financial metrics reflect overall territory performance and are used to establish shared management accountability within the region” |
| “A sharp drop in May provision expenses proves customer repayment improved” | The general ledger currently records only a single net provision line without separating new provision charges from provision reversals | “New provision charges and provision reversals need to be separated using data from the Risk Management Division before evaluating changes in credit quality” |
| “High new loan disbursements in May directly caused May's profit increase” | Newly disbursed card balances within a period typically require time to generate substantial interest income in subsequent periods | “New loan sales reflect customer scale expansion speed rather than the primary driver of profit variance within the same month” |
| “Immediately apply South Central Coast's model across the other 6 regions” | The region has a small personnel scale (5 ASMs) and the current dataset covers a 5-month observation window | “South Central Coast is a strong-performing case for study and controlled pilot testing before considering broader application” |

---

## 🛠️ Tools And Technologies Used

Tools in the project were selected based on data processing and reporting requirements:

| Technical Requirement | Tool Used | Role in the Project |
|---|---|---|
| Read an Excel file of nearly 3 million rows with missing `dimension` metadata and standardize province names | Python 3.10.11 (`openpyxl`, `psycopg2`, XML streaming) | Stream data without memory overload, unpivot wide sheets to vertical format, and load data into the warehouse via `TRUNCATE` + `COPY` |
| Centralize data storage and execute 2-way cost allocation rules and multi-step ranking algorithms | PostgreSQL 16, PL/pgSQL (`stored procedure`) | Perform calculations using `Window Function` (`RANK()`), `CTE` (`WITH`), safe transaction control, and step-by-step logging |
| Inspect intermediate data and manage the database schema diagram | DBeaver | Display the 23-object schema with 9 `Virtual Foreign Keys` and support quick inspection of intermediate tables (`tmp_`) after each calculation step |
| Build interactive reports and calculate monthly variance analysis metrics | Power BI Desktop (`Import` mode), 72 DAX `measures` | Update heatmaps, scatter plots, and analytical commentary according to the month selected on the `slicer` |

<div align="center">

<p>
  <img src="https://img.shields.io/badge/PostgreSQL-Data%20Warehouse-4169E1?style=flat-square&logo=postgresql&logoColor=white">
  <img src="https://img.shields.io/badge/Python-Data%20Ingestion-3776AB?style=flat-square&logo=python&logoColor=white">
  <img src="https://img.shields.io/badge/DBeaver-Data%20Audit-000B19?style=flat-square&logo=dbeaver&logoColor=white">
  <img src="https://img.shields.io/badge/Power%20BI-Visualization-F2C811?style=flat-square&logo=powerbi&logoColor=black">
  <img src="https://img.shields.io/badge/Excel-Report%20Template-217346?style=flat-square&logo=microsoftexcel&logoColor=white">
</p>

</div>

---

## 📂 Project Structure

```text
.
├── input/              # Stores the parameter & benchmark template file; 3 raw data files exceed GitHub size limits and are managed separately
│   └── Tham so va mau doi chieu.xlsx  # Maps 64 provinces to 8 regions, maps GL accounts, and provides templates for both reports
├── ingestion/          # Python scripts for reading Excel data, standardizing records, loading the warehouse, and exporting reports
│                       # db_config.example.py — sample database connection configuration
│                       # run_all.py orchestrates the 4 load steps · run_report.py auto-detects new months and exports the Excel report
├── sql/                # SQL source code organized across 4 processing layers:
│   ├── dim/            #   dim_month_headcount (month axis, date axis + headcount), dim_asm, dim_report_detail (50-item tree)
│   ├── tmp/            #   tmp_pnl_step, tmp_xh_step — 6 intermediate step tables paired with their 6 step stored procedures
│   ├── fct/            #   fct_pnl_allocation (rules 1 & 2), fct_xephang_asm (2 pillars) — fact tables and 2 orchestrator stored procedures
│   └── rpt/            #   rpt_pnl_view, rpt_xephang_view — 4 wide views serving Power BI and Excel
├── output/             # Deliverables: cumulative Excel report workbook and Power BI report (.pbix)
├── images/             # Pipeline workflow and database schema diagrams referenced in documentation
├── docs/               # 4 operational documents: HIEN_TRANG_HE_THONG, PIPELINE, NHAT_KY_CONG_VIEC, LOI_THUONG_GAP (58 cases)
├── requirements.txt    # Declares the 2 Python packages used: psycopg2-binary and openpyxl
├── README.md           # Vietnamese project documentation (default landing page)
└── README_eng.md       # English project documentation
```

---

## 🔒 Data Provenance And Usage Rights

- The four Excel data sources used in this project are **real operational datasets provided and authorized by the sponsoring institution** for capstone project execution and for presenting the data analysis methodology.
- **Why the `input/` directory in the repository retains only 1 file:** GitHub enforces a maximum file size of 100 megabytes per file (and the project maintains a 25 megabyte threshold per file for convenient browser downloads). The raw card contract statement file has a size of **117.2 megabytes** and is not pushed to the public repository; the other two transactional files (general ledger at 1.95 megabytes and ASM targets at 26 kilobytes) are stored with the original dataset. The repository retains **`Tham so va mau doi chieu.xlsx`** (127,976 bytes) containing the 64-province mapping table and formatting templates for both reports. Viewers can inspect the complete source code, calculation logic, `.pbix` file, and output Excel report; if re-running data ingestion from scratch is required, the three raw data files can be requested separately.
- To read the 117.2 megabyte contract statement file reliably in Python, the original archive was split into two parts (`part1` weighing 83.6 megabytes and `part2` weighing 33.6 megabytes) at the zip container level without altering the internal data content; the total rows loaded into the warehouse match **2,932,922 records**.
- When personnel anonymization is needed for presentation, the manager name (`sale_name`) and `email` columns in `banking_project.dim_asm` can be masked without affecting regional P&L calculations or rankings.

---

## 📚 Project Implementation Experience

1. **Understand accounting conventions and sign rules before writing calculation queries:** In the general ledger data, funding costs and operating expenses are recorded with negative signs, while entries booked centrally at Head Office carry province code `'00'` in the general ledger and map to region code `'A'` in `dim_area`. Establishing sign conventions and identifier mappings upfront prevents errors when aggregating financial metrics.
2. **Standardize dimension keys to prevent record loss during table joins:** During raw data inspection, the province name “Bà Rịa - Vũng Tàu” in the contract statement file was spelled differently from “Vũng Tàu” in the parameter table. Standardizing the province string (`pos_city_norm`) retained all **36,043 contract rows** belonging to the Southeast region when calculating non-performing loan ratios and allocation drivers.
3. **Decompose aggregate figures into detailed components to identify the actual drivers of variance:** Looking only at the headline figure for month 5 shows system-wide profit growing by +8.4%. Separating cumulative balances into standalone monthly flows and comparing them against regional NPL ratios clarifies that profit growth in Southwest and the Red River Delta came primarily from lower provision expenses.

---

## 📖 Handover Documentation

Four documents in the `docs/` directory describe the system state, operating procedures, and resolved issues in detail:

- [`docs/HIEN_TRANG_HE_THONG.md`](docs/HIEN_TRANG_HE_THONG.md) — Current data warehouse state, row counts for all 19 tables and 4 `views`, table ownership map, and reconciliation benchmarks.
- [`docs/PIPELINE.md`](docs/PIPELINE.md) — Detailed architecture of the 4-stage processing pipeline and system execution commands.
- [`docs/NHAT_KY_CONG_VIEC.md`](docs/NHAT_KY_CONG_VIEC.md) — Worklog recording implementation steps and verification results across phases.
- [`docs/LOI_THUONG_GAP.md`](docs/LOI_THUONG_GAP.md) — Troubleshooting guide summarizing **58 real-world error cases** (raw data, SQL, Python, Power BI DAX) along with causes and resolutions.

---

## 💼 Applied Project Skills

<div align="center">

`Business Data Analysis` · `Bank Management Accounting` · `Multi-Driver Cost Allocation` · `Profit Variance Decomposition` ·  
`Star Schema Design` · `SQL & PL/pgSQL (stored procedure, view)` · `Data Integrity Verification` ·  
`Workflow Automation with Python` · `Large-Scale Data Cleansing` ·  
`Power BI (Import mode) & DAX` · `Automated Data Reconciliation` · `Management Reporting`

</div>

---

## 👤 Author

<div align="center">

**Tran Ngoc Duc** · Data Analyst · Business Intelligence · Data Science · Management Information Systems · Operations

*Banking & financial data analysis · Management reporting system design · Data verification and reconciliation*

[📧 tranduc22104@gmail.com](mailto:tranduc22104@gmail.com) · [💼 LinkedIn](https://www.linkedin.com/in/tr%E1%BA%A7n-ng%E1%BB%8Dc-%C4%91%E1%BB%A9c-48b3a7439/)

</div>
