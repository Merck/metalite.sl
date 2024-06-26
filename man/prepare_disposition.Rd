% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/prepare_disposition.R
\name{prepare_disposition}
\alias{prepare_disposition}
\title{Prepare data for treatment compliance table}
\usage{
prepare_disposition(
  meta,
  analysis = "disp",
  population = meta$plan[meta$plan$analysis == analysis, ]$population,
  parameter = paste(meta$plan[meta$plan$analysis == analysis, ]$parameter, collapse =
    ";")
)
}
\arguments{
\item{meta}{A metadata object created by metalite.}

\item{analysis}{A character value of analysis term name.
The term name is used as key to link information.}

\item{population}{A character value of population term name.
The term name is used as key to link information.}

\item{parameter}{A character value of parameter term name.
The term name is used as key to link information.}
}
\value{
A list of analysis raw datasets.
}
\description{
Prepare data for treatment compliance table
}
\examples{
meta <- meta_sl_example()
meta |> prepare_base_char()
}
