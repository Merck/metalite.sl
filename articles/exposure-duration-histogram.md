# Interactive exposure duration histogram

``` r
library(metalite.sl)
library(dplyr)
```

## Create Exposure Duration Histogram

The plotly_exp_duration() function provides an interactive visualization
of subject-level exposure duration in clinical trials. This histogram
helps assess how long participants remained on treatment, with
configurable duration categories such as “≥1 day”, “≥7 days”, “≥28
days”, and so on.

Using pre-processed output from prepare_exp_duration() (and optionally
extend_exp_duration()), plotly_exp_duration() generates an intuitive,
browser-based plot built with Plotly. Users can customize the display
type (e.g., counts or proportions), color, tooltip summary statistics,
and axis labels.

- `meta_sl_exposure_example`: create example exposure metadata (`meta`
  object) for demonstration or testing purposes.

- `prepare_exp_duration`: process subject-level exposure data to
  calculate treatment duration and prepare it for further analysis.

- `extend_exp_duration`: categorize duration into user-defined time
  windows (e.g., ≥7 days, ≥12 weeks) and add group-level summaries.

- `plotly_exp_duration`: generate an interactive histogram plot to
  visualize exposure duration distribution across subjects or treatment
  arms.

### 1. Build a metadata

### meta_sl_exposure_example()

There are two steps in `meta_sl_exposure_example` function in order to
build the metadata (`meta` object): processing the ADaM dataset and save
meta information for A&R reporting.

Step1: ADEXSUM, the ADaM dataset for Drug Exposrue Summary Data, is
utilized to:

- Sum up duration by STUDYID SITENUM USUBJID SUBJID APERIOD EXTRT
  ADOSEFRM PARAMCD.
- Subset the exposure data by `upcase(trim(left(paramcd))) = "TRTDUR"`.
- Get the exposure duration `adexsum$AVAL` for all participants.
- Assign duration category `adexsum$EXDURGR` i.e.”\>=1 day”, “\>=7
  days”,“\>=28 days”, “\>=12 weeks” and “\>=24 weeks”.

``` r
adsl <- r2rtf::r2rtf_adsl
adexsum <- data.frame(USUBJID = adsl$USUBJID)
adexsum$TRTA <- factor(adsl$TRT01A,
  levels = c("Placebo", "Xanomeline Low Dose", "Xanomeline High Dose"),
  labels = c("Placebo", "Low Dose", "High Dose")
)

adexsum$APERIODC <- "Base"
adexsum$APERIOD <- 1

set.seed(123) # Set a seed for reproducibility
adexsum$AVAL <- sample(x = 0:(24 * 7), size = length(adexsum$USUBJID), replace = TRUE)
adexsum$EXDURGR <- "not treated"
adexsum$EXDURGR[adexsum$AVAL >= 1] <- ">=1 day"
adexsum$EXDURGR[adexsum$AVAL >= 7] <- ">=7 days"
adexsum$EXDURGR[adexsum$AVAL >= 28] <- ">=28 days"
adexsum$EXDURGR[adexsum$AVAL >= 12 * 7] <- ">=12 weeks"
adexsum$EXDURGR[adexsum$AVAL >= 24 * 7] <- ">=24 weeks"

adexsum$EXDURGR <- factor(adexsum$EXDURGR,
  levels = c("not treated", ">=1 day", ">=7 days", ">=28 days", ">=12 weeks", ">=24 weeks")
)
unique(adexsum$EXDURGR)
#> [1] >=12 weeks  >=7 days    >=28 days   >=1 day     >=24 weeks  not treated
#> Levels: not treated >=1 day >=7 days >=28 days >=12 weeks >=24 weeks
```

Step2: Save analysis plan and metadata(parameter and analysis)
information, then build meta object.

``` r
plan <- metalite::plan(
  analysis = "exp_dur", population = "apat",
  observation = "apat", parameter = "expdur"
)

meta <- metalite::meta_adam(
  population = adexsum,
  observation = adexsum
) |>
  metalite::define_plan(plan) |>
  metalite::define_population(
    name = "apat",
    group = "TRTA",
    subset = quote(APERIOD == 1 & AVAL > 0)
  ) |>
  metalite::define_parameter(
    name = "expdur",
    var = "AVAL",
    label = "Exposure Duration (Days)",
    vargroup = "EXDURGR"
  ) |>
  metalite::define_analysis(
    name = "exp_dur",
    title = "Summary of Exposure Duration",
    label = "exposure duration table"
  ) |>
  metalite::meta_build()
```

