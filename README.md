# Synthetic HR Analytics Database (R)

## Overview
This project demonstrates the design and generation of a synthetic enterprise-level HR and People Analytics database using R.

The dataset simulates a modern organization with 10,000 employees and includes workforce, recruiting, compensation, performance, engagement, and operational data across a fully relational structure.

The goal of this project is to showcase skills in:
- R-based data engineering
- synthetic data generation
- dimensional data modeling
- people analytics
- data preparation for SQL and BI tools

All data is synthetic and created for portfolio and educational use.

---

## Project Highlights

- 10,000 synthetic employees
- 12+ interconnected tables (dimension + fact)
- Realistic workforce lifecycle modeling
- Manager hierarchy and span of control
- Compensation history and progression
- Recruiting pipeline and candidate tracking
- Performance and engagement analytics
- Monthly headcount tracking
- Automated CSV export pipeline
- Built-in QA validation checks

---

## Tech Stack

- **R**
- dplyr
- tidyr
- stringr
- purrr
- lubridate
- tibble

---

## Data Model

This project follows a dimensional-style data model commonly used in analytics and BI environments.

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

## Key Features

### Workforce Modeling
- Employee demographics, job levels, departments, and locations
- Employment status (active vs terminated)
- Tenure and age calculations
- Remote vs onsite classification

### Compensation Analytics
- Salary bands by job level
- Historical compensation tracking
- Bonus targets and progression
- Pay grade simulation

### Performance & Engagement
- Annual performance reviews
- Potential ratings
- Goal completion metrics
- Engagement and inclusion scores
- Intent-to-stay indicators

### Recruiting Pipeline
- Requisitions and hiring managers
- Candidate funnel stages
- Source tracking (LinkedIn, referral, etc.)
- Interview scoring
- Time-to-fill metrics

### Organizational Insights
- Manager hierarchy
- Span of control
- Department-level headcount
- Monthly workforce snapshots

---

## Project Structure

```text
synthetic-hr-analytics-database/
│
├── R/
│   └── synthetic_company_database.R
│
├── data/
│   └── (generated CSV files)
│
├── documentation/
│   └── (data dictionary / schema)
│
├── screenshots/
│   └── (project outputs / dashboards)
│
└── README.md
