# Demand-analysis figures for the AGUASAN 2027 openwashdata bid.
# Reads the de-identified ds4owd pre-course / registration survey extracts
# (demand/data/, gitignored) and writes aggregate figures to demand/figures/.
# Palette matches the pitch deck (openwashdata/brand): owd-purple #5b195b.
#
# Comparable questions are faceted/dodged by cohort (ds4owd-001 vs -002);
# richer AI/LLM questions exist only in 002 and get their own figures.

suppressPackageStartupMessages({
  library(readr); library(dplyr); library(ggplot2); library(tidyr); library(forcats); library(stringr)
})

# --- brand palette (openwashdata/brand, same as slides/custom.scss) ---
owd_purple      <- "#5b195b"
owd_purple_dark <- "#2d0e2d"
owd_purple_lt   <- "#c8a3c8"
owd_blue        <- "#272bd1"
owd_orange      <- "#c14a09"
owd_mint        <- "#3EB489"
ink             <- "#1e1e1e"
paper           <- "#f5eef5"
cohort_cols     <- c(`ds4owd-001` = owd_purple_lt, `ds4owd-002` = owd_purple)

theme_owd <- function(base_size = 15) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.background  = element_rect(fill = paper, colour = NA),
      panel.background = element_rect(fill = paper, colour = NA),
      panel.grid.minor = element_blank(),
      panel.grid.major.y = element_blank(),
      text = element_text(colour = ink),
      plot.title = element_text(face = "bold", colour = owd_purple_dark, size = base_size + 3),
      plot.subtitle = element_text(colour = "#6b665e"),
      legend.position = "top", legend.title = element_blank(),
      strip.text = element_text(face = "bold", colour = owd_purple_dark),
      axis.text = element_text(colour = ink),
      plot.title.position = "plot"
    )
}
save_fig <- function(p, name, w = 8, h = 4.8) {
  ggsave(file.path("demand/figures", name), p, width = w, height = h, dpi = 150, bg = paper)
}

s1 <- read_csv("demand/data/ds4owd-001-presurvey.csv", show_col_types = FALSE)
s2 <- read_csv("demand/data/ds4owd-002-registration-deidentified.csv", show_col_types = FALSE)
n1 <- nrow(s1); n2 <- nrow(s2)

# ============================================================
# FACETED CROSS-COHORT FIGURES (same question, both cohorts)
# ============================================================

# ---- 1. Programming experience, dodged by cohort (percent within cohort) ----
prog_levels <- c("None", "A few lines", "Own use", "Maintained\nsoftware")
d1_prog <- s1 |>
  mutate(lvl = case_when(
    str_detect(prog_exp, "none")                     ~ "None",
    str_detect(prog_exp, "few lines")                ~ "A few lines",
    str_detect(prog_exp, "for my own use|own use")   ~ "Own use",
    str_detect(prog_exp, "maintained")               ~ "Maintained\nsoftware"),
    cohort = "ds4owd-001")
d2_prog <- s2 |>
  mutate(lvl = recode(trimws(prog_general),
                      none = "None", few_lines = "A few lines",
                      own_use = "Own use", maintained = "Maintained\nsoftware"),
         cohort = "ds4owd-002")
d_prog <- bind_rows(select(d1_prog, cohort, lvl), select(d2_prog, cohort, lvl)) |>
  filter(!is.na(lvl)) |>
  count(cohort, lvl) |>
  group_by(cohort) |> mutate(pct = 100 * n / sum(n)) |> ungroup() |>
  mutate(lvl = factor(lvl, levels = prog_levels))
p_prog <- ggplot(d_prog, aes(lvl, pct, fill = cohort)) +
  geom_col(position = position_dodge(0.72), width = 0.66) +
  geom_text(aes(label = paste0(round(pct), "%")),
            position = position_dodge(0.72), vjust = -0.3, size = 3.8, colour = ink) +
  scale_fill_manual(values = cohort_cols) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.12))) +
  labs(title = "They arrive as beginners, in both cohorts",
       subtitle = paste0("Programming experience at sign-up (ds4owd-001 n=", n1,
                         ", ds4owd-002 n=", n2, ")"),
       x = NULL, y = "% of cohort") +
  theme_owd()
save_fig(p_prog, "01-skill-by-cohort.png")

# ---- 2. Data format, dodged by cohort ----
fmt_levels <- c("Spreadsheet", "Machine-readable", "Database", "Paper", "Other")
classify_fmt <- function(x) case_when(
  str_detect(x, regex("spreadsheet", ignore_case = TRUE))            ~ "Spreadsheet",
  str_detect(x, regex("machine|csv|json", ignore_case = TRUE))       ~ "Machine-readable",
  str_detect(x, regex("relational|sql|database", ignore_case = TRUE))~ "Database",
  str_detect(x, regex("paper|notebook", ignore_case = TRUE))         ~ "Paper",
  TRUE                                                               ~ "Other")
