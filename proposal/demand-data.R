# Data preparation for proposal/demand-analysis.qmd.
#
# Reads the de-identified ds4owd pre-course and registration survey extracts
# (../demand/data/, gitignored) and builds one tidy data frame per figure.
# No plotting here: every figure is a ggplot chunk in the qmd, which sources
# this file from its setup chunk. Paths are relative to proposal/, the working
# directory when Quarto renders the document; run it standalone from proposal/
# in the same way.
#
# Comparable questions are compared by cohort (ds4owd-001 vs ds4owd-002);
# the richer AI questions exist only in 002.

suppressPackageStartupMessages({
  library(readr); library(dplyr); library(tidyr); library(forcats); library(stringr)
})

s1 <- read_csv("../demand/data/ds4owd-001-presurvey.csv", show_col_types = FALSE)
s2 <- read_csv("../demand/data/ds4owd-002-registration-deidentified.csv", show_col_types = FALSE)
n1 <- nrow(s1); n2 <- nrow(s2)

# ---- programming experience, both cohorts ---------------------------------
prog_levels <- c("None", "A few lines", "Own use", "Maintained\nsoftware")
d_prog <- bind_rows(
  s1 |> mutate(lvl = case_when(
    str_detect(prog_exp, "none")                   ~ "None",
    str_detect(prog_exp, "few lines")              ~ "A few lines",
    str_detect(prog_exp, "for my own use|own use") ~ "Own use",
    str_detect(prog_exp, "maintained")             ~ "Maintained\nsoftware"),
    cohort = "ds4owd-001") |> select(cohort, lvl),
  s2 |> mutate(lvl = recode(trimws(prog_general),
                            none = "None", few_lines = "A few lines",
                            own_use = "Own use", maintained = "Maintained\nsoftware"),
               cohort = "ds4owd-002") |> select(cohort, lvl)) |>
  filter(!is.na(lvl)) |>
  count(cohort, lvl) |>
  group_by(cohort) |> mutate(pct = 100 * n / sum(n)) |> ungroup() |>
  mutate(lvl = factor(lvl, levels = prog_levels))

# ---- data format, both cohorts ----------------------------------------------
fmt_levels <- c("Spreadsheet", "Machine-readable", "Database", "Paper", "Other")
classify_fmt <- function(x) case_when(
  str_detect(x, regex("spreadsheet", ignore_case = TRUE))             ~ "Spreadsheet",
  str_detect(x, regex("machine|csv|json", ignore_case = TRUE))        ~ "Machine-readable",
  str_detect(x, regex("relational|sql|database", ignore_case = TRUE)) ~ "Database",
  str_detect(x, regex("paper|notebook", ignore_case = TRUE))          ~ "Paper",
  TRUE                                                                ~ "Other")
d_fmt <- bind_rows(
  tibble(cohort = "ds4owd-001", fmt = classify_fmt(s1$data_format)),
  tibble(cohort = "ds4owd-002", fmt = classify_fmt(s2$data_format))) |>
  count(cohort, fmt) |>
  group_by(cohort) |> mutate(pct = 100 * n / sum(n)) |> ungroup() |>
  mutate(fmt = factor(fmt, levels = fmt_levels))

# ---- organisation type, both cohorts ----------------------------------------
org_levels <- c("NGO", "Academia", "Government", "Consultant", "Private sector")
d_org <- bind_rows(
  tibble(cohort = "ds4owd-001", org = recode(trimws(s1$work_organisation),
    `NGO (non-governmental organisation)` = "NGO", Academia = "Academia",
    Government = "Government", `Independent consultant` = "Consultant",
    `Private sector` = "Private sector")),
  s2 |>
    filter(!(is.na(org_type) | org_type %in% c("", "NA"))) |>
    transmute(cohort = "ds4owd-002", org = recode(trimws(org_type),
      ngo = "NGO", academia = "Academia", government = "Government",
      independent_consultant = "Consultant", private_sector = "Private sector",
      multilateral = "Other", other = "Other"))) |>
  filter(org %in% org_levels) |>
  count(cohort, org) |>
  group_by(cohort) |> mutate(pct = 100 * n / sum(n)) |> ungroup() |>
  mutate(org = factor(org, levels = rev(org_levels)))

