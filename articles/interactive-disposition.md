# Interactive Disposition Table

``` r
library(metalite.sl)
library(metalite.ae)
library(metalite)
library(dplyr)
```

## Build a metadata

``` r
adsl <- metalite_sl_adsl
metadata_ae <- metalite.ae::meta_ae_example()
metadata_ae$data_observation <- metalite_sl_adae
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

## Interactive Disposition

``` r
react_disposition(
  metadata_sl = meta,
  metadata_ae = metadata_ae,
  width = 1200
)
```
