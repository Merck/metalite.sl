# Baseline Characteristics Table

``` r

library(metalite)
library(metalite.sl)
```

## Create Baseline Characteristic Table

The baseline characteristic analysis aims to provide tables to summarize
details of participants. The development of baseline characteristic
analysis involves functions:

- `prepare_base_char`: prepare analysis raw datasets.
- `format_base_char`: prepare analysis outdata with proper format.
- `rtf_base_char`: transfer output dataset to RTF table.

### Build a metadata

``` r

adsl <- r2rtf::r2rtf_adsl
adsl$TRTA <- adsl$TRT01A
adsl$TRTA <- factor(
  adsl$TRTA,
  levels = c("Placebo", "Xanomeline Low Dose", "Xanomeline High Dose"),
  labels = c("Placebo", "Low Dose", "High Dose")
)
```

``` r

meta <- metalite::meta_adam(
  population = adsl,
  observation = adsl
) |>
  metalite::define_plan(plan = metalite::plan(
    analysis = "base_char",
    population = "apat",
    observation = "apat",
    parameter = "age;gender;race"
  )) |>
  metalite::define_population(
    name = "apat",
    group = "TRTA",
    subset = SAFFL == "Y",
    var = names(adsl),
    label = "All Participants as Treated"
  ) |>
  metalite::define_observation(
    name = "apat",
    group = "TRTA",
    subset = SAFFL == "Y",
    var = names(adsl),
    label = ""
  ) |>
  metalite::define_parameter(
    name = "age",
    var = "AGE",
    vargroup = "AGEGR1",
    label = attr(adsl$AGE, "label")
  ) |>
  metalite::define_parameter(
    name = "gender",
    var = "SEX",
    label = attr(adsl$SEX, "label")
  ) |>
  metalite::define_parameter(
    name = "race",
    var = "RACE",
    label = attr(adsl$RACE, "label")
  ) |>
  metalite::define_analysis(
    name = "base_char",
    label = "",
    title = "Participant Baseline Characteristics by Treatment Group"
  ) |>
  metalite::meta_build()
```

Click to show the output

``` r

meta
```

    ## ADaM metadata: 
    ##    .$data_population     Population data with 254 subjects 
    ##    .$data_observation    Observation data with 254 records 
    ##    .$plan    Analysis plan with 1 plans 
    ## 
    ## 
    ##   Analysis population type:
    ##     name        id  group
    ## 1 'apat' 'USUBJID' 'TRTA'
    ##                                                                                                                                                                                                                                                                                                                                                                                                                    var
    ## 1 STUDYID, USUBJID, SUBJID, SITEID, SITEGR1, ARM, TRT01P, TRT01PN, TRT01A, TRT01AN, TRTSDT, TRTEDT, TRTDUR, AVGDD, CUMDOSE, AGE, AGEGR1, AGEGR1N, AGEU, RACE, RACEN, SEX, ETHNIC, SAFFL, ITTFL, EFFFL, COMP8FL, COMP16FL, COMP24FL, DISCONFL, DSRAEFL, DTHFL, BMIBL, BMIBLGR1, HEIGHTBL, WEIGHTBL, EDUCLVL, DISONSDT, DURDIS, DURDSGR1, VISIT1DT, RFSTDTC, RFENDTC, VISNUMEN, RFENDT, DCDECOD, DCREASCD, MMSETOT, TRTA
    ##         subset                         label
    ## 1 SAFFL == 'Y' 'All Participants as Treated'
    ## 
    ## 
    ##   Analysis observation type:
    ##     name        id  group
    ## 1 'apat' 'USUBJID' 'TRTA'
    ##                                                                                                                                                                                                                                                                                                                                                                                                                    var
    ## 1 STUDYID, USUBJID, SUBJID, SITEID, SITEGR1, ARM, TRT01P, TRT01PN, TRT01A, TRT01AN, TRTSDT, TRTEDT, TRTDUR, AVGDD, CUMDOSE, AGE, AGEGR1, AGEGR1N, AGEU, RACE, RACEN, SEX, ETHNIC, SAFFL, ITTFL, EFFFL, COMP8FL, COMP16FL, COMP24FL, DISCONFL, DSRAEFL, DTHFL, BMIBL, BMIBLGR1, HEIGHTBL, WEIGHTBL, EDUCLVL, DISONSDT, DURDIS, DURDSGR1, VISIT1DT, RFSTDTC, RFENDTC, VISNUMEN, RFENDT, DCDECOD, DCREASCD, MMSETOT, TRTA
    ##         subset label
    ## 1 SAFFL == 'Y'    ''
    ## 
    ## 
    ##   Analysis parameter type:
    ##       name  label subset
    ## 1    'age'  'Age'       
    ## 2 'gender'  'Sex'       
    ## 3   'race' 'Race'       
    ## 
    ## 
    ##   Analysis function:
    ##          name label
    ## 1 'base_char'    ''

