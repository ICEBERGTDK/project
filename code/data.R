start_using_memoise()
stop_using_memoise()
reset_cache()
nots <- get_national_data()
#> Downloading data from https://covid19.who.int/WHO-COVID-19-global-data.csv
#> Cleaning data
#> Processing data
nots
#> # A tibble: 182,253 × 15
#>    date       un_region who_region country iso_code cases_new cases_total deaths_new deaths_total recovered_new
#>    <date>     <chr>     <chr>      <chr>   <chr>        <dbl>       <dbl>      <dbl>        <dbl>         <dbl>
#>  1 2020-01-03 Asia      WPRO       China… CN               0           0          0            0            NA
#>  2 2020-01-03 Oceania   WPRO       Australia AU               0           0          0            0            NA
#>  3 2020-01-03 Africa    AFRO       Algeria DZ               0           0          0            0            NA
#> # … with 182,243 more rows, and 5 more variables: recovered_total <dbl>, hosp_new <dbl>, hosp_total <dbl>,
#> #   tested_new <dbl>, tested_total <dbl>
COM7 <- c(
  "United States", "United Kingdom", "France", "Germany",
  "Italy", "Canada", "China"
)
COM7_nots <- get_national_data(countries = COM7, verbose = FALSE)

COM7_nots %>%
  ggplot() +
  aes(x = date, y = deaths_new, col = country) +
  geom_line(alpha = 0.4) +
  labs(x = "Date", y = "Reported Covid-19 deaths") +
  scale_y_continuous(labels = comma) +
  theme_minimal() +
  theme(legend.position = "top") +
  guides(col = guide_legend(title = "Country"))
