% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/react_subgroup_table.R
\name{format_ae_specific_subgroup}
\alias{format_ae_specific_subgroup}
\title{Format AE specific analysis}
\usage{
format_ae_specific_subgroup(
  outdata,
  display = c("n", "prop"),
  digits_prop = 1,
  digits_ci = 1,
  digits_p = 3,
  digits_dur = c(1, 1),
  digits_events = c(1, 1),
  mock = FALSE
)
}
\arguments{
\item{outdata}{An \code{outdata} object created by \code{\link[metalite.ae:prepare_ae_specific]{prepare_ae_specific()}}.}

\item{display}{A character vector of measurement to be displayed.
\itemize{
\item \code{n}: Number of subjects with AE.
\item \code{prop}: Proportion of subjects with AE.
\item \code{total}: Total columns.
\item \code{dur}: Average of AE duration.
\item \code{events}: Average number of AE per subject.
}}

\item{digits_prop}{A numeric value of number of digits for proportion value.}

\item{digits_ci}{A numeric value of number of digits for confidence interval}

\item{digits_p}{A numeric value of number of digits for p-value .}

\item{digits_dur}{A numeric value of number of digits for
average duration of AE.}

\item{digits_events}{A numeric value of number of digits for
average of number of AE per subjects.}

\item{mock}{Logical. Display mock table or not.}
}
\value{
A list of analysis raw datasets.
}
\description{
Format AE specific analysis
}