### Analysis preparation

The input of the function
[`prepare_base_char()`](https://merck.github.io/metalite.sl/reference/prepare_base_char.md)
is a `meta` object created by the metalite package.

``` r

outdata <- meta |>
  prepare_base_char(parameter = "age;gender;race")

outdata
```

    ## List of 14
    ##  $ meta           :List of 7
    ##  $ population     : chr "apat"
    ##  $ observation    : chr "apat"
    ##  $ parameter      : chr "age;gender;race"
    ##  $ n              :'data.frame': 1 obs. of  6 variables:
    ##  $ order          : NULL
    ##  $ group          : chr "TRTA"
    ##  $ reference_group: NULL
    ##  $ char_n         :List of 3
    ##  $ char_var       : chr [1:3] "AGE" "SEX" "RACE"
    ##  $ char_prop      :List of 3
    ##  $ var_type       :List of 3
    ##  $ group_label    : Factor w/ 3 levels "Placebo","Low Dose",..: 1 3 2
    ##  $ analysis       : chr "base_char"

Click to show the output

``` r

outdata$n
```

    ##                         name n_1 n_2 n_3 n_9999 var_label
    ## 1 Participants in population  86  84  84    254     -----

``` r

outdata$char_n
```

    ## [[1]]
    ##        name        Placebo Low Dose   High Dose    Total var_label
    ## 1       <65             14        8          11       33       Age
    ## 2       >80             30       29          18       77       Age
    ## 3     65-80             42       47          55      144       Age
    ## 4      <NA>           <NA>     <NA>        <NA>     <NA>       Age
    ## 5      Mean           75.2     75.7        74.4     75.1       Age
    ## 6        SD            8.6      8.3         7.9      8.2       Age
    ## 7        SE            0.9      0.9         0.9      0.5       Age
    ## 8    Median           76.0     77.5        76.0     77.0       Age
    ## 9       Min           52.0     51.0        56.0     51.0       Age
    ## 10      Max           89.0     88.0        88.0     89.0       Age
    ## 11 Q1 to Q3 69.25 to 81.75 71 to 82 70.75 to 80 70 to 81       Age
    ## 12    Range       52 to 89 51 to 88    56 to 88 51 to 89       Age
    ## 
    ## [[2]]
    ##   name Placebo Low Dose High Dose Total var_label
    ## 1    F      53       50        40   143       Sex
    ## 2    M      33       34        44   111       Sex
    ## 
    ## [[3]]
    ##                               name Placebo Low Dose High Dose Total var_label
    ## 1 AMERICAN INDIAN OR ALASKA NATIVE       0        0         1     1      Race
    ## 2        BLACK OR AFRICAN AMERICAN       8        6         9    23      Race
    ## 3                            WHITE      78       78        74   230      Race

``` r

outdata$char_var
```

    ## [1] "AGE"  "SEX"  "RACE"

``` r

outdata$char_prop
```

    ## [[1]]
    ##        name  Placebo Low Dose High Dose    Total var_label
    ## 1       <65 16.27907  9.52381  13.09524 12.99213       Age
    ## 2       >80 34.88372 34.52381  21.42857 30.31496       Age
    ## 3     65-80 48.83721 55.95238  65.47619 56.69291       Age
    ## 4      <NA>       NA       NA        NA       NA       Age
    ## 5      Mean       NA       NA        NA       NA       Age
    ## 6        SD       NA       NA        NA       NA       Age
    ## 7        SE       NA       NA        NA       NA       Age
    ## 8    Median       NA       NA        NA       NA       Age
    ## 9       Min       NA       NA        NA       NA       Age
    ## 10      Max       NA       NA        NA       NA       Age
    ## 11 Q1 to Q3       NA       NA        NA       NA       Age
    ## 12    Range       NA       NA        NA       NA       Age
    ## 
    ## [[2]]
    ##   name  Placebo Low Dose High Dose    Total var_label
    ## 1    F 61.62791 59.52381  47.61905 56.29921       Sex
    ## 2    M 38.37209 40.47619  52.38095 43.70079       Sex
    ## 
    ## [[3]]
    ##                               name   Placebo  Low Dose High Dose      Total
    ## 1 AMERICAN INDIAN OR ALASKA NATIVE  0.000000  0.000000  1.190476  0.3937008
    ## 2        BLACK OR AFRICAN AMERICAN  9.302326  7.142857 10.714286  9.0551181
    ## 3                            WHITE 90.697674 92.857143 88.095238 90.5511811
    ##   var_label
    ## 1      Race
    ## 2      Race
    ## 3      Race

### Format the numbers

`format_base_char` to prepare analysis dataset before generate RTF
output

``` r

outdata <-
  outdata |> format_base_char(
    display_col = c("n", "prop", "total"),
    digits_prop = 2
  )
```

Click to show the output

``` r

outdata$tbl
```

    ##                                name            n_1     p_1      n_2     p_2
    ## 1        Participants in population             86    <NA>       84    <NA>
    ## 2                               <65             14 (16.28)        8  (9.52)
    ## 3                               >80             30 (34.88)       29 (34.52)
    ## 4                             65-80             42 (48.84)       47 (55.95)
    ## 5                              <NA>           <NA>    <NA>     <NA>    <NA>
    ## 6                              Mean           75.2    <NA>     75.7    <NA>
    ## 7                                SD            8.6    <NA>      8.3    <NA>
    ## 8                                SE            0.9    <NA>      0.9    <NA>
    ## 9                            Median           76.0    <NA>     77.5    <NA>
    ## 10                         Q1 to Q3 69.25 to 81.75    <NA> 71 to 82    <NA>
    ## 11                            Range       52 to 89    <NA> 51 to 88    <NA>
    ## 12                                F             53 (61.63)       50 (59.52)
    ## 13                                M             33 (38.37)       34 (40.48)
    ## 14 AMERICAN INDIAN OR ALASKA NATIVE              0  (0.00)        0  (0.00)
    ## 15        BLACK OR AFRICAN AMERICAN              8  (9.30)        6  (7.14)
    ## 16                            WHITE             78 (90.70)       78 (92.86)
    ##            n_3     p_3   n_9999  p_9999 var_label
    ## 1           84    <NA>      254    <NA>     -----
    ## 2           11 (13.10)       33 (12.99)       Age
    ## 3           18 (21.43)       77 (30.31)       Age
    ## 4           55 (65.48)      144 (56.69)       Age
    ## 5         <NA>    <NA>     <NA>    <NA>       Age
    ## 6         74.4    <NA>     75.1    <NA>       Age
    ## 7          7.9    <NA>      8.2    <NA>       Age
    ## 8          0.9    <NA>      0.5    <NA>       Age
    ## 9         76.0    <NA>     77.0    <NA>       Age
    ## 10 70.75 to 80    <NA> 70 to 81    <NA>       Age
    ## 11    56 to 88    <NA> 51 to 89    <NA>       Age
    ## 12          40 (47.62)      143 (56.30)       Sex
    ## 13          44 (52.38)      111 (43.70)       Sex
    ## 14           1  (1.19)        1  (0.39)      Race
    ## 15           9 (10.71)       23  (9.06)      Race
    ## 16          74 (88.10)      230 (90.55)      Race

### Output as RTF

`rtf_base_char` to generate RTF output

``` r

outdata |> rtf_base_char(
  source = "Source: [CDISCpilot: adam-adsl]",
  path_outdata = tempfile(fileext = ".Rdata"),
  path_outtable = "outtable/base0char.rtf"
)
```

    ## The outdata is saved in/tmp/RtmpWjPwhF/file1c257fcfcb99.Rdata

    ## The output is saved in/home/runner/work/metalite.sl/metalite.sl/vignettes/outtable/base0char.rtf
