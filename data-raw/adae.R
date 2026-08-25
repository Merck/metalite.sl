# Create a variable EOSSTT indicating the end of end of study status
adae <- r2rtf::r2rtf_adae
adae$TRTA <- factor(
  adae$TRTA,
  levels = c("Placebo", "Xanomeline Low Dose", "Xanomeline High Dose"),
  labels = c("Placebo", "Low Dose", "High Dose")
)
adae$RACE <- tools::toTitleCase(adae$RACE)

adae$related <- ifelse(
  adae$AEREL == "RELATED",
  "Y",
  ifelse(
    toupper(adae$AEREL) == "NOT RELATED",
    "N",
    tools::toTitleCase(tolower(adae$AEREL))
  )
)

adae$outcome <- tools::toTitleCase(tolower(adae$AEOUT))
adae$outcome[adae$AEOUT == "RECOVERED/RESOLVED"] <- "Resolved"
adae$outcome[adae$AEOUT == "RECOVERING/RESOLVING"] <- "Resolving"
adae$outcome[adae$AEOUT == "RECOVERED/RESOLVED WITH SEQUELAE"] <- "Sequelae"
adae$outcome[adae$AEOUT == "NOT RECOVERED/NOT RESOLVED"] <- "Not Resolved"

# If no value populate for AEACN in AE, then generate dummy values
if (length(unique(adae$AEACN)) == 1) {
  adae$AEACN <- sample(
    x = c("DOSE NOT CHANGED", "DRUG INTERRUPTED", "DRUG WITHDRAWN", "NOT APPLICABLE", "UNKNOWN"),
    size = length(adae$USUBJID),
    prob = c(0.7, 0.1, 0.05, 0.1, 0.05), replace = TRUE
  )
}

adae$action_taken <- tools::toTitleCase(tolower(adae$AEACN))
adae$action_taken[adae$AEACN == "DOSE NOT CHANGED"] <- "None"
adae$action_taken[adae$AEACN == "DOSE REDUCED"] <- "Reduced"
adae$action_taken[adae$AEACN == "DRUG INTERRUPTED"] <- "Interrupted"
adae$action_taken[adae$AEACN == "DRUG WITHDRAWN"] <- "Discontinued"
adae$action_taken[adae$AEACN == "DOSE INCREASED"] <- "Increased"
adae$action_taken[adae$AEACN == "NOT APPLICABLE"] <- "N/A"
adae$action_taken[adae$AEACN == "UNKNOWN"] <- "Unknown"
adae$action_taken[adae$AEACN == ""] <- "None"

adae$duration <- paste(
  ifelse(is.na(adae$ADURN), "", as.character(adae$ADURN)),
  tools::toTitleCase(tolower(adae$ADURU))
)
continuing <- toupper(adae$AEOUT) %in% c(
  "RECOVERING/RESOLVING",
  "NOT RECOVERED/NOT RESOLVED"
)
adae$duration[is.na(adae$ADURN)] <- ifelse(
  continuing[is.na(adae$ADURN)],
  "Continuing",
  "Unknown"
)

adae$subline <- paste0(
  "Subject ID = ", adae$USUBJID,
  ", Gender = ", adae$SEX,
  ", Race = ", adae$RACE,
  ", AGE = ", adae$AGE, " Years",
  ", TRT = ", adae$TRTA
)

adae <- metalite::assign_label(
  adae,
  var = c("related", "outcome", "duration", "AESEV", "AESER", "AEDECOD", "action_taken"),
  label = c("Related", "Outcome", "Duration", "Intensity", "Serious", "Adverse Event", "Action Taken")
)

metalite_sl_adae <- adae

usethis::use_data(metalite_sl_adae, overwrite = TRUE)
