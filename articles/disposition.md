# Disposition Table

``` r
library(metalite.sl)
library(metalite)
library(dplyr)
```

## Create Disposition Table

The objective of this tutorial is to generate a production-ready
Disposition table specification analyses.

This report produces a table that contains counts and percentage of
disposition for the participants in population for overall study. To
accomplish this using metalite.sl, four essential functions are
required:

- [`prepare_disposition ()`](https://merck.github.io/metalite.sl/reference/prepare_disposition.md):subset
  data for disposition analysis.

- [`format_disposition()`](https://merck.github.io/metalite.sl/reference/format_disposition.md):
  prepare analysis outdata with proper format.

- [`rtf_disposition ()`](https://merck.github.io/metalite.sl/reference/rtf_disposition.md):
  transfer output dataset to RTF table.

An example output:

### Example data

Within metalite.sl, we utilized the ADSL datasets from the metalite
package to create an illustrative dataset. The metadata structure
remains consistent across all analysis examples within metalite.sl.
Additional information can be accessed on the [metalite package
website](https://merck.github.io/metalite/articles/metalite.html).

### Build a metadata

``` r
adsl <- metalite_sl_adsl
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
#>                       DCDECOD         DCREASCD MMSETOT      TRTA          AEACN
#> 1                   COMPLETED        Completed      23   Placebo           <NA>
#> 2               ADVERSE EVENT    Adverse Event      23   Placebo           <NA>
#> 3                   COMPLETED        Completed      23 High Dose DRUG WITHDRAWN
#> 4 STUDY TERMINATED BY SPONSOR Sponsor Decision      23  Low Dose           <NA>
#> 5                   COMPLETED        Completed      21 High Dose           <NA>
#> 6               ADVERSE EVENT    Adverse Event      23   Placebo DRUG WITHDRAWN
#>         EOTSTT           DCTREAS       EOSSTT           DCSREAS
#> 1     Complete              <NA>     Complete              <NA>
#> 2     Complete              <NA>     Complete              <NA>
#> 3 Discontinued     Adverse Event Discontinued             Other
#> 4     Complete              <NA>     Complete              <NA>
#> 5 Discontinued Lost to Follow-Up Discontinued Lost to Follow-Up
#> 6 Discontinued     Adverse Event Discontinued             Other
```

``` r
plan <- plan(
  analysis = "disp", population = "apat",
  observation = "apat", parameter = "disposition;medical-disposition"
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
    subset = quote(SAFFL == "Y")
  ) |>
  define_parameter(
    name = "disposition",
    var = "EOSSTT",
    label = "Trial Disposition",
    var_lower = "DCSREAS"
  ) |>
  define_parameter(
    name = "medical-disposition",
    var = "EOTSTT",
    label = "Participant Study Medication Disposition",
    var_lower = "DCTREAS"
  ) |>
  define_analysis(
    name = "disp",
    title = "Disposition of Participant",
    label = "disposition table"
  ) |>
  meta_build()
```

Click to show the output

``` r
meta
#> ADaM metadata: 
#>    .$data_population     Population data with 254 subjects 
#>    .$data_observation    Observation data with 254 records 
#>    .$plan    Analysis plan with 1 plans 
#> 
#> 
#>   Analysis population type:
#>     name        id  group var       subset                         label
#> 1 'apat' 'USUBJID' 'TRTA'     SAFFL == 'Y' 'All Participants as Treated'
#> 
#> 
#>   Analysis observation type:
#>     name        id  group var subset                         label
#> 1 'apat' 'USUBJID' 'TRTA'            'All Participants as Treated'
#> 
#> 
#>   Analysis parameter type:
#>                    name                                      label subset
#> 1         'disposition'                        'Trial Disposition'       
#> 2 'medical-disposition' 'Participant Study Medication Disposition'       
#> 
#> 
#>   Analysis function:
#>     name               label
#> 1 'disp' 'disposition table'
```

### Analysis preparation

The function
[`prepare_disposition()`](https://merck.github.io/metalite.sl/reference/prepare_disposition.md)
is written to prepare data for subject disposition analysis.The function
takes four arguments:

Meta is metadata object created by metalite and it contains data from
ADSL. Analysis, Population, and Parameter arguments are used to subset
and process the meta data. They have default values, which rely on the
meta data object.

The function assign default value Analysis to `prepare_disposition`,
Population to the population value associated with the
`prepare_disposition` analysis in meta plan, and parameter to the
parameter(s) associated with the `prepare_disposition` analysis in
meta\$plan.

However, the user can also manually specify the analysis, population,
and parameter values when calling the function, if they want to override
the default values.

In the body of the function, it calls another function
`prepare_sl_summary` with the same meta, analysis, population, and
parameter arguments. `prepare_sl_summary` takes the meta data, subsets
it based on the analysis, population, and parameter values, and then
calculates and returns a summary of the relevant data.

The result of `prepare_sl_summary` is then returned as the result of
`prepare_disposition`.

The resulting output of the function
[`prepare_disposition()`](https://merck.github.io/metalite.sl/reference/prepare_disposition.md)
comprises a collection of raw datasets for analysis and reporting.

``` r
outdata <- prepare_disposition(meta)
```

Click to show the output

``` r
outdata
#> List of 14
#>  $ meta           :List of 7
#>  $ population     : chr "apat"
#>  $ observation    : chr "apat"
#>  $ parameter      : chr "disposition;medical-disposition"
#>  $ n              :'data.frame': 1 obs. of  6 variables:
#>  $ order          : NULL
#>  $ group          : chr "TRTA"
#>  $ reference_group: NULL
#>  $ char_n         :List of 2
#>  $ char_var       : chr [1:2] "EOSSTT" "EOTSTT"
#>  $ char_prop      :List of 2
#>  $ var_type       :List of 2
#>  $ group_label    : Factor w/ 3 levels "Placebo","Low Dose",..: 1 3 2
#>  $ analysis       : chr "disp"
```

- `parameter`: parameter name

``` r
outdata$parameter
#> [1] "disposition;medical-disposition"
```

- `n`: number of participants in population

``` r
outdata$n
#>                         name n_1 n_2 n_3 n_9999 var_label
#> 1 Participants in population  86  84  84    254     -----
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
#>                        name Placebo Low Dose High Dose Total         var_label
#> 1                  Complete      47       34        38   119 Trial Disposition
#> 2              Discontinued      26       37        38   101 Trial Disposition
#> 3          Lack of Efficacy       2        3         9    14 Trial Disposition
#> 4         Lost to Follow-Up       2        7         8    17 Trial Disposition
#> 5                     Other      15       18        18    51 Trial Disposition
#> 6     Withdrawal By Subject       7        9         3    19 Trial Disposition
#> 7      Participants Ongoing      13       13         8    34 Trial Disposition
#> 
#> [[2]]
#>                        name Placebo Low Dose High Dose Total
#> 1                  Complete      47       34        38   119
#> 2              Discontinued      26       37        38   101
#> 3             Adverse Event      15       18        18    51
#> 4          Lack of Efficacy       2        3         9    14
#> 5         Lost to Follow-Up       2        7         8    17
#> 6     Withdrawal By Subject       7        9         3    19
#> 7      Participants Ongoing      13       13         8    34
#>                                  var_label
#> 1 Participant Study Medication Disposition
#> 2 Participant Study Medication Disposition
#> 3 Participant Study Medication Disposition
#> 4 Participant Study Medication Disposition
#> 5 Participant Study Medication Disposition
#> 6 Participant Study Medication Disposition
#> 7 Participant Study Medication Disposition
```

- `char_var` : name of parameter

``` r
outdata$char_var
#> [1] "EOSSTT" "EOTSTT"
```

- `char_prop` : proportion of subject with disposition

``` r
outdata$char_prop
#> [[1]]
#>                        name          Placebo         Low Dose        High Dose
#> 1                  Complete         54.65116         40.47619         45.23810
#> 2              Discontinued         30.23256         44.04762         45.23810
#> 3          Lack of Efficacy 2.32558139534884 3.57142857142857 10.7142857142857
#> 4         Lost to Follow-Up 2.32558139534884 8.33333333333333 9.52380952380952
#> 5                     Other 17.4418604651163 21.4285714285714 21.4285714285714
#> 6     Withdrawal By Subject 8.13953488372093 10.7142857142857 3.57142857142857
#> 7      Participants Ongoing         15.11628         15.47619          9.52381
#>              Total         var_label
#> 1         46.85039 Trial Disposition
#> 2         39.76378 Trial Disposition
#> 3 5.51181102362205 Trial Disposition
#> 4 6.69291338582677 Trial Disposition
#> 5 20.0787401574803 Trial Disposition
#> 6 7.48031496062992 Trial Disposition
#> 7         13.38583 Trial Disposition
#> 
#> [[2]]
#>                        name          Placebo         Low Dose        High Dose
#> 1                  Complete         54.65116         40.47619         45.23810
#> 2              Discontinued         30.23256         44.04762         45.23810
#> 3             Adverse Event 17.4418604651163 21.4285714285714 21.4285714285714
#> 4          Lack of Efficacy 2.32558139534884 3.57142857142857 10.7142857142857
#> 5         Lost to Follow-Up 2.32558139534884 8.33333333333333 9.52380952380952
#> 6     Withdrawal By Subject 8.13953488372093 10.7142857142857 3.57142857142857
#> 7      Participants Ongoing         15.11628         15.47619          9.52381
#>              Total                                var_label
#> 1         46.85039 Participant Study Medication Disposition
#> 2         39.76378 Participant Study Medication Disposition
#> 3 20.0787401574803 Participant Study Medication Disposition
#> 4 5.51181102362205 Participant Study Medication Disposition
#> 5 6.69291338582677 Participant Study Medication Disposition
#> 6 7.48031496062992 Participant Study Medication Disposition
#> 7         13.38583 Participant Study Medication Disposition
```

### Format output

Once the raw analysis results are obtained, the
[`format_disposition()`](https://merck.github.io/metalite.sl/reference/format_disposition.md)
function can be employed to prepare the outdata,ensuring its
compatibility with production-ready RTF tables.

``` r
outdata <- outdata |> format_disposition()
```

Click to show the output

``` r
outdata$tbl
#>                          name n_1    p_1 n_2    p_2 n_3    p_3 n_9999 p_9999
#> 1  Participants in population  86   <NA>  84   <NA>  84   <NA>    254   <NA>
#> 2                    Complete  47 (54.7)  34 (40.5)  38 (45.2)    119 (46.9)
#> 3                Discontinued  26 (30.2)  37 (44.0)  38 (45.2)    101 (39.8)
#> 4            Lack of Efficacy   2  (2.3)   3  (3.6)   9 (10.7)     14  (5.5)
#> 5           Lost to Follow-Up   2  (2.3)   7  (8.3)   8  (9.5)     17  (6.7)
#> 6                       Other  15 (17.4)  18 (21.4)  18 (21.4)     51 (20.1)
#> 7       Withdrawal By Subject   7  (8.1)   9 (10.7)   3  (3.6)     19  (7.5)
#> 8        Participants Ongoing  13 (15.1)  13 (15.5)   8  (9.5)     34 (13.4)
#> 9                    Complete  47 (54.7)  34 (40.5)  38 (45.2)    119 (46.9)
#> 10               Discontinued  26 (30.2)  37 (44.0)  38 (45.2)    101 (39.8)
#> 11              Adverse Event  15 (17.4)  18 (21.4)  18 (21.4)     51 (20.1)
#> 12           Lack of Efficacy   2  (2.3)   3  (3.6)   9 (10.7)     14  (5.5)
#> 13          Lost to Follow-Up   2  (2.3)   7  (8.3)   8  (9.5)     17  (6.7)
#> 14      Withdrawal By Subject   7  (8.1)   9 (10.7)   3  (3.6)     19  (7.5)
#> 15       Participants Ongoing  13 (15.1)  13 (15.5)   8  (9.5)     34 (13.4)
#>                                   var_label
#> 1                                     -----
#> 2                         Trial Disposition
#> 3                         Trial Disposition
#> 4                         Trial Disposition
#> 5                         Trial Disposition
#> 6                         Trial Disposition
#> 7                         Trial Disposition
#> 8                         Trial Disposition
#> 9  Participant Study Medication Disposition
#> 10 Participant Study Medication Disposition
#> 11 Participant Study Medication Disposition
#> 12 Participant Study Medication Disposition
#> 13 Participant Study Medication Disposition
#> 14 Participant Study Medication Disposition
#> 15 Participant Study Medication Disposition
```

### RTF tables

The last step is to prepare the RTF table using `rtf_trt_compliance`.

``` r
outdata$tbl <- outdata$tbl %>%
  mutate(name = ifelse(trimws(name) == "Status Not Recorded", "    Status Not Recorded", name))

outdata |>
  rtf_disposition(
    "Source: [CDISCpilot: adam-adsl]",
    path_outdata = tempfile(fileext = ".Rdata"),
    path_outtable = "outtable/disposition.rtf"
  )
#> The outdata is saved in/tmp/RtmpGy0OnV/file1bc06844fad1.Rdata
#> The output is saved in/home/runner/work/metalite.sl/metalite.sl/vignettes/outtable/disposition.rtf
```
