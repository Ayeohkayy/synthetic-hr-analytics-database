# Synthetic HR Analytics Database (R)

## Overview
This project demonstrates the design and generation of a synthetic enterprise-level HR and People Analytics database using R.

The dataset simulates a modern organization with 10,000 employees and includes workforce, recruiting, compensation, performance, engagement, and operational data across a relational data model.

In addition to data generation, this project includes advanced workforce analytics, specifically survival modeling to understand employee attrition over time.

---

## What This Project Demonstrates

### Data Engineering
- End-to-end synthetic data generation pipeline in R  
- Scalable dataset creation (10K+ records)  
- Structured export to analytics-ready CSVs  

### People Analytics
- Workforce lifecycle modeling (hire → performance → promotion → attrition)  
- Engagement and retention indicators  
- Recruiting funnel and hiring metrics  
- Survival analysis to model attrition risk over time  

### Data Modeling
- Dimension and fact table design  
- Business-ready schema for BI tools  
- Support for relational joins and KPI calculations  

---

## Key Highlights
- 10,000 synthetic employees  
- 15+ interconnected tables (dimension + fact)  
- Enterprise-style HR data model  
- Manager hierarchy and span of control  
- Compensation history with salary progression  
- Recruiting pipeline with candidate tracking  
- Performance and engagement analytics  
- Monthly headcount snapshots  
- Automated CSV export pipeline  
- Built-in QA validation checks  
- Advanced attrition modeling using Cox Proportional Hazards and survival curves  

---

## Tech Stack
- R  
- dplyr  
- tidyr  
- stringr  
- purrr  
- lubridate  
- tibble  
- survival  
- survminer  
- ggplot2  

---

## Data Model

The dataset follows a dimensional structure used in analytics and data warehousing.

### Dimension Tables
- dim_employees  
- dim_employee_demographics  
- dim_departments  
- dim_jobs  
- dim_locations  

### Fact Tables
- fact_employee_current  
- fact_compensation_history  
- fact_promotions  
- fact_performance_reviews  
- fact_engagement_surveys  
- fact_learning_completions  
- fact_leave_events  
- fact_requisitions  
- fact_candidates  
- fact_headcount_monthly  
- fact_manager_span  

---

## Attrition & Retention Analysis (Survival Modeling)

### Objective
Move beyond traditional attrition rates and model when employees leave and what factors influence attrition risk over time.

---

### Approach
- Built a Cox Proportional Hazards model to quantify attrition risk  
- Engineered salary-based features and tenure variables  
- Created Kaplan-Meier survival curves to visualize retention patterns  
- Controlled for department-level effects to isolate key drivers  

---

### Key Findings

#### 1. Compensation is the strongest driver of attrition
- Every $10,000 increase in salary is associated with a ~15.7% reduction in attrition risk  

#### 2. Department-level differences are limited
- After controlling for compensation, most department effects are not statistically significant  
- This suggests compensation explains much of the variation often attributed to departments  

#### 3. Attrition is concentrated in early tenure
- Lower-paid employees experience higher attrition within the first year  
- Higher compensation improves both retention and time-to-exit  

---

## Visual Insights (Survival Analysis)

### Attrition Risk by Salary
![Attrition Risk Curve](screenshots/Survival%20Analysis/attrition_salary_curve.png)

### Retention Over Time by Salary Band
![Retention Curve](screenshots/Survival%20Analysis/retention_by_salary_band.png)

---

## Business Implications
- Compensation is a primary lever for retention strategy  
- Early-tenure employees represent the highest risk population  
- Retention strategies should focus on:
  - Competitive pay structures  
  - First-year employee experience  
  - Early engagement interventions  

---

## Example Business Questions
- What is the attrition rate by department?  
- Which job levels experience the highest turnover?  
- How does performance relate to promotions?  
- What is the average salary by job level and location?  
- Which recruiting sources produce the most hires?  
- What is the average time-to-fill by recruiter?  
- How does engagement impact intent to stay?  
- What is the average manager span of control?  
- How does compensation impact attrition risk over time?  

---

## Project Structure

```bash
synthetic-hr-analytics-database/
│
├── R/
│   ├── synthetic_company_database.R
│   ├── survival_model_salary.R
│   └── survival_curves_salary_band.R
│
├── data/
│   └── (generated CSV files)
│
├── visuals/
│   ├── salary_attrition_curve.png
│   └── retention_salary_bands.png
│
├── results/
│   └── cox_model_salary_only_results.csv
│
├── documentation/
│   └── (data dictionary and schema files)
│
├── powerbi/
│   └── (synthetic_hr_dashboard.pbix)
│
├── screenshots/
│   └── (sample outputs and dashboards)
│
└── README.md
```
---

## How to Run
1. Clone the repository

2. Open the R script


3. Install required packages
```text
install.packages(c("dplyr", "tidyr", "stringr", "purrr", "lubridate", "tibble","survival", "survminer", "ggplot2"))
```

4. Run scripts
synthetic_company_database.R → generate dataset
survival_model_salary.R → build attrition model
survival_curves_salary_band.R → generate retention curves

---

## Output

The project produces a complete analytics dataset including:

 - Employee master data
 - Compensation history
 - Recruiting pipeline
 - Performance reviews
 - Engagement surveys
 - Learning and leave events
 - Monthly workforce snapshots
 - Attrition risk modeling outputs
 - Retention visualization charts


  

## This dataset is ready for:

- SQL database ingestion
- Power BI dashboards
- Tableau dashboards
- analytics case studies

---

## Next Steps

Planned enhancements include:

- SQL schema and table creation scripts
- Power BI dashboard with workforce KPIs
- Attrition and retention analysis
- ERD diagram and schema visualization
- Advanced analytics use cases
- Predictive attrition modeling extensions

---


### Author

Joshua Watson

People Analytics | Data Analytics | HR Technology


