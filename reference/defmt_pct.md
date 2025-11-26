# Deformat percent

Deformat percent

## Usage

``` r
defmt_pct(pct)
```

## Arguments

- pct:

  string eager to remove percent

## Value

Numeric value without percent

## Examples

``` r
defmt_pct("10.0%")
#> [1] 10
defmt_pct(c("10.0%", "(11.2%)"))
#> [1] 10.0 11.2
```
