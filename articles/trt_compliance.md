# Treatment Compliance Table

``` r
library(metalite)
library(metalite.sl)
library(dplyr)
```

## Create Treatment Compliance Table

The objective of this tutorial is to generate a production-ready
Treatment Compliance specification analyses.

This report produces a table that contains a summary of treatment
compliance information. The report consists of a treatment compliance
category section and a treatment compliance statistics section. To
accomplish this using metalite.sl, three essential functions are
required:

- [`prepare_trt_compliance ()`](https://merck.github.io/metalite.sl/reference/prepare_trt_compliance.md):this
  function is a wrapper function of
  [`prepare_sl_summary ()`](https://merck.github.io/metalite.sl/reference/prepare_sl_summary.md)
  which prepares data for treatment compliance analysis.

- [`format_trt_compliance()`](https://merck.github.io/metalite.sl/reference/format_trt_compliance.md):
  prepare analysis outdata with proper format.

- [`rtf_trt_compliance()`](https://merck.github.io/metalite.sl/reference/rtf_trt_compliance.md):
  transfer output dataset to RTF table.

An example output:

### Example data

Within metalite.sl, we utilized the ADSL datasets from the metalite
package to create an illustrative dataset. The metadata structure
remains consistent across all analysis examples within metalite.sl. To
calculate treatment compliance percent and treatment compliance range,
we utilized adex dataset. Additional information can be accessed on the
[metalite package
website](https://merck.github.io/metalite/articles/metalite.html).

### Build a metadata

``` r
adsl <- r2rtf::r2rtf_adsl

adex <- metalite.ae::metalite_ae_adex

adex1 <- adex |>
  filter(EXNUMDOS > 0 & !(is.na(AENDY))) |>
  group_by(USUBJID) |>
  slice(n()) |>
  select(USUBJID, AENDY) |>
  rename(ADURN = AENDY)

adsl <- merge(adsl, adex1, by = "USUBJID")

adsl <- adsl |>
  mutate(
    TRTDUR = as.numeric(TRTDUR),
    ADURN = as.numeric(ADURN),
    CMPLPCT = round((ADURN / TRTDUR) * 100, 2)
  )

adsl <- adsl |>
  mutate(
    CMPLRNG = case_when(
      CMPLPCT >= 0 & CMPLPCT <= 20 ~ "0% to <=20%",
      CMPLPCT > 20 & CMPLPCT <= 40 ~ ">20% to <=40%",
      CMPLPCT > 40 & CMPLPCT <= 60 ~ ">40% to <=60%",
      CMPLPCT > 60 & CMPLPCT <= 80 ~ ">60% to <=80%",
      CMPLPCT > 80 ~ ">80%"
    ),
    CMPLRNGN = case_when(
      CMPLPCT >= 0 & CMPLPCT <= 20 ~ 1,
      CMPLPCT > 20 & CMPLPCT <= 40 ~ 2,
      CMPLPCT > 40 & CMPLPCT <= 60 ~ 3,
      CMPLPCT > 60 & CMPLPCT <= 80 ~ 4,
      CMPLPCT > 80 ~ 5
    )
  )

head(adsl)
#>       USUBJID      STUDYID SUBJID SITEID SITEGR1                  ARM
#> 1 01-701-1015 CDISCPILOT01   1015    701     701              Placebo
#> 2 01-701-1023 CDISCPILOT01   1023    701     701              Placebo
#> 3 01-701-1028 CDISCPILOT01   1028    701     701 Xanomeline High Dose
#> 4 01-701-1033 CDISCPILOT01   1033    701     701  Xanomeline Low Dose
#> 5 01-701-1034 CDISCPILOT01   1034    701     701 Xanomeline High Dose
#> 6 01-701-1047 CDISCPILOT01   1047    701     701              Placebo
#>                 TRT01P TRT01PN               TRT01A TRT01AN     TRTSDT
#> 1              Placebo       0              Placebo       0 2014-01-02
#> 2              Placebo       0              Placebo       0 2012-08-05
#> 3 Xanomeline High Dose      81 Xanomeline High Dose      81 2013-07-19
#> 4  Xanomeline Low Dose      54  Xanomeline Low Dose      54 2014-03-18
#> 5 Xanomeline High Dose      81 Xanomeline High Dose      81 2014-07-01
#> 6              Placebo       0              Placebo       0 2013-02-12
#>       TRTEDT TRTDUR AVGDD CUMDOSE AGE AGEGR1 AGEGR1N  AGEU  RACE RACEN SEX
#> 1 2014-07-02    182   0.0       0  63    <65       1 YEARS WHITE     1   F
#> 2 2012-09-01     28   0.0       0  64    <65       1 YEARS WHITE     1   M
#> 3 2014-01-14    180  77.7   13986  71  65-80       2 YEARS WHITE     1   M
#> 4 2014-03-31     14  54.0     756  74  65-80       2 YEARS WHITE     1   M
#> 5 2014-12-30    183  76.9   14067  77  65-80       2 YEARS WHITE     1   F
#> 6 2013-03-09     26   0.0       0  85    >80       3 YEARS WHITE     1   F
#>                   ETHNIC SAFFL ITTFL EFFFL COMP8FL COMP16FL COMP24FL DISCONFL
#> 1     HISPANIC OR LATINO     Y     Y     Y       Y        Y        Y         
#> 2     HISPANIC OR LATINO     Y     Y     Y       N        N        N        Y
#> 3 NOT HISPANIC OR LATINO     Y     Y     Y       Y        Y        Y         
#> 4 NOT HISPANIC OR LATINO     Y     Y     Y       N        N        N        Y
#> 5 NOT HISPANIC OR LATINO     Y     Y     Y       Y        Y        Y         
#> 6 NOT HISPANIC OR LATINO     Y     Y     Y       N        N        N        Y
#>   DSRAEFL DTHFL BMIBL BMIBLGR1 HEIGHTBL WEIGHTBL EDUCLVL   DISONSDT DURDIS
#> 1                25.1   25-<30    147.3     54.4      16 2010-04-30   43.9
#> 2       Y        30.4     >=30    162.6     80.3      14 2006-03-11   76.4
#> 3                31.4     >=30    177.8     99.3      16 2009-12-16   42.8
#> 4                28.8   25-<30    175.3     88.5      12 2009-08-02   55.3
#> 5                26.1   25-<30    154.9     62.6       9 2011-09-29   32.9
#> 6       Y        30.4     >=30    148.6     67.1       8 2009-07-26   42.0
#>   DURDSGR1   VISIT1DT    RFSTDTC    RFENDTC VISNUMEN     RFENDT
#> 1     >=12 2013-12-26 2014-01-02 2014-07-02       12 2014-07-02
#> 2     >=12 2012-07-22 2012-08-05 2012-09-02        5 2012-09-02
#> 3     >=12 2013-07-11 2013-07-19 2014-01-14       12 2014-01-14
#> 4     >=12 2014-03-10 2014-03-18 2014-04-14        5 2014-04-14
#> 5     >=12 2014-06-24 2014-07-01 2014-12-30       12 2014-12-30
#> 6     >=12 2013-01-22 2013-02-12 2013-03-29        6 2013-03-29
#>                       DCDECOD         DCREASCD MMSETOT ADURN CMPLPCT CMPLRNG
#> 1                   COMPLETED        Completed      23   182     100    >80%
#> 2               ADVERSE EVENT    Adverse Event      23    28     100    >80%
#> 3                   COMPLETED        Completed      23   180     100    >80%
#> 4 STUDY TERMINATED BY SPONSOR Sponsor Decision      23    14     100    >80%
#> 5                   COMPLETED        Completed      21   183     100    >80%
#> 6               ADVERSE EVENT    Adverse Event      23    26     100    >80%
#>   CMPLRNGN
#> 1        5
#> 2        5
#> 3        5
#> 4        5
#> 5        5
#> 6        5
```

``` r
adsl$TRTA <- adsl$TRT01A
adsl$TRTA <- factor(adsl$TRTA,
  levels = c("Placebo", "Xanomeline Low Dose", "Xanomeline High Dose"),
  labels = c("Placebo", "Low Dose", "High Dose")
)
```

``` r
plan <- plan(
  analysis = "trt_compliance", population = "apat",
  observation = "apat", parameter = "CMPLRNG;CMPLPCT"
)
```

``` r
meta <- meta_adam(
  population = adsl,
  observation = adsl
) |>
  define_plan(plan = plan) |>
  define_population(
    name = "apat",
    group = "TRTA",
    subset = quote(SAFFL == "Y"),
    var = c("USUBJID", "TRTA", "SAFFL", "CMPLPCT", "CMPLRNG")
  ) |>
  metalite::define_parameter(
    name = "CMPLPCT",
    var = "CMPLPCT",
    label = "Treatment Compliance Percent",
  ) |>
  metalite::define_parameter(
    name = "CMPLRNG",
    var = "CMPLRNG",
    label = "Treatment Compliance Range",
  ) |>
  define_analysis(
    name = "trt_compliance",
    title = "Summary of Treatment Compliance",
    label = "treatment compliance table"
  ) |>
  meta_build()
```

Click to show the output

``` r
meta
#> ADaM metadata: 
#>    .$data_population     Population data with 252 subjects 
#>    .$data_observation    Observation data with 252 records 
#>    .$plan    Analysis plan with 1 plans 
#> 
#> 
#>   Analysis population type:
#>     name        id  group                                    var       subset
#> 1 'apat' 'USUBJID' 'TRTA' USUBJID, TRTA, SAFFL, CMPLPCT, CMPLRNG SAFFL == 'Y'
#>                           label
#> 1 'All Participants as Treated'
#> 
#> 
#>   Analysis observation type:
#>     name        id  group var subset                         label
#> 1 'apat' 'USUBJID' 'TRTA'            'All Participants as Treated'
#> 
#> 
#>   Analysis parameter type:
#>        name                          label subset
#> 1 'CMPLPCT' 'Treatment Compliance Percent'       
#> 2 'CMPLRNG'   'Treatment Compliance Range'       
#> 
#> 
#>   Analysis function:
#>               name                        label
#> 1 'trt_compliance' 'treatment compliance table'
```

### Analysis preparation

The function
[`prepare_trt_compliance()`](https://merck.github.io/metalite.sl/reference/prepare_trt_compliance.md)
is written to prepare data for treatment compliance analysis.The
function takes four arguments:

meta is metadata object created by metalite and it contains data from
ADSL. Analysis, Population, and Parameter arguments are used to subset
and process the meta data. They have default values, which rely on the
meta data object.

The function assign default value Analysis to `trt_compliance`,
Population to the population value associated with the `trt_compliance`
analysis in meta plan, and parameter to the parameter(s) associated with
the `trt_compliance` analysis in meta\$plan.

However, the user can also manually specify the analysis, population,
and parameter values when calling the function, if they want to override
the default values.

In the body of the function, it calls another function
prepare_sl_summary with the same meta, analysis, population, and
parameter arguments. `prepare_sl_summary` takes the meta data, subsets
it based on the analysis, population, and parameter values, and then
calculates and returns a summary of the relevant data.

The result of prepare_sl_summary is then returned as the result of
prepare_trt_compliance.

The resulting output of the function
[`prepare_trt_compliance()`](https://merck.github.io/metalite.sl/reference/prepare_trt_compliance.md)
comprises a collection of raw datasets for analysis and reporting.

``` r
outdata <- prepare_trt_compliance(meta)
```

Click to show the output

``` r
outdata
#> List of 14
#>  $ meta           :List of 7
#>  $ population     : chr "apat"
#>  $ observation    : chr "apat"
#>  $ parameter      : chr "CMPLRNG;CMPLPCT"
#>  $ n              :'data.frame': 1 obs. of  6 variables:
#>  $ order          : NULL
#>  $ group          : chr "TRTA"
#>  $ reference_group: NULL
#>  $ char_n         :List of 2
#>  $ char_var       : chr [1:2] "CMPLRNG" "CMPLPCT"
#>  $ char_prop      :List of 2
#>  $ var_type       :List of 2
#>  $ group_label    : Factor w/ 3 levels "Placebo","Low Dose",..: 1 3 2
#>  $ analysis       : chr "trt_compliance"
```

- `parameter`: parameter name

``` r
outdata$parameter
#> [1] "CMPLRNG;CMPLPCT"
```

- `n`: number of participants in population

``` r
outdata$n
#>                         name n_1 n_2 n_3 n_9999 var_label
#> 1 Participants in population  85  84  83    252     -----
```

The resulting dataset contains frequently used statistics, with
variables indexed according to the order specified in `outdata$group`.

``` r
outdata$group
#> [1] "TRTA"
```

- `char_n`: number of participants completed vs not completed in each
  parameter

``` r
outdata$char_n
#> [[1]]
#>            name Placebo Low Dose High Dose Total                  var_label
#> 1 >20% to <=40%       0        0         1     1 Treatment Compliance Range
#> 2          >80%      84       83        81   248 Treatment Compliance Range
#> 3   0% to <=20%       1        1         1     3 Treatment Compliance Range
#> 
#> [[2]]
#>       name      Placebo     Low Dose   High Dose       Total
#> 1     Mean         99.0         99.0        98.1        98.7
#> 2       SD          9.4          9.5        12.2        10.4
#> 3       SE          1.0          1.0         1.3         0.7
#> 4   Median        100.0        100.0       100.0       100.0
#> 5      Min         12.9         13.2         8.9         8.9
#> 6      Max        100.0        100.0       100.0       100.0
#> 7 Q1 to Q3   100 to 100   100 to 100  100 to 100  100 to 100
#> 8    Range 12.93 to 100 13.25 to 100 8.88 to 100 8.88 to 100
#>                      var_label
#> 1 Treatment Compliance Percent
#> 2 Treatment Compliance Percent
#> 3 Treatment Compliance Percent
#> 4 Treatment Compliance Percent
#> 5 Treatment Compliance Percent
#> 6 Treatment Compliance Percent
#> 7 Treatment Compliance Percent
#> 8 Treatment Compliance Percent
```

- `char_var` : name of parameter

``` r
outdata$char_var
#> [1] "CMPLRNG" "CMPLPCT"
```

- `char_prop` : proportion of subject with treatment compliance

``` r
outdata$char_prop
#> [[1]]
#>            name   Placebo  Low Dose High Dose      Total
#> 1 >20% to <=40%  0.000000  0.000000  1.204819  0.3968254
#> 2          >80% 98.823529 98.809524 97.590361 98.4126984
#> 3   0% to <=20%  1.176471  1.190476  1.204819  1.1904762
#>                    var_label
#> 1 Treatment Compliance Range
#> 2 Treatment Compliance Range
#> 3 Treatment Compliance Range
#> 
#> [[2]]
#>       name Placebo Low Dose High Dose Total                    var_label
#> 1     Mean      NA       NA        NA    NA Treatment Compliance Percent
#> 2       SD      NA       NA        NA    NA Treatment Compliance Percent
#> 3       SE      NA       NA        NA    NA Treatment Compliance Percent
#> 4   Median      NA       NA        NA    NA Treatment Compliance Percent
#> 5      Min      NA       NA        NA    NA Treatment Compliance Percent
#> 6      Max      NA       NA        NA    NA Treatment Compliance Percent
#> 7 Q1 to Q3      NA       NA        NA    NA Treatment Compliance Percent
#> 8    Range      NA       NA        NA    NA Treatment Compliance Percent
```

### Format output

Once the raw analysis results are obtained, the
[`format_trt_compliance()`](https://merck.github.io/metalite.sl/reference/format_trt_compliance.md)
function can be employed to prepare the outdata,ensuring its
compatibility with production-ready RTF tables.

``` r
outdata <- outdata |> format_trt_compliance()
```

Click to show the output

``` r
outdata$tbl
#>                          name          n_1    p_1          n_2    p_2
#> 1  Participants in population           85   <NA>           84   <NA>
#> 2               >20% to <=40%            0  (0.0)            0  (0.0)
#> 3                        >80%           84 (98.8)           83 (98.8)
#> 4                 0% to <=20%            1  (1.2)            1  (1.2)
#> 5                        Mean         99.0   <NA>         99.0   <NA>
#> 6                          SD          9.4   <NA>          9.5   <NA>
#> 7                          SE          1.0   <NA>          1.0   <NA>
#> 8                      Median        100.0   <NA>        100.0   <NA>
#> 9                    Q1 to Q3   100 to 100   <NA>   100 to 100   <NA>
#> 10                      Range 12.93 to 100   <NA> 13.25 to 100   <NA>
#>            n_3    p_3      n_9999 p_9999                    var_label
#> 1           83   <NA>         252   <NA>                        -----
#> 2            1  (1.2)           1  (0.4)   Treatment Compliance Range
#> 3           81 (97.6)         248 (98.4)   Treatment Compliance Range
#> 4            1  (1.2)           3  (1.2)   Treatment Compliance Range
#> 5         98.1   <NA>        98.7   <NA> Treatment Compliance Percent
#> 6         12.2   <NA>        10.4   <NA> Treatment Compliance Percent
#> 7          1.3   <NA>         0.7   <NA> Treatment Compliance Percent
#> 8        100.0   <NA>       100.0   <NA> Treatment Compliance Percent
#> 9   100 to 100   <NA>  100 to 100   <NA> Treatment Compliance Percent
#> 10 8.88 to 100   <NA> 8.88 to 100   <NA> Treatment Compliance Percent
```

### Additional statistics

By using the `display` argument, we can choose specific statistics to
include.

``` r
tbl <- outdata |> format_trt_compliance(display_stat = c("mean", "sd", "median", "range"), display_col = c("n", "prop", "total"))
```

Click to show the output

``` r
tbl$tbl
#>                         name          n_1    p_1          n_2    p_2
#> 1 Participants in population           85   <NA>           84   <NA>
#> 2              >20% to <=40%            0  (0.0)            0  (0.0)
#> 3                       >80%           84 (98.8)           83 (98.8)
#> 4                0% to <=20%            1  (1.2)            1  (1.2)
#> 5                       Mean         99.0   <NA>         99.0   <NA>
#> 6                         SD          9.4   <NA>          9.5   <NA>
#> 7                     Median        100.0   <NA>        100.0   <NA>
#> 8                      Range 12.93 to 100   <NA> 13.25 to 100   <NA>
#>           n_3    p_3      n_9999 p_9999                    var_label
#> 1          83   <NA>         252   <NA>                        -----
#> 2           1  (1.2)           1  (0.4)   Treatment Compliance Range
#> 3          81 (97.6)         248 (98.4)   Treatment Compliance Range
#> 4           1  (1.2)           3  (1.2)   Treatment Compliance Range
#> 5        98.1   <NA>        98.7   <NA> Treatment Compliance Percent
#> 6        12.2   <NA>        10.4   <NA> Treatment Compliance Percent
#> 7       100.0   <NA>       100.0   <NA> Treatment Compliance Percent
#> 8 8.88 to 100   <NA> 8.88 to 100   <NA> Treatment Compliance Percent
```

### RTF tables

The last step is to prepare the RTF table using `rtf_trt_compliance`.

``` r
outdata |>
  format_trt_compliance() |>
  rtf_trt_compliance(
    "Source: [CDISCpilot: adam-adsl]",
    path_outtable = "outtable/treatment0compliance.rtf"
  )
#> The output is saved in/home/runner/work/metalite.sl/metalite.sl/vignettes/outtable/treatment0compliance.rtf
```
