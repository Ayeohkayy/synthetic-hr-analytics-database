# =========================================================
# SYNTHETIC COMPANY DATABASE - VERSION 2
# 10,000 employees | 12 tables
# Enterprise-style people analytics model
# =========================================================

# -------------------------
# Packages
# -------------------------
# install.packages(c("dplyr", "tidyr", "stringr", "purrr", "lubridate", "tibble"))

library(dplyr)
library(tidyr)
library(stringr)
library(purrr)
library(lubridate)
library(tibble)

set.seed(20260310)

# =========================================================
# Helper functions
# =========================================================

clip_num <- function(x, min_val, max_val) {
  pmin(pmax(x, min_val), max_val)
}

random_date <- function(n, start_date, end_date) {
  start_date <- as.Date(start_date)
  end_date <- as.Date(end_date)
  start_date + sample(0:as.integer(end_date - start_date), n, replace = TRUE)
}

weighted_sample <- function(x, n, prob = NULL) {
  sample(x, size = n, replace = TRUE, prob = prob)
}

safe_dir_create <- function(path) {
  if (!dir.exists(path)) dir.create(path, recursive = TRUE)
}

# Create a large synthetic surname bank so the company does not
# look like it is made up of a few giant families.
generate_surnames <- function(n_target = 3000) {
  starts <- c(
    "Ash","Bar","Beck","Bell","Benn","Bland","Blake","Bram","Brook","Burn",
    "Cald","Cam","Car","Chand","Clark","Cole","Cran","Cross","Dal","Darn",
    "Del","East","Ell","Em","Fair","Field","Fin","Ford","Glen","Grant",
    "Gray","Green","Hall","Hart","Hawk","Hay","Kend","King","Lake","Lang",
    "Mar","Mill","Mon","North","Oak","Park","Pine","Quill","Rain","Reed",
    "Rock","Rose","Row","Sand","Stone","Storm","Thorn","Vale","Ward","West",
    "Will","Wind","Wren","York","Caldw","Holl","Long","Nor","Rad","Torr",
    "Pres","Dun","Whit","Black","Bright","Gold","Silver","Winter","Summer",
    "Autumn","Spring","River","Mead","Fox","Wolf","Swan","Crow","Perry","Adler"
  )
  
  middles <- c(
    "", "", "", "a", "e", "i", "o", "u",
    "an", "en", "in", "on", "un",
    "er", "el", "ar", "or",
    "ing", "ell", "ett", "son", "lin", "ton", "ley", "well"
  )
  
  ends <- c(
    "son","sen","man","man","well","worth","ford","field","ton","ley",
    "wood","stone","brook","dale","ridge","mont","land","ham","strom","quist",
    "berg","thorne","hart","croft","more","way","wall","stead","bry","den",
    "lin","mond","win","ridge","crest","mere","ward","cott","by","shire"
  )
  
  pool <- c()
  while (length(unique(pool)) < n_target) {
    batch <- paste0(
      sample(starts, 5000, replace = TRUE),
      sample(middles, 5000, replace = TRUE),
      sample(ends, 5000, replace = TRUE)
    )
    
    batch <- str_replace_all(batch, "(.)\\1\\1+", "\\1\\1")
    batch <- str_to_title(batch)
    batch <- batch[nchar(batch) >= 5 & nchar(batch) <= 12]
    pool <- unique(c(pool, batch))
  }
  
  unique(pool)[1:n_target]
}

# =========================================================
# Large first-name banks
# =========================================================

first_names_m <- c(
  "Aaron","Adam","Adrian","Aiden","Alan","Albert","Alex","Alexander","Andrew","Anthony",
  "Arthur","Asher","Austin","Benjamin","Blake","Brandon","Brian","Caleb","Cameron","Carlos",
  "Carter","Charles","Christian","Christopher","Cole","Colin","Connor","Daniel","David","Dominic",
  "Dylan","Eli","Elijah","Ethan","Evan","Felix","Gabriel","Gavin","George","Grant",
  "Henry","Hudson","Ian","Isaac","Jack","Jackson","Jacob","James","Jason","Jayden",
  "Jeremiah","Joel","Jonathan","Jordan","Jose","Joshua","Julian","Justin","Kai","Kevin",
  "Kingston","Kyle","Landon","Leo","Liam","Logan","Lucas","Luis","Luke","Marcus",
  "Mason","Mateo","Matthew","Michael","Miles","Nathan","Nicholas","Nolan","Noah","Oliver",
  "Owen","Parker","Patrick","Paul","Peter","Preston","Rafael","Richard","Robert","Roman",
  "Ryan","Samuel","Sebastian","Seth","Simon","Stephen","Theodore","Thomas","Tyler","Victor",
  "Vincent","Wesley","William","Xavier","Zachary"
)

first_names_f <- c(
  "Abigail","Addison","Aisha","Alexa","Alexis","Alice","Alicia","Allison","Alyssa","Amelia",
  "Amy","Ana","Andrea","Angela","Anna","Aria","Ashley","Aubrey","Audrey","Autumn",
  "Ava","Avery","Bella","Brianna","Brooklyn","Camila","Carla","Carmen","Caroline","Charlotte",
  "Chloe","Claire","Clara","Daniela","Delilah","Destiny","Diana","Eleanor","Elena","Eliana",
  "Elizabeth","Ella","Emily","Emma","Erica","Eva","Evelyn","Faith","Gabriella","Genesis",
  "Gianna","Grace","Hailey","Hannah","Harper","Hazel","Isabella","Isla","Jade","Jasmine",
  "Jennifer","Jessica","Julia","Juliana","Kaitlyn","Kayla","Kennedy","Kiara","Layla","Leah",
  "Lillian","Lily","Lucy","Luna","Madeline","Madison","Maria","Maya","Melanie","Mia",
  "Naomi","Natalie","Nicole","Nora","Olivia","Paige","Penelope","Rachel","Rebecca","Riley",
  "Rose","Ruby","Samantha","Sarah","Savannah","Scarlett","Sofia","Sophia","Stella","Sydney",
  "Taylor","Valentina","Victoria","Violet","Zoe"
)

