
###################################################
### Preparation of the Environment ####

# Clear environment
remove(list = ls())

# Create list with needed libraries
pkgs <- c("readr", "dplyr", "reticulate", "ggplot2", "Metrics")

# Load each listed library and check if it is installed and install if necessary
for (pkg in pkgs) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg)
    library(pkg, character.only = TRUE)
  }
}




###################################################
### Data Import ####

# Reading the data file
data <- read_csv("0_DataPreparation/df.csv")
names(data)




###################################################
### Data Preparation ####

# Pick columns with booleans
columns_to_float <- c("KielerWoche", "Schulferien", "Wochenende")

# Change booleans to Floats
data <- data %>%
  mutate(across(all_of(columns_to_float), as.numeric))

# Check
print(head(data))


# Preparation of independent variables ('features') by dummy coding the categorical variables
features <- as_tibble(model.matrix(Umsatz ~ as.factor(Warengruppe) +
                                            KielerWoche +
                                            Bewoelkung +
                                            Temperatur +
                                            Windgeschwindigkeit +
                                            as.factor(Wettercode) +
                                            Schulferien +
                                            Wochenende,
                                    data))
names(features)

# Construction of prepared data set
prepared_data <- tibble(label=data$Umsatz, features) %>%  # inclusion of the dependent variable ('label')
    filter(complete.cases(.)) # Handling of missing values (here: only keeping rows without missing values)

# Add variable Datum to prepared_data for sorting by date in the next step
Datum <- data$Datum
prepared_data <- cbind(Datum, prepared_data)
head(prepared_data)


###################################################
### Selection of Training, Validation and Test Data ####

# sort data by Datum
prepared_data_sorted <- prepared_data %>% arrange(Datum)
head(prepared_data_sorted)

# Split the features and labels for training, validation, and test
training_features <-
  prepared_data_sorted %>% select(-label) %>% filter(Datum <= "2017-07-31")
validation_features <-
  prepared_data_sorted %>% select(-label) %>% filter(Datum >= "2017-08-01" & Datum <= "2018-07-31")
test_features <-
  prepared_data_sorted %>% select(-label) %>% filter(Datum >= "2018-08-01")

training_labels <-
  prepared_data_sorted %>% select(label) %>% filter(Datum <= "2017-07-31")
validation_labels <-
  prepared_data_sorted %>% select(label) %>% filter(Datum >= "2017-08-01" & Datum <= "2018-07-31")
test_labels <-
  prepared_data_sorted %>% select(label) %>% filter(Datum >= "2018-08-01")

# Check the dimensions of the dataframes
cat("Training features dimensions:", dim(training_features), "\n")
cat("Validation features dimensions:",
    dim(validation_features),
    "\n")
cat("Test features dimensions:", dim(test_features), "\n")
cat("\n")
cat("Training labels dimensions:", dim(training_labels), "\n")
cat("Validation labels dimensions:", dim(validation_labels), "\n")
cat("Test labels dimensions:", dim(test_labels), "\n")

###################################################
### Export of the prepared data ####

# Create subdirectory for the csv files
subdirectory <- "csv_df_neural_net"
dir.create(subdirectory)

# Export of the prepared data to subdirectory
write_csv(training_features, paste0(subdirectory, "/training_features.csv"))
write_csv(validation_features, paste0(subdirectory, "/validation_features.csv"))
write_csv(test_features, paste0(subdirectory, "/test_features.csv"))
write_csv(training_labels, paste0(subdirectory, "/training_labels.csv"))
write_csv(validation_labels, paste0(subdirectory, "/validation_labels.csv"))
write_csv(test_labels, paste0(subdirectory, "/test_labels.csv"))
