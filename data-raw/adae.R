# Create a variable EOSSTT indicating the end of end of study status
metadata_ae <- metalite.ae::meta_ae_example()
adae <- metadata_ae$data_observation

# If no value populate for AEACN in AE, then generate dummy values
if (length(unique(adae$AEACN)) == 1) {
  adae$AEACN <- sample(
    x = c("DOSE NOT CHANGED", "DRUG INTERRUPTED", "DRUG WITHDRAWN", "NOT APPLICABLE", "UNKNOWN"),
    size = length(adae$USUBJID),
    prob = c(0.7, 0.1, 0.05, 0.1, 0.05), replace = TRUE
  )
}

metalite_sl_adae <- adae

usethis::use_data(metalite_sl_adae, overwrite = TRUE)