first_names_unisex <- c(
  "Alex","Ariel","Avery","Bailey","Blair","Cameron","Casey","Charlie","Dakota","Drew",
  "Eden","Elliot","Emerson","Finley","Harley","Hayden","Jamie","Jordan","Kai","Kendall",
  "Lane","Logan","Micah","Morgan","Parker","Peyton","Phoenix","Quinn","Reese","River",
  "Rowan","Sage","Sawyer","Skyler","Taylor"
)

last_names <- generate_surnames(3200)

# =========================================================
# Build a large unique name pool
# =========================================================

n_employees <- 10000
employee_ids <- 100001:(100000 + n_employees)

gender_pool <- c("Male", "Female", "Non-Binary")
gender_probs <- c(0.485, 0.485, 0.03)

employee_gender <- weighted_sample(gender_pool, n_employees, prob = gender_probs)

get_first_name <- function(g) {
  if (g == "Male") {
    sample(c(first_names_m, first_names_unisex), 1)
  } else if (g == "Female") {
    sample(c(first_names_f, first_names_unisex), 1)
  } else {
    sample(c(first_names_m, first_names_f, first_names_unisex), 1)
  }
}

first_name <- map_chr(employee_gender, get_first_name)

# Create unique full-name combinations so duplicates do not happen
name_combo_pool <- expand.grid(
  FirstName = unique(c(first_names_m, first_names_f, first_names_unisex)),
  LastName = last_names,
  stringsAsFactors = FALSE
) %>%
  as_tibble() %>%
  mutate(FullName = paste(FirstName, LastName))

name_combo_pool <- name_combo_pool %>%
  sample_n(size = n_employees, replace = FALSE)

first_name <- name_combo_pool$FirstName
last_name  <- name_combo_pool$LastName

# =========================================================
# Dimensions
# =========================================================

# -------------------------
# dim_locations
# -------------------------
dim_locations <- tibble(
  LocationID = 1:12,
  LocationName = c(
    "Las Vegas","Phoenix","Austin","Chicago","Atlanta","Seattle",
    "Denver","Nashville","Miami","Remote-East","Remote-Central","Remote-West"
  ),
  State = c("NV","AZ","TX","IL","GA","WA","CO","TN","FL","Remote","Remote","Remote"),
  Region = c("West","West","South","Midwest","South","West","West","South","South","East","Central","West"),
  CostIndex = c(1.00,0.96,1.04,1.10,0.99,1.18,1.08,0.98,1.06,1.00,1.00,1.03)
)

# -------------------------
# dim_departments
# -------------------------
dim_departments <- tibble(
  DepartmentID = 1:11,
  DepartmentName = c(
    "Executive","Engineering","Product","IT","Finance",
    "HR","Marketing","Sales","Operations","Customer Support","Legal"
  ),
  FunctionGroup = c(
    "Corporate","Technical","Technical","Technical","Corporate",
    "Corporate","Business","Business","Business","Business","Corporate"
  )
)

# -------------------------
# dim_jobs
# -------------------------
dim_jobs <- tribble(
  ~JobID, ~DepartmentID, ~JobTitle, ~JobLevel, ~Exempt,
  1,  1, "Chief Executive Officer",            10, TRUE,
  2,  1, "Chief Operating Officer",             9, TRUE,
  3,  1, "Vice President",                      8, TRUE,
  
  4,  2, "Software Engineer I",                 1, TRUE,
  5,  2, "Software Engineer II",                2, TRUE,
  6,  2, "Senior Software Engineer",            3, TRUE,
  7,  2, "Engineering Manager",                 4, TRUE,
  8,  2, "Director of Engineering",             6, TRUE,
  
  9,  3, "Product Analyst",                     2, TRUE,
  10, 3, "Product Manager",                     3, TRUE,
  11, 3, "Senior Product Manager",              4, TRUE,
  12, 3, "Director of Product",                 6, TRUE,
  
  13, 4, "IT Support Specialist",               1, FALSE,
  14, 4, "Systems Administrator",               2, TRUE,
  15, 4, "IT Manager",                          4, TRUE,
  
  16, 5, "Financial Analyst",                   2, TRUE,
  17, 5, "Senior Financial Analyst",            3, TRUE,
  18, 5, "Finance Manager",                     4, TRUE,
  19, 5, "Director of Finance",                 6, TRUE,
  
  20, 6, "HR Coordinator",                      1, FALSE,
  21, 6, "HR Generalist",                       2, TRUE,
  22, 6, "HR Business Partner",                 3, TRUE,
  23, 6, "HR Manager",                          4, TRUE,
  24, 6, "Director of HR",                      6, TRUE,
  
  25, 7, "Marketing Specialist",                1, TRUE,
  26, 7, "Digital Marketing Manager",           3, TRUE,
  27, 7, "Marketing Director",                  5, TRUE,
  
  28, 8, "Sales Development Representative",    1, FALSE,
  29, 8, "Account Executive",                   2, TRUE,
  30, 8, "Sales Manager",                       4, TRUE,
  31, 8, "Director of Sales",                   6, TRUE,
  
  32, 9, "Operations Analyst",                  2, TRUE,
  33, 9, "Operations Manager",                  4, TRUE,
  34, 9, "Director of Operations",              6, TRUE,
  
  35, 10, "Customer Support Representative",    1, FALSE,
  36, 10, "Customer Support Manager",           3, TRUE,
  37, 10, "Director of Customer Support",       5, TRUE,
  
  38, 11, "Legal Analyst",                      2, TRUE,
  39, 11, "Corporate Counsel",                  4, TRUE,
  40, 11, "General Counsel",                    8, TRUE
) %>%
  left_join(dim_departments, by = "DepartmentID") %>%
  mutate(
    BaseSalaryMin = case_when(
      JobLevel == 1 ~ 43000,
      JobLevel == 2 ~ 62000,
      JobLevel == 3 ~ 86000,
      JobLevel == 4 ~ 112000,
      JobLevel == 5 ~ 145000,
      JobLevel == 6 ~ 185000,
      JobLevel == 8 ~ 250000,
      JobLevel == 9 ~ 310000,
      JobLevel == 10 ~ 400000,
      TRUE ~ 60000
    ),
    BaseSalaryMax = case_when(
      JobLevel == 1 ~ 62000,
      JobLevel == 2 ~ 88000,
      JobLevel == 3 ~ 118000,
      JobLevel == 4 ~ 150000,
      JobLevel == 5 ~ 185000,
      JobLevel == 6 ~ 235000,
      JobLevel == 8 ~ 340000,
      JobLevel == 9 ~ 420000,
      JobLevel == 10 ~ 560000,
      TRUE ~ 85000
    )
  )

