# Code to download some data

source("~setup_context.R")

cpi_df <- readr::read_csv(
  file.path(RAW_DATA_PATH, "CPIAUCSL.csv"), 
  show_col_types = FALSE
)

rgdp_df <- readr::read_csv(
  file.path(RAW_DATA_PATH, "GDPC1.csv"), 
  show_col_types = FALSE
)

final_df <- 
  expand.grid(
    date = unique(
      c(cpi_df$observation_date, rgdp_df$observation_date)
    )
  ) |> 
  dplyr::left_join(cpi_df, by = c("date" = "observation_date")) |> 
  dplyr::left_join(rgdp_df, by = c("date" = "observation_date")) |> 
  dplyr::mutate(date = zoo::as.Date(date)) |> 
  dplyr::filter(lubridate::year(date) < 2025)


# Write the final dataframe 

readr::write_csv(x = final_df, file = file.path(INTERMEDIARY_DATA_PATH, "cpi_gdp_df.csv"))
