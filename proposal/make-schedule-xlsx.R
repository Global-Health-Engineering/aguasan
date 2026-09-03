# Single-sheet xlsx of the week schedule, for sharing.
# Input:  proposal/week-schedule.csv (written by proposal/extract-tables.py)
# Output: proposal/week-schedule.xlsx, one sheet with the same rows
# Run from the repo root after the extractor: Rscript proposal/make-schedule-xlsx.R

suppressPackageStartupMessages({ library(readr); library(openxlsx) })

csv <- read_csv("proposal/week-schedule.csv", show_col_types = FALSE)
wb <- createWorkbook()
addWorksheet(wb, "Schedule")
writeData(wb, "Schedule", csv,
          headerStyle = createStyle(textDecoration = "bold", fgFill = "#f5eef5",
                                    border = "Bottom", borderColour = "#5b195b"))
addStyle(wb, "Schedule", createStyle(wrapText = TRUE, valign = "top"),
         rows = 2:(nrow(csv) + 1), cols = 1:3, gridExpand = TRUE)
setColWidths(wb, "Schedule", cols = 1:3, widths = c(20, 40, 110))
freezePane(wb, "Schedule", firstRow = TRUE)
saveWorkbook(wb, "proposal/week-schedule.xlsx", overwrite = TRUE)
cat(sprintf("  week-schedule.xlsx  (%d rows)\n", nrow(csv)))
