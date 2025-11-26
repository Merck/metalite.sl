# Prepare data for Subgroup Analysis for Baseline Characteristic

Prepare data for Subgroup Analysis for Baseline Characteristic

## Usage

``` r
format_base_char_subgroup(
  outdata,
  display = c("n", "prop", "total"),
  display_stat = c("mean", "sd", "median", "range"),
  display_total = TRUE
)
```

## Arguments

- outdata:

  A metadata object created by
  [`prepare_base_char_subgroup()`](https://merck.github.io/metalite.sl/reference/prepare_base_char_subgroup.md).

- display:

  Column wants to display on the table. The term could be selected from
  `c("n", "prop", "total")`. "total" can display the total column for
  the first level header.

- display_stat:

  A vector of statistics term name. The term name could be selected from
  `c("mean", "sd", "se", "median", "q1 to q3", "range", "q1", "q3", "min", "max")`.

- display_total:

  A logic value of displaying the total column for the second level
  header.

## Value

A list of analysis raw datasets.

## Examples

``` r
meta <- meta_sl_example()

outdata <- prepare_base_char_subgroup(
  meta,
  population = "apat",
  parameter = "age",
  subgroup_var = "TRTA",
  subgroup_header = c("SEX", "TRTA")
)

outdata |> format_base_char_subgroup()
#> $group
#> [1] "F" "M"
#> 
#> $subgroup
#> [1] "Placebo"   "Low Dose"  "High Dose"
#> 
#> $meta
#> ADaM metadata: 
#>    .$data_population     Population data with 254 subjects 
#>    .$data_observation    Observation data with 254 records 
#>    .$plan    Analysis plan with 4 plans 
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
#> 1                 'age'                              'Age (years)'       
#> 2              'gender'                                   'Gender'       
#> 3                'race'                                     'Race'       
#> 4         'disposition'                        'Trial Disposition'       
#> 5 'medical-disposition' 'Participant Study Medication Disposition'       
#> 6               'comp8'                      'Compliance (Week 8)'       
#> 7              'comp16'                     'Compliance (Week 16)'       
#> 8              'comp24'                     'Compliance (Week 24)'       
#> 
#> 
#>   Analysis function:
#>                   name                                     label
#> 1          'base_char'           'baseline characteristic table'
#> 2     'trt_compliance'              'treatment compliance table'
#> 3               'disp'                       'disposition table'
#> 4 'base_char_subgroup' 'baseline characteristic sub group table'
#> 
#> 
#> $population
#> [1] "apat"
#> 
#> $observation
#> [1] "apat"
#> 
#> $parameter
#> [1] "age"
#> 
#> $out_all
#> $out_all$Placebo
#> List of 14
#>  $ meta           :List of 7
#>  $ population     : chr "apat"
#>  $ observation    : chr "apat"
#>  $ parameter      : chr "age"
#>  $ n              :'data.frame': 1 obs. of  5 variables:
#>  $ order          : NULL
#>  $ group          : chr "SEX"
#>  $ reference_group: NULL
#>  $ char_n         :List of 1
#>  $ char_var       : chr "AGE"
#>  $ char_prop      :List of 1
#>  $ var_type       :List of 1
#>  $ group_label    : Factor w/ 2 levels "F","M": 1 2
#>  $ analysis       : chr "base_char_subgroup"
#> 
#> $out_all$`Low Dose`
#> List of 14
#>  $ meta           :List of 7
#>  $ population     : chr "apat"
#>  $ observation    : chr "apat"
#>  $ parameter      : chr "age"
#>  $ n              :'data.frame': 1 obs. of  5 variables:
#>  $ order          : NULL
#>  $ group          : chr "SEX"
#>  $ reference_group: NULL
#>  $ char_n         :List of 1
#>  $ char_var       : chr "AGE"
#>  $ char_prop      :List of 1
#>  $ var_type       :List of 1
#>  $ group_label    : Factor w/ 2 levels "F","M": 2 1
#>  $ analysis       : chr "base_char_subgroup"
#> 
#> $out_all$`High Dose`
#> List of 14
#>  $ meta           :List of 7
#>  $ population     : chr "apat"
#>  $ observation    : chr "apat"
#>  $ parameter      : chr "age"
#>  $ n              :'data.frame': 1 obs. of  5 variables:
#>  $ order          : NULL
#>  $ group          : chr "SEX"
#>  $ reference_group: NULL
#>  $ char_n         :List of 1
#>  $ char_var       : chr "AGE"
#>  $ char_prop      :List of 1
#>  $ var_type       :List of 1
#>  $ group_label    : Factor w/ 2 levels "F","M": 2 1
#>  $ analysis       : chr "base_char_subgroup"
#> 
#> $out_all$Total
#> List of 14
#>  $ meta           :List of 7
#>  $ population     : chr "apat"
#>  $ observation    : chr "apat"
#>  $ parameter      : chr "age"
#>  $ n              :'data.frame': 1 obs. of  5 variables:
#>  $ order          : NULL
#>  $ group          : chr "SEX"
#>  $ reference_group: NULL
#>  $ char_n         :List of 1
#>  $ char_var       : chr "AGE"
#>  $ char_prop      :List of 1
#>  $ var_type       :List of 1
#>  $ group_label    : Factor w/ 2 levels "F","M": 1 2
#>  $ analysis       : chr "base_char_subgroup"
#> 
#> 
#> $tbl
#>                         name   var_label order Placebon_1 Placebop_1 Placebon_2
#> 7 Participants in population       -----     1         53       <NA>         33
#> 1                      65-80 Age (years)     2         22     (41.5)         20
#> 2                        <65 Age (years)     3          9     (17.0)          5
#> 3                        >80 Age (years)     4         22     (41.5)          8
#> 6                       <NA> Age (years)     5       <NA>       <NA>       <NA>
#> 4                       Mean Age (years)     6       76.4       <NA>       73.4
#> 9                         SD Age (years)     7        8.7       <NA>        8.1
#> 5                     Median Age (years)     8       78.0       <NA>       74.0
#> 8                      Range Age (years)     9   59 to 89       <NA>   52 to 85
#>   Placebop_2 Placebon_9999 Placebop_9999 Low Dosen_1 Low Dosep_1 Low Dosen_2
#> 7       <NA>            86          <NA>          50        <NA>          34
#> 1     (60.6)            42        (48.8)          28      (56.0)          19
#> 2     (15.2)            14        (16.3)           5      (10.0)           3
#> 3     (24.2)            30        (34.9)          17      (34.0)          12
#> 6       <NA>          <NA>          <NA>        <NA>        <NA>        <NA>
#> 4       <NA>          75.2          <NA>        75.7        <NA>        75.6
#> 9       <NA>           8.6          <NA>         8.1        <NA>         8.7
#> 5       <NA>          76.0          <NA>        77.5        <NA>        77.5
#> 8       <NA>      52 to 89          <NA>    54 to 87        <NA>    51 to 88
#>   Low Dosep_2 Low Dosen_9999 Low Dosep_9999 High Dosen_1 High Dosep_1
#> 7        <NA>             84           <NA>           40         <NA>
#> 1      (55.9)             47         (56.0)           28       (70.0)
#> 2       (8.8)              8          (9.5)            5       (12.5)
#> 3      (35.3)             29         (34.5)            7       (17.5)
#> 6        <NA>           <NA>           <NA>         <NA>         <NA>
#> 4        <NA>           75.7           <NA>         74.7         <NA>
#> 9        <NA>            8.3           <NA>          7.7         <NA>
#> 5        <NA>           77.5           <NA>         76.0         <NA>
#> 8        <NA>       51 to 88           <NA>     56 to 88         <NA>
#>   High Dosen_2 High Dosep_2 High Dosen_9999 High Dosep_9999 Totaln_1 Totalp_1
#> 7           44         <NA>              84            <NA>      143     <NA>
#> 1           27       (61.4)              55          (65.5)       78   (54.5)
#> 2            6       (13.6)              11          (13.1)       19   (13.3)
#> 3           11       (25.0)              18          (21.4)       46   (32.2)
#> 6         <NA>         <NA>            <NA>            <NA>     <NA>     <NA>
#> 4         74.1         <NA>            74.4            <NA>     75.7     <NA>
#> 9          8.2         <NA>             7.9            <NA>      8.2     <NA>
#> 5         77.0         <NA>            76.0            <NA>     77.0     <NA>
#> 8     56 to 86         <NA>        56 to 88            <NA> 54 to 89     <NA>
#>   Totaln_2 Totalp_2 Totaln_9999 Totalp_9999
#> 7      111     <NA>         254        <NA>
#> 1       66   (59.5)         144      (56.7)
#> 2       14   (12.6)          33      (13.0)
#> 3       31   (27.9)          77      (30.3)
#> 6     <NA>     <NA>        <NA>        <NA>
#> 4     74.4     <NA>        75.1        <NA>
#> 9      8.3     <NA>         8.2        <NA>
#> 5     77.0     <NA>        77.0        <NA>
#> 8 51 to 88     <NA>    51 to 89        <NA>
#> 
#> $display
#> [1] "n"     "prop"  "total"
#> 
#> $display_stat
#> [1] "mean"   "sd"     "median" "range" 
#> 
#> $display_total
#> [1] TRUE
#> 
```