# ---- LLM adoption, 001 (asked directly) vs 002 (any platform) --------------
d_llm <- bind_rows(
  tibble(cohort = "ds4owd-001",
         uses = ifelse(str_detect(s1$current_use_llm, "not used"), "No", "Yes")),
  s2 |>
    mutate(uses = ifelse(llm_platforms_none == 1 |
                         rowSums(across(starts_with("llm_platforms_") &
                                        !any_of("llm_platforms_none")), na.rm = TRUE) == 0,
                         "No", "Yes")) |>
    transmute(cohort = "ds4owd-002", uses)) |>
  count(cohort, uses) |>
  group_by(cohort) |> mutate(pct = 100 * n / sum(n)) |> ungroup() |>
  filter(uses == "Yes")

# ---- LLM platforms, 002 -----------------------------------------------------
plat_lbl <- c(chatgpt = "ChatGPT", gemini = "Gemini", copilot_365 = "Copilot (365)",
              deepseek = "DeepSeek", perplexity = "Perplexity", claude = "Claude",
              notebooklm = "NotebookLM", copilot_ide = "Copilot (IDE)",
              grok = "Grok", claude_code = "Claude Code")
d_plat <- tibble(
  platform = names(plat_lbl),
  n = sapply(names(plat_lbl), \(p) sum(s2[[paste0("llm_platforms_", p)]] == 1, na.rm = TRUE))) |>
  mutate(label = plat_lbl[platform], pct = round(100 * n / n2),
         label = fct_reorder(label, n))

# ---- LLM use by task, 002 ---------------------------------------------------
task_lbl <- c(llm_summarization = "Summarization", llm_translation = "Translation",
              llm_qa = "Q&A / search", llm_learning = "Learning",
              llm_content_gen = "Content generation", llm_data_analysis = "Data analysis",
              llm_coding = "Coding", llm_conversation = "Conversation",
              llm_automation = "Automation")
use_levels <- c("never", "occasional", "regular", "rely")
d_task <- lapply(names(task_lbl), function(col) {
  tibble(task = task_lbl[col], level = trimws(as.character(s2[[col]]))) }) |>
  bind_rows() |>
  filter(level %in% use_levels) |>
  count(task, level) |>
  group_by(task) |> mutate(pct = 100 * n / sum(n),
                           uses = sum(pct[level != "never"])) |> ungroup() |>
  mutate(level = factor(level, levels = rev(use_levels)),
         task = fct_reorder(task, uses))

# ---- registrations, both cohorts --------------------------------------------
d_grow <- tibble(cohort = factor(c("ds4owd-001", "ds4owd-002"),
                                 levels = c("ds4owd-001", "ds4owd-002")),
                 registrations = c(n1, n2))

# ---- country of residence, 002 (001 did not capture country cleanly) --------
iso_name <- c(NGA = "Nigeria", CHE = "Switzerland", UGA = "Uganda", GHA = "Ghana",
              ETH = "Ethiopia", MWI = "Malawi", ZAF = "South Africa", USA = "United States",
              KEN = "Kenya", DEU = "Germany", FRA = "France", IND = "India", CAN = "Canada",
              GBR = "United Kingdom", NLD = "Netherlands", BOL = "Bolivia")
n_countries <- s2 |> mutate(c = trimws(country_residence)) |>
  filter(c != "", !is.na(c)) |> distinct(c) |> nrow()
d_ctry <- s2 |>
  mutate(c = trimws(country_residence)) |>
  filter(c != "", !is.na(c)) |>
  count(c, sort = TRUE) |>
  slice_head(n = 15) |>
  mutate(name = coalesce(iso_name[c], c), name = fct_reorder(name, n))

# ---- age band as a career-stage proxy, 002 ----------------------------------
# The survey has no seniority, role, or leadership field yet
# (ds4owd-dev/pre-course-survey#5); age is the closest available signal.
age_lbl <- c(`18_24` = "18-24", `25_34` = "25-34", `35_44` = "35-44",
             `45_54` = "45-54", `55_64` = "55-64", `65_or_older` = "65+",
             prefer_not_to_say_age = "Prefer not to say")
age_order <- c("18-24", "25-34", "35-44", "45-54", "55-64", "65+", "Prefer not to say")
d_age <- s2 |>
  mutate(a = age_lbl[trimws(age_group)]) |>
  filter(!is.na(a)) |>
  count(a) |>
  mutate(pct = round(100 * n / sum(n)),
         a = factor(a, levels = rev(age_order)))
