library(reactable)
library(htmltools)

#Test 1 Overall testing for react_disposition function
test_that("Testing react_disposition function", {
  
  table <- react_disposition(
    metadata_sl = meta_sl_example(),
    metadata_ae = metalite.ae::meta_ae_example(),
    width = 1200
  )
  
  html <- gsub("id=\"htmlwidget-[A-Za-z0-9]+\"", "id=\"htmlwidget-123456\"", table)
  html <- gsub(
    "\"dataKey\":\"[a-f0-9]{32}\"", # Regex pattern to match the dataKey
    "\"dataKey\":\"fixed_data_key\"", # New fixed dataKey value
    html
  )
  
  expect_snapshot(html)
})

#Test 2 Testing AE selected column 
test_that("Testing react_disposition function AE selection column", {
  
  table <- react_disposition(
    metadata_sl = meta_sl_example(),
    metadata_ae = metalite.ae::meta_ae_example(),
    ae_col_selected = c("AESOC", "ASTDT", "AENDT", "AETERM", "duration", "AESEV", "AESER", "related", "AEACN", "AEOUT"),
    ae_col_names = c("SOC", "Onset Date", "End Date", "AE", "Duraion", "Intensity", "Serious", "Related", "Action Taken", "Outcome"),
    width = 1200
  )
  
  html <- gsub("id=\"htmlwidget-[A-Za-z0-9]+\"", "id=\"htmlwidget-123456\"", table)
  html <- gsub(
    "\"dataKey\":\"[a-f0-9]{32}\"", # Regex pattern to match the dataKey
    "\"dataKey\":\"fixed_data_key\"", # New fixed dataKey value
    html
  )
  
  expect_snapshot(html)
})

#Test 3 Testing Disposition selected column 
test_that("Testing react_disposition function Disposition selection column", {
  
  table <- react_disposition(
    metadata_sl = meta_sl_example(),
    metadata_ae = metalite.ae::meta_ae_example(),
    sl_col_selected = c("trt01a", "siteid", "subjid", "sex", "age", "weightbl"),
    sl_col_names = c("Treatment", "Site", "Subject ID", "Sex", "Age (Year)", "Weight (kg)"),
    width = 1200
  )
  
  html <- gsub("id=\"htmlwidget-[A-Za-z0-9]+\"", "id=\"htmlwidget-123456\"", table)
  html <- gsub(
    "\"dataKey\":\"[a-f0-9]{32}\"", # Regex pattern to match the dataKey
    "\"dataKey\":\"fixed_data_key\"", # New fixed dataKey value
    html
  )
  
  expect_snapshot(html)
})