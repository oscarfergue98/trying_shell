# Functions file 

adapt_vars <- function(df, country_name){
  current_df <- df |>
    dplyr::filter(country == country_name)
  
  current_df |>
    dplyr::mutate(trend = c(1:dim(current_df)[1]), 
                  trend2 = c(1:dim(current_df)[1])^2, 
                  nx = nx / exp(lm(gdp ~ trend + trend2)$fitted.values), 
                  nx = lm(nx ~ trend + trend2)$residuals,
                  consumption = lm(consumption ~ trend + trend2)$residuals,
                  gdp = lm(gdp ~ trend + trend2)$residuals, 
                  gfcf = lm(gfcf ~ trend + trend2)$residuals) |>
    dplyr::select(-trend, -trend2)
}