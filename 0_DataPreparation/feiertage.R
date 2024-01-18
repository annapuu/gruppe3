library(httr)
library(dplyr)
library(lubridate)

# Function to get "Feiertage" for certain year/state
get_feiertage <- function(jahr, land) {
  url <- paste0("https://feiertage-api.de/api/?jahr=", jahr, "&nur_land=", land)
  response <- GET(url)
  feiertage <- content(response, "parsed")
  return(feiertage)
}

# Concerning period
start_date <- as.Date("2013-07-01")
end_date <- as.Date("2019-07-31")

# List for "Feiertage"
feiertage_list <- list()

# calling and saving "Feiertage" for each year
for (year in seq(year(start_date), year(end_date))) {
  feiertage_year <- get_feiertage(year, "SH")  # SH steht für Schleswig-Holstein
  feiertage_list[[as.character(year)]] <- feiertage_year
}

# "Feiertage" in a df
feiertage_df <- bind_rows(feiertage_list)

# Creating df with the wished date format
feiertage_csv <- data.frame(Datum = seq(start_date, end_date, by = "days"))

# Filling corresponding rows with 1 for each "Feiertag"
for (feiertag in colnames(feiertage_df)) {
  feiertage_csv[[feiertag]] <- as.numeric(feiertage_csv$Datum %in% feiertage_df[[feiertag]])
}

# Saving transformed data frame in a csv file
# write.csv(feiertage_csv, "0_DataPreparation/feiertage_separated.csv", row.names = FALSE)
# View(feiertage_csv)

# Loading csv file of the separated "Feiertage" (Each "Feiertag" has its own column in this file)
# feiertage_csv <- read.csv("feiertage_separated.csv", stringsAsFactors = FALSE)

# Creating a column with the name "Feiertag"
feiertage_csv$Feiertag <- apply(feiertage_csv[, -1, drop = FALSE], 1, max)

# Replacing 1st column "Date" with "Datum"
feiertage_csv <- feiertage_csv[, c("Datum", "Feiertag")]

# Saving new/updated df
write.csv(feiertage_csv, "0_DataPreparation/feiertage.csv", row.names = FALSE)

# Showing new/updated df
View(feiertage_csv)

