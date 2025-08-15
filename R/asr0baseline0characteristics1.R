#' Generate Baseline Characteristics Table
#'
#' This function creates a baseline characteristics table based on the provided metadata and population definitions.
#' It supports customization of variables, display options, formatting, and output paths.
#'
#' @param meta Metadata object containing variable mappings and population definitions created by metalite.
#' @param analysis Character string specifying the analysis term defined in `meta`. Used for generating the table title. Default is `"base0char"`.
#' @param population Character string specifying the analysis population for the baseline characteristics table.
#'   For example, `"apat"` refers to all participants as treated, filtered by `SAFFL = "Y"` and non-missing `TRT01A`.
#' @param parameter Character string of parameter term names (semicolon-separated variable names) to include in the table.
#'   Default is `"age;gender;race"`.
#' @param frame Data frame controlling the order of sections and categories in the table. (Currently TODO)
#' @param display_col Character vector specifying which columns to display. Options include `"n"` (counts), `"prop"` (proportions), and `"total"`.
#'   Default is `c("n", "prop", "total")`.
#' @param display_totals_select_grps Optional argument to select specific columns and treatment groups for total display. (Currently TODO)
#' @param decimal_places_percent Integer specifying the number of decimal places for percentages. Default is `2`.
#' @param display_stat Character vector specifying which descriptive statistics to display for numeric variables.
#'   Options include `"mean"`, `"sd"`, `"se"`, `"median"`, `"q1 to q3"`, `"range"`, `"q1"`, `"q3"`, `"min"`, `"max"`.
#'   Default is `c("mean", "sd", "se", "median", "q1 to q3", "range")`.
#' @param data_source_txt Character string specifying the data source label to appear in the table footer.
#'   Default is `"Source: [MKxxxx: adam-adsl]"`.
#' @param rel_col_widths Numeric vector specifying relative column widths for the output table.
#'   Must match the number of columns in the output table. Default is `NULL` (automatic).
#' @param font_size Numeric font size for the table text. Default is `9`.
#' @param page_orientation Character string specifying page orientation for the output table. Options: `"portrait"` or `"landscape"`. Default is `"portrait"`.
#' @param end_notes Character vector of footnotes to include at the end of the table. Default is `NULL`.
#' @param title Character vector specifying the table title lines. If `NULL`, title is generated from metadata. Default is `NULL`.
#' @param path_outdata File path to save the intermediate R data output. Default is `paste0(path$outdata, "/asr0baseline0characteristics.Rdata")`.
#' @param path_outtable File path to save the final RTF table output. Default is `paste0(path$outtable, "/asr0baseline0characteristics.rtf")`.
#'
#' @return Invisibly returns a list containing the processed data and RTF output.
#' @export
#'
#' @examples
#' \dontrun{
#' asr0baseline0characteristics(meta = meta, population = "apat", parameter = "age;gender;race")
#' }
asr0baseline0characteristics <- function(meta = meta,
                                         # analysis = "base0char" specifies the analysis term defined in meta. Used for generating title.
                                         analysis = "base0char",
                                         # population = "apat" specifies the analysis population of the baseline characteristics table.
                                         # In this example, "apat" population is defined as, in ADSL, filtered by SAFFL is "Y' and TRT01A is not missing, group by TRT01A and "apat" is labeling as "(All Participants as Treated)" in the TLF
                                         population = "apat",
                                         # default we have three variable Age, Sex and Race. User could add other variable.
                                         parameter = "age;gender;race",
                                         # TODO: implement a new argument frame as the input dataframe to control the order section and category. More details are illustrated in the code of Part 1.
                                         # frame,
                                         # display_col controls whether the counts, proportion and total column is displayed.
                                         # This arguments replaced the parameter display_totals from SAS macro %asr0baseline0characteristics.
                                         display_col = c("n", "prop", "total"),
                                         # TODO: implement a new argument display_totals_select_grps which has the same logic in SAS macro %asr0baseline0characteristics.
                                         # The input of this variable contains column label and treatment group code selected. (i.e., "Total Column" ~ 1 + 2)
                                         # display_totals_select_grps = NULL,
                                         # decimal_places_percent has the same functionality as decimal_places_percent from SAS macro %asr0baseline0characteristics to define the number of digits to display after the decimal place for a percentage
                                         decimal_places_percent = 2,
                                         # display_stat controls the statistics displayed in the output table.
                                         # user needs to select the statistics term from `c("mean", "sd", "se", "median", "q1 to q3", "range", "q1", "q3", "min", "max")`
                                         # if the statistics term displays in the vector, then it will be displayed. Otherwise, it will not be displayed.
                                         # This argument combines parameter display_mean, display_median, display_q1_q3, display_range, display_std_dev, display_std_err from SAS macro %asr0baseline0characteristics.
                                         display_stat = c("mean", "sd", "se", "median", "q1 to q3", "range"),
                                         # data_source_txt argument controls data source label. user have to manually provide the text.
                                         # TODO: Ideally, the data_source_txt text should be generted automatically by metadata and the analysis term specifies.
                                         data_source_txt = "Source: [MKxxxx: adam-adsl]",
                                         # rel_col_widths controls the relative column width. This argument has the same concept as parameter rel_col_widths from SAS macro %asr0baseline0characteristics
                                         rel_col_widths = NULL,
                                         # font_size controls font size for table. Same as font_size from SAS macro %asr0baseline0characteristics
                                         font_size = 9,
                                         # page_orientation controls the page orientation of the table. Same as page_orientation from SAS macro %asr0baseline0characteristics
                                         page_orientation = "portrait",
                                         # end_notes is similar to end_notes from SAS macro %asr0baseline0characteristics which controls text to appear as end notes in the table.
                                         end_notes = NULL,
                                         # title combines the functionality of title_alternative and subtitle from SAS macro %asr0baseline0characteristics.
                                         # By default, it collects title from metadata. User can also define a character vector for each line of table titles.
                                         title = NULL,
                                         path_outdata = paste0(path$outdata, "/asr0baseline0characteristics.Rdata"),
                                         path_outtable = paste0(path$outtable, "/asr0baseline0characteristics.rtf")) {
  ## PART 1: manipulate the input data to make the variables displayed in a desired way
  # These variables include section variable(i.e., AGE, SEX, RACE) category variable (i.e., AGEGRP1) and treatment group variable (i.e., TRT01P)
  # Section variable is defined by the parameter term in metadata. ; is used to concatenate different parameter term.
  parameters <- unlist(strsplit(parameter, ";"))
  # Get the variable name for each section variable (i.e., AGE, SEX, RACE)
  par_var <- do.call(c, lapply(parameters, function(x) {
    metalite::collect_adam_mapping(meta, x)$var
  }))
  # Get the category variable probably defined in term for section variable (i.e., AGEGRP1)
  par_var_group <- do.call(c, lapply(parameters, function(x) {
    metalite::collect_adam_mapping(meta, x)$vargroup
  }))
  # TODO: use the `var_lower` to implement the same logic as ethnic_by_race and display_multi_race in SAS macro %asr0baseline0characteristics
  par_var_lower <- do.call(c, lapply(parameters, function(x) {
    metalite::collect_adam_mapping(meta, x)$var_lower
  }))
  # No observation since only ADSL is used
  observation <- population

  # Get the treatment variable (i.e., TRT01P) defined in population
  pop_group <- metalite::collect_adam_mapping(meta, population)$group

  # TODO: Make the section variable displayed in desired order by converting into factor.
  # The order is getting from a dataframe same as the FRAME dataset (always called lptmt.asr0fram) when using SAS Macro
  # Convert the section variable into factor with all the possible value shown in the data frame, even it is not existed in the variable
  # If the value is blank, "Missing" will be used.

  # TODO: Make the category variable displayed in desired order by converting into factor.
  # The order is getting from a dataframe same as the FRAME dataset (always called lptmt.asr0fram) when using SAS Macro
  # Convert the category variable into factor with all the possible value shown in the section_frame dataframe. even it is not existed in the variable

  # TODO: Make the treatment variable displayed in desired order by converting into factor.
  # The order is getting from the numeric value corresponding to the treatment arm variable. For example, if "TRT01P" is the variable then "TRT01PN" is used for ordering.

  ## PART 2: calculate the counts and proportion for column displaying in baseline characteristics table
  # The code below is wrapped into metalite.sl::prepare_sl_summary() which might not be able to use for other tables.
  pop_id <- metalite::collect_adam_mapping(meta, population)$id
  pop <- metalite::collect_population_record(meta, population,
    var = c(par_var, par_var_group, par_var_lower)
  )
  group <- unique(pop[[pop_group]])
  # Get the population counts for each treatment group
  n_pop <- metalite::n_subject(id = pop[[pop_id]], group = pop[[pop_group]])
  names(n_pop) <- do.call(c, lapply(as.numeric(factor(names(n_pop),
    levels = levels(pop[[pop_group]])
  )), function(x) {
    paste0("n_", x)
  }))
  n_pop$n_9999 <- sum(n_pop[1, ])
  n_pop$name <- "Participants in population"
  n_pop <- n_pop[, c(length(group) + 2, 1:(length(group) +
    1))]
  n_pop$var_label <- "-----"
  char_var <- par_var
  # Get the counts for each section variable by treatment group
  # TODO: `name` column contains AGE unit should generated automatically from variable such as AGEU in ADSL
  # TODO: "Unknown" age category will be included in summary statistics calculation here in prepare_base_char().
  char_n <- lapply(parameters, function(x) {
    collect_baseline(meta, population, x)[[2]]
  })
  # Get the proportion for each section variable by treatment group
  char_prop <- lapply(parameters, function(x) {
    collect_baseline(meta, population, x)[[3]]
  })
  # Get the variable type for each section variable
  var_type <- lapply(parameters, function(x) {
    collect_baseline(meta, population, x)[[4]]
  })
  # TODO: If implement CDISC ARS, table level metadata such as AnlysisGrouping, AnalysisProgrammingCode should be generated in this part.
  outdata <- metalite::outdata(meta, population, observation, parameter,
    n = n_pop, order = NULL, group = pop_group, reference_group = NULL,
    char_n = char_n, char_var = char_var, char_prop = char_prop,
    var_type = var_type, group_label = unique(pop[[pop_group]]),
    analysis = analysis
  )
  ## PART 3: format the analysis results displaying in baseline characteristics table
  # The code below is wrapped into metalite.sl::format_sl_summary() which might not be able to use for other tables.
  n_group <- length(outdata$group_label)
  if ("tbl" %in% names(outdata)) {
    outdata$tbl <- NULL
  }
  # select the descriptive statistics displayed on the output table
  for (i in 1:length(outdata$var_type)) {
    if (("integer" %in% outdata$var_type[[i]]) || ("numeric" %in%
      outdata$var_type[[i]])) {
      n_num <- outdata$char_n[[i]]
      n_num_group <- n_num[which(!tolower(n_num$name) %in%
        c(
          "mean", "sd", "se", "median", "q1 to q3", "range",
          "q1", "q3", "min", "max"
        )), ]
      n_num_stat <- n_num[which(tolower(n_num$name) %in%
        tolower(display_stat)), ] # Fixed: added tolower() for consistent comparison
      n_num <- rbind(n_num_group, n_num_stat)
      outdata$char_n[[i]] <- n_num
      outdata$char_prop[[i]] <- outdata$char_prop[[i]][which(outdata$char_prop[[i]]$name %in%
        n_num$name), ]
    }
  }
  # TODO: logic for display_totals_select_grps should be implemented from here
  # select the counts, proportion and 'total' columns displayed on the output table
  tbl <- list()
  if ("n" %in% display_col) {
    n <- do.call(rbind, outdata$char_n)
    if ("total" %in% display_col) {
      names(n) <- c(
        "name", paste0("n_", seq(1, n_group)),
        "n_9999", "var_label"
      )
    } else {
      n <- n[, -(2 + n_group)]
      names(n) <- c(
        "name", paste0("n_", seq(1, n_group)),
        "var_label"
      )
    }
    tbl[["n"]] <- n
  }
  tbl$n <- rbind(
    outdata$n[, names(outdata$n) %in% names(tbl$n)],
    tbl$n
  )
  if ("prop" %in% display_col) {
    prop <- do.call(rbind, outdata$char_prop)
    name <- prop$name
    label <- prop$var_label
    value <- data.frame(apply(
      prop[2:(ncol(prop) - 1)], 2,
      function(x) as.numeric(as.character(x))
    ))
    prop <- as.data.frame(apply(value, 2, metalite.ae::fmt_pct,
      digits = decimal_places_percent, pre = "(", post = ")"
    ))
    prop <- data.frame(name = name, prop, var_label = label)
    if ("total" %in% display_col) {
      names(prop) <- c(
        "name", paste0("p_", seq(1, n_group)),
        "p_9999", "var_label"
      )
    } else {
      prop <- prop[, -(2 + n_group)]
      names(prop) <- c(
        "name", paste0("p_", seq(1, n_group)),
        "var_label"
      )
    }
    tbl[["prop"]] <- prop
  }
  # Ordering the columns
  tbl$prop <- rbind(
    c(tbl$n[1, 1], rep(NA, ifelse("total" %in%
      display_col, n_group + 1, n_group)), tbl$n[1, ncol(tbl$n)]),
    tbl$prop
  )
  within_var <- names(tbl)[names(tbl) %in% c("n", "prop")]
  within_tbl <- tbl[within_var]
  names(within_tbl) <- NULL
  n_within <- length(within_tbl)
  n_row <- ncol(tbl[["n"]])
  within_tbl <- do.call(cbind, within_tbl)
  within_tbl <- within_tbl[, !duplicated(names(within_tbl))]
  within_tbl <- within_tbl[, c(1, do.call(c, lapply(2:(1 +
    n_group + ifelse("total" %in% display_col, 1, 0)), function(x) {
    c(x, x + n_group + ifelse("total" %in% display_col, 1,
      0
    ) + 1)
  })), (1 + n_group + ifelse("total" %in% display_col, 1, 0) +
    1))]
  rownames(within_tbl) <- NULL
  outdata$tbl <- within_tbl
  outdata$display_col <- display_col
  outdata$display_stat <- display_stat
  # TODO: If implement CDISC ARS, table level metadata such as AnlysisResults, AnalysisMethods should be generated in this part.

  ## PART 4: generate the RTF output
  # The code below is wrapped into metalite.sl::rtf_sl_summary() which might not be able to use for other tables.
  tbl <- outdata$tbl
  display_total <- "total" %in% outdata$display_col
  # TODO: consider the implementation of display_totals_select_grps when calculating the number of columns
  if (display_total == TRUE) {
    group <- c(levels(outdata$group_label), "Total")
    n_group <- length(outdata$group_label) + 1
  } else {
    group <- levels(outdata$group_label)
    n_group <- length(outdata$group_label)
  }
  n_row <- nrow(tbl)
  n_col <- ncol(tbl)
  # Fixed: changed col_rel_width to rel_col_widths to match the function parameter
  if (!is.null(rel_col_widths) && !(n_col == length(rel_col_widths))) {
    stop("rel_col_widths must have the same length (has ",
      length(rel_col_widths), ") as `outdata$tbl` has number of columns (has ",
      n_col, ").",
      call. = FALSE
    )
  }
  # Collect the title automatically from metadata if eligible
  if (is.null(title)) {
    title <- metalite::collect_title(outdata$meta, outdata$population,
      "", outdata$parameter,
      analysis = outdata$analysis
    )
  }
  # Collect the footnote automatically from metadata if eligible
  # TODO: "a Not included in summary statistics for age." will not be displayed when "Unknown" is displayed in the Age Category Row
  footnotes_stat <- NULL
  # Fixed: properly check var_type which is a list
  if (any(sapply(outdata$var_type, function(x) "integer" %in% x || "numeric" %in% x))) {
    if ("sd" %in% tolower(outdata$display_stat)) {
      footnotes_stat <- c(footnotes_stat, "SD=Standard deviation")
    }
    if ("se" %in% tolower(outdata$display_stat)) {
      # Fixed: complete the word "error"
      footnotes_stat <- c(footnotes_stat, paste0("SE=Standard error"))
    }
    if ("q1 to q3" %in% tolower(outdata$display_stat)) {
      footnotes_stat <- c(footnotes_stat, "Q1=First quartile, Q3=Third quartile")
    }
    footnotes_stat <- paste(footnotes_stat, collapse = "; ")
    if (nchar(footnotes_stat) > 0) {
      if (!is.null(end_notes)) {
        end_notes <- c(paste0(footnotes_stat, "."), end_notes)
      } else {
        end_notes <- paste0(footnotes_stat, ".")
      }
    }
  }
  colheader <- c(
    paste0(" | ", paste(group, collapse = " | ")),
    paste0(" | ", paste(rep("n | (%)", n_group), collapse = " | "))
  )

  # prepare the parameter for controlling the layout of RTF table
  if (is.null(rel_col_widths)) {
    rel_width_body <- c(3, rep(1, 2 * n_group), 1)
  } else {
    rel_width_body <- rel_col_widths
  }
  rel_width_head2 <- rel_width_body[1:(length(rel_width_body) -
    1)]
  rel_width_head1 <- c(rel_width_head2[1], tapply(rel_width_head2[2:(n_group *
    2 + 1)], c(rep(1:n_group, each = 2)), sum), rel_width_head2[-(1:(n_group * 2 + 1))])
  border_top <- c("", rep("single", n_group * 2))
  border_top_body <- c(rep("", n_col - 1), "single")
  border_bottom <- c(rep("", n_col - 1), "single")
  border_left <- c("single", rep(c("single", ""), n_group))
  border_left_body <- c(border_left, "single")
  text_format <- c(rep("", 1 + n_group * 2), "b")
  text_justification <- c("l", rep("c", n_group * 2), "l")
  text_indent <- matrix(0, nrow = n_row, ncol = n_col)
  text_indent[, 1] <- ifelse(FALSE, 0, 100)
  text_indent[1, 1] <- 0

  # Use functions from r2rtf to generate the RTF output
  # Fixed: changed text_font_size to font_size in the first occurrence
  outdata$rtf <- r2rtf::rtf_body(
    r2rtf::rtf_colheader(
      r2rtf::rtf_colheader(
        r2rtf::rtf_title(r2rtf::rtf_page(tbl,
          orientation = page_orientation
        ), title),
        colheader = colheader[1],
        col_rel_width = rel_width_head1, text_font_size = font_size
      ),
      colheader = colheader[2], border_top = border_top, border_left = border_left,
      col_rel_width = rel_width_head2, text_font_size = font_size
    ),
    page_by = "var_label", col_rel_width = rel_width_body,
    border_left = border_left_body, border_top = border_top_body,
    border_bottom = border_bottom, text_justification = text_justification,
    text_indent_first = text_indent, text_indent_left = text_indent,
    text_format = text_format, text_font_size = font_size
  )
  if (!is.null(end_notes)) {
    outdata$rtf <- r2rtf::rtf_footnote(outdata$rtf, end_notes,
      text_font_size = font_size
    )
  }

  if (!is.null(data_source_txt)) {
    outdata$rtf <- r2rtf::rtf_source(outdata$rtf, data_source_txt,
      text_font_size = font_size
    )
  }
  rtf_output(outdata, path_outdata, path_outtable)
}