d_fmt <- bind_rows(
  tibble(cohort = "ds4owd-001", fmt = classify_fmt(s1$data_format)),
  tibble(cohort = "ds4owd-002", fmt = classify_fmt(s2$data_format))) |>
  count(cohort, fmt) |>
  group_by(cohort) |> mutate(pct = 100 * n / sum(n)) |> ungroup() |>
  mutate(fmt = factor(fmt, levels = fmt_levels))
p_fmt <- ggplot(d_fmt, aes(fmt, pct, fill = cohort)) +
  geom_col(position = position_dodge(0.72), width = 0.66) +
  geom_text(aes(label = paste0(round(pct), "%")),
            position = position_dodge(0.72), vjust = -0.3, size = 3.8, colour = ink) +
  scale_fill_manual(values = cohort_cols) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.12))) +
  labs(title = "Their data starts in spreadsheets",
       subtitle = "Where registrants store data now (~70% spreadsheets in both cohorts)",
       x = NULL, y = "% of cohort") +
  theme_owd()
save_fig(p_fmt, "02-dataformat-by-cohort.png")

# ---- 3. Organisation type, dodged by cohort ----
org_levels <- c("NGO", "Academia", "Government", "Consultant", "Private sector")
d1_org <- tibble(cohort = "ds4owd-001", org = recode(trimws(s1$work_organisation),
  `NGO (non-governmental organisation)` = "NGO", Academia = "Academia",
  Government = "Government", `Independent consultant` = "Consultant",
  `Private sector` = "Private sector"))
d2_org <- s2 |>
  filter(!(is.na(org_type) | org_type %in% c("", "NA"))) |>
  transmute(cohort = "ds4owd-002", org = recode(trimws(org_type),
    ngo = "NGO", academia = "Academia", government = "Government",
    independent_consultant = "Consultant", private_sector = "Private sector",
    multilateral = "Other", other = "Other"))
d_org <- bind_rows(d1_org, d2_org) |>
  filter(org %in% org_levels) |>
  count(cohort, org) |>
  group_by(cohort) |> mutate(pct = 100 * n / sum(n)) |> ungroup() |>
  mutate(org = factor(org, levels = rev(org_levels)))
p_org <- ggplot(d_org, aes(pct, org, fill = cohort)) +
  geom_col(position = position_dodge(0.72), width = 0.66) +
  scale_fill_manual(values = cohort_cols) +
  scale_x_continuous(expand = expansion(mult = c(0, 0.1))) +
  labs(title = "Demand is cross-sector, in both cohorts",
       subtitle = "NGO, academia, government, consulting and private sector all sign up",
       x = "% of cohort (org type answered)", y = NULL) +
  theme_owd()
save_fig(p_org, "03-sector-by-cohort.png")

# ============================================================
# COHORT SHIFT: LLM adoption 001 -> 002
# ============================================================

# ---- 4. Overall LLM adoption, 001 (asked directly) vs 002 (any platform) ----
d1_llm <- tibble(cohort = "ds4owd-001",
  uses = ifelse(str_detect(s1$current_use_llm, "not used"), "No", "Yes"))
d2_any <- s2 |>
  mutate(uses = ifelse(llm_platforms_none == 1 |
                       rowSums(across(starts_with("llm_platforms_") &
                                      !any_of("llm_platforms_none")), na.rm = TRUE) == 0,
                       "No", "Yes")) |>
  transmute(cohort = "ds4owd-002", uses)
d_llm <- bind_rows(d1_llm, d2_any) |>
  count(cohort, uses) |>
  group_by(cohort) |> mutate(pct = 100 * n / sum(n)) |> ungroup() |>
  filter(uses == "Yes")
p_llm <- ggplot(d_llm, aes(cohort, pct, fill = cohort)) +
  geom_col(width = 0.55, show.legend = FALSE) +
  geom_text(aes(label = paste0(round(pct), "%")), vjust = -0.35, size = 5,
            fontface = "bold", colour = ink) +
  scale_fill_manual(values = cohort_cols) +
  scale_y_continuous(limits = c(0, 100), expand = expansion(mult = c(0, 0.08))) +
  labs(title = "AI adoption jumped between cohorts",
       subtitle = "Share using at least one LLM tool: 56% (ds4owd-001) to 96% (ds4owd-002)",
       x = NULL, y = "% of cohort using an LLM") +
  theme_owd() + theme(panel.grid.major.x = element_blank())
save_fig(p_llm, "04-llm-adoption-shift.png", w = 6, h = 4.6)

# ============================================================
# 002-ONLY AI/LLM DETAIL (richer questions)
# ============================================================

# ---- 5. Which LLM platforms (002), top platforms by count ----
plat_lbl <- c(chatgpt="ChatGPT", gemini="Gemini", copilot_365="Copilot (365)",
              deepseek="DeepSeek", perplexity="Perplexity", claude="Claude",
              notebooklm="NotebookLM", copilot_ide="Copilot (IDE)",
              grok="Grok", claude_code="Claude Code")
d_plat <- tibble(
  platform = names(plat_lbl),
  n = sapply(names(plat_lbl), \(p) sum(s2[[paste0("llm_platforms_", p)]] == 1, na.rm = TRUE))) |>
  mutate(label = plat_lbl[platform], pct = round(100 * n / n2),
         label = fct_reorder(label, n))
