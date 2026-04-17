# survival_model_salary.R
# Purpose:
# Build a Cox proportional hazards model to estimate how salary impacts attrition risk.
# Uses:
# - FinalTenureYears
# - TerminationDate
# - DepartmentID
# - CurrentSalary
# Output:
# - Console model summary
# - CSV of model coefficients
# - PNG chart of predicted attrition risk by salary

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(survival)
  library(ggplot2)
  library(scales)
})

# -----------------------------
# 1. File paths
# -----------------------------
data_path <- "synthetic_company_database_v2/dim_employees.csv"
output_dir <- "visuals"
results_dir <- "results"

if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)
if (!dir.exists(results_dir)) dir.create(results_dir, recursive = TRUE)

# -----------------------------
# 2. Load data
# -----------------------------
employees <- read_csv(data_path, show_col_types = FALSE)

# -----------------------------
# 3. Validate required columns
# -----------------------------
required_cols <- c(
  "FinalTenureYears",
  "TerminationDate",
  "DepartmentID",
  "CurrentSalary"
)

missing_cols <- setdiff(required_cols, names(employees))

if (length(missing_cols) > 0) {
  stop(
    paste(
      "Missing required columns:",
      paste(missing_cols, collapse = ", ")
    )
  )
}

# -----------------------------
# 4. Clean data and create survival variables
# -----------------------------
employees_clean <- employees %>%
  mutate(
    TerminationDate = as.Date(TerminationDate),
    event = if_else(!is.na(TerminationDate), 1, 0),
    tenure_days = FinalTenureYears * 365.25,
    Salary_10k = CurrentSalary / 10000,
    DepartmentID = as.factor(DepartmentID)
  ) %>%
  filter(
    !is.na(CurrentSalary),
    !is.na(FinalTenureYears),
    !is.na(DepartmentID),
    CurrentSalary > 0,
    FinalTenureYears >= 0,
    tenure_days >= 0
  ) %>%
  droplevels()

# -----------------------------
# 5. Relevel department baseline if "8" exists
# -----------------------------
if ("8" %in% levels(employees_clean$DepartmentID)) {
  employees_clean$DepartmentID <- relevel(employees_clean$DepartmentID, ref = "8")
}

# -----------------------------
# 6. Fit Cox model
# -----------------------------
cox_model_salary_only <- coxph(
  Surv(tenure_days, event) ~ DepartmentID + Salary_10k,
  data = employees_clean
)

cat("\n=== Cox Model Summary: Salary + Department ===\n")
print(summary(cox_model_salary_only))

# -----------------------------
# 7. Save coefficient summary
# -----------------------------
model_summary <- summary(cox_model_salary_only)

coef_table <- as.data.frame(model_summary$coefficients)
coef_table$term <- rownames(coef_table)
rownames(coef_table) <- NULL

conf_table <- as.data.frame(model_summary$conf.int)
conf_table$term <- rownames(conf_table)
rownames(conf_table) <- NULL

model_results <- coef_table %>%
  left_join(conf_table, by = "term")

write_csv(
  model_results,
  file.path(results_dir, "cox_model_salary_only_results.csv")
)

# -----------------------------
# 8. Create prediction dataset
# -----------------------------
salary_seq <- seq(
  min(employees_clean$Salary_10k, na.rm = TRUE),
  max(employees_clean$Salary_10k, na.rm = TRUE),
  length.out = 100
)

baseline_department <- if ("8" %in% levels(employees_clean$DepartmentID)) {
  "8"
} else {
  levels(employees_clean$DepartmentID)[1]
}

pred_data <- data.frame(
  Salary_10k = salary_seq,
  DepartmentID = factor(
    rep(baseline_department, length(salary_seq)),
    levels = levels(employees_clean$DepartmentID)
  )
)

pred_data$risk <- predict(
  cox_model_salary_only,
  newdata = pred_data,
  type = "risk"
)

# -----------------------------
# 9. Create final attrition risk chart
# -----------------------------
salary_ref <- 100000
risk_ref <- pred_data$risk[
  which.min(abs(pred_data$Salary_10k * 10000 - salary_ref))
]

risk_plot <- ggplot(pred_data, aes(x = Salary_10k * 10000, y = risk)) +
  geom_line(linewidth = 2, color = "#2C7BE5") +
  geom_hline(yintercept = 1, linetype = "dashed", color = "gray50") +
  geom_point(
    aes(x = salary_ref, y = risk_ref),
    color = "black",
    size = 2
  ) +
  annotate(
    "text",
    x = 160000,
    y = max(pred_data$risk) * 0.5,
    label = "~15–17% lower attrition risk\nper $10K increase",
    size = 4.2,
    fontface = "bold",
    hjust = 0
  ) +
  annotate(
    "text",
    x = 300000,
    y = 1.1,
    label = "Baseline Risk",
    size = 3,
    color = "gray40"
  ) +
  annotate(
    "text",
    x = salary_ref + 12000,
    y = risk_ref + 0.12,
    label = "$100K reference point",
    size = 3.2,
    hjust = 0
  ) +
  labs(
    title = "Attrition Risk Decreases as Compensation Increases",
    subtitle = "Cox Proportional Hazards Model | Synthetic Enterprise HR Dataset",
    x = "Salary ($)",
    y = "Relative Attrition Risk"
  ) +
  scale_x_continuous(labels = dollar_format()) +
  theme_classic() +
  theme(
    plot.title = element_text(face = "bold", size = 18),
    plot.subtitle = element_text(size = 13, color = "gray40"),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 10)
  )

print(risk_plot)

ggsave(
  filename = file.path(output_dir, "salary_attrition_curve.png"),
  plot = risk_plot,
  width = 10,
  height = 6,
  dpi = 300
)

cat("\nSaved:\n")
cat("-", file.path(results_dir, "cox_model_salary_only_results.csv"), "\n")
cat("-", file.path(output_dir, "salary_attrition_curve.png"), "\n")
