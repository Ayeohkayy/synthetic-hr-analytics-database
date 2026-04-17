# survival_curves_salary_band.R
# Purpose:
# Build Kaplan-Meier survival curves by salary band to show retention over time.
# Output:
# - Console survival summary
# - PNG chart of retention by salary band

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(survival)
  library(survminer)
  library(ggplot2)
})

# -----------------------------
# 1. File paths
# -----------------------------
data_path <- "data/employees.csv"
output_dir <- "visuals"

if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

# -----------------------------
# 2. Load data
# -----------------------------
employees <- read_csv(data_path, show_col_types = FALSE)

# -----------------------------
# 3. Validate required columns
# -----------------------------
required_cols <- c("CurrentSalary", "tenure_days", "event")
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
# 4. Clean data and create salary bands
# -----------------------------
employees_clean <- employees %>%
  filter(
    !is.na(CurrentSalary),
    !is.na(tenure_days),
    !is.na(event),
    tenure_days >= 0,
    CurrentSalary > 0
  ) %>%
  mutate(
    salary_band = case_when(
      CurrentSalary < 80000 ~ "<$80K",
      CurrentSalary < 120000 ~ "$80K–$120K",
      CurrentSalary < 180000 ~ "$120K–$180K",
      TRUE ~ "$180K+"
    )
  )

employees_clean$salary_band <- factor(
  employees_clean$salary_band,
  levels = c("<$80K", "$80K–$120K", "$120K–$180K", "$180K+")
)

# -----------------------------
# 5. Fit survival model by salary band
# -----------------------------
surv_fit <- survfit(
  Surv(tenure_days, event) ~ salary_band,
  data = employees_clean
)

cat("\n=== Kaplan-Meier Survival Summary by Salary Band ===\n")
print(summary(surv_fit))

# -----------------------------
# 6. Create survival curve plot
# -----------------------------
p <- ggsurvplot(
  surv_fit,
  data = employees_clean,
  risk.table = FALSE,
  conf.int = FALSE,
  censor = FALSE,
  pval = FALSE,
  palette = c("#d73027", "#fc8d59", "#91bfdb", "#1f4e79"),
  title = "Compensation Drives Employee Retention Over Time",
  xlab = "Tenure (Days)",
  ylab = "Employee Retention Probability",
  legend.title = "Salary Band",
  legend.labs = c("<$80K", "$80K–$120K", "$120K–$180K", "$180K+"),
  legend = "bottom",
  ggtheme = theme_classic(base_size = 13)
)

p$plot <- p$plot +
  geom_vline(
    xintercept = 365,
    linetype = "dashed",
    color = "gray70"
  ) +
  annotate(
    "text",
    x = 365,
    y = 0.05,
    label = "1 Year",
    size = 3.2,
    color = "gray40"
  ) +
  annotate(
    "text",
    x = 800,
    y = 0.72,
    label = "Early attrition is highest\nfor lower-paid employees",
    size = 4,
    hjust = 0,
    fontface = "bold"
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 18),
    plot.subtitle = element_text(size = 12, color = "gray40"),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 10),
    legend.title = element_text(size = 11),
    legend.text = element_text(size = 10)
  )

print(p)

# -----------------------------
# 7. Save chart
# -----------------------------
ggsave(
  filename = file.path(output_dir, "retention_salary_bands.png"),
  plot = p$plot,
  width = 10,
  height = 7,
  dpi = 300
)

cat("\nSaved:\n")
cat("-", file.path(output_dir, "retention_salary_bands.png"), "\n")
