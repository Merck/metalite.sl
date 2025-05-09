% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/react_disposition.R
\name{react_disposition}
\alias{react_disposition}
\title{Display interactive disposition tables with AE subgroup analysis}
\usage{
react_disposition(
  metadata_sl,
  metadata_ae,
  analysis = "disp",
  trtvar = metalite::collect_adam_mapping(metadata_sl, population)$group,
  population = metadata_sl$plan$population[metadata_sl$plan$analysis == analysis],
  sl_parameter = paste(metadata_sl$plan$parameter[metadata_sl$plan$analysis == analysis],
    collapse = ";"),
  sl_col_selected = c("siteid", "subjid", "sex", "age", "weightbl"),
  sl_col_names = c("Site", "Subject ID", "Sex", "Age (Year)", "Weight (kg)"),
  ae_observation = "wk12",
  ae_population = population,
  ae_col_selected = c("AESOC", "ASTDT", "AENDT", "AETERM", "duration", "AESEV", "AESER",
    "related", "AEACN", "AEOUT"),
  ae_col_names = c("SOC", "Onset Date", "End Date", "AE", "Duraion", "Intensity",
    "Serious", "Related", "Action Taken", "Outcome"),
  display_total = TRUE,
  width = 1200
)
}
\arguments{
\item{metadata_sl}{A metadata created by metalite,
which builds the baseline characteristic table}

\item{metadata_ae}{A metadata created by metalite,
which builds the AE subgroup specific table}

\item{analysis}{The analysis label provided in \code{metadata_sl}.}

\item{trtvar}{A character that indicate variable for the treatment group.}

\item{population}{A character value of population term name.
The term name is used as key to link information.}

\item{sl_parameter}{A character value of parameter term name for
the baseline characteristic table.
The term name is used as key to link information.}

\item{sl_col_selected}{A character vector of variable which will be shown in the participant detail.}

\item{sl_col_names}{A character vector for the columns names of the participant detail. Same length as sl_col_selected.}

\item{ae_observation}{The meta parameter of the observation in adverse event listing.}

\item{ae_population}{The meta parameter of the population in adverse event listing.}

\item{ae_col_selected}{A character vector of variable which will be shown in the AE detail.}

\item{ae_col_names}{A character vector for the columns names of the AE detail. Same length as ae_col_selected.}

\item{display_total}{Display total column or not.}

\item{width}{A numeric value of width of the table in pixels.}
}
\value{
An reactable combing both baseline characteristic table
and AE subgroup specific tables.
}
\description{
Display interactive disposition tables with AE subgroup analysis
}
\examples{
if (interactive()) {
  react_disposition(
    metadata_sl = meta_sl_example(),
    metadata_ae = metalite.ae::meta_ae_example()
  )
}
}