### 2. Analysis preparation

### prepare_exp_duration()

The input of the function
[`prepare_exp_duration()`](https://merck.github.io/metalite.sl/reference/prepare_exp_duration.md)
is a `meta` object created by the metalite package. The resulting output
comprises a collection of raw datasets for analysis and reporting.

This function takes raw data (e.g., participant-level data with exposure
durations and treatment groups). It calculates summary statistics
(counts, proportions, medians, etc.) grouped by treatment group. It also
creates exposure duration categories (e.g., \>=1 day, \>=7 days, etc.)
by binning or categorizing the raw exposure duration variable. The
output is a structured dataset (outdata) that contains: Counts and
proportions of participants in each treatment group. Summary statistics
for the exposure duration variable within each treatment group. However,
at this stage, the statistics are grouped only by treatment group, not
yet broken down by exposure duration categories.

``` r
outdata <- prepare_exp_duration(meta)
outdata
#> List of 14
#>  $ meta           :List of 7
#>  $ population     : chr "apat"
#>  $ observation    : chr "apat"
#>  $ parameter      : chr "expdur"
#>  $ n              :'data.frame': 1 obs. of  6 variables:
#>  $ order          : NULL
#>  $ group          : chr "TRTA"
#>  $ reference_group: NULL
#>  $ char_n         :List of 1
#>  $ char_var       : chr "AVAL"
#>  $ char_prop      :List of 1
#>  $ var_type       :List of 1
#>  $ group_label    : Factor w/ 3 levels "Placebo","Low Dose",..: 1 3 2
#>  $ analysis       : chr "exp_dur"
```

Number of participants in population

``` r
outdata$n[, 1:5]
#>                         name n_1 n_2 n_3 n_9999
#> 1 Participants in population  86  83  84    253
```

Number of participants in each duration category

``` r
charn <- data.frame(outdata$char_n[1])
head(charn[, 1:5], 6)
#>          name Placebo Low.Dose High.Dose Total
#> 1 not treated       0        0         0     0
#> 2     >=1 day       2        4         3     9
#> 3    >=7 days      13       11         9    33
#> 4   >=28 days      31       20        27    78
#> 5  >=12 weeks      39       48        45   132
#> 6  >=24 weeks       1        0         0     1
```

Proportion of participants in each duration category

``` r
charp <- data.frame(outdata$char_prop[1])
head(charp[, 1:5], 6)
#>          name   Placebo  Low.Dose High.Dose      Total
#> 1 not treated  0.000000  0.000000  0.000000  0.0000000
#> 2     >=1 day  2.325581  4.819277  3.571429  3.5573123
#> 3    >=7 days 15.116279 13.253012 10.714286 13.0434783
#> 4   >=28 days 36.046512 24.096386 32.142857 30.8300395
#> 5  >=12 weeks 45.348837 57.831325 53.571429 52.1739130
#> 6  >=24 weeks  1.162791  0.000000  0.000000  0.3952569
```

Statistical summary of exposure duration for each treatment

``` r
chars <- data.frame(outdata$char_n[1])
tail(chars[, 1:5], 8)
#>        name         Placebo    Low.Dose       High.Dose     Total
#> 8      Mean            81.5        90.8            87.6      86.6
#> 9        SD            49.1        51.3            48.8      49.7
#> 10       SE             5.3         5.6             5.3       3.1
#> 11   Median            76.0        93.0            90.0      88.0
#> 12      Min             3.0         1.0             4.0       1.0
#> 13      Max           168.0       167.0           167.0     168.0
#> 14 Q1 to Q3 41.25 to 123.25 48 to 137.5 44.75 to 129.25 44 to 133
#> 15    Range        3 to 168    1 to 167        4 to 167  1 to 168
```

### extend_exp_duration()

This function takes the output of prepare_exp_duration() and further
processes the data to create exposure duration categories explicitly. It
applies the specified duration category cutoffs (e.g., \>=1 day, \>=7
days, etc.) to the exposure duration variable. It calculates counts,
proportions, and summary statistics for each exposure duration category
within each treatment group. This means now we have a two-dimensional
grouping: By treatment group (e.g., Placebo, Low Dose and High Dose). By
exposure duration category (e.g., \>=1 day, \>=7 days). The output
outdata now contains tables like: char_n: counts by exposure duration
category and treatment group. char_prop: proportions by exposure
duration category and treatment group. char_stat_groups: summary
statistics by exposure duration category and treatment group.

``` r
outdata <- meta |>
  prepare_exp_duration() |>
  extend_exp_duration(
    duration_category_list = list(c(1, NA), c(7, NA), c(28, NA), c(12 * 7, NA), c(24 * 7, NA)),
    duration_category_labels = c(">=1 day", ">=7 days", ">=28 days", ">=12 weeks", ">=24 weeks")
  )
outdata
#> List of 19
#>  $ meta            :List of 7
#>  $ population      : chr "apat"
#>  $ observation     : chr "apat"
#>  $ parameter       : chr "expdur"
#>  $ n               :'data.frame':    1 obs. of  6 variables:
#>  $ order           : NULL
#>  $ group           : chr "TRTA"
#>  $ reference_group : NULL
#>  $ char_n          :List of 1
#>  $ char_var        : chr "AVAL"
#>  $ char_prop       :List of 1
#>  $ var_type        :List of 1
#>  $ group_label     : Factor w/ 3 levels "Placebo","Low Dose",..: 1 3 2
#>  $ analysis        : chr "exp_dur"
#>  $ char_stat_groups:List of 5
#>  $ char_n_cum      :List of 1
#>  $ char_prop_cum   :List of 1
#>  $ char_stat_cums  :List of 5
#>  $ extend_call     :List of 1
```

``` r
all_stats <- bind_rows(outdata$char_stat_groups, .id = "duration_category")

all_stats
#>    duration_category     name      Placebo         Low Dose  High Dose
#> 1            >=1 day     Mean          4.5              4.0        5.0
#> 2            >=1 day       SD          2.1              2.4        1.0
#> 3            >=1 day       SE          1.5              1.2        0.6
#> 4            >=1 day   Median          4.5              4.5        5.0
#> 5            >=1 day      Min          3.0              1.0        4.0
#> 6            >=1 day      Max          6.0              6.0        6.0
#> 7            >=1 day Q1 to Q3 3.75 to 5.25         2.5 to 6 4.5 to 5.5
#> 8            >=1 day    Range       3 to 6           1 to 6     4 to 6
#> 9           >=7 days     Mean         17.6             17.8       19.1
#> 10          >=7 days       SD          6.0              5.4        6.6
#> 11          >=7 days       SE          1.7              1.6        2.2
#> 12          >=7 days   Median         21.0             19.0       21.0
#> 13          >=7 days      Min          9.0              9.0        8.0
#> 14          >=7 days      Max         25.0             25.0       26.0
#> 15          >=7 days Q1 to Q3     13 to 23         14 to 22   15 to 25
#> 16          >=7 days    Range      9 to 25          9 to 25    8 to 26
#> 17         >=28 days     Mean         55.3             57.2       54.1
#> 18         >=28 days       SD         15.1             16.8       16.6
#> 19         >=28 days       SE          2.7              3.7        3.2
#> 20         >=28 days   Median         54.0             54.5       53.0
#> 21         >=28 days      Min         28.0             29.0       29.0
#> 22         >=28 days      Max         80.0             82.0       83.0
#> 23         >=28 days Q1 to Q3 44.5 to 67.5      43.75 to 73 40.5 to 68
#> 24         >=28 days    Range     28 to 80         29 to 82   29 to 83
#> 25        >=12 weeks     Mean        125.4            128.8      126.8
#> 26        >=12 weeks       SD         27.5             25.1       25.4
#> 27        >=12 weeks       SE          4.4              3.6        3.8
#> 28        >=12 weeks   Median        124.0            135.0      126.0
#> 29        >=12 weeks      Min         89.0             84.0       84.0
#> 30        >=12 weeks      Max        165.0            167.0      167.0
#> 31        >=12 weeks Q1 to Q3  98.5 to 155 108.75 to 150.25 105 to 152
#> 32        >=12 weeks    Range    89 to 165        84 to 167  84 to 167
#> 33        >=24 weeks     Mean        168.0             <NA>       <NA>
#> 34        >=24 weeks       SD           NA             <NA>       <NA>
#> 35        >=24 weeks       SE           NA             <NA>       <NA>
#> 36        >=24 weeks   Median        168.0             <NA>       <NA>
#> 37        >=24 weeks      Min        168.0             <NA>       <NA>
#> 38        >=24 weeks      Max        168.0             <NA>       <NA>
#> 39        >=24 weeks Q1 to Q3   168 to 168             <NA>       <NA>
#> 40        >=24 weeks    Range   168 to 168             <NA>       <NA>
#>         Total                var_label
#> 1         4.4 Exposure Duration (Days)
#> 2         1.8 Exposure Duration (Days)
#> 3         0.6 Exposure Duration (Days)
#> 4         5.0 Exposure Duration (Days)
#> 5         1.0 Exposure Duration (Days)
#> 6         6.0 Exposure Duration (Days)
#> 7      3 to 6 Exposure Duration (Days)
#> 8      1 to 6 Exposure Duration (Days)
#> 9        18.1 Exposure Duration (Days)
#> 10        5.8 Exposure Duration (Days)
#> 11        1.0 Exposure Duration (Days)
#> 12       20.0 Exposure Duration (Days)
#> 13        8.0 Exposure Duration (Days)
#> 14       26.0 Exposure Duration (Days)
#> 15   13 to 23 Exposure Duration (Days)
#> 16    8 to 26 Exposure Duration (Days)
#> 17       55.4 Exposure Duration (Days)
#> 18       15.9 Exposure Duration (Days)
#> 19        1.8 Exposure Duration (Days)
#> 20       53.0 Exposure Duration (Days)
#> 21       28.0 Exposure Duration (Days)
#> 22       83.0 Exposure Duration (Days)
#> 23 42 to 70.5 Exposure Duration (Days)
#> 24   28 to 83 Exposure Duration (Days)
#> 25      127.1 Exposure Duration (Days)
#> 26       25.7 Exposure Duration (Days)
#> 27        2.2 Exposure Duration (Days)
#> 28      130.5 Exposure Duration (Days)
#> 29       84.0 Exposure Duration (Days)
#> 30      167.0 Exposure Duration (Days)
#> 31 105 to 152 Exposure Duration (Days)
#> 32  84 to 167 Exposure Duration (Days)
#> 33      168.0 Exposure Duration (Days)
#> 34         NA Exposure Duration (Days)
#> 35         NA Exposure Duration (Days)
#> 36      168.0 Exposure Duration (Days)
#> 37      168.0 Exposure Duration (Days)
#> 38      168.0 Exposure Duration (Days)
#> 39 168 to 168 Exposure Duration (Days)
#> 40 168 to 168 Exposure Duration (Days)
```

### plotly_exp_duration()

The function takes the fully prepared outdata from the above steps to
simply visualizes these pre-calculated statistics in an interactive way.
It reshapes the counts and proportions tables from wide to long format,
so each row corresponds to a specific combination of: Exposure duration
category (e.g., \>=7 days). Treatment group (e.g., Placebo). It uses
these reshaped tables to create stacked bar charts or grouped bar charts
that show: The number or proportion of participants in each exposure
duration category for each treatment group. It also uses the summary
statistics (char_stat_groups) to create hover text that shows detailed
statistics for each bar (i.e., for each treatment group × exposure
duration category). The interactive dropdown lets you switch between
different views (e.g., cumulative exposure duration, exclusive
categories, horizontal bars).

Histogram type

Comparison of Exposure Duration (\> = x days) by Treatment Groups
Comparison of Exposure Duration (\> = x days and \< y days) by Treatment
Groups Comparison by Exposure Duration (\> = x days)
