library(httr)
library(dplyr)
library(lubridate)

# Funktion zum Abrufen der Feiertage für ein bestimmtes Jahr und Bundesland
get_feiertage <- function(jahr, land) {
  url <- paste0("https://feiertage-api.de/api/?jahr=", jahr, "&nur_land=", land)
  response <- GET(url)
  feiertage <- content(response, "parsed")
  return(feiertage)
}

# Start- und Enddatum festlegen
start_date <- as.Date("2013-07-01")
end_date <- as.Date("2017-12-27")

# Liste für Feiertage
feiertage_list <- list()

# Feiertage für jedes Jahr abrufen und speichern
for (year in seq(year(start_date), year(end_date))) {
  feiertage_year <- get_feiertage(year, "SH")  # SH steht für Schleswig-Holstein
  feiertage_list[[as.character(year)]] <- feiertage_year
}

# Feiertage in einen einzigen Datenrahmen zusammenführen
feiertage_df <- bind_rows(feiertage_list)

# Create a new data frame with the desired format
feiertage_csv <- data.frame(Date = seq(start_date, end_date, by = "days"))

# Fill corresponding columns with 1 for each feiertag hit
for (feiertag in colnames(feiertage_df)) {
  feiertage_csv[[feiertag]] <- as.numeric(feiertage_csv$Date %in% feiertage_df[[feiertag]])
}

# Save the transformed data frame to CSV
write.csv(feiertage_csv, "feiertage_kiel_transformed.csv", row.names = FALSE)
