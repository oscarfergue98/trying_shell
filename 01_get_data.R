# Code to download some data

source("~setup_context.R")
source("~funcs.R") 

developing_subset <- c("Argentina", "Brazil", "Mexico", "Ecuador", "South Africa")


# Import GDPs data #

gdps <- readxl::read_excel(file.path(RAW_DATA_PATH, "gdps.xlsx"), range = "B7:KH68", na = "...", sheet = "Quarterly") |>
  dplyr::select(-Scale, -`Base Year`) |>
  dplyr::rename(country = Country) |>
  tidyr::pivot_longer(!country, names_to = "date", values_to = "gdp") |>
  dplyr::mutate(date = zoo::as.Date(zoo::as.yearqtr(date, format = "%YQ%q")))

# Import consumption data #

consumption <- readxl::read_excel(file.path(RAW_DATA_PATH, "private_cons.xlsx"), range = "B7:KH63", na = "...", sheet = "Quarterly") |>
  dplyr::select(-Scale, -`Base Year`) |>
  dplyr::rename(country = Country) |>
  tidyr::pivot_longer(!country, names_to = "date", values_to = "consumption") |>
  dplyr::mutate(date = zoo::as.Date(zoo::as.yearqtr(date, format = "%YQ%q")))

# Import GFCF 

gfcf <- readxl::read_excel(file.path(RAW_DATA_PATH, "gfcf.xlsx"), range = "B7:JN64", na = "...", sheet = "Quarterly") |>
  dplyr::select(-Scale, -`Base Year`) |>
  dplyr::rename(country = Country) |>
  tidyr::pivot_longer(!country, names_to = "date", values_to = "gfcf") |>
  dplyr::mutate(date = zoo::as.Date(zoo::as.yearqtr(date, format = "%YQ%q")))

# Import imports #

imports <- readxl::read_excel(file.path(RAW_DATA_PATH, "imports.xlsx"), range = "B7:KH64", na = "...", sheet = "Quarterly") |>
  dplyr::select(-Scale, -`Base Year`) |>
  dplyr::rename(country = Country) |>
  tidyr::pivot_longer(!country, names_to = "date", values_to = "imports") |>
  dplyr::mutate(date = zoo::as.Date(zoo::as.yearqtr(date, format = "%YQ%q")))

# Import exports #

exports <- readxl::read_excel(file.path(RAW_DATA_PATH, "exports.xlsx"), range = "B7:KH64", na = "...", sheet = "Quarterly") |>
  dplyr::select(-Scale, -`Base Year`) |>
  dplyr::rename(country = Country) |>
  tidyr::pivot_longer(!country, names_to = "date", values_to = "exports")  |>
  dplyr::mutate(date = zoo::as.Date(zoo::as.yearqtr(date, format = "%YQ%q")))

# First, merge exports and imports to create net exports #

nx <- expand.grid(
  date = unique(c(exports$date, imports$date)), 
  country = unique(c(exports$country, imports$country)), stringsAsFactors = FALSE
) |> 
  dplyr::arrange(country, date) |> 
  dplyr::left_join(imports, by = c("date", "country")) |> 
  dplyr::left_join(exports, by = c("date", "country")) |>
  dplyr::mutate(nx = imports - exports) |>
  dplyr::select(-imports, -exports)

# Merge all the datasets #

national_accounts <- expand.grid(
  date = unique(c(gdps$date, consumption$date, gfcf$date, nx$date)),
  country = unique(c(gdps$country, consumption$country, gfcf$country, nx$country)),
  stringsAsFactors = FALSE
) |>
  dplyr::arrange(country, date) |>
  dplyr::left_join(gdps, by = c("date", "country")) |>
  dplyr::left_join(consumption, by = c("date", "country")) |>
  dplyr::left_join(gfcf, by = c("date", "country")) |>
  dplyr::left_join(nx, by = c("date", "country")) |>
  dplyr::filter(country %in% developing_subset)

# Import EMBI TS #