p_plat <- ggplot(d_plat, aes(n, label)) +
  geom_col(fill = owd_purple, width = 0.7) +
  geom_text(aes(label = paste0(n, "  (", pct, "%)")), hjust = -0.12, size = 3.8, colour = ink) +
  scale_x_continuous(expand = expansion(mult = c(0, 0.2))) +
  labs(title = "ChatGPT dominates; assistants are consumer-grade",
       subtitle = paste0("LLM platforms used by ds4owd-002 registrants (n=", n2, "), top 10"),
       x = NULL, y = NULL) +
  theme_owd(base_size = 14)
save_fig(p_plat, "05-llm-platforms.png", h = 5)

# ---- 6. What they use LLMs FOR (002), ordinal, stacked ----
task_lbl <- c(llm_summarization="Summarization", llm_translation="Translation",
              llm_qa="Q&A / search", llm_learning="Learning",
              llm_content_gen="Content generation", llm_data_analysis="Data analysis",
              llm_coding="Coding", llm_conversation="Conversation",
              llm_automation="Automation")
use_levels <- c("never", "occasional", "regular", "rely")
use_fill   <- c(never="#d8ccd8", occasional=owd_purple_lt, regular=owd_purple, rely=owd_purple_dark)
d_task <- lapply(names(task_lbl), function(col) {
  tibble(task = task_lbl[col], level = trimws(as.character(s2[[col]]))) }) |>
  bind_rows() |>
  filter(level %in% use_levels) |>
  count(task, level) |>
  group_by(task) |> mutate(pct = 100 * n / sum(n),
    uses = sum(pct[level != "never"])) |> ungroup() |>
  mutate(level = factor(level, levels = rev(use_levels)),
         task = fct_reorder(task, uses))
p_task <- ggplot(d_task, aes(pct, task, fill = level)) +
  geom_col(width = 0.72) +
  scale_fill_manual(values = use_fill, breaks = use_levels,
                    labels = c("Never","Occasional","Regular","Rely on it")) +
  scale_x_continuous(expand = expansion(mult = c(0, 0.02))) +
  labs(title = "They use AI for words, not yet for code and data",
       subtitle = paste0("How ds4owd-002 registrants use LLMs by task (n=", n2,
                         "); coding and data analysis lag"),
       x = "% of cohort", y = NULL) +
  theme_owd(base_size = 14)
save_fig(p_task, "06-llm-tasks.png", h = 5.2)

# ---- 7. Registrations growth (unchanged, both cohorts) ----
d_grow <- tibble(cohort = factor(c("ds4owd-001", "ds4owd-002"),
                                 levels = c("ds4owd-001","ds4owd-002")),
                 registrations = c(n1, n2))
p_grow <- ggplot(d_grow, aes(cohort, registrations, fill = cohort)) +
  geom_col(width = 0.55, show.legend = FALSE) +
  geom_text(aes(label = registrations), vjust = -0.4, size = 5, fontface = "bold", colour = ink) +
  scale_fill_manual(values = cohort_cols) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  labs(title = "Two cohorts, 421 registrations",
       subtitle = "Sustained demand across the two ds4owd iterations",
       x = NULL, y = NULL) +
  theme_owd() + theme(panel.grid.major.x = element_blank())
save_fig(p_grow, "07-growth.png", w = 6, h = 4.4)

# ---- 8. Global reach (ds4owd-002 country of residence, ranked bar, top 15) ----
# 002-only: 001 did not capture country cleanly.
iso_name <- c(NGA="Nigeria", CHE="Switzerland", UGA="Uganda", GHA="Ghana",
              ETH="Ethiopia", MWI="Malawi", ZAF="South Africa", USA="United States",
              KEN="Kenya", DEU="Germany", FRA="France", IND="India", CAN="Canada",
              GBR="United Kingdom", NLD="Netherlands", BOL="Bolivia")
n_countries <- s2 |> mutate(c = trimws(country_residence)) |>
  filter(c != "", !is.na(c)) |> distinct(c) |> nrow()
d_ctry <- s2 |>
  mutate(c = trimws(country_residence)) |>
  filter(c != "", !is.na(c)) |>
  count(c, sort = TRUE) |>
  slice_head(n = 15) |>
  mutate(name = coalesce(iso_name[c], c), name = fct_reorder(name, n))
p_ctry <- ggplot(d_ctry, aes(n, name)) +
  geom_col(fill = owd_purple, width = 0.7) +
  geom_text(aes(label = n), hjust = -0.3, size = 4, colour = ink) +
  scale_x_continuous(expand = expansion(mult = c(0, 0.12))) +
  labs(title = "A global, Global-South-led audience",
       subtitle = paste0(n2, " ds4owd-002 registrants from ", n_countries,
                         " countries (~64% Global South); top 15 shown"),
       x = NULL, y = NULL) +
  theme_owd(base_size = 14)
save_fig(p_ctry, "08-geography.png", h = 5.2)

cat("Wrote 8 figures to demand/figures/\n")
