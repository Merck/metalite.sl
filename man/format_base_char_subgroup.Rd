% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/format_base_char_subgroup.R
\name{format_base_char_subgroup}
\alias{format_base_char_subgroup}
\title{Prepare data for Subgroup Analysis for Baseline Characteristic}
\usage{
format_base_char_subgroup(
  outdata,
  display = c("n", "prop", "total"),
  display_stat = c("mean", "sd", "median", "range"),
  display_total = TRUE
)
}
\arguments{
\item{outdata}{A metadata object created by \code{\link[=prepare_base_char_subgroup]{prepare_base_char_subgroup()}}.}

\item{display}{Column wants to display on the table.
The term could be selected from \code{c("n", "prop", "total")}.
"total" can display the total column for the first level header.}

\item{display_stat}{A vector of statistics term name.
The term name could be selected from
\code{c("mean", "sd", "se", "median", "q1 to q3", "range", "q1", "q3", "min", "max")}.}

\item{display_total}{A logic value of displaying the total column
for the second level header.}
}
\value{
A list of analysis raw datasets.
}
\description{
Prepare data for Subgroup Analysis for Baseline Characteristic
}
\examples{
meta <- meta_sl_example()

outdata <- prepare_base_char_subgroup(
  meta,
  population = "apat",
  parameter = "age",
  subgroup_var = "TRTA",
  subgroup_header = c("SEX", "TRTA")
)

outdata |> format_base_char_subgroup()
}
