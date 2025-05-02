# metalite.sl 0.1.1

## New features

-   `react_disposition()` now has new arguments `trtvar`, `sl_col_selected`, `sl_col_names`, `ae_observation`. `ae_population`, `ae_col_selected`, and `ae_col_names` to customize subject lists in an interactive disposition table (#72, #100).
-   Add a vignette for an interactive disposition table (#77).
-   Add new utility function `extract_duration_category_ranges()` to extract category labels from fixed-format strings (#76).

## Bug fixes

-   Fix a bug to correctly extract subjects for a list of each disposition event in `react_disposition()` (#74, #100).
-   Fix a bug to correct the order of the first-level header of a table and to correctly merge data when the row dimention differs between groups in `base_char_subgroup()` (#80).

## Improvements

-   Remove the `forestly` dependency (#72, #75, #100).
-   Update `plotly_exp_duration()` to change the example, the default value of `duration_category_list` and `duration_category_labels`, and the labels of a drop down for histograms (#73, #92).
-   Update `react_disposition()` to change the default value of `population` and `sl_parameter` according to the new metadata structure, and to modify the condition under which a drill-down list is available for a disposition (#74, #77, #93).
-   Update `extend_exp_duration()` to set the default value of `category_section_label`, `duration_category_list`, and `duration_category_labels` (#76).
-   Update `meta_sl_example()` to add AE data example for disposition analysis, remove factorization of SEX, and change the variable name of medication disposition (#77, #78).
-   The argument controlling the display total for the second-level header is moved from `prepare_base_char_subgroup()` to `format_base_char_subgroup()`, and it is renamed to `display_total`(#80).
-   Update `format_base_char_subgroup()` to adjust alignment of count values when a subgroup has no subject for a parameter value (#83).
-   Update `react_base_char()` to display an error message when there is a mismatch between display values in sl summary table and AE table column names of a subgroup, and to add space before rows labeled "with one or more adverse events," "with no adverse events," and the AE terms in a drill-down table (#84, #97).

# metalite.sl 0.1.0

-   Initial version.
-   Added a `NEWS.md` file to track changes to the package.
