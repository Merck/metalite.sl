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

#' Create an interactive plot for exposure duration
#'
#' @param outdata An `outdata` object created from `prepare_exp_duration()`.
#'   `extend_exp_duration()` can also be applied.
#' @param color Color for a histogram.
#' @param display A character vector of display type.
#'  `n` or `prop` can be selected.
#' @param display_total A logical value to display total.
#' @param plot_group_label A label for grouping.
#' @param plot_category_label A label for category.
#' @param hover_summary_var A character vector of statistics to be displayed
#'   on hover label of bar.
#' @param width Width of the plot.
#' @param height Height of the plot.
#'
#' @return Interactive plot for exposure duration.
#'
#' @importFrom plotly plot_ly layout
#' @importFrom stats reshape
#'
#' @export
#'
#' @examples
#' # Only run this example in interactive R sessions
#' if (interactive()) {
#'   meta <- meta_sl_exposure_example()
#'   outdata <- meta |> 
#'     prepare_exp_duration() |>
#'     extend_exp_duration(
#'       duration_category_list = list(c(1, 7), c(7, 21), c(21, 84)),
#'       duration_category_labels = c("1-7 days", "7-21 days", "21-84 days")
#'     )
#'   
#'   outdata |> plotly_exposure_duration()
#' }
plotly_exposure_duration <- function(outdata,
                                     color = NULL,
                                     display = c("n", "prop"),
                                     display_total = TRUE,
                                     plot_group_label = "Treatment group",
                                     plot_category_label = "Exposure duration",
                                     hover_summary_var = c("median", "sd", "se", "median", "min", "max", "q1 to q3", "range"),
                                     width = 1000,
                                     height = 400){
  # input check
  display <- tolower(display)
  display <- match.arg(
    display,
    c("n", "prop")
  )
  hover_summary_var <- tolower(hover_summary_var)
  
  group_label <- outdata$group_label
  n_group <- length(outdata$group_label)
  parameter <- outdata$parameter
  par_var_group <- metalite::collect_adam_mapping(outdata$meta, parameter)$vargroup
  p <- list()
  
  # implement color
  if (is.null(color)) {
    color_pal <- c("#00857C", "#6ECEB2", "#BFED33", "#FFF063", "#0C2340", "#5450E4")
    color <- c("#66203A", rep(color_pal, length.out = n_group - 1))
  } else {
    color <- rep(color, length.out = n_group)
  }
  
  # Exclusive counting
  if (!is.null(par_var_group)) {
    tbl <- outdata$char_n[[1]]
    prop <- outdata$char_prop[[1]]
    res <- tbl[1:(which(is.na(tbl$name)) - 1), ]
    stats <- outdata$char_stat_groups
    
    res <- stats::reshape(
      res,
      varying = names(res)[!names(res) %in% c("name", "var_label")], 
      v.names = "n", 
      timevar = "group", 
      times = names(res)[!names(res) %in% c("name", "var_label")], 
      idvar = "name", 
      new.row.names = NULL,
      direction = "long"
    )
    rownames(res) <- NULL
    
    if (display == "n") {
      plot_count_label <- "Number of participants"
      res$res <- as.numeric(res$n)
    } else {
      plot_count_label <- "Percentage of participants"
      res_prop <- tbl[1:(which(is.na(prop$name)) - 1), ]
      res_prop <- stats::reshape(
        res_prop,
        varying = names(res)[!names(res) %in% c("name", "var_label")], 
        v.names = "prop", 
        timevar = "group", 
        times = names(res)[!names(res) %in% c("name", "var_label")], 
        idvar = "name", 
        new.row.names = NULL,
        direction = "long"
      )
      rownames(res_prop) <- NULL
      res <- merge(res, res_prop, by = c("name", "var_label", "group"))
      res$res <- as.numeric(res$prop)
    }      
    
    res$text <- mapply(
      function(x, y) {
        stat <- stats[[x]][tolower(stats[[x]][["name"]]) %in% hover_summary_var, ]
        paste(paste(stat[["name"]], stat[[y]], sep = ": "), collapse = "\n")
      },
      res$name, 
      res$group, 
      SIMPLIFY = TRUE, 
      USE.NAMES = FALSE
    )
    if ("n" %in% hover_summary_var) {
      res$text <- paste(paste0("N: ", res$n), res$text, sep = "\n")
    }
    if (display_total == TRUE) {
      res$group <- factor(res$group, levels = c(levels(group_label), "Total"))
    } else {
      res <- res[!res$group == "Total", ]
      res$group <- factor(res$group, levels = c(levels(group_label)))
    }
    res$name <- factor(res$name, levels = unique(res$name))
    
    plot_type2 <- res |> 
      plotly::plot_ly(
        x = ~group, 
        y = ~res, 
        color = ~name, 
        type = "bar",
        hoverinfo = "text",
        text = ~text,
        textposition = "none",
        colors = color,
        width = width,
        height = height
      ) |>
      plotly::layout(
        xaxis = list(
          title = list(text = plot_group_label, standoff = 20), titlefont = list(size = 12),
          ticks = "outside", tickwidth = 1, tickfont = list(size = 9),
          showline = TRUE, linewidth = 2, linecolor = "#cccccc", mirror = TRUE
        ),
        yaxis = list(
          title = list(text = plot_count_label, standoff = 20), titlefont = list(size = 12),
          ticks = "outside", tickwidth = 1, tickfont = list(size = 9),
          showline = TRUE, linewidth = 2, linecolor = "#cccccc", mirror = TRUE
        ),
        legend = list(
          title = list(text = plot_category_label),
          x = 1.05,
          titlefont = list(size = 12),
          font = list(size = 9)
        ),
        barmode = "stack",
        autosize = FALSE
      )
    p[["Stacked histogram"]] <- plot_type2
  }
  if (!is.null(outdata$char_n_cum)) {
    tbl_cum <- outdata$char_n_cum[[1]]
    prop_cum <- outdata$char_prop_cum[[1]]
    res_cum <- tbl_cum
    stats_cum <- outdata$char_stat_cums
    
    res_cum <- stats::reshape(
      res_cum,
      varying = names(res_cum)[!names(res_cum) %in% c("name", "var_label")], 
      v.names = "n", 
      timevar = "group", 
      times = names(res_cum)[!names(res_cum) %in% c("name", "var_label")], 
      idvar = "name", 
      new.row.names = NULL,
      direction = "long"
    )
    rownames(res_cum) <- NULL
    
    if (display == "n") {
      plot_count_label <- "Number of participants"
      res_cum$res <- as.numeric(res_cum$n)
    } else {
      plot_count_label <- "Percentage of participants"
      res_cum_prop <- tbl[1:(which(is.na(prop$name)) - 1), ]
      res_cum_prop <- stats::reshape(
        res_cum_prop,
        varying = names(res_cum_prop)[!names(res_cum_prop) %in% c("name", "var_label")], 
        v.names = "prop", 
        timevar = "group", 
        times = names(res_cum_prop)[!names(res_cum_prop) %in% c("name", "var_label")], 
        idvar = "name", 
        new.row.names = NULL,
        direction = "long"
      )
      rownames(res_cum_prop) <- NULL
      res_cum <- merge(res_cum, res_cum_prop, by = c("name", "var_label", "group"))
      res_cum$res <- as.numeric(res_cum$prop)
    }      
    
    res_cum$text <- mapply(
      function(x, y) {
        stat_cum <- stats_cum[[x]][tolower(stats_cum[[x]][["name"]]) %in% hover_summary_var, ]
        paste(paste(stat_cum[["name"]], stat_cum[[y]], sep = ": "), collapse = "\n")
      }, 
      res_cum$name, 
      res_cum$group, 
      SIMPLIFY = TRUE, 
      USE.NAMES = FALSE
    )
    if ("n" %in% hover_summary_var) {
      res_cum$text <- paste(paste0("N: ", res_cum$n), res_cum$text, sep = "\n")
    }    
    if (display_total == TRUE) {
      res_cum$group <- factor(res_cum$group, levels = c(levels(group_label), "Total"))
    } else {
      res_cum <- res_cum[!res_cum$group == "Total", ]
      res_cum$group <- factor(res_cum$group, levels = c(levels(group_label)))
    }
    
    res_cum$name <- factor(res_cum$name, levels = unique(res_cum$name))
    
    plot_type1 <- res_cum |> 
      plotly::plot_ly(
        x = ~group, 
        y = ~res, 
        color = ~name, 
        colors = color, 
        type = "bar", 
        hoverinfo = "text",
        text = ~text,
        textposition = "none",
        width = width, 
        height = height
      ) |>
      plotly::layout(
        xaxis = list(
          title = list(text = plot_group_label, standoff = 20), titlefont = list(size = 12),
          ticks = "outside", tickwidth = 1, tickfont = list(size = 9),
          showline = TRUE, linewidth = 2, linecolor = "#cccccc", mirror = TRUE
        ),
        yaxis = list(
          title = list(text = plot_count_label, standoff = 20), titlefont = list(size = 12),
          ticks = "outside", tickwidth = 1, tickfont = list(size = 9),
          showline = TRUE, linewidth = 2, linecolor = "#cccccc", mirror = TRUE
        ),
        legend = list(
          title = list(text = plot_caetgory_label),
          x = 1.05,
          titlefont = list(size = 12),
          font = list(size = 9)
        ),
        autosize = FALSE
      )
    
    plot_type3 <- res_cum |> 
      plotly::plot_ly(
        x = ~res, 
        y = ~name, 
        color = ~group, 
        colors = color, 
        type = "bar", 
        orientation = "h",
        hoverinfo = "text",
        text = ~text,
        textposition = "none",
        width = width,
        height = height
      ) |>
      plotly::layout(
        xaxis = list(
          title = list(text = plot_count_label, standoff = 20), titlefont = list(size = 12),
          ticks = "outside", tickwidth = 1, tickfont = list(size = 9),
          showline = TRUE, linewidth = 2, linecolor = "#cccccc", mirror = TRUE
        ),
        yaxis = list(
          title = list(text = plot_group_label, standoff = 20), titlefont = list(size = 12),
          ticks = "outside", tickwidth = 1, tickfont = list(size = 9),
          showline = TRUE, linewidth = 2, linecolor = "#cccccc", mirror = TRUE
        ),
        legend = list(
          title = list(text = plot_group_label),
          x = 1.05,
          titlefont = list(size = 12),
          font = list(size = 9)
        ),
        autosize = FALSE
      )
    
    p[["Histogram with cumulative count"]] <- plot_type1
    p[["Horizontal histogram with cumulative count"]] <- plot_type3
  }
  
  histograms <- names(p)
  histograms_ids <- paste0("histogram_type_", uuid::UUIDgenerate(), "|", histograms)
  plot_divs <- lapply(histograms_ids, function(x) {
    element <- unlist(strsplit(x, "\\|"))[2]
    htmltools::div(
      id = x,
      style = "width: 100%; height: 100%; display: none;",
      plotly::as_widget(p[[element]])
    )
  })
  # Show the first plot by default
  plot_divs[[1]]$attribs$style <- "width: 100%; height: 100%; display: block;"
  
  # JavaScript to handle drop down selection
  brew::brew(
    system.file("js/dropdownController.js", package = "metalite.sl"),
    output = file.path(tempdir(), "dropdownController.js")
  )
  paste(readLines(file.path(tempdir(), "dropdownController.js")), collapse = "\n")  
  
  # Create the drop down menu
  dropdown_id <- paste0("histogram_dropdown_", uuid::UUIDgenerate())
  dropdown <- htmltools::tags$div(
    id = dropdown_id,
    htmltools::tags$label(
      class = "dropdown-label", 
      `for` = dropdown_id, 
      "Histogram type",
      style = "margin-bottom: 0; font-weight: 400; font-family: sans-serif; font-size: 12px;"
    ),
    htmltools::tags$div(
      htmltools::tags$select(
        onchange = "dropdownController(this.value)",
        style = paste("width:", paste0(width, "px;"), "margin-bottom: 15px; cursor: pointer;",
                      "font-weight: 400; font-family: sans-serif; font-size: 12px;",
                      "padding: 1px 3px; border: 1px solid #cccccc;",
                      "border-radius: 4px;"),
        lapply(histograms_ids, function(x) {
          htmltools::tags$option(unlist(strsplit(x, "\\|"))[2], value = x)
        })
      )
    )
  )
  
  htmltools::browsable(
    htmltools::tagList(
      htmltools::htmlDependency(
        "dropdownController.js", 
        "0.1.0",
        src = tempdir(),
        script = "dropdownController.js",
        all_files = FALSE
      ),
      htmltools::div(
        dropdown,
        do.call(htmltools::tags$div, plot_divs)
      )
    )
  )
}
