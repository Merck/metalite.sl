% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/react_subgroup_table.R
\name{react_subgroup_table}
\alias{react_subgroup_table}
\title{Create interactive table for a subgroup}
\usage{
react_subgroup_table(tbl, group, subgroup_name)
}
\arguments{
\item{tbl}{A tibble to create reactable.}

\item{group}{Treatment group label.}

\item{subgroup_name}{Subgroup label.}
}
\value{
A reactable combining both baseline characteristic table
and AE subgroup specific tables for a subgroup.
}
\description{
Create interactive table for a subgroup
}