EMBI_TS <- readxl::read_excel(file.path(RAW_DATA_PATH, "EMBI TS.xlsx"),
                              range = "A1:HP410", na = "..") |>
  dplyr::select(-Series, -`Series Code`, -`Time Code`) |>
  dplyr::rename(
    date = Time,
    Argentina = `Argentina [ARG]`,
    Brazil = `Brazil [BRA]`,
    Ecuador = `Ecuador [ECU]`,
    Mexico = `Mexico [MEX]`,
    Peru = `Peru [PER]`,
    Philippines = `Philippines [PHL]`,
    `South Africa` = `South Africa [ZAF]`
  ) |>
  dplyr::filter(grepl("M", date)) |>
  dplyr::mutate(date = zoo::as.Date(zoo::as.yearmon(date, format = "%YM%m"))) |>
  tidyr::pivot_longer(!date, names_to = "country", values_to = "embi") |>
  dplyr::mutate(year = lubridate::year(date), quarter = lubridate::quarter(date)) |>
  dplyr::group_by(year, quarter, country) |>
  dplyr::summarise(embi = mean(embi, na.rm = TRUE), .groups = "drop") |>
  dplyr::mutate(date = zoo::as.Date(zoo::as.yearqtr(paste0(year, "-", quarter)), format = "%Y Q%q")) |>
  dplyr::select(-year, -quarter) |>
  dplyr::arrange(country, date)


# Now, need to add the "world" interest rate #
# 3-Month Treasury Bill Secondary Market Rate, Discount Basis #

treasury_bill <- fredr::fredr("DTB3", frequency = "q") |>
  dplyr::select(date, value) |>
  dplyr::rename(treasury_bill = value)

# Now, need to deflate it by US GDP Deflator #

# Gross Domestic Product: Implicit Price Deflator #
# Percent Change from Preceding Period, Seasonally Adjusted Annual Rate #

us_deflator <- fredr::fredr("USAGDPDEFQISMEI") |>
  dplyr::select(date, value) |>
  dplyr::mutate(us_deflator = 100 * log(value / dplyr::lag(value))) |> 
  dplyr::select(-value)

# Merge Treasury bill and GDP deflator inflation #

us_data <- expand.grid(
  date = unique(c(treasury_bill$date, us_deflator$date)),
  stringsAsFactors = FALSE
) |>
  dplyr::mutate(date = as.Date(date)) |>
  dplyr::arrange(date) |>
  dplyr::left_join(treasury_bill, by = "date") |>
  dplyr::left_join(us_deflator, by = "date") |>
  dplyr::mutate(us_real_rate = treasury_bill/4 - 0.25 * (us_deflator + lag(us_deflator, n = 1)+ lag(us_deflator, n = 2)+ lag(us_deflator, n = 3))) |>
  dplyr::select(date, us_real_rate)


emerging_rates <- expand.grid(
  date = unique(c(EMBI_TS$date, us_data$date)),
  country = unique(EMBI_TS$country),
  stringsAsFactors = FALSE
) |>
  dplyr::mutate(date = zoo::as.Date(date)) |>
  dplyr::arrange(country, date) |>
  dplyr::left_join(EMBI_TS, by = c("date", "country")) |>
  dplyr::left_join(us_data, by = "date") |>
  dplyr::mutate(real_rate = as.numeric(embi)/400 + as.numeric(us_real_rate)) |>
  dplyr::select(-embi) |> 
  dplyr::filter(!is.na(real_rate), country %in% developing_subset)

# Create the final dataset #

developing_dataset <- expand.grid(
  date = unique(c(national_accounts$date, emerging_rates$date)),
  country = unique(c(national_accounts$country, emerging_rates$country)),
  stringsAsFactors = FALSE
) |>
  dplyr::mutate(date = as.Date(date)) |>
  dplyr::arrange(country, date) |>
  dplyr::left_join(national_accounts, by = c("date", "country")) |>
  dplyr::left_join(emerging_rates, by = c("date", "country")) |>
  na.omit() |>
  dplyr::filter(lubridate::year(date) <= 2019) |>
  dplyr::mutate(gdp = log(gdp), 
         consumption = log(consumption), 
         gfcf = log(gfcf)) |>
  dplyr::arrange(country, date)


# Finally, import Brent spot oil price 

