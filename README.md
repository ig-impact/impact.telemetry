
<!-- README.md is generated from README.Rmd. Please edit that file -->

# impact.telemetry <img src="man/figures/logo.png" align="right" height="138" alt="" />

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

The goal of impact.telemetry is to …

## Installation

You can install the development version of impact.telemetry from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("ig-impact/impact.telemetry")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(impact.telemetry)

log_file <- start_telemetry_logging()
#> Telemetry logging started. Log file: telemetry-94938.log

log_add <- with_telemetry(function(a, b) {
  a + b
}, event_name = "add", log_args = TRUE, log_result = TRUE)

result <- log_add(1, 2)

result <- log_add(1, 20)
```

``` r
lapply(readLines(log_file, n = 10), jsonlite::fromJSON)
#> [[1]]
#> [[1]]$timestamp
#> [1] "2025-06-11 15:50:28"
#> 
#> [[1]]$event
#> [1] "add"
#> 
#> [[1]]$status
#> [1] "success"
#> 
#> [[1]]$args
#> [1] 1 2
#> 
#> [[1]]$duration_ms
#> [1] 0.012
#> 
#> [[1]]$result
#> [1] 3
#> 
#> 
#> [[2]]
#> [[2]]$timestamp
#> [1] "2025-06-11 15:50:28"
#> 
#> [[2]]$event
#> [1] "add"
#> 
#> [[2]]$status
#> [1] "success"
#> 
#> [[2]]$args
#> [1]  1 20
#> 
#> [[2]]$duration_ms
#> [1] 0.01
#> 
#> [[2]]$result
#> [1] 21
```
