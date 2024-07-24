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

#' Prepare data for baseline characteristic table
#'
#' @param outdata A metadata object created by [prepare_sl_summary()].
#' @param display_col Column wants to display on the table.
#'   The term could be selected from `c("n", "prop", "total")`.
#' @param digits_prop Number of digits for proportion columns.
#' @param display_stat A vector of statistics term name.
#'   The term name could be selected from
#'   `c("mean", "sd", "se", "median", "q1 to q3", "range", "q1", "q3", "min", "max")`.
#'
#' @return A list of analysis raw datasets.
#'
#' @export
#'
#' @examples
#' meta <- meta_sl_example()
#'
#' meta |>
#'   prepare_sl_summary(population = "apat", analysis = "base_char", parameter = "age;gender") |>
#'   format_sl_summary()
format_sl_summary <- function(
    outdata,
    display_col = c("n", "prop", "total"),
    digits_prop = 1,
    display_stat = c("mean", "sd", "se", "median", "q1 to q3", "range")) {
  n_group <- length(outdata$group_label)

  # Select statistics want to display
  for (i in 1:length(outdata$var_type)) {
    if ("numeric" %in% outdata$var_type[[i]]) {
      n_num <- outdata$char_n[[i]]
      n_num_group <- n_num[which(!tolower(n_num$name)
      %in% c(
          "mean", "sd", "se", "median", "q1 to q3",
          "range", "q1", "q3", "min", "max"
        )), ]
      n_num_stat <- n_num[which(tolower(n_num$name) %in% display_stat), ]
      n_num <- rbind(n_num_group, n_num_stat)
      outdata$char_n[[i]] <- n_num
      outdata$char_prop[[i]] <- outdata$char_prop[[i]][which(outdata$char_prop[[i]]$name %in% n_num$name), ]
    }
  }

  # Create output
  tbl <- list()

  if ("n" %in% display_col) {
    n <- do.call(rbind, outdata$char_n)
    if ("total" %in% display_col) {
      names(n) <- c("name", paste0("n_", seq(1, n_group)), "n_9999", "var_label")
    } else {
      n <- n[, -(2 + n_group)]
      names(n) <- c("name", paste0("n_", seq(1, n_group)), "var_label")
    }

    tbl[["n"]] <- n
  }

  tbl$n <- rbind(outdata$n[, names(outdata$n) %in% names(tbl$n)], tbl$n)

  if ("prop" %in% display_col) {
    prop <- do.call(rbind, outdata$char_prop)
    name <- prop$name
    label <- prop$var_label
    value <- data.frame(apply(prop[2:(ncol(prop) - 1)], 2, function(x) as.numeric(as.character(x))))
    prop <- apply(value, 2, metalite.ae::fmt_pct, digits = digits_prop, pre = "(", post = ")") |> as.data.frame()
    prop <- data.frame(name = name, prop, var_label = label)
    if ("total" %in% display_col) {
      names(prop) <- c("name", paste0("p_", seq(1, n_group)), "p_9999", "var_label")
    } else {
      prop <- prop[, -(2 + n_group)]
      names(prop) <- c("name", paste0("p_", seq(1, n_group)), "var_label")
    }
    tbl[["prop"]] <- prop
  }
  tbl$prop <- rbind(c(tbl$n[1, 1], rep(NA, ifelse("total" %in% display_col, n_group + 1, n_group)), tbl$n[1, ncol(tbl$n)]), tbl$prop)

  # Arrange Within Group information
  within_var <- names(tbl)[names(tbl) %in% c("n", "prop")]
  within_tbl <- tbl[within_var]

  names(within_tbl) <- NULL
  n_within <- length(within_tbl)
  n_row <- ncol(tbl[["n"]])
  within_tbl <- do.call(cbind, within_tbl)
  within_tbl <- within_tbl[!duplicated(as.list(within_tbl))]
  within_tbl <- within_tbl[, c(
    1, do.call(c, lapply(
      2:(1 + n_group + ifelse("total" %in% display_col, 1, 0)),
      function(x) {
        c(x, x + n_group + ifelse("total" %in% display_col, 1, 0) + 1)
      }
    )),
    (1 + n_group + ifelse("total" %in% display_col, 1, 0) + 1)
  )]

  rownames(within_tbl) <- NULL
  outdata$tbl <- within_tbl
  outdata$display_col <- display_col
  outdata$display_stat <- display_stat

  return(outdata)
}

#' Format Baseline Characteristics Analysis
#'
#' @inheritParams format_sl_summary
#'
#' @return A list of analysis raw datasets.
#'
#' @export
#'
#' @examples
#' meta <- meta_sl_example()
#'
#' meta |>
#'   prepare_base_char(population = "apat", parameter = "age;gender") |>
#'   format_base_char()
format_base_char <- format_sl_summary

#' Format Treatment Compliance Analysis
#'
#' @inheritParams format_sl_summary
#'
#' @return A list of analysis raw datasets.
#'
#' @export
#'
#' @examples
#' meta <- meta_sl_example()
#'
#' meta |>
#'   prepare_trt_compliance(parameter = "comp8;comp16") |>
#'   format_trt_compliance()
format_trt_compliance <- format_sl_summary

#' Format Treatment Compliance Analysis
#'
#' @inheritParams format_sl_summary
#'
#' @return A list of analysis raw datasets.
#'
#' @export
#'
#' @examples
#' meta <- meta_sl_example()
#'
#' meta |>
#'   prepare_trt_compliance(population = "apat", parameter = "comp8;comp16") |>
#'   format_trt_compliance()
format_trt_compliance <- format_sl_summary


#' Format Disposition Analysis
#'
#' @inheritParams format_sl_summary
#'
#' @return A list of analysis raw datasets.
#'
#' @export
#'
#' @examples
#' meta <- meta_sl_example()
#'
#' meta |>
#'   prepare_disposition(population = "apat", parameter = "disposition;medical-disposition") |>
#'   format_disposition()
format_disposition <- format_sl_summary

#' Format Exposure Duration Analysis
#'
#' @inheritParams format_sl_summary
#'
#' @return A list of analysis raw datasets.
#'
#' @export
#'
#' @examples
#' meta <- meta_sl_exposure_example()
#'
#' meta |>
#'   prepare_exp_duration(population = "apat", parameter = "expdur") |>
#'   format_exp_duration()
format_exp_duration <- format_sl_summary