oil_price <- readxl::read_excel(file.path(RAW_DATA_PATH, "RBRTEm.xls"), 
                       range = "A3:B429", 
                       sheet = "Data 1") |> 
  dplyr::rename(date = Date, 
         oil_price = `Europe Brent Spot Price FOB (Dollars per Barrel)`) |> 
  dplyr::mutate(date = as.Date(date, format = "%Y-%m-%d")) |> 
  dplyr::mutate(quarter = lubridate::quarter(date), 
         year = lubridate::year(date)) |> 
  dplyr::arrange(year,quarter) |> 
  dplyr::group_by(year, quarter) |> 
  dplyr::summarise(oil_price = mean(oil_price), .groups = "drop") |> 
  dplyr::mutate(tmp_date = paste(year,"Q", quarter, sep = ""), 
         date = zoo::as.Date(zoo::as.yearqtr(tmp_date, format = "%YQ%q"))) |> 
  dplyr::ungroup() |> 
  dplyr::select(-tmp_date, -year, -quarter) |> 
  dplyr::filter(lubridate::year(date) <= 2019)

developing_dataset <- expand.grid(
  date = unique(c(developing_dataset$date, oil_price$date)),
  country = unique(developing_dataset$country),
  stringsAsFactors = FALSE
) |>
  dplyr::mutate(date = as.Date(date)) |>
  dplyr::arrange(country, date) |>
  dplyr::left_join(developing_dataset, by = c("date", "country")) |>
  dplyr::left_join(oil_price, by = "date") |> 
  na.omit()

# Need to get the min date for BEAR toolbox #

min_date <- developing_dataset |> 
  dplyr::group_by(country) |> 
  dplyr::summarise(min_date = min(date), .groups = "drop")

min_date <- min_date |> 
  dplyr::summarise(min_date = max(min_date))

developing_dataset_truncated <- developing_dataset |> 
  dplyr::filter(date >= min_date$min_date)

# Generate data for Matlab plots 

plots_data <- developing_dataset_truncated |> 
  dplyr::select(date,country,gdp,real_rate) |> 
  dplyr::group_by(country) |> 
  dplyr::mutate(trend = dplyr::row_number(), 
         trend2 = trend^2, 
         gdp = 100 * lm(gdp~trend+trend2)$residuals) |> 
  dplyr::ungroup() |> 
  dplyr::select(-trend,-trend2)

writexl::write_xlsx(plots_data, file.path(INTERMEDIARY_DATA_PATH, "plots_data.xlsx"))

# Divide real rate by 100 so that all variables are 
# expressed in the same units!
# Do not select the US real rate for now

developing_dataset_truncated = developing_dataset_truncated |> 
  dplyr::mutate(real_rate = real_rate / 100) |> 
  dplyr::select(-us_real_rate)

# Adapt net exports, GDP and consumption #
# Disregard for now the cointegration issues #

country_data <- setNames(
  lapply(developing_subset, function(c) adapt_vars(developing_dataset_truncated, c)),
  c("argentina_data", "brazil_data", "mexico_data", "ecuador_data", "southafrica_data")
)

list2env(country_data, envir = .GlobalEnv)

# Put here for BEAR #

argentina <- argentina_data |>
  dplyr::mutate(date = format(zoo::as.yearqtr(date), format = "%Yq%q"))


brazil <- brazil_data |>
  dplyr::mutate(date = format(zoo::as.yearqtr(date), format = "%Yq%q"))


mexico <- mexico_data |>
  dplyr::mutate(date = format(zoo::as.yearqtr(date), format = "%Yq%q"))



ecuador <- ecuador_data |>
  dplyr::mutate(date = format(zoo::as.yearqtr(date), format = "%Yq%q"))


southafrica <- southafrica_data |>
  dplyr::mutate(date = format(zoo::as.yearqtr(date), format = "%Yq%q"))


developing_panel_bvar <- dplyr::bind_rows(argentina, brazil, mexico, ecuador, 
                                  southafrica) 

developing_panel_bvar <- developing_panel_bvar |>
  dplyr::mutate(
    country = tolower(gsub(" ", "", country)),
    dplyr::across(c(gdp, consumption, gfcf, nx, real_rate), ~ . * 100)
  )

developing_panel_bvar <- split(developing_panel_bvar, developing_panel_bvar$country)

developing_panel_bvar <- lapply(developing_panel_bvar, function(x) {x <- x |> dplyr::select(-country)})

col.names = c("", "gdp", "consumption", "gfcf", "nx", "real_rate", "oil_price")

developing_panel_bvar = lapply(developing_panel_bvar, setNames, col.names)

# Write the dataset for the normal Cholesky model + the Jarocinski one 

writexl::write_xlsx(developing_panel_bvar, file.path(INTERMEDIARY_DATA_PATH, "final_developing.xlsx"))