# =========================================================
# Employee assignment logic
# =========================================================

birth_date <- random_date(n_employees, "1962-01-01", "2004-12-31")
hire_date  <- random_date(n_employees, "2013-01-01", "2026-02-01")

department_probs <- c(
  0.008, # Executive
  0.29,  # Engineering
  0.08,  # Product
  0.08,  # IT
  0.07,  # Finance
  0.07,  # HR
  0.08,  # Marketing
  0.15,  # Sales
  0.12,  # Operations
  0.10,  # Customer Support
  0.012  # Legal
)

employee_department_id <- weighted_sample(
  dim_departments$DepartmentID,
  n_employees,
  prob = department_probs
)

# Assign job within department with weighted levels
employee_job_id <- map_int(employee_department_id, function(dep_id) {
  valid_jobs <- dim_jobs %>% filter(DepartmentID == dep_id)
  
  lvl_probs <- case_when(
    valid_jobs$JobLevel == 1 ~ 0.34,
    valid_jobs$JobLevel == 2 ~ 0.24,
    valid_jobs$JobLevel == 3 ~ 0.16,
    valid_jobs$JobLevel == 4 ~ 0.11,
    valid_jobs$JobLevel == 5 ~ 0.05,
    valid_jobs$JobLevel == 6 ~ 0.03,
    valid_jobs$JobLevel == 8 ~ 0.012,
    valid_jobs$JobLevel == 9 ~ 0.006,
    valid_jobs$JobLevel == 10 ~ 0.002,
    TRUE ~ 0.01
  )
  
  lvl_probs <- lvl_probs / sum(lvl_probs)
  sample(valid_jobs$JobID, 1, prob = lvl_probs)
})

employee_location_id <- weighted_sample(
  dim_locations$LocationID,
  n_employees,
  prob = c(0.10,0.08,0.12,0.08,0.08,0.08,0.07,0.07,0.08,0.08,0.08,0.08)
)

dim_employees <- tibble(
  EmployeeID = employee_ids,
  FirstName = first_name,
  LastName = last_name,
  Gender = employee_gender,
  BirthDate = birth_date,
  HireDate = hire_date,
  DepartmentID = employee_department_id,
  JobID = employee_job_id,
  LocationID = employee_location_id
) %>%
  left_join(dim_jobs %>% select(JobID, JobTitle, JobLevel, Exempt, BaseSalaryMin, BaseSalaryMax), by = "JobID") %>%
  left_join(dim_locations %>% select(LocationID, CostIndex), by = "LocationID") %>%
  mutate(
    Age = floor(time_length(interval(BirthDate, as.Date("2026-03-10")), "years")),
    TenureYears = round(time_length(interval(HireDate, as.Date("2026-03-10")), "years"), 2),
    FTE = sample(c(1.0, 0.8, 0.6), n(), replace = TRUE, prob = c(0.87, 0.09, 0.04)),
    RemoteStatus = sample(c("Onsite","Hybrid","Remote"), n(), replace = TRUE, prob = c(0.41,0.39,0.20)),
    EmploymentType = sample(c("Regular","Temporary"), n(), replace = TRUE, prob = c(0.94,0.06)),
    WorkerType = sample(c("Employee","Contractor"), n(), replace = TRUE, prob = c(0.95,0.05))
  )

# =========================================================
# Employment status / termination logic
# =========================================================

