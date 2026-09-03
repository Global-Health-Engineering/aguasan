# Gantt style xlsx export of the AGUASAN 2027 week schedule and overall timeline.
#
# Input:  exports/aguasan-week-schedule.csv, written by proposal/extract-tables.py
#         from proposal/week-outline-draft.qmd, so the outline stays the single
#         source of truth. Run the extractor first.
# Output: exports/aguasan-week-schedule.xlsx (exports/ is gitignored) with
#         Week      one row per block grouped by day, 30 minute columns from
#                   08:30 to 16:30 plus an Evening column, filled by activity type
#         Timeline  one row per overview row, one column per month, bars from
#                   the month mentions in the "When" text (see parse_months)
#         Data      the CSV as is
# Run from the repo root: Rscript proposal/make-schedule-xlsx.R
# Palette matches demand/make-figures.R (openwashdata/brand).

suppressPackageStartupMessages({
  library(readr); library(dplyr); library(stringr); library(openxlsx)
})

csv <- read_csv("exports/aguasan-week-schedule.csv", show_col_types = FALSE)
names(csv) <- c("section", "when", "what")

# --- palette ---
owd_purple <- "#5b195b"; owd_purple_lt <- "#c8a3c8"; owd_blue <- "#272bd1"
owd_orange <- "#c14a09"; owd_mint <- "#3EB489"; ink <- "#1e1e1e"
grey_mid <- "#6b665e"; grey_lt <- "#d9d4d9"; paper <- "#f5eef5"

fill_style <- function(hex, dark_text = FALSE) {
  createStyle(fgFill = hex, fontColour = if (dark_text) ink else "#ffffff",
              border = "TopBottomLeftRight", borderColour = "#ffffff")
}
head_style <- createStyle(textDecoration = "bold", fgFill = paper, fontColour = ink,
                          halign = "center", valign = "center", wrapText = TRUE,
                          border = "Bottom", borderColour = owd_purple)
day_style  <- createStyle(textDecoration = "bold", fgFill = owd_purple, fontColour = "#ffffff")
wrap_style <- createStyle(wrapText = TRUE, valign = "top")
top_style  <- createStyle(valign = "top")

wb <- createWorkbook()

# ============================================================ Week sheet ===
to_min <- function(x) { p <- as.integer(str_split_fixed(x, ":", 2)); p[1] * 60 + p[2] }
slots <- sprintf("%02d:%02d", rep(8:16, each = 2), rep(c(0, 30), 9))[-1]   # 08:30 .. 16:30
slot_min <- vapply(slots, to_min, numeric(1))

parse_when <- function(w) {
  w <- str_squish(w)
  t <- str_extract_all(w, "\\d{1,2}:\\d{2}")[[1]]
  if (str_detect(w, "\\d{1,2}:\\d{2} to \\d{1,2}:\\d{2}"))   # a range anywhere in the text
    return(list(kind = "block", start = to_min(t[1]), end = to_min(t[2])))
  if (str_detect(w, "^Until \\d{1,2}:\\d{2}$"))
    return(list(kind = "block", start = to_min("08:30"), end = to_min(t[1])))
  if (str_detect(w, "^\\d{1,2}:\\d{2} to lunch$"))
    return(list(kind = "block", start = to_min(t[1]), end = to_min("12:00")))
  if (w == "Morning") return(list(kind = "block", start = to_min("09:00"), end = to_min("12:00")))
  if (w == "Evening") return(list(kind = "evening", start = NA, end = NA))
  if (str_detect(w, "^\\d{1,2}:\\d{2}$")) return(list(kind = "marker", start = to_min(t[1]), end = to_min(t[1])))
  list(kind = "unparsed", start = NA, end = NA)
}

activity_type <- function(what) {
  case_when(
    str_detect(what, "Opening|Closing|Arrival|^Close")                       ~ "Opening and closing",
    str_detect(what, "Excursion|[Ww]alk|fire")                                ~ "Retreat",
    str_detect(what, "^Work session|project work|^Data project")              ~ "Project work",
    str_detect(what, "[Cc]ase stud|share their")                              ~ "Case studies and presentations",
    str_detect(what, "module|Foundations|workshop|FAIR|Agentic AI|Quarto|AI session|Data management strategy") ~ "Taught module",
    TRUE                                                                      ~ "Other"
  )
}
type_fill <- c("Taught module" = owd_purple, "Project work" = owd_purple_lt,
               "Case studies and presentations" = owd_blue, "Retreat" = owd_mint,
               "Opening and closing" = owd_orange, "Other" = grey_lt)
type_dark <- c("Taught module" = FALSE, "Project work" = TRUE,
               "Case studies and presentations" = FALSE, "Retreat" = TRUE,
               "Opening and closing" = FALSE, "Other" = TRUE)

week <- csv %>% filter(section != "Timeline (overview)") %>% mutate(type = activity_type(what))
days <- unique(week$section)

