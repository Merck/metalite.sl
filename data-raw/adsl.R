# Load adsl
adsl <- r2rtf::r2rtf_adsl

# Factorize treatment
adsl$TRTA <- adsl$TRT01A
adsl$TRTA <- factor(adsl$TRTA,
  levels = c("Placebo", "Xanomeline Low Dose", "Xanomeline High Dose"),
  labels = c("Placebo", "Low Dose", "High Dose")
)

# Load adae
adae <- metalite_sl_adae

# Treatment Disposition
# For discontinued due to AE
adaedisc <- subset(adae[which(adae$AEACN == "DRUG WITHDRAWN"), ], select = c(USUBJID, AEACN))
adaedisc <- adaedisc[!duplicated(adaedisc), ]

adsl <- merge(adsl, adaedisc, by = "USUBJID", all.x = TRUE)
adsl$EOTSTT <- ifelse(adsl$AEACN == "DRUG WITHDRAWN", "Discontinued", NA)
adsl$DCTREAS <- ifelse(adsl$EOTSTT == "Discontinued", "Adverse Event", NA)

# sample assignment cannot be NA value
adsl$EOTSTT[is.na(adsl$EOTSTT)] <- "temp"
adsl$DCTREAS[is.na(adsl$DCTREAS)] <- "temp"

adsl[adsl$EOTSTT != "Discontinued", "EOTSTT"] <- sample(
  x = c("Complete", "Discontinued", "Participants Ongoing"),
  size = length(adsl[adsl[["EOTSTT"]] != "Discontinued", "USUBJID"]),
  prob = c(0.6, 0.2, 0.2), replace = TRUE
)

adsl[adsl$EOTSTT == "Discontinued" & adsl$DCTREAS != "Adverse Event", "DCTREAS"] <- sample(
  x = c("Withdrawal By Subject", "Lack of Efficacy", "Lost to Follow-Up"),
  size = length(adsl[adsl$EOTSTT == "Discontinued" & adsl$DCTREAS != "Adverse Event", "USUBJID"]),
  prob = c(0.3, 0.4, 0.3), replace = TRUE
)

adsl[adsl[["EOTSTT"]] != "Discontinued", "DCTREAS"] <- NA

# Trial Disposition
adsl$EOSSTT <- adsl$EOTSTT
adsl$DCSREAS <- adsl$DCTREAS
adsl$DCSREAS <- ifelse(adsl$DCSREAS == "Adverse Event", "Other", adsl$DCTREAS)

metalite_sl_adsl <- adsl

usethis::use_data(metalite_sl_adsl, overwrite = TRUE)
