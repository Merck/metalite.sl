#' Format Exposure Duration Analysis
#'
#' @inheritParams format_sl_summary
#' @param display_col Column wants to display on the table.
#'   "n_cum", "prop_cum" can additionally be selected.
#'   - `n_cum`: Number of subjects created by `extend_exp_duration()`.
#'   - `prop_cum`: Proportion of subjects created by `extend_exp_duration()`.
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
#'   format_exp_duration(display_col = c("n", "prop", "total"))
format_exp_duration <- function(
    outdata,
    display_col = c("n", "prop", "n_cum", "prop_cum", "total"),
    digits_prop = 1,
    display_stat = c("mean", "sd", "se", "median", "q1 to q3", "range")) {
  n_group <- length(outdata$group_label)
  
  display_col <- match.arg(
    display_col,
    c("n", "prop", "total", "n_cum", "prop_cum"),
    several.ok = TRUE
  )
  
  # Check if the "tbl" element exists in the "outdata" object
  if ("tbl" %in% names(outdata)) {
    # If the element exists, delete it
    outdata$tbl <- NULL
  }
  
  # Select statistics want to display
  for (i in 1:length(outdata$var_type)) {
    if (("integer" %in% outdata$var_type[[i]]) || ("numeric" %in% outdata$var_type[[i]])) {
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
  
  if ("n_cum" %in% display_col) {
    if (is.null(outdata$char_n_cum)) {
      stop(
        "Please use `extend_exp_duration()` with `duration_category_list` and `duration_category_labels` to get n for a defined category.",
        call. = FALSE
      )
    }
    
    n_cum <- do.call(rbind, outdata$char_n_cum)
    if ("total" %in% display_col) {
      names(n_cum) <- c("name", paste0("n_", seq(1, n_group)), "n_9999", "var_label")
    } else {
      n_cum <- n_cum[, -(2 + n_group)]
      names(n_cum) <- c("name", paste0("n_", seq(1, n_group)), "var_label")
    }
    
    tbl[["n"]] <- rbind(n_cum, tbl[["n"]])
  }
  tbl$n <- rbind(outdata$n[, names(outdata$n) %in% names(tbl$n)], tbl$n)
  
  if ("prop_cum" %in% display_col) {
    if (is.null(outdata$char_prop_cum)) {
      stop(
        "Please use `extend_exp_duration()` with `duration_category_list` and `duration_category_labels` to get proportion for a defined category.",
        call. = FALSE
      )
    }
    
    prop_cum <- do.call(rbind, outdata$char_prop_cum)
    name_cum <- prop_cum$name
    label_cum <- prop_cum$var_label
    value_cum <- data.frame(apply(prop_cum[2:(ncol(prop_cum) - 1)], 2, function(x) as.numeric(as.character(x))))
    prop_cum <- apply(value_cum, 2, metalite.ae::fmt_pct, digits = digits_prop, pre = "(", post = ")") |> as.data.frame()
    prop_cum <- data.frame(name = name_cum, prop_cum, var_label = label_cum)
    if ("total" %in% display_col) {
      names(prop_cum) <- c("name", paste0("p_", seq(1, n_group)), "p_9999", "var_label")
    } else {
      prop_cum <- prop_cum[, -(2 + n_group)]
      names(prop_cum) <- c("name", paste0("p_", seq(1, n_group)), "var_label")
    }
    tbl[["prop"]] <- rbind(prop_cum, tbl[["prop"]])
  }
  tbl$prop <- rbind(c(tbl$n[1, 1], rep(NA, ifelse("total" %in% display_col, n_group + 1, n_group)), tbl$n[1, ncol(tbl$n)]), tbl$prop)
  
  # Arrange Within Group information
  within_var <- names(tbl)[names(tbl) %in% c("n", "prop")]
  within_tbl <- tbl[within_var]
  
  names(within_tbl) <- NULL
  n_within <- length(within_tbl)
  n_row <- ncol(tbl[["n"]])
  within_tbl <- do.call(cbind, within_tbl)
  
  within_tbl <- within_tbl[, !duplicated(names(within_tbl))]
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
  outdata$extend_call <- c(outdata$extend_call, match.call())
  
  return(outdata)
}