addWorksheet(wb, "Week", gridLines = FALSE)
hdr <- c("Time", "Block", slots, "Evening")
ncol_w <- length(hdr)
writeData(wb, "Week", matrix(hdr, nrow = 1), colNames = FALSE, startRow = 1)
addStyle(wb, "Week", head_style, rows = 1, cols = seq_len(ncol_w))
setRowHeights(wb, "Week", rows = 1, heights = 30)

r <- 2
unparsed <- character(0)
for (d in days) {
  writeData(wb, "Week", d, startRow = r, startCol = 1, colNames = FALSE)
  mergeCells(wb, "Week", cols = seq_len(ncol_w), rows = r)
  addStyle(wb, "Week", day_style, rows = r, cols = seq_len(ncol_w))
  r <- r + 1
  rows <- week %>% filter(section == d)
  for (i in seq_len(nrow(rows))) {
    writeData(wb, "Week", matrix(c(rows$when[i], rows$what[i]), nrow = 1), startRow = r, startCol = 1, colNames = FALSE)
    addStyle(wb, "Week", top_style,  rows = r, cols = 1)
    addStyle(wb, "Week", wrap_style, rows = r, cols = 2)
    p <- parse_when(rows$when[i])
    st <- fill_style(type_fill[[rows$type[i]]], type_dark[[rows$type[i]]])
    if (p$kind == "block") {
      cols <- which(slot_min >= p$start & slot_min < p$end) + 2
      if (length(cols)) addStyle(wb, "Week", st, rows = r, cols = cols)
    } else if (p$kind == "marker") {
      cols <- which(slot_min == p$start) + 2
      if (length(cols)) addStyle(wb, "Week", fill_style(ink), rows = r, cols = cols)
    } else if (p$kind == "evening") {
      addStyle(wb, "Week", st, rows = r, cols = ncol_w)
    } else {
      unparsed <- c(unparsed, rows$when[i])
    }
    r <- r + 1
  }
}
# legend
r <- r + 1
writeData(wb, "Week", "Legend", startRow = r, startCol = 2, colNames = FALSE)
addStyle(wb, "Week", createStyle(textDecoration = "bold"), rows = r, cols = 2)
for (nm in names(type_fill)) {
  r <- r + 1
  addStyle(wb, "Week", fill_style(type_fill[[nm]], type_dark[[nm]]), rows = r, cols = 1)
  writeData(wb, "Week", nm, startRow = r, startCol = 2, colNames = FALSE)
}
r <- r + 1
addStyle(wb, "Week", fill_style(ink), rows = r, cols = 1)
writeData(wb, "Week", "Close", startRow = r, startCol = 2, colNames = FALSE)

setColWidths(wb, "Week", cols = 1, widths = 16)
setColWidths(wb, "Week", cols = 2, widths = 64)
setColWidths(wb, "Week", cols = 3:(ncol_w - 1), widths = 5.2)
setColWidths(wb, "Week", cols = ncol_w, widths = 9)
freezePane(wb, "Week", firstActiveRow = 2, firstActiveCol = 3)
if (length(unparsed)) warning("Week rows with unparsed times (no bar drawn): ", paste(unparsed, collapse = "; "))

# ======================================================== Timeline sheet ===
month_rx <- "\\b(jan(?:uary)?|feb(?:ruary)?|mar(?:ch)?|apr(?:il)?|may|jun(?:e)?|jul(?:y)?|aug(?:ust)?|sep(?:t(?:ember)?)?|oct(?:ober)?|nov(?:ember)?|dec(?:ember)?)\\b\\.?\\s*(\\d{4})?"
season_rx <- "(autumn|winter|spring|summer)\\s+(\\d{4})"
seasons <- list(autumn = c(10, 11), winter = c(12, 2), spring = c(3, 5), summer = c(6, 8))
month_no <- function(m) match(substr(m, 1, 3), c("jan","feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec"))
ym <- function(y, m) as.Date(sprintf("%d-%02d-01", as.integer(y), as.integer(m)))

# Returns a list of c(start, end) month pairs for one "When" string.
# Rule: a season with a year spans its months (winter rolls into the next year);
# otherwise every month mention becomes a point, months without a year borrow
# the nearest year in the string; " and " or " or " join separate bars, anything else is
# one bar from the earliest to the latest month.
parse_months <- function(w) {
  wl <- tolower(w)
  s <- str_match(wl, season_rx)
  if (!is.na(s[1, 1])) {
    mm <- seasons[[s[1, 2]]]; y <- as.integer(s[1, 3])
    return(list(c(ym(y, mm[1]), ym(if (mm[2] < mm[1]) y + 1 else y, mm[2]))))
  }
  m <- str_match_all(wl, month_rx)[[1]]
  if (!nrow(m)) return(list())
  mon <- month_no(m[, 2]); yr <- suppressWarnings(as.integer(m[, 3]))
  if (all(is.na(yr))) return(list())
  for (i in which(is.na(yr))) { cand <- which(!is.na(yr)); yr[i] <- yr[cand[which.min(abs(cand - i))]] }
  pts <- sort(unique(ym(yr, mon)))
  if (str_detect(wl, "\\b(and|or)\\b")) lapply(pts, function(p) c(p, p)) else list(c(min(pts), max(pts)))
}