attrition_prob <- dim_employees %>%
  mutate(
    p = case_when(
      JobLevel == 1 ~ 0.19,
      JobLevel == 2 ~ 0.14,
      JobLevel == 3 ~ 0.10,
      JobLevel == 4 ~ 0.07,
      JobLevel >= 5 ~ 0.05,
      TRUE ~ 0.10
    ),
    p = p + ifelse(DepartmentID %in% c(8, 10), 0.04, 0),
    p = p + ifelse(TenureYears < 1.0, 0.05, 0),
    p = p - ifelse(TenureYears > 7.0, 0.02, 0),
    p = clip_num(p, 0.02, 0.30)
  ) %>%
  pull(p)

terminated_flag <- rbinom(n_employees, 1, attrition_prob)
termination_date <- rep(as.Date(NA), n_employees)

for (i in seq_len(n_employees)) {
  if (terminated_flag[i] == 1) {
    min_term <- dim_employees$HireDate[i] + sample(120:2800, 1)
    max_term <- as.Date("2026-02-28")
    if (min_term <= max_term) {
      termination_date[i] <- sample(seq(min_term, max_term, by = "day"), 1)
    }
  }
}

dim_employees <- dim_employees %>%
  mutate(
    TerminationDate = termination_date,
    EmploymentStatus = ifelse(is.na(TerminationDate), "Active", "Terminated"),
    TerminationType = case_when(
      EmploymentStatus == "Active" ~ NA_character_,
      TRUE ~ sample(c("Voluntary","Involuntary","Reduction in Force"), n(), replace = TRUE, prob = c(0.70,0.22,0.08))
    ),
    FinalTenureYears = ifelse(
      EmploymentStatus == "Active",
      round(time_length(interval(HireDate, as.Date("2026-03-10")), "years"), 2),
      round(time_length(interval(HireDate, TerminationDate), "years"), 2)
    ),
    Email = paste0(
      str_to_lower(FirstName), ".", str_to_lower(LastName),
      EmployeeID, "@synteccorp.com"
    )
  )

# =========================================================
# Manager hierarchy
# =========================================================

dim_employees <- dim_employees %>%
  arrange(desc(JobLevel), DepartmentID, HireDate)

dim_employees$ManagerID <- NA_integer_

for (dep in unique(dim_employees$DepartmentID)) {
  dep_idx <- which(dim_employees$DepartmentID == dep)
  dep_df  <- dim_employees[dep_idx, ]
  
  mgr_lvl2 <- dep_df$EmployeeID[dep_df$JobLevel >= 2 & dep_df$EmploymentStatus == "Active"]
  mgr_lvl3 <- dep_df$EmployeeID[dep_df$JobLevel >= 3 & dep_df$EmploymentStatus == "Active"]
  mgr_lvl4 <- dep_df$EmployeeID[dep_df$JobLevel >= 4 & dep_df$EmploymentStatus == "Active"]
  mgr_lvl5 <- dep_df$EmployeeID[dep_df$JobLevel >= 5 & dep_df$EmploymentStatus == "Active"]
  mgr_lvl6 <- dep_df$EmployeeID[dep_df$JobLevel >= 6 & dep_df$EmploymentStatus == "Active"]
  
  for (j in dep_idx) {
    emp_id <- dim_employees$EmployeeID[j]
    lvl    <- dim_employees$JobLevel[j]
    
    possible_manager <- integer(0)
    
    if (lvl <= 1) {
      possible_manager <- setdiff(mgr_lvl2, emp_id)
    } else if (lvl == 2) {
      possible_manager <- setdiff(mgr_lvl3, emp_id)
    } else if (lvl == 3) {
      possible_manager <- setdiff(mgr_lvl4, emp_id)
    } else if (lvl == 4) {
      possible_manager <- setdiff(mgr_lvl5, emp_id)
    } else if (lvl == 5) {
      possible_manager <- setdiff(mgr_lvl6, emp_id)
    }
    
    if (length(possible_manager) > 0) {
      dim_employees$ManagerID[j] <- sample(possible_manager, 1)
    }
  }
}

active_execs <- dim_employees %>%
  filter(DepartmentID == 1, EmploymentStatus == "Active") %>%
  arrange(desc(JobLevel))

ceo_id <- active_execs$EmployeeID[1]

dim_employees <- dim_employees %>%
  mutate(
    ManagerID = case_when(
      EmployeeID == ceo_id ~ NA_integer_,
      is.na(ManagerID) & EmployeeID != ceo_id ~ ceo_id,
      TRUE ~ ManagerID
    )
  )

manager_lookup <- dim_employees %>%
  transmute(
    ManagerID = EmployeeID,
    ManagerName = paste(FirstName, LastName)
  )

dim_employees <- dim_employees %>%
  left_join(manager_lookup, by = "ManagerID")

# =========================================================
# dim_employee_demographics
# =========================================================

ethnicity_vals <- c(
  "White","Hispanic or Latino","Black or African American",
  "Asian","Two or More Races","Native Hawaiian or Pacific Islander",
  "American Indian or Alaska Native","Prefer Not to Say"
)

ethnicity_probs <- c(0.34,0.24,0.14,0.16,0.05,0.01,0.01,0.05)

dim_employee_demographics <- dim_employees %>%
  transmute(
    EmployeeID,
    GenderIdentity = Gender,
    Ethnicity = sample(ethnicity_vals, n(), replace = TRUE, prob = ethnicity_probs),
    VeteranStatus = sample(c("Yes","No","Prefer Not to Say"), n(), replace = TRUE, prob = c(0.06,0.89,0.05)),
    DisabilityStatus = sample(c("Yes","No","Prefer Not to Say"), n(), replace = TRUE, prob = c(0.05,0.90,0.05)),
    MaritalStatus = sample(c("Single","Married","Divorced","Prefer Not to Say"), n(), replace = TRUE, prob = c(0.38,0.46,0.10,0.06)),
    EducationLevel = sample(
      c("High School","Associate","Bachelor","Master","Doctorate"),
      n(),
      replace = TRUE,
      prob = c(0.16,0.14,0.42,0.22,0.06)
    )
  )

