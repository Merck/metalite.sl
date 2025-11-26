# Count number of subjects

Count number of subjects

## Usage

``` r
collect_baseline(
  meta,
  population,
  parameter,
  type = "Subjects",
  use_na = c("ifany", "no", "always"),
  display_total = TRUE
)
```

## Arguments

- meta:

  A metadata object created by metalite.

- population:

  A character value of population term name. The term name is used as
  key to link information.

- parameter:

  A character value of parameter term name. The term name is used as key
  to link information.

- type:

  A character value to control title name, e.g., Subjects or Records.

- use_na:

  A character value for whether to include `NA` values in the table. See
  the `useNA` argument in
  [`base::table()`](https://rdrr.io/r/base/table.html) for more details.

- display_total:

  A logical value to display total column.

## Value

A list containing number of subjects

## Examples

``` r
meta <- meta_sl_example()
meta |> collect_baseline(
  population = "apat",
  parameter = "age"
)
#> $n
#>                 name Placebo Low Dose High Dose Total   var_label
#> 1 Subjects with Data      86       84        84   254 Age (years)
#> 2            Missing       0        0         0     0 Age (years)
#> 
#> $stat
#>        name        Placebo Low Dose   High Dose    Total   var_label
#> 1     65-80             42       47          55      144 Age (years)
#> 2       <65             14        8          11       33 Age (years)
#> 3       >80             30       29          18       77 Age (years)
#> 4      <NA>           <NA>     <NA>        <NA>     <NA> Age (years)
#> 5      Mean           75.2     75.7        74.4     75.1 Age (years)
#> 6        SD            8.6      8.3         7.9      8.2 Age (years)
#> 7        SE            0.9      0.9         0.9      0.5 Age (years)
#> 8    Median           76.0     77.5        76.0     77.0 Age (years)
#> 9       Min           52.0     51.0        56.0     51.0 Age (years)
#> 10      Max           89.0     88.0        88.0     89.0 Age (years)
#> 11 Q1 to Q3 69.25 to 81.75 71 to 82 70.75 to 80 70 to 81 Age (years)
#> 12    Range       52 to 89 51 to 88    56 to 88 51 to 89 Age (years)
#> 
#> $pop
#>        name  Placebo Low Dose High Dose    Total   var_label
#> 1     65-80 48.83721 55.95238  65.47619 56.69291 Age (years)
#> 2       <65 16.27907  9.52381  13.09524 12.99213 Age (years)
#> 3       >80 34.88372 34.52381  21.42857 30.31496 Age (years)
#> 4      <NA>       NA       NA        NA       NA Age (years)
#> 5      Mean       NA       NA        NA       NA Age (years)
#> 6        SD       NA       NA        NA       NA Age (years)
#> 7        SE       NA       NA        NA       NA Age (years)
#> 8    Median       NA       NA        NA       NA Age (years)
#> 9       Min       NA       NA        NA       NA Age (years)
#> 10      Max       NA       NA        NA       NA Age (years)
#> 11 Q1 to Q3       NA       NA        NA       NA Age (years)
#> 12    Range       NA       NA        NA       NA Age (years)
#> 
#> $var_type
#> [1] "numeric"
#> 
```
