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

#' Subgroup Analysis for Baseline Characteristic
#'
#' @param outdata An `outdata` object created by [prepare_base_char_subgroup()]
#' @param source A character value of the data source.
#' @inheritParams r2rtf::rtf_page
#' @inheritParams r2rtf::rtf_body
#' @param footnotes A character vector of table footnotes.
#' @param title Term "analysis", "observation" and "population") for collecting title from metadata or a character vector of table titles.
#' @param path_outdata A character string of the outdata path.
#' @param path_outtable A character string of the outtable path.
#'
#' @return RTF file and source dataset for baseline characteristic table.
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
#' outdata |>
#'     format_base_char_subgroup() |>
#'     rtf_base_char_subgroup(
#'     source = "Source:  [CDISCpilot: adam-adsl]",
#'     path_outtable = "outtable/bar0char0subgroup.rtf"
#'  )
#'  
rtf_base_char_subgroup <- function(
    outdata,
    source,
    col_rel_width = NULL,
    text_font_size = 8,
    orientation = "landscape",
    footnotes = NULL,
    title = NULL,
    path_outdata = NULL,
    path_outtable = NULL) {
  
  out_all <- outdata$out_all
  tbl <- outdata$tbl
  
  #Add empty line before stats summary section
  tbl<- tbl |> 
    dplyr::mutate(split = cumsum(ifelse(tolower(name) == outdata$display_stat[1], 1, 0))) |>
    dplyr::group_by(split) |> 
    dplyr::group_modify(.f = ~dplyr::add_row(.data = .,
                               name = "", var_label= tbl[tolower(tbl$name) == outdata$display_stat[1],]$var_label))
  
  tbl1 <- tbl[!names(tbl) %in% c("order","split")]
  tgroup <- outdata$group
  sgroup <- outdata$subgroup
  if (outdata$display_subgroup_total) tgroup <- c(tgroup, "Total")
  n_sgroup <- length(sgroup)
  n_tgroup <- length(tgroup)
  n_row <- nrow(tbl1)
  n_col <- ncol(tbl1)
  
  if (!is.null(col_rel_width) && !n_col == length(col_rel_width)) {
    stop(
      "col_rel_width must have the same length (has ",
      length(col_rel_width),
      ") as as outdata$tbl has number of columns (has ",
      n_col, ")."
    )
  }
  
  # Define title
  if (is.null(title)) {
      title <- metalite::collect_title(outdata$meta,
                    outdata$population,
                    "",
                    outdata$parameter,
                    analysis = "base_char_subgroup")
  }
  
  # Set default footnote
  footnotes_stat <- NULL
  if ("sd" %in% tolower(outdata$display_stat)) {
      footnotes_stat <- c(footnotes_stat, "SD=Standard deviation")
  }
  if ("se" %in% tolower(outdata$display_stat)) {
      footnotes_stat <- c(footnotes_stat, paste0("SE=Standard err", "or"))
  }
  if ("q1 to q3" %in% tolower(outdata$display_stat)) {
      footnotes_stat <- c(footnotes_stat, "Q1=First quartile, Q3=Third quartile")
  }
  # combine footnotes for abbreviation of statistics
  footnotes_stat <- paste(footnotes_stat, collapse = "; ")
  # combine with user defined footnotes if not NULL
  if (nchar(footnotes_stat) > 0) {
    if (!is.null(footnotes)) {
        footnotes <- paste0(footnotes_stat, ".\n", footnotes)
    } else {
        footnotes <- paste0(footnotes_stat, ".")
    }
  }
  
  col_tbl_within <- outdata$display
  
  col_tbl_within <- col_tbl_within |>
    (\(list) list[list %in% c("n","prop")])() |>
    unique()
  
  colhead_within <- paste(
    vapply(
      X = col_tbl_within,
      FUN.VALUE = "character",
      FUN = switch,
      "n" = "n",
      "prop" = "(%)"
    ),
    collapse = " | "
  )
  
  colhead_1_within <- paste(sgroup, collapse = " |")
  colhead_2_within <- paste(rep(tgroup, n_sgroup), collapse = " | ")
  colhead_3_within <- paste(rep(colhead_within, n_sgroup * n_tgroup), collapse = " | ")
  
  colborder_within <- vapply(
    X = col_tbl_within,
    FUN.VALUE = "character",
    FUN = switch,
    "n" = "single",
    "prop" = "",
    USE.NAMES = FALSE
  )
  
  rwidth_3_within <- rep(1, length(col_tbl_within) * n_sgroup * n_tgroup)
  
  rwidth_2_within <- tapply(
    rwidth_3_within,
    c(rep(1:(n_sgroup * n_tgroup), each = length(col_tbl_within))),
    sum
  )
  names(rwidth_2_within) <- NULL
  
  rwidth_1_within <- tapply(
    rwidth_3_within,
    c(rep(1:n_sgroup, each = length(col_tbl_within) * n_tgroup)),
    sum
  )
  names(rwidth_1_within) <- NULL
  
  
  colborder_within <- rep(colborder_within, n_sgroup * n_tgroup)
  
  # Column headers
  
  colheader <- c(
    paste0(" | ", colhead_1_within),
    paste0(" | ", colhead_2_within),
    paste0(" | ", colhead_3_within)
  )
  
  # Relative width
  
  if (is.null(col_rel_width)) {
    rwidth_1 <- c(2, rwidth_1_within)
    rwidth_2 <- c(2, rwidth_2_within)
    rwidth_3 <- c(2, rwidth_3_within)
  } else {
    rwidth_3 <- col_rel_width
    
    rwidth_2 <- tapply(
      col_rel_width[2:length(col_rel_width)],
      c(rep(1:(n_sgroup * n_tgroup), each = length(col_tbl_within))),
      sum
    )
    
    rwidth_2 <- c(
      rwidth_3[1],
      rwidth_2
    )
    
    
    rwidth_1 <- tapply(
      col_rel_width[2:length(col_rel_width)],
      c(rep(1:n_sgroup, each = length(col_tbl_within) * n_tgroup)),
      sum
    )
    
    rwidth_1 <- c(
      rwidth_3[1],
      rwidth_1
    )
  }
  
  if ((sum(rwidth_1) != sum(rwidth_2)) || (sum(rwidth_1) != sum(rwidth_3))) {
    stop("Width calculation breaks, contact developer.")
  }
  
  # Column border
  border_top2 <- c("", rep("single", n_sgroup * n_tgroup))
  border_top3 <- c("", rep("single", n_sgroup * n_tgroup * 2))
  
  border_left2 <- c("single", rep("single", n_sgroup * n_tgroup))
  border_left3 <- c("single", colborder_within)
  border_left4 <- c(rep("single",2), colborder_within)
  
  # Using order number to customize row format
  
  text_justification <- c("l", rep("l", n_sgroup * n_tgroup * 2))
  #text_format <- c(rep("", 1 + n_sgroup * n_tgroup * 2), "b")
  
  text_indent <- matrix(0, nrow = n_row, ncol = n_col)
  text_indent[, 1] <- ifelse(FALSE, 0, 100)
  text_indent[1, 1] <- 0
  
  # Using r2rtf
  outdata$rtf <- tbl1 |>
    r2rtf::rtf_page(orientation = orientation) |>
    r2rtf::rtf_title(title) |>
    r2rtf::rtf_colheader(
      colheader = colheader[1], 
      col_rel_width = rwidth_1, 
      text_font_size = text_font_size) |>
    r2rtf::rtf_colheader(
      colheader = colheader[2], 
      border_top = border_top2, 
      border_left = border_left2,
      col_rel_width = rwidth_2, 
      text_font_size = text_font_size
    ) |>
    r2rtf::rtf_colheader(
      colheader = colheader[3], 
      border_top = border_top3, 
      border_left = border_left3,
      col_rel_width = rwidth_3, 
      text_font_size = text_font_size
    ) |>
    r2rtf::rtf_body(
      page_by = "var_label",
      col_rel_width = c(rwidth_3,1),
      border_left = border_left4,
      text_justification = text_justification,
      text_indent_first = text_indent, 
      text_indent_left = text_indent, 
      #text_format = text_format,
      text_font_size = text_font_size
    )
  
  if (!is.null(footnotes)) {
    outdata$rtf <- outdata$rtf |>
      r2rtf::rtf_footnote(footnotes,
                          text_font_size = text_font_size
      )
  }
  
  if (!is.null(source)) {
    outdata$rtf <- outdata$rtf |>
      r2rtf::rtf_source(source,
                        text_font_size = text_font_size
      )
  }
  
  # Prepare output
  rtf_output(outdata, path_outdata, path_outtable)
  
  to_pdf(
    path_outtable,
    output = gsub("\\.[[:alnum:]]+$", ".pdf", path_outtable),
    timeout = 120,
    UserInstallation = NULL
  )
}