phase_of <- function(what) {
  case_when(
    str_detect(what, "Outreach")                                            ~ "Outreach",
    str_detect(what, "[Pp]articipant selection|Screening|Submission due")   ~ "Selection",
    str_detect(what, "SNSF|[Bb]udget|grant")                                ~ "Funding",
    str_detect(what, "Precourse")                                           ~ "Precourse",
    str_detect(what, "Workshop week")                                       ~ "Event",
    str_detect(what, "ds4owd|Data Science for openwashdata|[Ee]valuation|report|monitoring|article|conference") ~ "Follow-up",
    TRUE                                                                    ~ "Organisers"
  )
}
phase_fill <- c(Organisers = owd_purple_lt, Outreach = owd_blue, Selection = owd_purple,
                Funding = owd_orange, Precourse = owd_mint, Event = ink, "Follow-up" = grey_mid)
phase_dark <- c(Organisers = TRUE, Outreach = FALSE, Selection = FALSE,
                Funding = FALSE, Precourse = TRUE, Event = FALSE, "Follow-up" = FALSE)

tl <- csv %>% filter(section == "Timeline (overview)") %>% mutate(phase = phase_of(what))
bars <- lapply(tl$when, parse_months)
all_dates <- do.call(c, unlist(bars, recursive = FALSE))
m_start <- as.Date("2026-09-01")
m_end   <- max(c(as.Date("2027-10-01"), all_dates))
months  <- seq(m_start, m_end, by = "month")
mlab    <- format(months, "%b %Y")

addWorksheet(wb, "Timeline", gridLines = FALSE)
hdr_t <- c("When", "What", mlab)
ncol_t <- length(hdr_t)
writeData(wb, "Timeline", matrix(hdr_t, nrow = 1), colNames = FALSE, startRow = 1)
addStyle(wb, "Timeline", head_style, rows = 1, cols = seq_len(ncol_t))
addStyle(wb, "Timeline", createStyle(textDecoration = "bold", fgFill = paper, fontColour = ink,
                                     textRotation = 90, halign = "center", valign = "bottom",
                                     border = "Bottom", borderColour = owd_purple),
         rows = 1, cols = 3:ncol_t)
setRowHeights(wb, "Timeline", rows = 1, heights = 62)
unmapped <- character(0)
for (i in seq_len(nrow(tl))) {
  r <- i + 1
  writeData(wb, "Timeline", matrix(c(tl$when[i], tl$what[i]), nrow = 1), startRow = r, startCol = 1, colNames = FALSE)
  addStyle(wb, "Timeline", wrap_style, rows = r, cols = 1:2)
  st <- fill_style(phase_fill[[tl$phase[i]]], phase_dark[[tl$phase[i]]])
  if (!length(bars[[i]])) { unmapped <- c(unmapped, tl$when[i]); next }
  for (b in bars[[i]]) {
    cols <- which(months >= b[1] & months <= b[2]) + 2
    if (length(cols)) addStyle(wb, "Timeline", st, rows = r, cols = cols)
  }
}
r <- nrow(tl) + 3
writeData(wb, "Timeline", "Legend", startRow = r, startCol = 2, colNames = FALSE)
addStyle(wb, "Timeline", createStyle(textDecoration = "bold"), rows = r, cols = 2)
for (nm in names(phase_fill)) {
  r <- r + 1
  addStyle(wb, "Timeline", fill_style(phase_fill[[nm]], phase_dark[[nm]]), rows = r, cols = 1)
  writeData(wb, "Timeline", nm, startRow = r, startCol = 2, colNames = FALSE)
}
setColWidths(wb, "Timeline", cols = 1, widths = 30)
setColWidths(wb, "Timeline", cols = 2, widths = 70)
setColWidths(wb, "Timeline", cols = 3:ncol_t, widths = 4.2)
freezePane(wb, "Timeline", firstActiveRow = 2, firstActiveCol = 3)
if (length(unmapped)) warning("Timeline rows without a month mention (no bar drawn): ", paste(unmapped, collapse = "; "))

# ============================================================ Data sheet ===
addWorksheet(wb, "Data")
writeData(wb, "Data", csv, headerStyle = head_style)
setColWidths(wb, "Data", cols = 1:3, widths = c(20, 34, 100))
addStyle(wb, "Data", wrap_style, rows = 2:(nrow(csv) + 1), cols = 3)

out <- "exports/aguasan-week-schedule.xlsx"
saveWorkbook(wb, out, overwrite = TRUE)
cat(sprintf("  %s  (Week: %d blocks over %d days; Timeline: %d rows over %d months; Data: %d rows)\n",
            out, nrow(week), length(days), nrow(tl), length(months), nrow(csv)))