# =========================================================
# fact_employee_current
# =========================================================

fact_employee_current <- dim_employees %>%
  transmute(
    EmployeeID, DepartmentID, JobID, LocationID, ManagerID,
    HireDate, TerminationDate, EmploymentStatus, TerminationType,
    WorkerType, EmploymentType, FTE, RemoteStatus,
    FinalTenureYears
  )

# =========================================================
# fact_compensation_history
# =========================================================

fact_compensation_history <- map_dfr(seq_len(nrow(dim_employees)), function(i) {
  emp <- dim_employees[i, ]
  
  start_date <- emp$HireDate
  end_date <- ifelse(is.na(emp$TerminationDate), as.Date("2026-03-10"), emp$TerminationDate)
  end_date <- as.Date(end_date)
  
  if (start_date >= end_date) {
    return(NULL)
  }
  
  annual_points <- seq(
    from = floor_date(start_date, "year"),
    to   = floor_date(end_date, "year"),
    by   = "1 year"
  )
  
  if (length(annual_points) == 0) annual_points <- start_date
  
  base_salary <- round(runif(1, emp$BaseSalaryMin, emp$BaseSalaryMax) * emp$CostIndex, 0)
  
  rows <- map_dfr(seq_along(annual_points), function(k) {
    eff_date <- annual_points[k]
    years_in <- max(0, as.numeric(difftime(eff_date, start_date, units = "days")) / 365.25)
    
    merit <- ifelse(k == 1, 0, runif(1, 0.015, 0.055))
    salary_k <- round(base_salary * ((1 + merit) ^ pmax(0, k - 1)), 0)
    
    bonus_pct <- case_when(
      emp$JobLevel <= 1 ~ 0.00,
      emp$JobLevel == 2 ~ 0.05,
      emp$JobLevel == 3 ~ 0.08,
      emp$JobLevel == 4 ~ 0.12,
      emp$JobLevel == 5 ~ 0.15,
      emp$JobLevel >= 6 ~ 0.20,
      TRUE ~ 0.05
    )
    
    tibble(
      CompensationEventID = paste0("C", emp$EmployeeID, "_", k),
      EmployeeID = emp$EmployeeID,
      EffectiveDate = eff_date,
      BaseSalary = salary_k,
      BonusTargetPct = bonus_pct,
      AnnualBonusTarget = round(salary_k * bonus_pct, 0),
      PayGrade = paste0("L", emp$JobLevel),
      CompensationChangeReason = ifelse(k == 1, "Hire", sample(c("Merit","Market Adjustment"), 1, prob = c(0.84,0.16)))
    )
  })
  
  rows
})

