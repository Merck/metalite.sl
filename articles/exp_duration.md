# Exposure Duration Table

``` r
library(metalite)
library(metalite.sl)
```

## Create Exposure Duration Table

The exposure duration analysis aims to provide table to summarize by
each identified duration category. The development of exposure duration
analysis involves functions:

- `meta_sl_exposure_example`: build the metadata (`meta` object) for
  analysis.
- `prepare_exp_duration`: prepare analysis raw datasets.
- `format_exp_duration`: prepare analysis outdata with proper format.
- `rtf_exp_duration`: transfer (mock) output dataset to RTF table.

### Build a metadata

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
```

    ## [1] >=12 weeks  >=7 days    >=28 days   >=1 day     >=24 weeks  not treated
    ## Levels: not treated >=1 day >=7 days >=28 days >=12 weeks >=24 weeks

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

### Analysis preparation

The input of the function
[`prepare_exp_duration()`](https://merck.github.io/metalite.sl/reference/prepare_exp_duration.md)
is a `meta` object created by the metalite package. The resulting output
comprises a collection of raw datasets for analysis and reporting.

``` r
outdata <- prepare_exp_duration(meta)
outdata
```

    ## List of 14
    ##  $ meta           :List of 7
    ##  $ population     : chr "apat"
    ##  $ observation    : chr "apat"
    ##  $ parameter      : chr "expdur"
    ##  $ n              :'data.frame': 1 obs. of  6 variables:
    ##  $ order          : NULL
    ##  $ group          : chr "TRTA"
    ##  $ reference_group: NULL
    ##  $ char_n         :List of 1
    ##  $ char_var       : chr "AVAL"
    ##  $ char_prop      :List of 1
    ##  $ var_type       :List of 1
    ##  $ group_label    : Factor w/ 3 levels "Placebo","Low Dose",..: 1 3 2
    ##  $ analysis       : chr "exp_dur"

Number of participants in population

``` r
outdata$n[, 1:5]
```

    ##                         name n_1 n_2 n_3 n_9999
    ## 1 Participants in population  86  83  84    253

Number of participants in each duration category

``` r
charn <- data.frame(outdata$char_n[1])
head(charn[, 1:5], 6)
```

    ##          name Placebo Low.Dose High.Dose Total
    ## 1 not treated       0        0         0     0
    ## 2     >=1 day       2        4         3     9
    ## 3    >=7 days      13       11         9    33
    ## 4   >=28 days      31       20        27    78
    ## 5  >=12 weeks      39       48        45   132
    ## 6  >=24 weeks       1        0         0     1

Proportion of participants in each duration category

``` r
charp <- data.frame(outdata$char_prop[1])
head(charp[, 1:5], 6)
```

    ##          name   Placebo  Low.Dose High.Dose      Total
    ## 1 not treated  0.000000  0.000000  0.000000  0.0000000
    ## 2     >=1 day  2.325581  4.819277  3.571429  3.5573123
    ## 3    >=7 days 15.116279 13.253012 10.714286 13.0434783
    ## 4   >=28 days 36.046512 24.096386 32.142857 30.8300395
    ## 5  >=12 weeks 45.348837 57.831325 53.571429 52.1739130
    ## 6  >=24 weeks  1.162791  0.000000  0.000000  0.3952569

Statistical summary of exposure duration for each treatment

``` r
chars <- data.frame(outdata$char_n[1])
tail(chars[, 1:5], 8)
```

    ##        name         Placebo    Low.Dose       High.Dose     Total
    ## 8      Mean            81.5        90.8            87.6      86.6
    ## 9        SD            49.1        51.3            48.8      49.7
    ## 10       SE             5.3         5.6             5.3       3.1
    ## 11   Median            76.0        93.0            90.0      88.0
    ## 12      Min             3.0         1.0             4.0       1.0
    ## 13      Max           168.0       167.0           167.0     168.0
    ## 14 Q1 to Q3 41.25 to 123.25 48 to 137.5 44.75 to 129.25 44 to 133
    ## 15    Range        3 to 168    1 to 167        4 to 167  1 to 168

### Format output

`format_exp_duration` to prepare analysis dataset before generate RTF
output

``` r
tbl <- format_exp_duration(outdata, display_col = c("n", "prop", "total"))
head(tbl$tbl)
```

    ##                         name n_1    p_1 n_2    p_2 n_3    p_3 n_9999 p_9999
    ## 1 Participants in population  86   <NA>  83   <NA>  84   <NA>    253   <NA>
    ## 2                not treated   0  (0.0)   0  (0.0)   0  (0.0)      0  (0.0)
    ## 3                    >=1 day   2  (2.3)   4  (4.8)   3  (3.6)      9  (3.6)
    ## 4                   >=7 days  13 (15.1)  11 (13.3)   9 (10.7)     33 (13.0)
    ## 5                  >=28 days  31 (36.0)  20 (24.1)  27 (32.1)     78 (30.8)
    ## 6                 >=12 weeks  39 (45.3)  48 (57.8)  45 (53.6)    132 (52.2)
    ##                  var_label
    ## 1                    -----
    ## 2 Exposure Duration (Days)
    ## 3 Exposure Duration (Days)
    ## 4 Exposure Duration (Days)
    ## 5 Exposure Duration (Days)
    ## 6 Exposure Duration (Days)

### Output as RTF

`rtf_exp_duration` to generate RTF output

``` r
outdata <- format_exp_duration(outdata, display_col = c("n", "prop", "total")) |>
  rtf_exp_duration(
    source = "Source:  [CDISCpilot: adam-adexsum]",
    path_outdata = tempfile(fileext = ".Rdata"),
    path_outtable = "outtable/exp0duration.rtf"
  )
```

    ## The outdata is saved in/tmp/RtmpZiWSkK/file1bfa60908720.Rdata

    ## The output is saved in/home/runner/work/metalite.sl/metalite.sl/vignettes/outtable/exp0duration.rtf
