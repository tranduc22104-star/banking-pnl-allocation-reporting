<div align="center">

# Building Credit Card Business Management Reporting And Ranking Regional Sales Management Performance

**Ngôn ngữ / Language**: [Tiếng Việt](README.md) · **English**

<p>
  <img src="https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white">
  <img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white">
  <img src="https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black">
  <img src="https://img.shields.io/badge/Excel-217346?style=for-the-badge&logo=microsoftexcel&logoColor=white">
</p>

</div>

## 📑 Table Of Contents

1. [🏢 Business Context And Executive Requirements](#1--business-context-and-executive-requirements)
2. [🎯 Requirement Analysis And Report Output Design](#2--requirement-analysis-and-report-output-design)
3. [🔍 Data Discovery And Assessment](#3--data-discovery-and-assessment)
4. [🧮 Business Logic And Metric Design](#4--business-logic-and-metric-design)
5. [🔄 Data Engineering And Warehouse Architecture](#5--data-engineering-and-warehouse-architecture)
6. [🧪 Data Validation And Quality Assurance](#6--data-validation-and-quality-assurance)
7. [📊 Business Insights And Management Recommendations](#7--business-insights-and-management-recommendations)
8. [📚 Key Takeaways](#8--key-takeaways)
9. [🛠️ Tools Used](#9--tools-used)
10. [📂 Project Repository Structure](#10--project-repository-structure)
11. [📖 Reference Documentation](#11--reference-documentation)
12. [👤 Author](#12--author)

---

## 1. 🏢 Business Context And Executive Requirements

### Credit card operational background
Credit card operations are distributed across **7 business regions** nationwide. Each region is managed directly by an Area Sales Management team, with total managerial headcount fluctuating between **74 to 84 Area Sales Managers (ASMs)** depending on the period.

### Stage 1 – Initial Broad Mandate From Executive Leadership
Executive Leadership initiated the assignment with a high-level strategic mandate, without providing pre-set calculation formulas, KPI scoring models, or benchmark reference datasets:
> *Build a management reporting system to monitor credit card business performance across regions and evaluate the operational effectiveness of the Area Sales Management network.*

At the inception point, this request was entirely **unspecified in technical and operational details**:
- Profitability calculation methods for individual regions were undefined.
- Principles for allocating centralized Head Office costs were unspecified.
- Business performance and credit risk metrics were not yet defined.
- Evaluation criteria for Area Sales Managers remained unestablished.
- Scoring formulas, ranking mechanisms, and report templates were wholly unmapped.

### Identified ambiguities and business management challenges
Reviewing legacy reporting methods revealed three core management challenges:

1. **Financial profitability was not fully reflected:**
   In general accounting ledgers, business branches directly record revenue from loan interest and card fees. However, major operating expenses such as funding costs, central marketing, core technology, and back-office support salaries are booked centrally under the Head Office pool. Without cost allocation, current reports showed all regions as profitable, making it difficult to identify underperforming regions.

2. **Sales manager evaluation incentivized credit risk expansion:**
   Evaluating Area Sales Managers purely on gross lending volume or active card issuance encouraged relaxing underwriting criteria to meet short-term targets. While this delivered rapid initial growth, non-performing loans (NPL) and provision expenses increased substantially in subsequent periods.

3. **Limitations of static financial reporting:**
   Current accounting reports only provided static year-to-date (YTD) aggregates without monthly variance breakdowns, failing to distinguish whether profit growth came from core business expansion or provision expense fluctuations.

Addressing these management dilemmas, Executive Leadership formulated 5 key business questions:

| Management Dilemma | Core Question To Address | Objective To Achieve |
|---|---|---|
| **Commercial Performance** | Which regions are genuinely profitable after absorbing central costs? | Determine accurate 7-region P&L after Head Office allocation |
| **Profit Variance** | What causes monthly profit fluctuations across regions? | Decompose profit flow into core revenue and cost components |
| **Credit Quality** | Which regions carry elevated credit risks threatening capital safety? | Monitor credit balances across 5 debt buckets and regional NPL ratios |
| **Managerial Performance** | Which ASMs demonstrate strong commercial growth alongside risk discipline? | Build an equitable multi-dimensional ranking system for 74 - 84 managers |
| **Executive Governance** | How should performance metrics be delivered for timely decision-making? | Build an interactive executive dashboard and audit-grade reconciliation models |

---

## 2. 🎯 Requirement Analysis And Report Output Design

### State 2 – Refined Business Requirements through Domain Analysis
Translating initial requests into an analytical solution required determining what information leadership needed to monitor regional performance and evaluate Area Sales Managers (ASMs). Therefore, reporting outputs were designed first (Output-First) and refined based on data exploration results.

### Business clarification and deliverable definition matrix:

| Initial Request | Unresolved Ambiguity | Business Domain Finding | Required Output Deliverable |
|---|---|---|---|
| **Monitor Commercial Results** | Does regional profit absorb Head Office expenses? What rules apply? | Must fully allocate indirect costs (funding, OPEX, provisions) across 7 regions using economic drivers | **7-Region Management P&L Report**: Net revenue, cost of funds, OPEX, provision charges, profit before tax (PBT) |
| **Analyze Variance Dynamics** | Does profit variance stem from sales expansion or provision write-backs? | Must separate cumulative YTD balances into monthly flows, decomposing line-item contributions | **Monthly Profit Flow Waterfall**: Month-over-month (MoM) variance decomposing 6 revenue and cost drivers |
| **Monitor Credit Risk** | How can leadership spot rising delinquency threatening capital soundness? | Must plot profit generation against territorial NPL ratios on a unified scale | **Profit – Risk Quadrant Matrix**: Classify 7 regions into 4 strategic governance quadrants |
| **Evaluate Sales Managers** | What criteria evaluate ASMs without incentivizing loose credit underwriting? | Must balance Commercial Scale (50%) equally against Risk Discipline & Financial Efficiency (50%) | **ASM Balanced Scorecard & Ranking**: 8 indicators evaluated across 2 independent pillars |
| **Multi-Tier Decision Support**| What reporting formats accommodate diverse divisional habits? | Executives require instant visual exploration; Finance requires cell-level formula auditability | **Integrated Reporting System**: 5-page Power BI dashboard and audit-grade 7-sheet Excel model |

### Logical architecture from business requirements to reporting deliverables:

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                        INITIAL BROAD EXECUTIVE GOVERNANCE MANDATE                      │
│   1. Regional card business P&L reporting        │   2. Field sales management evaluation│
└───────────────────────────────────┬────────────────────────────────────────────────────┘
                                    │ (Domain analysis & Requirement refinement)
                                    ▼
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                                TARGET REPORTING OUTPUT GROUPS                          │
├────────────────────────────────────────┬───────────────────────────────────────────────┤
│ GROUP 1: REGIONAL MANAGEMENT P&L       │ GROUP 2: AREA SALES MANAGEMENT RANKING        │
│ • Gross card income, funding cost,     │ • Individual sales volume: Gross lending,     │
│   operating expense, loan provisions   │   active credit cards, approval rate          │
│ • Head Office cost allocation drivers  │ • Territorial stewardship: Regional NPL,      │
│ • Monthly profit variance decomposition│   regional CIR, Margin, average profit / ASM  │
└───────────────────────────────────┬────────────────────────────────────────────────────┘
                                    │ (Translation to visual delivery layer)
                                    ▼
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                          POWER BI MANAGEMENT DASHBOARD (5 PAGES)                       │
│ • Page 1: Executive Overview           │ • Page 4: ASM Ranking Scorecard               │
│ • Page 2: Data Glossary                │ • Page 5: Deep-Dive Diagnosis & Conclusion    │
│ • Page 3: Regional P&L Management      │ + 7-Sheet Excel Accounting Reconciliation Model│
└────────────────────────────────────────────────────────────────────────────────────────┘
```

### Roles of the two indicator groups:
- **Commercial Performance Metrics (P&L, Regional NPL, CIR, Margin):** Reflect the comprehensive financial health of each region after absorbing indirect Head Office costs, supporting leadership decisions on capital and credit limit allocation.
- **Area Sales Management Evaluation Metrics (8 ranking indicators):** Combine individual sales achievement with regional credit quality to foster sustainable motivation, preventing the pursuit of short-term volume at the expense of credit risk.

---

## 3. 🔍 Data Discovery And Assessment

### Data discovery aligned with target output requirements
The bank lacked a centralized data mart or single comprehensive table meeting all target output requirements. Data exploration was directly anchored to specific deliverable metrics:

| Supplying Department | Source Dataset | Volume | Role In Fulfilling Desired Outputs & Key Joins |
|---|---|---:|---|
| **Accounting & Finance** | General Ledger (`fact_txn_month`) | **63,134** entries | Captures line-item revenue and cost entries; includes 62,953 branch-tagged entries (direct regional assignment) and 181 centralized Head Office entries (pool `'00'`, requiring allocation). Join keys: `city_code`, `account_code`. |
| **Card Operations** | Card Contract Statements (`fact_kpi_month`) | **2,932,922** rows | Records customer-level credit balances across 5 debt buckets, written-off accounts, and turnover across 5 months; serves as the basis for regional NPL calculation and allocation driver ratios. Join keys: `branch_code`, `month_key`. |
| **Network Sales Management** | Commercial Target Sheet (`kpi_asm_data`) | **420** rows | Tracks individual monthly sales targets: gross lending volume, active card count, and credit approval rates for 74 to 84 Area Sales Managers. Join keys: `asm_id`, `month_key`. |
| **Planning & Data Governance** | Parameter Matrix & Template Mapping | **64** provinces | Maps 64 administrative provinces into 8 geographic management zones (Head Office `'A'` and 7 regions `'B'..'H'`) with standardized reporting layouts. Join keys: `city_code`, `area_code`. |

### Data feasibility and granularity assessment (Gap Analysis):

| Target Deliverable | Required Data Attributes | Available Source Data | Feasibility And Granularity Assessment |
|---|---|---|---|
| **7-Region P&L Report** | Itemized income/expense, branch province codes, GL accounts | General Ledger (`fact_txn_month`) & Regional Parameter Matrix | **Feasible**: 62,953 entries possess province keys for direct assignment; 181 Head Office pool lines (`'00'`) require indirect allocation algorithms |
| **Regional NPL & Risk** | Credit balances across 5 buckets, written-off debt | Card contract statements (`fact_kpi_month`) | **Feasible at regional granularity**: Branch codes allow aggregation into regional totals across 5 operating months |
| **ASM Scale Evaluation** | Individual lending targets, active cards, approval rates | Commercial target sheet (`kpi_asm_data`) | **Feasible**: Monthly individual manager metrics available for all 74 to 84 Area Sales Managers |
| **Individual ASM NPL Tracking**| Delinquent balances tagged directly to employee IDs | Statements contain branch codes, not employee IDs | **Infeasible at individual level**: Delinquency and financial indicators must be measured regionally and applied uniformly to ASMs within the same region |

### Three key challenges in raw data:
1. **Card statement data exceeded standard spreadsheet limits:** Containing nearly 3 million rows and weighing **117.2 MB**, the file overwhelmed conventional spreadsheet tools.
2. **Wide-format ASM target data:** The target worksheet arranged monthly metrics across horizontal columns, requiring transformation into a vertical (tall) relational structure.
3. **Inconsistent dimensional naming:** Name discrepancies between departments (e.g., statements recording "Bà Rịa - Vũng Tàu" vs. parameter tables recording "Vũng Tàu") would drop over **36,000 credit card accounts** if joined directly, distorting Southeast regional NPL figures.

---

## 4. 🧮 Business Logic And Metric Design

**Business Context:** In practice, Executive Leadership provides general goals rather than pre-calculated formulas, standardized KPI scorecards, or sample benchmark data. The entire calculation logic was independently built based on financial cash flow principles and management accounting standards.

### 4.1. P&L Allocation Framework

Core analytical question: *How can actual regional operating profitability be determined when major revenues and corporate overheads are centralized at Head Office?*

The solution is structured across 9 management accounting stages:
1. Analyze all 63,134 General Ledger (GL) journal entries.
2. Identify transactions with specific branch codes for direct cost tracing.
3. Segregate centralized Head Office transactions (province code `'00'`, region `'A'`).
4. Analyze the underlying economic driver behind each expense category.
5. Define relevant Cost Drivers reflecting operational resource consumption.
6. Assess source data feasibility and granularity to support each driver.
7. Select appropriate driver-based allocation keys.
8. Formulate mathematical allocation procedures in PostgreSQL Stored Procedures.
9. Verify economic reasonableness and conservation of aggregate balances.

**Two Core Cost Allocation Rules:**
- **Rule 1 – Direct Cost Tracing:** 62,953 branch-level transactions are directly assigned 100% of their revenues (card interest, annual fees) and direct costs to their managing commercial region.
- **Rule 2 – Driver-Based Indirect Allocation:** 181 centralized Head Office overhead entries are allocated across 7 commercial regions based on dynamic economic driver ratios:

$$\text{Allocation Ratio for Region } i = \frac{\text{Driver Value for Region } i}{\sum_{k=1}^7 \text{Driver Value for Region } k}$$

$$\text{Allocated Expense to Region } i = \text{Head Office Expense} \times \text{Allocation Ratio for Region } i$$

*Economic Rationale for Head Office Cost Drivers:*
- **Treasury Cost of Funds:** Represents the bank's wholesale funding costs to finance cardholder credit balances. Driven directly by credit exposure $\rightarrow$ Allocated by **Average Performing Loan Balance (Bucket 1)**. Regions carrying higher performing credit volumes consume more internal liquidity and must bear proportional funding expenses.
- **Credit Risk Provisioning:** Represents expected credit loss allowances. Allocated based on **Overdue Loan Balance (Buckets 2 to 5) plus Off-Balance-Sheet Write-Offs** (`d25_sau` or `dtruoc`). This driver reflects regional risk exposure as an indirect managerial allocation proxy under centralized Head Office GL accounting, not contract-level tracing.
- **Card Technology and Operations:** IT infrastructure, telecommunications, and core banking processing costs $\rightarrow$ Allocated by **Average Active Contracts with Balance** (`psdn`), representing active card portfolio scale and core infrastructure servicing rather than asserting direct transaction frequency per cardholder.
- **Corporate Overhead and Support Headcount:** Administrative, compliance, and centralized human resource expenses $\rightarrow$ Allocated by regional **Staff Headcount**.
- *Assumptions and Limitations:* The allocation model assumes linear cost elasticity and uniform resource consumption per driver unit across all regions; targeted local marketing campaigns are not individually isolated.

*Converting Cumulative (YTD) to Monthly Incremental Figures:*
Year-to-date accounting figures are converted into discrete monthly cash flows:
$$V_{\text{Month } M} = V_{\text{Cumulative } M} - V_{\text{Cumulative } (M-1)}$$
Enabling variance decomposition of Profit Before Tax (PBT) across 6 distinct revenue and expense components.

### 4.2. Designing Area Sales Management Operational Scorecard (Multi-dimensional ASM Scorecard)

Core analytical question: *If Area Sales Manager (ASM) performance is evaluated solely on new card volume, does the scorecard truly capture business profitability and risk control?*

**Scorecard combining sales results with territorial stewardship:**
The scorecard was designed to combine individual Area Sales Manager (ASM) sales achievements with territorial financial health and credit quality. This evaluation helps prevent focusing solely on sales volume while ignoring credit risk. However, because several metrics are available only at the regional level, the ranking results do not fully capture individual manager capability in isolation.

The framework establishes 8 metrics distributed across 2 independent pillars, balanced by metric count (4 metrics per pillar, each contributing an independent rank from 1 to $N$ to the composite score, without assuming an econometrically calibrated 50% weight):
- **Pillar 1: Commercial Results and Quality Growth Control (`diem_qm`):** Combines 3 individual sales metrics (New lending volume, Average active contracts with balance, Approval rate) with 1 territorial credit quality indicator (Regional extended credit risk ratio). Crucially, a **higher approval rate is not necessarily better**: elevated approval rates can reflect efficient origination or relaxed underwriting standards. Therefore, approval rates must be evaluated alongside regional delinquency ratios.
- **Pillar 2: Financial Efficiency (`diem_fin`):** Encompasses 4 regional indicators (Cost-to-Income Ratio CIR, Profit Margin, Capital Productivity, Average Profit per ASM). Because card contracts lack individual manager identifiers (tracked only by branch and region), assigning regional financial and risk metrics to individual scorecards is an essential mechanism to enforce collective territorial accountability, curbing short-term volume growth at the expense of portfolio asset quality.

**Clarifying the Extended Credit Risk Ratio (Including Written-Off Debts):**
Within SQL Stored Procedures (`report_id = 204`), the implemented metric is:

$$\text{Extended Credit Risk Ratio} = \frac{\text{Bucket 3–5 Balances} + \text{Cumulative Write-offs}}{\text{Total Balances} + \text{Cumulative Write-offs}} \times 100$$

Unlike conventional accounting NPL (which tracks only on-balance Buckets 3–5 over total loans), this is a **custom management metric independently designed** through cash-flow analysis and credit risk management principles. Off-balance write-offs are accumulated from year-start to neutralize artificial cosmetic cleansing effects following debt write-off events. *Analytical Limitation:* This indicator reflects cumulative historical losses rather than exclusively point-in-time risk. Territories with mature card portfolios naturally accumulate larger write-off volumes than newly expanded regions, requiring cautious interpretation when comparing regions with divergent portfolio vintages:

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                 MULTI-DIMENSIONAL ASM OPERATIONAL SCORECARD (SCORECARD)                │
├──────────────────────────────────────────┬─────────────────────────────────────────────┤
│ PILLAR 1: COMMERCIAL RESULTS & QUALITY   │ PILLAR 2: FINANCIAL EFFICIENCY (diem_fin)   │
│ GROWTH CONTROL (diem_qm)                 │                                             │
│ • Average new loan disbursement (High)   │ • Cost-to-Income Ratio - CIR (Low is best)  │
│ • Average active card count (High)       │ • Profit Margin (High is best)              │
│ • Average approval rate (Evaluated)      │ • Capital productivity coefficient (High)   │
│ • EXTENDED CREDIT RISK RATIO (Low)       │ • Profit per ASM Headcount (High is best)   │
│   (Incorporates off-balance write-offs)  │   (Aligns stewardship with territory P&L)   │
└──────────────────────────────────────────┴─────────────────────────────────────────────┘
```

**Detailed Matrix of 8 Area Sales Manager Evaluation Metrics (ASM):**

| Metric | Dimension Measured | Strategic Rationale | Source Table | Preferred Direction | Data Granularity | Analytical Limitation |
|---|---|---|---|---|---|---|
| **New Loan Volume** | Direct sales execution | Reflects market acquisition speed | Target KPI Table | Higher is better | Individual ASM | Does not penalize post-issuance churn |
| **Average Active Cards** | Customer card usage | Measures retained transactional base | Contract Statement | Higher is better | Individual ASM | Requires active stimulation spending |
| **Application Approval Rate** | Underwriting efficiency | Evaluates application quality | Target KPI Table | Higher is better | Individual ASM | Excessively high rates risk loose vetting |
| **Regional NPL Ratio** | Credit risk discipline | Essential brake against moral hazard | Contract Statement | Lower is better | Regional level | Contract data lacks ASM IDs; shared by region |
| **Regional CIR** | Cost operational efficiency | Measures operating cost burn rate | General Ledger | Lower is better | Regional level | Subject to Head Office cost allocation keys |
| **Profit Margin** | Quality of earnings | Ensures revenue growth yields profit | General Ledger | Higher is better | Regional level | Sensitive to internal fund transfer pricing |
| **Capital Efficiency Ratio** | Asset productivity | Profit generated per loan balance | GL & Contract | Higher is better | Regional level | Measures holistic territorial return |
| **Profit per ASM Headcount**| Bottom-line accountability | Connects managerial compensation to profit | GL & Headcount | Higher is better | Regional level | Distributed uniformly across regional ASMs |

*Normalization and Metric Scaling Methodology:*
Because the indicators feature non-commensurate measurement units (million VND, card units, percentages), raw arithmetic aggregation is invalid. The framework implements **Independent Percentile Rank Scaling**:
- Each metric is independently ranked from 1 to $N$ across the nationwide sales force (rank 1 represents top performance).
- For inverse metrics where lower values indicate superior performance (NPL ratio, CIR), rank sorting is reversed so the lowest value receives rank 1.
- Total performance score equals the sum of ranks from both pillars:
$$\text{Total Score} = \text{Scale Rank Score } (diem\_qm) + \text{Financial Rank Score } (diem\_fin)$$
- Regional managers with a **lower total score achieve a superior final nationwide ranking**. The evaluation scale applies across active sales management cohorts numbering 74 to 84 ASMs across monthly periods.

---

## 5. 🔄 Data Engineering And Warehouse Architecture

To transform multi-source raw data into a complete reporting system, the workflow is structured into 4 engineering stages:

<div align="center">

![Technical Pipeline — 4 Processing Stages](images/quy-trinh.png)

</div>

### Detailed engineering steps:

- **Stage 1 – Data Ingestion (Python Streaming Ingestion):**
  Utilized Python libraries (`openpyxl` combined with `zipfile` + `xml.etree` streaming parsing) to read the **117.2 MB** statement file containing nearly 3 million rows without memory overflows. Transformed the wide-format ASM target worksheet into a vertical relational data structure.

- **Stage 2 – Data Cleaning (Standardization and Quality Enforcement):**
  Enforced strict data types; handled null values; implemented Vietnamese text normalization (`pos_city_norm`) to resolve province naming mismatches, salvaging 36,000 credit card contracts. Loaded clean data into 3 staging tables (`stg_fact_kpi_month`, `stg_fact_txn_month`, `stg_asm_target`) and 2 regional dimension tables (`dim_area`, `dim_param_area`).

- **Stage 3 – Data Warehouse Design (Kimball Star Schema in PostgreSQL):**
  Structured within schema `banking_project` encompassing **19 tables and 4 `views`**:
  - **7 Dimension Tables (`dim_`):** `dim_area` (8 zones), `dim_param_area` (64 provinces), `dim_month` (5 months), `dim_asm` (84 personnel), `dim_report_detail` (50 metrics), `dim_month_headcount` (35 rows), `dim_sm_headcount` (35 rows).
  - **3 Staging Tables (`stg_`):** `stg_fact_kpi_month` (2,932,922 rows), `stg_fact_txn_month` (63,134 rows), `stg_asm_target` (420 rows).
  - **6 Temporary Processing Tables (`tmp_`):** Unified vertical schema (`month_key`, `area_code`, `report_id`, `value`) storing intermediate computations for P&L (`tmp_pnl_step1..3`) and Ranking (`tmp_xh_step1..3`).
  - **2 Core Fact Tables (`fct_`):** `fct_pnl_value` (1,115 rows) storing regional P&L results and `fct_asm_value` (8,536 rows) storing ASM ranking scores across 5 months.
  - **1 Audit Log Table (`log_`):** `log_proc_run` recording procedure execution history (65 `START` and `OK` entries, 0 `FAIL` entries).
  - **9 `Virtual Foreign Keys`:** Documenting relational integrity in DBeaver diagrams without degrading transactional batch ingestion speeds.

<div align="center">

![Mô hình kho dữ liệu Star Schema](images/thiet-ke-schema.png)

</div>

- **Stage 4 – Data Processing (PL/pgSQL Stored Procedures):**
  Engineered 9 stored procedures executing allocation logic and ranking algorithms. Encapsulated processing in atomic transactions with automated error trapping and rollback safeguards.

---

## 6. 🧪 Data Validation And Quality Assurance

**Independent Verification Context:** In real-world enterprise deployments, executive leadership does not supply pre-computed benchmark answers. The validation framework was therefore designed with 5 independent quality control layers, ensuring internal consistency and calculation accuracy across the entire data pipeline.

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                        5-LAYER DATA QUALITY ASSURANCE FRAMEWORK                        │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ Layer 1: GL RECONCILIATION CONSERVATION (Sum of regions = Nationwide General Ledger)   │
│ Layer 2: MATHEMATICAL INVARIANTS (Allocation ratio sum equals exactly 1.0)             │
│ Layer 3: DATA INTEGRITY AND REFERENTIAL INTEGRITY (Zero orphaned or duplicated records)│
│ Layer 4: BUSINESS SANITY AND FINANCIAL BOUNDARY CHECKS (MoM thresholds and NPL ranges) │
│ Layer 5: INDEPENDENT RECALCULATION AND CROSS-AUDIT (Zero variance across systems)      │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

### Layer 1 – General Ledger Balance Reconciliation
- **Control Risk:** Financial leakage or cost duplication when disaggregating 181 Head Office entries across 7 regions.
- **Control Principle:** Aggregate post-allocation regional revenues and expenses plus remaining corporate balances must match 100% of nationwide GL balances:
$$\left| \sum_{k=1}^7 \text{Allocated Regional Expense}_k - \text{Total Head Office Expense} \right| \le 10^{-6}$$
- **Implementation Method:** Automated SQL reconciliation scripts comparing raw transactions in `stg_fact_txn_month` against allocated entries in `fct_pnl_allocation`.
- **Observed Result:** Variance equals exactly $0.00$ VND across all 63,134 journal rows across 5 reporting months.
- **Known Limitation:** Aggregate reconciliation verifies allocation arithmetic conservation; it cannot detect misclassifications within raw GL source entries.

### Layer 2 – Mathematical Invariants And Formula Validity
- **Control Risk:** Divide-by-zero runtime exceptions, unallocated residuals, or sign inversions on revenue/expense line items.
- **Control Principle:** Dynamic allocation weights for each economic driver must sum to exactly 1:
$$\sum_{i=1}^7 w_i = 1.000000 \quad (\text{for all driver categories})$$
All division expressions are guarded with `NULLIF(denominator, 0)`.
- **Implementation Method:** Automated invariant assertions verifying table `tmp_pnl_step2_head_alloc_ratio` across 9 distinct economic drivers.
- **Observed Result:** 100% of allocation drivers sum to exactly 1; zero divide-by-zero exceptions or `NaN`/`Infinity` values occurred.
- **Known Limitation:** Assumes linear cost allocation elasticity; non-linear step-fixed overhead costs are not modeled.

### Layer 3 – Data Integrity And Referential Integrity
- **Control Risk:** Duplicate spreadsheet records, data drop-off during table joins, or unmapped branch/province identifiers.
- **Control Principle:** Foreign key referential integrity and entity uniqueness constraints.
- **Implementation Method:** Row count reconciliation before and after SQL `JOIN` statements; scanning for province IDs absent from `dim_param_area`.
- **Observed Result:** All 2,932,922 card contracts and 63,134 accounting transactions loaded completely; zero orphaned records. 181 Head Office entries with province code `'00'` routed successfully to the allocation pipeline.
- **Known Limitation:** Cardholders who relocated across regions remain mapped to their original issuing branch territory.

### Layer 4 – Business Sanity And Boundary Conditions
- **Control Risk:** Results violating financial logic or displaying inexplicable month-over-month variances.
- **Control Principle:** Establishing domain boundary conditions:
  - Regional $NPL \in [0\%, 100\%]$; Loan balances, active card counts, and staff headcount $\ge 0$.
  - Credit risk provisioning must correlate positively with delinquent loan movements in Buckets 3 to 5.
  - Red Flag threshold triggers for expense lines with month-over-month variance $MoM > \pm 50\%$.
- **Implementation Method:** Boundary query assertions on fact tables and time-series sensitivity monitoring from January through May 2023.
- **Observed Result:** Regional NPL across all 7 regions fluctuated within 10.11% to 21.99% throughout the 5 months (specifically 11.24% to 21.99% in May 2023). The sharp spike in May 2023 credit provisioning was verified as expected provisioning on Buckets 3 to 5 from earlier credit expansion.
- **Known Limitation:** Threshold scanning cannot distinguish organic business expansion from retroactive accounting policy adjustments without accountant notes.

### Layer 5 – Independent Recalculation And Cross-Audit
- **Control Risk:** Latent logic divergence between PostgreSQL database storage and Power BI analytical measures.
- **Control Principle:** Single-case reverse auditing, multi-platform cross-validation, and total general ledger accounting balancing.
- **Implementation Method:**
  1. *Sample Reverse Audit:* Randomly sampled 3 representative entities (Southeast Region, Northwest Region, and 1 specific Area Sales Manager - ASM); recalculated numbers manually outside SQL via standalone managerial accounting formulas.
  2. *Cross-System Audit:* Exhaustive **91-cell matrix audit** (13 core financial indicators $\times$ 7 regions for May 2023) between PostgreSQL SQL queries and 72 DAX measures in Power BI.
  3. *Accounting Reconciliation & Flow Conservation:* Reconciled total allocated profits and revenues across all regions against total balance-sheet movements in the General Ledger (GL), verifying zero capital leakage: Nationwide Profit Before Tax (February 2023 reached 92,226.35 million VND, May 2023 reached 250,450.06 million VND) perfectly reconciled with the general ledger without creating or losing any capital.
- **Observed Result:**
  - Independent manual calculations matched stored procedure outputs with zero variance.
  - All **91 audited cells between PostgreSQL and Power BI yielded exactly 0 variance**.
  - Total accounting reconciliation was fully preserved: Nationwide PBT closed at **92,226.35 million VND** (February 2023) and **250,450.06 million VND** (May 2023), confirming 100% allocation of centralized Head Office costs, with nationwide Top 1 Area Sales Manager reaching **34 points** in composite performance.
- **Known Limitation:** Manual recalculation can only cover representative audit samples; full 3-million-row coverage relies on the preceding 4 automated control layers.

---

## 7. 📊 Business Insights And Management Recommendations

### Part A – Executive Requirement Fulfillment Audit:

| Original Leadership Requirement | Operational Deliverable | Evaluation Outcome |
|---|---|---|
| **Measure true regional P&L** | P&L Allocation Engine | **100% Satisfied**: 7 regions absorb indirect costs with zero ledger variance. |
| **Analyze monthly variance** | 6-Component Waterfall Chart | **100% Satisfied**: Monthly flows cleanly separated, identifying profit drivers. |
| **Monitor credit risk** | Profit – Risk Quadrant Matrix | **Satisfied**: Territories with elevated delinquency identified for early risk containment. |
| **Equitable ASM ranking** | 2-Pillar Balanced Scorecard | **Satisfied**: Balanced commercial scale against risk discipline for all 74 - 84 managers. |
| **Interactive governance tools** | 5-Page Dashboard & Excel model | **100% Satisfied**: Instant visual exploration for executives; cell-level models for accounting. |

### Part B – Key Findings from May 2023 Operational Data:

1. **Southwest Region – Profit growth driven primarily by declining net provisioning:**
   - *Observed Facts:* Regional PBT surged by **+4,267.8 million VND**, accounting for **97.2%** of total system-wide profit growth in May. However, net card income rose marginally by +16.3 million VND while OPEX reduced profit by −195.9 million VND, with net **provision charges decreasing by +4,447.3 million VND**. The territory carries the **highest extended risk ratio nationwide (21.99%)** with zero Area Sales Managers (ASMs) qualifying for the top 25 nationwide ranking.
   - *Business Inferences:* May profit growth was driven primarily by declining net provision expenses. Net income from card operations increased by only 16.3 million VND compared to the previous month, remaining essentially flat and indicating minimal improvement in core business earnings.
   - *Hypotheses Requiring Further Verification:* Verify whether provision declines reflect genuine recovery collections or technical restructuring; conduct on-site credit quality audits in July.

2. **Southeast Region – Net income expanded but bottom line remained negative under provisioning pressure:**
   - *Observed Facts:* The Southeast territory recorded an operating loss of **−8,787.4 million VND** during the month. Commercial sales expanded robustly with **net income surging by +3,210.7 million VND**, but was offset by **credit provision charges rising by −3,234.2 million VND**, pushing **16 out of 19 Area Sales Managers** into the lower half of national rankings despite high gross sales.
   - *Business Inferences:* Operating loss was recorded because monthly credit risk provision expenses exceeded the net revenue gains generated from new business originations.
   - *Hypotheses Requiring Further Verification:* Conduct vintage/cohort analysis to determine whether rapid past lending growth is migrating into overdue buckets; audit delinquent files in the Southeast within 30 days to evaluate transition rates and adjust underwriting standards.

3. **Red River Delta – Profit Increased Due To Reduced Net Provision Expenses:**
   - *Observed Facts:* Regional profit expanded by **+1,310.9 million VND** MoM, whereas core net card income contracted by **−232.2 million VND** and net provision charges dropped by **+1,455.8 million VND**.
   - *Business Inferences:* Contraction in net card revenue during May is a signal warranting continued monitoring in subsequent periods, especially as headline profit increased due to declining net provision expenses.
   - *Hypotheses Requiring Further Verification:* Because accounting ledgers aggregate new provisioning and recoveries into one net line, internal audits should inspect raw provision entries to distinguish organic risk improvement from technical accounting adjustments before concluding long-term trends.

4. **South Central Coast – Favorable ranking performance accompanied by low delinquency:**
   - *Observed Facts:* Operating with 5 ASMs, the region maintained the lowest extended risk ratio nationwide (**11.24%**) with **4 out of 5 Area Sales Managers** ranking among the top 25 nationwide.
   - *Business Inferences:* These results show that the South Central Coast is an area worth studying further regarding customer origination methods and credit risk management.
   - *Hypotheses Requiring Further Verification:* Given the compact sample size (5 Area Sales Managers), detailed field surveys of local screening practices are necessary to evaluate feasibility before considering controlled pilot replication in other regions.

### Part C – Deep-Dive Diagnosis & Executive Decision Support Framework:

This section synthesizes deep-dive analytical findings and executive decision support benchmarks, seamlessly linking macro commercial performance with micro governance mechanisms across 4 analytical tiers:

1. **Four Executive KPI Cards:**
   - **Southwest drives 67% of system profit:** Generating +167.9 billion VND of total bank-wide profit.
   - **Southwest NPL reaches peak 22.0%:** Far exceeding safe benchmarks across the institution.
   - **Southeast is the sole loss-making region:** Cumulative operating loss stands at −48.8 billion VND.
   - **South Central Coast achieves optimal quality:** Lowest NPL ratio nationwide (11.2%) while providing 20% of net profit (+50.0 billion VND).

2. **Regional Pre-Tax Profit Flow Decomposition (Waterfall Analysis):**
   - *Cumulative positive contributions:* Red River Delta (+54.3 billion VND), South Central Coast (+50.0 billion VND), Southwest (+167.9 billion VND), and 3 Other Regions (+27.0 billion VND) elevate cumulative profit to a peak of **+299.2 billion VND**.
   - *Drag effect:* The **−48.8 billion VND** operating loss from the Southeast erodes **16%** of total system cumulative profit.
   - *Final institutional bottom line:* System-wide pre-tax profit closes at **+250.5 billion VND**.

3. **Deconstructing Evaluation Mechanism Paradox in the Southeast:**
   - *Regional penalty points:* Regional loss of −48.8 billion VND incurs a maximum penalty of **+26 points** (Rank 7/7 nationwide).
   - *Blanket allocation mechanism:* Penalty points were uniformly applied across all **19 Area Sales Managers**, eliminating individual sales advantages.
   - *Evidence from 3 representative managers:*
     * Le Van Binh: Sales rank #24 dropped to final rank #31 (down 7 ranks).
     * Tran Van Hai: Sales rank #28 dropped to final rank #33 (down 5 ranks).
     * Tran Van Anh: Sales rank #36 dropped to final rank #41 (down 5 ranks).
   - *Consequences & Recommendations:* **74% of Managers** (14/19 personnel) were pushed into the bottom 25% national quartile. *Actionable policy recommendation:* Decouple Individual Sales Scorecards (incentives) from Regional Profit Targets (assigned to Regional Directors).

4. **Multi-Dimensional Management Action Matrix:**
   - *Southwest (High Growth with Heightened Risk):* Tighten credit risk appetite and audit debt collection procedures with NPL reaching 22.0% and provision charges at 14.6 billion VND.
   - *Southeast (Evaluation Mechanism Paradox):* Calibrate blanket penalty policies to unlock motivation for top sales performers.
   - *North Central Coast (Operating Cost Overhead):* Restructure operating overhead as territorial CIR reaches 124.9%.
   - *South Central Coast (Operational Benchmark):* Replicate credit screening protocols to maintain low NPL standards (11.2%).

### Five Concrete Management Action Plans:

| # | Action Recommendation | Empirical Basis (May 2023) | Department Responsible · Timeline |
|:---:|:---|:---|:---|
| 01 | **Separate provision adjustments from core profit:** Break out new provision charges from write-back recoveries to measure core operational viability. | Current single-line reporting obscures operating realities | Credit Risk Division · June |
| 02 | **Audit delinquent loan portfolios in 3 priority regions:** Inspect migration files across the Southeast, Northeast, and Northwest. | Combined provision charges across these 3 regions surged by **6,035.1 million VND** | Regional ASMs + Risk Division · 30 Days |
| 03 | **Conduct field audits in the Southwest:** Re-audit credit approval standards and debt collection effectiveness. | NPL stands at **21.99%** (highest nationwide) while driving **97.2%** of profit growth | Retail Division + Risk Division · July |
| 04 | **Pilot underwriting standards from the South Central Coast:** Replicate high-quality client screening protocols. | Lowest NPL ratio (**11.24%**) with 4/5 ASMs in top 25 | Retail Banking Division · Review in 2 Months |
| 05 | **Recalibrate incentive compensation:** Combine net income with regional NPL thresholds rather than relying on unadjusted net profit. | Prevents rewarding territories displaying artificial profit gains from provision reductions | Executive Committee · Immediate |

---

## 8. 📚 Key Takeaways

1. **Master banking domain principles before writing code:**
   In institutional financial data, understanding why funding costs are signed negative and why Head Office cost centers bear province code `'00'` and zone `'A'` is essential for correct SQL allocation queries. Technical skill cannot compensate for a lack of domain understanding.

2. **Entity resolution and dimensional cleaning are mission-critical:**
   Identifying naming discrepancies between "Bà Rịa - Vũng Tàu" and "Vũng Tàu" during data ingestion salvaged over **36,000 credit card accounts**, preventing severe distortions in Southeast regional NPL metrics.

3. **Transaction control and auditability in ETL pipelines:**
   Designing 6 vertical temporary tables and maintaining strict transaction control in Stored Procedures ensures full auditability across calculation steps and permits safe rollbacks during batch failures.

4. **Never evaluate performance through isolated aggregate metrics:**
   Favorable aggregate profits frequently conceal underlying contractions in core revenue or severe surges in latent credit risk. Multi-dimensional decomposition is fundamental to professional data analytics.

5. **Acknowledge data boundaries to avoid unjustified conclusions:**
   When credit risk metrics are tracked at regional branch level rather than individual contract level, reports must explicitly state this boundary so leadership uses findings appropriately without drawing unsupported conclusions.

---

## 9. 🛠️ Tools Used

Tools were chosen based on fit for purpose across project stages:

| Technology | Component | Technical Role | Selection Justification |
|---|---|---|---|
| **Python 3.10** | `openpyxl`, `zipfile`, `xml.etree` | Ingestion of raw 3M-row statements, text normalization, and database loading | Streaming parsing handles 117.2 MB file without memory exhaustion |
| **PostgreSQL 15** | PL/pgSQL, Stored Procedures | Kimball Star Schema repository (19 tables, 4 `views`), cost allocation, and ranking logic | High-performance relational calculation with strict ACID transaction controls |
| **Power BI Desktop** | Import Mode, 72 DAX Measures | 5-page interactive dashboard suite with multi-dimensional slicing | Delivers instant executive exploration and diagnostic drill-downs |
| **Microsoft Excel** | XLSX, Automated Reports | Automated generation of 7-sheet management report workbooks | Facilitates detailed financial verification and accounting reconciliation |

---

## 10. 📂 Project Repository Structure

Standardized across 6 operational directories:

```text
.
├── input/              # Master parameter mapping files; 3 raw files managed locally due to GitHub limits
│   └── Tham so va mau doi chieu.xlsx  # Maps 64 provinces to 8 zones, GL account crosswalk, layout specifications for 2 reports
├── ingestion/          # Python extraction, transformation, database loading, and reporting scripts
│                       # run_all.py orchestrates 4-stage ingestion · run_report.py generates Excel workbook
├── sql/                # SQL DDL, temporary tables, stored procedures, and reporting views
│   ├── dim/            # Dimension tables: dim_month_headcount, dim_asm, dim_report_detail
│   ├── tmp/            # Temporary tables and procedures for P&L (step 1-3) and ASM ranking (step 1-3)
│   ├── fct/            # Fact tables and orchestrators: fct_pnl_allocation, fct_xephang_asm
│   └── rpt/            # Analytical views: rpt_pnl_view, rpt_xephang_view
├── images/             # Technical pipeline diagrams, warehouse architecture, and dashboard screenshots
├── docs/               # Technical documentation: HIEN_TRANG_HE_THONG, PIPELINE, NHAT_KY_CONG_VIEC, LOI_THUONG_GAP
├── output/             # Deliverables: Power BI report model (.pbix) and Excel workbook
├── README.md           # Vietnamese documentation (default)
└── README_eng.md       # English documentation
```

---

## 11. 📖 Reference Documentation

Comprehensive system documentation is maintained within `docs/`:
- [`docs/HIEN_TRANG_HE_THONG.md`](docs/HIEN_TRANG_HE_THONG.md) — Warehouse status, row counts across 19 tables and 4 `views`, file ownership matrix, and reconciliation benchmarks.
- [`docs/PIPELINE.md`](docs/PIPELINE.md) — 4-stage processing pipeline specifications and operational execution guides.
- [`docs/NHAT_KY_CONG_VIEC.md`](docs/NHAT_KY_CONG_VIEC.md) — Worklog recording implementation steps, testing phases, and optimization history.
- [`docs/LOI_THUONG_GAP.md`](docs/LOI_THUONG_GAP.md) — Troubleshooting manual cataloging **58 real-world error cases** spanning source data, SQL syntax, Python logic, and DAX expressions.

---

## 12. 👤 Author

<div align="center">

**Tran Ngoc Duc** · [Email](mailto:tranduc22104@gmail.com) · [LinkedIn](https://www.linkedin.com/in/tr%E1%BA%A7n-ng%E1%BB%8Dc-%C4%91%E1%BB%A9c-48b3a7439/)

</div>
