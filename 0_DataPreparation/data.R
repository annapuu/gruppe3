# import libraries
library("readr")
library("dplyr")
library("lubridate")

# load all datasets
d1 <- read_csv("0_DataPreparation/train_kaggle.csv")
d2 <- read_csv("0_DataPreparation/kiwo.csv")
d3 <- read_csv("0_DataPreparation/wetter.csv")
d4 <- read_csv("0_DataPreparation/schulferien.csv")

# create a single dataset (tibble)
data <- d1 %>%
  full_join(d2, by = "Datum") %>%
  full_join(d3, by = "Datum") %>%
  full_join(d4, by = "Datum")

# create a new column for the variable weekend
data <- data %>%
  mutate(Wochenende = ifelse(wday(Datum) %in% c(1, 7), 1, 0))

# fill missing values in columns KielerWoche and Schulferien with zero
data_filled <- data %>%
  mutate(KielerWoche = ifelse(is.na(KielerWoche), 0, KielerWoche),
         Schulferien = ifelse(is.na(Schulferien), 0, Schulferien))

# save tibble as a csv-file
write.csv(data_filled, file = "0_DataPreparation/data.csv", row.names = FALSE)
