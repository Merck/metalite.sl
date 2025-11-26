# Create metadata for subject-level analysis table

Create metadata for subject-level analysis table

## Usage

``` r
meta_sl(
  dataset_population,
  dataset_observation = NULL,
  population_term,
  observation_term = NULL,
  parameter_term = "age;race;gender",
  parameter_var = "AGE^AGEGR1;RACE;SEX",
  parameter_labels = NULL,
  analysis_term = "base_char",
  analysis_title = "Participant Baseline Characteristics by Treatment Group",
  population_subset = SAFFL == "Y",
  observation_subset = NULL,
  population_label = "All Participants as Treated",
  treatment_group = "TRT01A"
)
```

## Arguments

- dataset_population:

  Source dataset of population.

- dataset_observation:

  Source dataset of observation

- population_term:

  A character value of population term name.

- observation_term:

  A character value of observation term name.

- parameter_term:

  A character value of parameter term name. If there are multiple terms,
  they are separated by the semicolon (;).

- parameter_var:

  A character value of parameter variable name. If there are multiple
  variables, they are separated by the semicolon (;). A group variable
  can be specified followed by a variable and the hat symbol (^).

- parameter_labels:

  A character vector of parameter label name. The length of vector
  should be the same as the number of parameter terms. A label from an
  input data is used if `NA` for a variable is specified.

- analysis_term:

  A character value of analysis term name.

- analysis_title:

  A character value of analysis title name.

- population_subset:

  An unquoted condition for selecting the populations from dataset of
  population.

- observation_subset:

  An unquoted condition for selecting the populations from dataset of
  observation

- population_label:

  A character value of population label.

- treatment_group:

  A character value of treatment group name.

## Value

A metalite object.

## Examples

``` r
meta_sl(
  dataset_population = r2rtf::r2rtf_adsl,
  population_term = "apat",
  parameter_term = "age;race",
  parameter_var = "AGE^AGEGR1;RACE"
)
#> ADaM metadata: 
#>    .$data_population     Population data with 254 subjects 
#>    .$data_observation    Observation data with 254 records 
#>    .$plan    Analysis plan with 1 plans 
#> 
#> 
#>   Analysis population type:
#>     name        id    group
#> 1 'apat' 'USUBJID' 'TRT01A'
#>                                                                                                                                                                                                                                                                                                                                                                                                              var
#> 1 STUDYID, USUBJID, SUBJID, SITEID, SITEGR1, ARM, TRT01P, TRT01PN, TRT01A, TRT01AN, TRTSDT, TRTEDT, TRTDUR, AVGDD, CUMDOSE, AGE, AGEGR1, AGEGR1N, AGEU, RACE, RACEN, SEX, ETHNIC, SAFFL, ITTFL, EFFFL, COMP8FL, COMP16FL, COMP24FL, DISCONFL, DSRAEFL, DTHFL, BMIBL, BMIBLGR1, HEIGHTBL, WEIGHTBL, EDUCLVL, DISONSDT, DURDIS, DURDSGR1, VISIT1DT, RFSTDTC, RFENDTC, VISNUMEN, RFENDT, DCDECOD, DCREASCD, MMSETOT
#>         subset                         label
#> 1 SAFFL == 'Y' 'All Participants as Treated'
#> 
#> 
#>   Analysis observation type:
#>     name        id    group
#> 1 'apat' 'USUBJID' 'TRT01A'
#>                                                                                                                                                                                                                                                                                                                                                                                                              var
#> 1 STUDYID, USUBJID, SUBJID, SITEID, SITEGR1, ARM, TRT01P, TRT01PN, TRT01A, TRT01AN, TRTSDT, TRTEDT, TRTDUR, AVGDD, CUMDOSE, AGE, AGEGR1, AGEGR1N, AGEU, RACE, RACEN, SEX, ETHNIC, SAFFL, ITTFL, EFFFL, COMP8FL, COMP16FL, COMP24FL, DISCONFL, DSRAEFL, DTHFL, BMIBL, BMIBLGR1, HEIGHTBL, WEIGHTBL, EDUCLVL, DISONSDT, DURDIS, DURDSGR1, VISIT1DT, RFSTDTC, RFENDTC, VISNUMEN, RFENDT, DCDECOD, DCREASCD, MMSETOT
#>         subset label
#> 1 SAFFL == 'Y'    ''
#> 
#> 
#>   Analysis parameter type:
#>     name  label subset
#> 1  'age'  'Age'       
#> 2 'race' 'Race'       
#> 
#> 
#>   Analysis function:
#>          name label
#> 1 'base_char'    ''
#> 
```