# Use latest comp value as current salary in dim_employees
latest_comp <- fact_compensation_history %>%
  group_by(EmployeeID) %>%
  slice_max(order_by = EffectiveDate, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  select(EmployeeID, CurrentSalary = BaseSalary, CurrentBonusTarget = AnnualBonusTarget)

dim_employees <- dim_employees %>%
  left_join(latest_comp, by = "EmployeeID")

# =========================================================
# fact_promotions
# =========================================================

promotion_eligible <- dim_employees %>%
  filter(JobLevel <= 5)

fact_promotions <- map_dfr(seq_len(nrow(promotion_eligible)), function(i) {
  emp <- promotion_eligible[i, ]
  
  p_promote <- case_when(
    emp$EmploymentStatus == "Active" & emp$FinalTenureYears >= 2 ~ 0.22,
    emp$FinalTenureYears >= 4 ~ 0.14,
    TRUE ~ 0.06
  )
  
  got_promo <- rbinom(1, 1, p_promote)
  
  if (got_promo == 0) return(NULL)
  
  promo_date_min <- emp$HireDate + 365
  promo_date_max <- ifelse(is.na(emp$TerminationDate), as.Date("2026-02-01"), emp$TerminationDate - 30)
  promo_date_max <- as.Date(promo_date_max)
  
  if (promo_date_min > promo_date_max) return(NULL)
  
  n_promos <- sample(c(1,2), 1, prob = c(0.87,0.13))
  promo_dates <- sort(sample(seq(promo_date_min, promo_date_max, by = "day"), n_promos))
  
  tibble(
    PromotionEventID = paste0("P", emp$EmployeeID, "_", seq_along(promo_dates)),
    EmployeeID = emp$EmployeeID,
    PromotionDate = promo_dates,
    PriorJobLevel = pmax(emp$JobLevel - 1, 1),
    NewJobLevel = pmin(emp$JobLevel, 10),
    PromotionType = sample(c("In-Level Progression","Promotion"), length(promo_dates), replace = TRUE, prob = c(0.30,0.70))
  )
})

# =========================================================
# fact_performance_reviews
# =========================================================

review_cycles <- as.Date(c("2023-12-31","2024-12-31","2025-12-31"))

fact_performance_reviews <- map_dfr(review_cycles, function(review_date) {
  eligible <- dim_employees %>%
    filter(HireDate <= review_date - 180)
  
  n <- nrow(eligible)
  
  perf_mean <- ifelse(eligible$EmploymentStatus == "Active", 3.45, 3.10)
  rating <- clip_num(round(rnorm(n, mean = perf_mean, sd = 0.75)), 1, 5)
  potential <- clip_num(round(rnorm(n, mean = 3.2, sd = 0.85)), 1, 5)
  
  tibble(
    ReviewID = paste0("R", format(review_date, "%Y"), "_", eligible$EmployeeID),
    EmployeeID = eligible$EmployeeID,
    ReviewDate = review_date,
    PerformanceRating = rating,
    PotentialRating = potential,
    GoalCompletionPct = clip_num(round(rnorm(n, mean = 84, sd = 16)), 25, 100),
    MeritIncreasePct = case_when(
      rating == 5 ~ round(runif(n, 0.050, 0.080), 3),
      rating == 4 ~ round(runif(n, 0.030, 0.050), 3),
      rating == 3 ~ round(runif(n, 0.010, 0.030), 3),
      rating == 2 ~ round(runif(n, 0.000, 0.010), 3),
      TRUE ~ 0.000
    ),
    PromotionRecommended = ifelse(rating >= 4 & eligible$JobLevel <= 4,
                                  sample(c("Yes","No"), n, replace = TRUE, prob = c(0.26,0.74)),
                                  "No")
  )
})

# =========================================================
# fact_engagement_surveys
# =========================================================

survey_cycles <- as.Date(c("2024-03-31","2024-09-30","2025-03-31","2025-09-30"))

fact_engagement_surveys <- map_dfr(survey_cycles, function(survey_date) {
  eligible <- dim_employees %>%
    filter(
      HireDate <= survey_date - 90,
      is.na(TerminationDate) | TerminationDate > survey_date
    )
  
  n <- nrow(eligible)
  
  base_mean <- ifelse(eligible$DepartmentID %in% c(8,10), 3.5, 3.8)
  
  tibble(
    SurveyResponseID = paste0("S", format(survey_date, "%Y%m"), "_", eligible$EmployeeID),
    EmployeeID = eligible$EmployeeID,
    SurveyDate = survey_date,
    EngagementScore = round(clip_num(rnorm(n, base_mean, 0.7), 1.0, 5.0), 1),
    ManagerEffectivenessScore = round(clip_num(rnorm(n, 3.9, 0.6), 1.0, 5.0), 1),
    InclusionScore = round(clip_num(rnorm(n, 4.0, 0.5), 1.0, 5.0), 1),
    IntentToStayScore = round(clip_num(rnorm(n, 3.7, 0.8), 1.0, 5.0), 1),
    SurveyParticipationFlag = "Yes"
  )
})

# =========================================================
# fact_learning_completions
# =========================================================

course_catalog <- tibble(
  CourseID = 1:12,
  CourseName = c(
    "Code of Conduct","Security Awareness","Manager Essentials","Inclusive Leadership",
    "Advanced Excel","Power BI Foundations","Project Management Basics","Customer Experience",
    "Sales Negotiation","HR Compliance","Finance for Managers","Data Literacy"
  ),
  CourseCategory = c(
    "Compliance","Compliance","Leadership","Leadership",
    "Technical","Technical","Business","Business",
    "Business","Compliance","Business","Technical"
  )
)

fact_learning_completions <- map_dfr(seq_len(nrow(dim_employees)), function(i) {
  emp <- dim_employees[i, ]
  
  n_courses <- sample(0:6, 1, prob = c(0.08,0.14,0.21,0.22,0.18,0.11,0.06))
  if (n_courses == 0) return(NULL)
  
  completion_dates <- sort(sample(seq(emp$HireDate, as.Date("2026-03-01"), by = "day"), n_courses))
  selected_courses <- sample(course_catalog$CourseID, n_courses, replace = FALSE)
  
  tibble(
    LearningEventID = paste0("L", emp$EmployeeID, "_", seq_len(n_courses)),
    EmployeeID = emp$EmployeeID,
    CourseID = selected_courses,
    CompletionDate = completion_dates,
    LearningHours = round(runif(n_courses, 0.5, 12), 1),
    CompletionStatus = "Completed"
  )
}) %>%
  left_join(course_catalog, by = "CourseID")

# =========================================================
# fact_leave_events
# =========================================================

leave_prob <- ifelse(dim_employees$EmploymentStatus == "Active", 0.14, 0.10)
leave_flag <- rbinom(nrow(dim_employees), 1, leave_prob)

fact_leave_events <- map_dfr(seq_len(nrow(dim_employees)), function(i) {
  if (leave_flag[i] == 0) return(NULL)
  
  emp <- dim_employees[i, ]
  
  n_leave <- sample(c(1,2), 1, prob = c(0.86,0.14))
  leave_dates <- sort(sample(seq(emp$HireDate, as.Date("2026-02-15"), by = "day"), n_leave))
  
  leave_types <- sample(
    c("Vacation","Sick Leave","Parental Leave","Bereavement","Medical Leave","Jury Duty"),
    n_leave,
    replace = TRUE,
    prob = c(0.40,0.28,0.08,0.05,0.12,0.07)
  )
  
  leave_days <- map_dbl(leave_types, function(x) {
    case_when(
      x == "Vacation" ~ sample(2:10, 1),
      x == "Sick Leave" ~ sample(1:5, 1),
      x == "Parental Leave" ~ sample(20:60, 1),
      x == "Bereavement" ~ sample(2:5, 1),
      x == "Medical Leave" ~ sample(5:40, 1),
      x == "Jury Duty" ~ sample(1:8, 1),
      TRUE ~ sample(1:5, 1)
    )
  })
  
  tibble(
    LeaveEventID = paste0("LV", emp$EmployeeID, "_", seq_len(n_leave)),
    EmployeeID = emp$EmployeeID,
    LeaveType = leave_types,
    LeaveStartDate = leave_dates,
    LeaveEndDate = leave_dates + ceiling(leave_days) - 1,
    LeaveDays = leave_days,
    PaidFlag = ifelse(leave_types %in% c("Vacation","Sick Leave","Bereavement","Jury Duty"), "Yes", sample(c("Yes","No"), n_leave, replace = TRUE, prob = c(0.55,0.45)))
  )
})

# =========================================================
# fact_requisitions
# =========================================================

n_reqs <- 2800

hiring_manager_pool <- dim_employees %>%
  filter(JobLevel >= 3, EmploymentStatus == "Active") %>%
  transmute(EmployeeID, ManagerName = paste(FirstName, LastName), DepartmentID)

req_job_ids <- sample(dim_jobs$JobID, n_reqs, replace = TRUE)
req_open_dates <- random_date(n_reqs, "2024-01-01", "2026-02-15")

fact_requisitions <- tibble(
  RequisitionID = 700001:(700000 + n_reqs),
  JobID = req_job_ids,
  OpenDate = req_open_dates,
  Recruiter = sample(
    c("A. Carter","J. Watson","M. Davis","S. Lee","K. Brown","T. Nguyen","R. Thomas","D. Patel"),
    n_reqs,
    replace = TRUE
  ),
  RequisitionStatus = sample(c("Open","Closed","Cancelled","On Hold"), n_reqs, replace = TRUE, prob = c(0.39,0.47,0.07,0.07)),
  Openings = sample(1:4, n_reqs, replace = TRUE, prob = c(0.74,0.18,0.06,0.02))
) %>%
  left_join(dim_jobs %>% select(JobID, DepartmentID, JobTitle, JobLevel), by = "JobID") %>%
  rowwise() %>%
  mutate(
    HiringManagerID = sample(
      hiring_manager_pool %>% filter(DepartmentID == cur_data()$DepartmentID) %>% pull(EmployeeID),
      1
    )
  ) %>%
  ungroup() %>%
  left_join(
    hiring_manager_pool %>% rename(HiringManagerName = ManagerName),
    by = c("HiringManagerID" = "EmployeeID", "DepartmentID" = "DepartmentID")
  ) %>%
  mutate(
    CloseDate = case_when(
      RequisitionStatus == "Closed" ~ OpenDate + sample(18:95, n(), replace = TRUE),
      RequisitionStatus == "Cancelled" ~ OpenDate + sample(5:40, n(), replace = TRUE),
      RequisitionStatus == "On Hold" ~ OpenDate + sample(8:30, n(), replace = TRUE),
      TRUE ~ as.Date(NA)
    )
  )

# =========================================================
# fact_candidates
# =========================================================

n_candidates <- 24000

candidate_gender <- weighted_sample(gender_pool, n_candidates, prob = gender_probs)
candidate_first <- map_chr(candidate_gender, get_first_name)
candidate_last  <- sample(last_names, n_candidates, replace = TRUE)

candidate_req_ids <- sample(fact_requisitions$RequisitionID, n_candidates, replace = TRUE)
candidate_apply_dates <- random_date(n_candidates, "2024-01-01", "2026-02-20")

fact_candidates <- tibble(
  CandidateID = 500001:(500000 + n_candidates),
  FirstName = candidate_first,
  LastName = candidate_last,
  Gender = candidate_gender,
  RequisitionID = candidate_req_ids,
  ApplicationDate = candidate_apply_dates,
  Source = sample(
    c("LinkedIn","Indeed","Referral","Career Site","Agency","Campus","Internal","Networking Event"),
    n_candidates,
    replace = TRUE,
    prob = c(0.23,0.19,0.14,0.16,0.08,0.07,0.07,0.06)
  ),
  CurrentStage = sample(
    c("Applied","Phone Screen","Interview","Final Interview","Offer Extended","Hired","Rejected","Withdrawn"),
    n_candidates,
    replace = TRUE,
    prob = c(0.19,0.15,0.17,0.11,0.08,0.10,0.16,0.04)
  )
) %>%
  left_join(fact_requisitions %>% select(RequisitionID, JobID, DepartmentID, JobTitle, JobLevel, Recruiter), by = "RequisitionID") %>%
  mutate(
    InterviewScore = ifelse(
      CurrentStage %in% c("Interview","Final Interview","Offer Extended","Hired","Rejected"),
      round(runif(n(), 2.0, 5.0), 1),
      NA_real_
    ),
    OfferAccepted = case_when(
      CurrentStage == "Hired" ~ "Yes",
      CurrentStage == "Offer Extended" ~ sample(c("Pending","No"), n(), replace = TRUE, prob = c(0.66,0.34)),
      TRUE ~ NA_character_
    ),
    DaysToFill = case_when(
      CurrentStage == "Hired" ~ sample(16:92, n(), replace = TRUE),
      CurrentStage == "Offer Extended" ~ sample(12:70, n(), replace = TRUE),
      TRUE ~ NA_integer_
    )
  )

# =========================================================
# fact_headcount_monthly
# =========================================================

snapshot_dates <- seq(as.Date("2024-01-01"), as.Date("2026-03-01"), by = "month")

fact_headcount_monthly <- map_dfr(snapshot_dates, function(snap_date) {
  dim_employees %>%
    filter(
      HireDate <= snap_date,
      is.na(TerminationDate) | TerminationDate > snap_date
    ) %>%
    count(DepartmentID, LocationID, name = "Headcount") %>%
    mutate(SnapshotDate = snap_date)
}) %>%
  left_join(dim_departments %>% select(DepartmentID, DepartmentName), by = "DepartmentID") %>%
  left_join(dim_locations %>% select(LocationID, LocationName, Region), by = "LocationID")

# =========================================================
# Span of control table
# =========================================================

fact_manager_span <- dim_employees %>%
  filter(!is.na(ManagerID)) %>%
  count(ManagerID, name = "DirectReports") %>%
  left_join(
    dim_employees %>%
      transmute(ManagerID = EmployeeID, ManagerName = paste(FirstName, LastName), ManagerDepartmentID = DepartmentID, ManagerJobID = JobID),
    by = "ManagerID"
  )

# =========================================================
# Final cleanup of dim_employees
# =========================================================

dim_employees <- dim_employees %>%
  select(
    EmployeeID, FirstName, LastName, Email, Gender, BirthDate, Age,
    DepartmentID, JobID, JobTitle, JobLevel, LocationID,
    HireDate, TerminationDate, EmploymentStatus, TerminationType,
    WorkerType, EmploymentType, Exempt, FTE, RemoteStatus,
    ManagerID, ManagerName, FinalTenureYears,
    CurrentSalary, CurrentBonusTarget
  )

# =========================================================
# QA checks
# =========================================================

cat("\n====================\n")
cat("ROW COUNTS\n")
cat("====================\n")
cat("dim_locations:", nrow(dim_locations), "\n")
cat("dim_departments:", nrow(dim_departments), "\n")
cat("dim_jobs:", nrow(dim_jobs), "\n")
cat("dim_employees:", nrow(dim_employees), "\n")
cat("dim_employee_demographics:", nrow(dim_employee_demographics), "\n")
cat("fact_employee_current:", nrow(fact_employee_current), "\n")
cat("fact_compensation_history:", nrow(fact_compensation_history), "\n")
cat("fact_promotions:", nrow(fact_promotions), "\n")
cat("fact_performance_reviews:", nrow(fact_performance_reviews), "\n")
cat("fact_engagement_surveys:", nrow(fact_engagement_surveys), "\n")
cat("fact_learning_completions:", nrow(fact_learning_completions), "\n")
cat("fact_leave_events:", nrow(fact_leave_events), "\n")
cat("fact_requisitions:", nrow(fact_requisitions), "\n")
cat("fact_candidates:", nrow(fact_candidates), "\n")
cat("fact_headcount_monthly:", nrow(fact_headcount_monthly), "\n")
cat("fact_manager_span:", nrow(fact_manager_span), "\n")

cat("\n====================\n")
cat("UNIQUE FULL NAMES CHECK\n")
cat("====================\n")
cat("Unique full names:", nrow(dim_employees %>% distinct(FirstName, LastName)), "\n")
cat("Employee rows:", nrow(dim_employees), "\n")

cat("\n====================\n")
cat("TOP 15 LAST NAME COUNTS\n")
cat("====================\n")
print(
  dim_employees %>%
    count(LastName, sort = TRUE) %>%
    slice_head(n = 15)
)

cat("\n====================\n")
cat("EMPLOYMENT STATUS\n")
cat("====================\n")
print(table(dim_employees$EmploymentStatus))

cat("\n====================\n")
cat("SALARY SUMMARY\n")
cat("====================\n")
print(summary(dim_employees$CurrentSalary))

# =========================================================
# Export CSV files
# =========================================================

output_folder <- "synthetic_company_database_v2"
safe_dir_create(output_folder)

write.csv(dim_locations, file.path(output_folder, "dim_locations.csv"), row.names = FALSE)
write.csv(dim_departments, file.path(output_folder, "dim_departments.csv"), row.names = FALSE)
write.csv(dim_jobs, file.path(output_folder, "dim_jobs.csv"), row.names = FALSE)
write.csv(dim_employees, file.path(output_folder, "dim_employees.csv"), row.names = FALSE)
write.csv(dim_employee_demographics, file.path(output_folder, "dim_employee_demographics.csv"), row.names = FALSE)

write.csv(fact_employee_current, file.path(output_folder, "fact_employee_current.csv"), row.names = FALSE)
write.csv(fact_compensation_history, file.path(output_folder, "fact_compensation_history.csv"), row.names = FALSE)
write.csv(fact_promotions, file.path(output_folder, "fact_promotions.csv"), row.names = FALSE)
write.csv(fact_performance_reviews, file.path(output_folder, "fact_performance_reviews.csv"), row.names = FALSE)
write.csv(fact_engagement_surveys, file.path(output_folder, "fact_engagement_surveys.csv"), row.names = FALSE)
write.csv(fact_learning_completions, file.path(output_folder, "fact_learning_completions.csv"), row.names = FALSE)
write.csv(fact_leave_events, file.path(output_folder, "fact_leave_events.csv"), row.names = FALSE)
write.csv(fact_requisitions, file.path(output_folder, "fact_requisitions.csv"), row.names = FALSE)
write.csv(fact_candidates, file.path(output_folder, "fact_candidates.csv"), row.names = FALSE)
write.csv(fact_headcount_monthly, file.path(output_folder, "fact_headcount_monthly.csv"), row.names = FALSE)
write.csv(fact_manager_span, file.path(output_folder, "fact_manager_span.csv"), row.names = FALSE)

cat("\nCSV files exported to folder:", output_folder, "\n")