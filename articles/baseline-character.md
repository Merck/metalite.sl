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
meta <- meta_sl(
  dataset_population = adsl,
  population_term = "apat",
  parameter_term = "age;gender;race",
  parameter_var = "AGE^AGEGR1;SEX;RACE",
  treatment_group = "TRTA"
)
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

    ## The outdata is saved in/tmp/RtmpmDRctF/file1d8eb1b6e1a.Rdata

    ## The output is saved in/home/runner/work/metalite.sl/metalite.sl/vignettes/outtable/base0char.rtf

## Create Baseline Characteristic Table for Subgroup Analysis

The baseline characteristic subgroup analysis aims to provide tables to
summarize details of participants by subgroup. The development of
baseline characteristic subgroup analysis involves functions:

- [`prepare_base_char_subgroup()`](https://merck.github.io/metalite.sl/reference/prepare_base_char_subgroup.md):
  prepare analysis raw datasets.
- [`format_base_char_subgroup()`](https://merck.github.io/metalite.sl/reference/format_base_char_subgroup.md):
  prepare analysis outdata with proper format.
- [`rtf_base_char_subgroup()`](https://merck.github.io/metalite.sl/reference/rtf_base_char_subgroup.md):
  transfer output dataset to RTF table.

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
plan <- plan(
  analysis = "base_char_subgroup",
  population = "apat",
  observation = "apat",
  parameter = "age;gender;race"
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
    var = c("USUBJID", "TRTA", "SAFFL", "AGEGR1", "SEX", "RACE")
  ) |>
  define_parameter(
    name = "age",
    var = "AGE",
    label = "Age (years)",
    vargroup = "AGEGR1"
  ) |>
  define_parameter(
    name = "race",
    var = "RACE",
    label = "Race"
  ) |>
  define_analysis(
    name = "base_char_subgroup",
    title = "Participant by Age Category and Sex",
    label = "baseline characteristic sub group table"
  ) |>
  meta_build()
```

    ## Warning in FUN(X[[i]], ...): gender: has missing label

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
    ##     name        id  group                                     var       subset
    ## 1 'apat' 'USUBJID' 'TRTA' USUBJID, TRTA, SAFFL, AGEGR1, SEX, RACE SAFFL == 'Y'
    ##                           label
    ## 1 'All Participants as Treated'
    ## 
    ## 
    ##   Analysis observation type:
    ##     name        id  group var subset                         label
    ## 1 'apat' 'USUBJID' 'TRTA'            'All Participants as Treated'
    ## 
    ## 
    ##   Analysis parameter type:
    ##       name         label subset
    ## 1    'age' 'Age (years)'       
    ## 2   'race'        'Race'       
    ## 3 'gender'                     
    ## 
    ## 
    ##   Analysis function:
    ##                   name                                     label
    ## 1 'base_char_subgroup' 'baseline characteristic sub group table'

### Analysis preparation

The input of the function
[`prepare_base_char_subgroup()`](https://merck.github.io/metalite.sl/reference/prepare_base_char_subgroup.md)
is a `meta` object created by the metalite package.

The output of the function is an `outdata` object containing a list of
analysis raw datasets. Key arguments are:

- `subgroup_var`: a character value of subgroup variable name in
  observation data saved in meta\$data_observation.
- `subgroup_header`: a character vector for column header hierarchy. The
  first element will be the first level header and the second element
  will be second level header.

``` r
outdata <- prepare_base_char_subgroup(
  meta,
  population = "apat",
  parameter = "age;race",
  subgroup_var = "TRTA",
  subgroup_header = c("SEX", "TRTA")
)
```

Click to show the output

The output dataset contains commonly used statistics within each
`subgroup_var`.

``` r
outdata$out_all$`Placebo`
```

    ## List of 14
    ##  $ meta           :List of 7
    ##  $ population     : chr "apat"
    ##  $ observation    : chr "apat"
    ##  $ parameter      : chr "age;race"
    ##  $ n              :'data.frame': 1 obs. of  5 variables:
    ##  $ order          : NULL
    ##  $ group          : chr "SEX"
    ##  $ reference_group: NULL
    ##  $ char_n         :List of 2
    ##  $ char_var       : chr [1:2] "AGE" "RACE"
    ##  $ char_prop      :List of 2
    ##  $ var_type       :List of 2
    ##  $ group_label    : Factor w/ 2 levels "F","M": 1 2
    ##  $ analysis       : chr "base_char_subgroup"

``` r
outdata$out_all$`High Dose`
```

    ## List of 14
    ##  $ meta           :List of 7
    ##  $ population     : chr "apat"
    ##  $ observation    : chr "apat"
    ##  $ parameter      : chr "age;race"
    ##  $ n              :'data.frame': 1 obs. of  5 variables:
    ##  $ order          : NULL
    ##  $ group          : chr "SEX"
    ##  $ reference_group: NULL
    ##  $ char_n         :List of 2
    ##  $ char_var       : chr [1:2] "AGE" "RACE"
    ##  $ char_prop      :List of 2
    ##  $ var_type       :List of 2
    ##  $ group_label    : Factor w/ 2 levels "F","M": 2 1
    ##  $ analysis       : chr "base_char_subgroup"

``` r
outdata$out_all$`Low Dose`
```

    ## List of 14
    ##  $ meta           :List of 7
    ##  $ population     : chr "apat"
    ##  $ observation    : chr "apat"
    ##  $ parameter      : chr "age;race"
    ##  $ n              :'data.frame': 1 obs. of  5 variables:
    ##  $ order          : NULL
    ##  $ group          : chr "SEX"
    ##  $ reference_group: NULL
    ##  $ char_n         :List of 2
    ##  $ char_var       : chr [1:2] "AGE" "RACE"
    ##  $ char_prop      :List of 2
    ##  $ var_type       :List of 2
    ##  $ group_label    : Factor w/ 2 levels "F","M": 2 1
    ##  $ analysis       : chr "base_char_subgroup"

The information about subgroup saved with `outdata$group` and
`outdata$subgroup`.

``` r
outdata$group
```

    ## [1] "F" "M"

``` r
outdata$subgroup
```

    ## [1] "Placebo"   "Low Dose"  "High Dose"

`n_pop`: participants in population within each `subgroup_var`.

``` r
outdata$out_all$`Placebo`$n
```

    ##                         name n_1 n_2 n_9999 var_label
    ## 1 Participants in population  53  33     86     -----

``` r
outdata$out_all$`High Dose`$n
```

    ##                         name n_1 n_2 n_9999 var_label
    ## 1 Participants in population  40  44     84     -----

``` r
outdata$out_all$`Low Dose`$n
```

    ##                         name n_1 n_2 n_9999 var_label
    ## 1 Participants in population  50  34     84     -----

### Format output

`format_base_char_subgroup` to prepare analysis dataset before generate
RTF output

``` r
outdata <- format_base_char_subgroup(outdata)
```

Click to show the output

``` r
outdata$tbl
```

    ##                                name   var_label order Placebon_1 Placebop_1
    ## 9        Participants in population       -----     1         53       <NA>
    ## 1                               <65 Age (years)     2          9     (17.0)
    ## 2                               >80 Age (years)     3         22     (41.5)
    ## 3                             65-80 Age (years)     4         22     (41.5)
    ## 8                              <NA> Age (years)     5       <NA>       <NA>
    ## 6                              Mean Age (years)     6       76.4       <NA>
    ## 11                               SD Age (years)     7        8.7       <NA>
    ## 7                            Median Age (years)     8       78.0       <NA>
    ## 10                            Range Age (years)     9   59 to 89       <NA>
    ## 4  AMERICAN INDIAN OR ALASKA NATIVE        Race    10          0      (0.0)
    ## 5         BLACK OR AFRICAN AMERICAN        Race    11          5      (9.4)
    ## 12                            WHITE        Race    12         48     (90.6)
    ##    Placebon_2 Placebop_2 Placebon_9999 Placebop_9999 Low Dosen_1 Low Dosep_1
    ## 9          33       <NA>            86          <NA>          50        <NA>
    ## 1           5     (15.2)            14        (16.3)           5      (10.0)
    ## 2           8     (24.2)            30        (34.9)          17      (34.0)
    ## 3          20     (60.6)            42        (48.8)          28      (56.0)
    ## 8        <NA>       <NA>          <NA>          <NA>        <NA>        <NA>
    ## 6        73.4       <NA>          75.2          <NA>        75.7        <NA>
    ## 11        8.1       <NA>           8.6          <NA>         8.1        <NA>
    ## 7        74.0       <NA>          76.0          <NA>        77.5        <NA>
    ## 10   52 to 85       <NA>      52 to 89          <NA>    54 to 87        <NA>
    ## 4           0      (0.0)             0         (0.0)           0       (0.0)
    ## 5           3      (9.1)             8         (9.3)           6      (12.0)
    ## 12         30     (90.9)            78        (90.7)          44      (88.0)
    ##    Low Dosen_2 Low Dosep_2 Low Dosen_9999 Low Dosep_9999 High Dosen_1
    ## 9           34        <NA>             84           <NA>           40
    ## 1            3       (8.8)              8          (9.5)            5
    ## 2           12      (35.3)             29         (34.5)            7
    ## 3           19      (55.9)             47         (56.0)           28
    ## 8         <NA>        <NA>           <NA>           <NA>         <NA>
    ## 6         75.6        <NA>           75.7           <NA>         74.7
    ## 11         8.7        <NA>            8.3           <NA>          7.7
    ## 7         77.5        <NA>           77.5           <NA>         76.0
    ## 10    51 to 88        <NA>       51 to 88           <NA>     56 to 88
    ## 4            0       (0.0)              0          (0.0)            0
    ## 5            0       (0.0)              6          (7.1)            6
    ## 12          34     (100.0)             78         (92.9)           34
    ##    High Dosep_1 High Dosen_2 High Dosep_2 High Dosen_9999 High Dosep_9999
    ## 9          <NA>           44         <NA>              84            <NA>
    ## 1        (12.5)            6       (13.6)              11          (13.1)
    ## 2        (17.5)           11       (25.0)              18          (21.4)
    ## 3        (70.0)           27       (61.4)              55          (65.5)
    ## 8          <NA>         <NA>         <NA>            <NA>            <NA>
    ## 6          <NA>         74.1         <NA>            74.4            <NA>
    ## 11         <NA>          8.2         <NA>             7.9            <NA>
    ## 7          <NA>         77.0         <NA>            76.0            <NA>
    ## 10         <NA>     56 to 86         <NA>        56 to 88            <NA>
    ## 4         (0.0)            1        (2.3)               1           (1.2)
    ## 5        (15.0)            3        (6.8)               9          (10.7)
    ## 12       (85.0)           40       (90.9)              74          (88.1)
    ##    Totaln_1 Totalp_1 Totaln_2 Totalp_2 Totaln_9999 Totalp_9999
    ## 9       143     <NA>      111     <NA>         254        <NA>
    ## 1        19   (13.3)       14   (12.6)          33      (13.0)
    ## 2        46   (32.2)       31   (27.9)          77      (30.3)
    ## 3        78   (54.5)       66   (59.5)         144      (56.7)
    ## 8      <NA>     <NA>     <NA>     <NA>        <NA>        <NA>
    ## 6      75.7     <NA>     74.4     <NA>        75.1        <NA>
    ## 11      8.2     <NA>      8.3     <NA>         8.2        <NA>
    ## 7      77.0     <NA>     77.0     <NA>        77.0        <NA>
    ## 10 54 to 89     <NA> 51 to 88     <NA>    51 to 89        <NA>
    ## 4         0    (0.0)        1    (0.9)           1       (0.4)
    ## 5        17   (11.9)        6    (5.4)          23       (9.1)
    ## 12      126   (88.1)      104   (93.7)         230      (90.6)

### Output as RTF

`rtf_base_char_subgroup` to generate RTF output

``` r
outdata |>
  rtf_base_char_subgroup(
    source = "Source:  [CDISCpilot: adam-adsl]",
    path_outdata = tempfile(fileext = ".Rdata"),
    path_outtable = "outtable/base0charsubgroup.rtf"
  )
```

    ## The outdata is saved in/tmp/RtmpmDRctF/file1d8efe37c12.Rdata

    ## The output is saved in/home/runner/work/metalite.sl/metalite.sl/vignettes/outtable/base0charsubgroup.rtf
