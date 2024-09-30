# Copyright (c) 2024 Merck & Co., Inc., Rahway, NJ, USA and its affiliates.
# All rights reserved.
#
# This file is part of the metalite.sl program.
#
# metalite.sl is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

#' Prepare data for Subgroup Analysis for Baseline Characteristic
#'
#' @param outdata A metadata object created by [prepare_base_char_subgroup()]. 
#' @param display Column wants to display on the table.
#'   The term could be selected from `c("n", "prop", "total")`.
#' @param display_stat A vector of statistics term name.
#'   The term name could be selected from
#'   `c("mean", "sd", "se", "median", "q1 to q3", "range", "q1", "q3", "min", "max")`.
#'
#' @return A list of analysis raw datasets.
#' @export
#'
#' @examples
#' meta <- meta_sl_example()
#' 
#' outdata <- prepare_base_char_subgroup(
#'           meta,
#'           population = "apat",
#'           parameter = "age",
#'           subgroup_var = "TRTA",
#'           subgroup_header = c("SEX","TRTA"),
#'           display_subgroup_total = TRUE
#' )
#' 
#' outdata |> format_base_char_subgroup()
     
format_base_char_subgroup <- function(
    outdata,
    display = c("n","prop","total"),
    display_stat = c("mean", "sd", "median", "range")) {
  
  out_all <- outdata$out_all
  
  outlst <- list()
  for (i in seq_along(out_all)) {
    tbl <- out_all[[i]] |>
      format_base_char(
        display_col = display,
        digits_prop = 1,
        display_stat = display_stat
      )
    
    #names(tbl$tbl)[-1] <- paste0(names(out_all[i]), names(tbl$tbl)[-1])
    names(tbl$tbl)[-1] <- ifelse(grepl("_label",names(tbl$tbl)[-1]) %in% "FALSE", paste0(names(out_all[i]), names(tbl$tbl)[-1]),names(tbl$tbl)[-1])
    
    tbl$tbl$order <- as.numeric(rownames(tbl$tbl))
    
    outlst[[i]] <- tbl$tbl
  }
  
  names(outlst) <- names(out_all)
  outlst <- outlst[-length(outlst)]
  
  i <- 1
  while (i < length(outlst)) {
    if (i == 1) {
      tbl <- merge(outlst[[i]], outlst[[i + 1]], by = c("name","var_label","order"), all = TRUE)
    }
    
    i <- i + 1
    
    if (i > 1 && i < length(outlst)) {
      tbl <- merge(tbl, outlst[[i + 1]], by = c("name","var_label","order"), all = TRUE)
    }
  }
  
  
  # If outdata$display_subgroup_total = FALSE, remove that part
  #if (!outdata$display_subgroup_total) {
  #  rm_tot <- names(outlst$Total) # Columns from Total Section
  #  rm_tot <- rm_tot[!rm_tot %in% c("name", "order")]
    
  #  tbl <- tbl[, -which(names(tbl) %in% rm_tot)]
  #}
  
  outdata$tbl <- tbl[order(tbl$order),]
  outdata$display <- display
  outdata$display_stat <- display_stat
  outdata
}