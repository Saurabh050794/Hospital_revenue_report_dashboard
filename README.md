# 🏥 Hospital Revenue & Profitability Analytics

A end-to-end **SQL + Power BI** project that analyzes hospital revenue, department performance, and payment behavior using real-world style data.

---

## 📌 Project Overview

This project helps hospital management understand:
- Where is revenue coming from?
- Which department is most profitable?
- What is the Insurance vs Self Pay split?
- How much revenue is Paid vs Pending?

---

## 🗂️ Project Structure

```
hospital-revenue-analytics/
│
├── data/
│   ├── billing.csv
│   ├── billing_detail.csv
│   ├── admission.csv
│   ├── department.csv
│   └── patient_insurance.csv
│
├── sql/
│   └── hospital_revenue_.sql
│
├── powerbi/
│   └── hospital_revenuedashboard.pbix
│
└── README.md
```

---

## 🗃️ Database: `hospital_revenue_db`

### Tables

| Table | Description |
|-------|-------------|
| `billing` | Bill details — amount, payment mode, status |
| `billing_detail` | Line items for each bill |
| `admission` | Patient admission info — department, dates |
| `department` | Department master data |
| `patient_insurance` | Insurance policy details per patient |

### Relationships

```
billing          →  billing_detail   (bill_id)
billing          →  admission        (admission_id)
admission        →  department       (department_id)
patient_insurance → insurance_provider (insurance_provider_id)
```

---

## 🔑 Core SQL — `revenue_analysis` View

```sql
CREATE VIEW revenue_analysis AS
SELECT 
    b.bill_id,
    b.bill_date,
    d.department_name,
    SUM(bd.amount) AS total_revenue,
    b.payment_status,
    b.payment_mode,
    CASE 
        WHEN b.insurance_covered_amount > 0 THEN 'Insurance'
        ELSE 'Self Pay'
    END AS payment_type
FROM billing b
JOIN billing_detail bd ON b.bill_id = bd.bill_id
JOIN admission a ON b.admission_id = a.admission_id
JOIN department d ON a.department_id = d.department_id
GROUP BY 
    b.bill_id, b.bill_date, d.department_name,
    b.payment_status, b.payment_mode,
    b.insurance_covered_amount;
```

---

## 📊 Power BI Dashboard

### Page 1 — Revenue Overview
| Visual | Fields |
|--------|--------|
| KPI Card | Total Bills |
| KPI Card | Total Revenue |
| KPI Card | Average Bill |
| Line Chart | Revenue Trend (by Year) |
| Donut Chart | Revenue by Payment Type |
| Donut Chart | Revenue by Payment Status |
| Bar Chart | Revenue by Payment Mode |
| Slicer | Select Date Range |

### Page 2 — Department Revenue
| Visual | Fields |
|--------|--------|
| KPI Card | Total Departments |
| KPI Card | Total Revenue |
| Bar Chart | Revenue by Department |
| Column Chart | Avg Revenue by Department |
| Donut Chart | Department Revenue Share |
| Slicer | Select Department |

### Page 3 — Payment Analysis
| Visual | Fields |
|--------|--------|
| KPI Card | Total Paid Revenue |
| KPI Card | Total Pending Revenue |
| Stacked Bar | Department Wise Payment Type |
| Line Chart | Insurance vs Self Pay Trend |
| Table | Transaction Level Payment Details |
| Slicer | Select Payment Status |
| Slicer | Select Payment Mode |

---

## 🧮 DAX Measures

```dax
Total Revenue = SUM(revenue_analysis[total_revenue])

Total Bills = COUNT(revenue_analysis[bill_id])

Avg Bill = AVERAGE(revenue_analysis[total_revenue])

Insurance Revenue =
CALCULATE([Total Revenue],
    revenue_analysis[payment_type] = "Insurance")

Self Pay Revenue =
CALCULATE([Total Revenue],
    revenue_analysis[payment_type] = "Self Pay")

Total Paid Revenue =
CALCULATE(SUM(revenue_analysis[total_revenue]),
    revenue_analysis[payment_status] = "Paid")

Total Pending Revenue =
CALCULATE(SUM(revenue_analysis[total_revenue]),
    revenue_analysis[payment_status] = "Pending")
```

---

## 📈 Key Insights

- **Total Revenue:** ₹1.48 Billion across 45,000 bills
- **Insurance dominates:** 80.11% revenue from insurance patients
- **Top Department:** Surgery — ₹310M total revenue
- **Highest Avg Bill:** ICU — ₹57K per bill
- **Payment Gap:** 50% revenue still Pending collection
- **Insurance dependency:** Insurance payment mode = ₹1.18bn vs Cash/Card/UPI = ₹0.10bn each

---

## 🛠️ Tools Used

| Tool | Purpose |
|------|---------|
| MySQL 8.0 | Database, tables, view creation |
| Power BI Desktop | Dashboard & visualization |
| DAX | Measures & calculations |
| CSV Files | Raw data source |

---

## 🚀 How to Run

### SQL Setup
1. Open MySQL Workbench
2. Run `hospital_revenue_.sql`
3. Verify: `SELECT * FROM revenue_analysis LIMIT 10;`

### Power BI Setup
1. Open `hospital_revenuedashboard.pbix`
2. Go to **Transform Data → Data Source Settings**
3. Update MySQL server name
4. Click **Refresh**

---

## 👤 Author

**Saurabh**  
SQL + Power BI | Hospital Analytics Project  
April 2026
