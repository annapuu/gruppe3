
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
data <- read_csv("0_DataPreparation/df_neural_net.csv")
names(data)




###################################################
### Data Preparation ####

# Pick columns with booleans
#columns_to_float <- c("KielerWoche", "Schulferien", "Wochenende")

# Change booleans to Floats
#data <- data %>%
#  mutate(across(all_of(columns_to_float), as.numeric))

# Check
print(head(data))

# fill missing values in Umsatz column with zero
data <- data %>%
  mutate(Umsatz = ifelse(is.na(Umsatz), 0, Umsatz))


# Preparation of independent variables ('features') by dummy coding the categorical variables
features <- as_tibble(model.matrix(Umsatz ~ as.factor(Warengruppe) +
                                            KielerWoche +
                                            Bewoelkung +
                                            Temperatur +
                                            Windgeschwindigkeit +
                                            as.factor(Wettercode) +
                                            Schulferien +
                                            Feiertag +
                                            Wochenende +
                                            as.factor(Season),
                                    data))
names(features)


# Removing missing values, otherwise the code after this won't work
data <- data[complete.cases(data), ]

# Construction of prepared data set
prepared_data <- tibble(label=data$Umsatz, features) %>%  # inclusion of the dependent variable ('label')
  filter(complete.cases(.)) # Handling of missing values (here: only keeping rows without missing values)


# Add variable Datum and id to prepared_data for sorting by date in the next step
Datum <- data$Datum
prepared_data <- cbind(Datum, prepared_data)
head(prepared_data)

id <- data$id
prepared_data <- cbind(id, prepared_data)
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
  prepared_data_sorted %>% select(-label) %>% filter(Datum >= "2018-08-01" & Datum <= "2019-07-30")

training_labels <-
  prepared_data_sorted %>% select(label) %>% filter(Datum <= "2017-07-31")
validation_labels <-
  prepared_data_sorted %>% select(label) %>% filter(Datum >= "2017-08-01" & Datum <= "2018-07-31")
test_labels <-
  prepared_data_sorted %>% select(label) %>% filter(Datum >= "2018-08-01" & Datum <= "2019-07-30")


###################################################
### delete column Datum in the features datasets and id in the first two datasets ###

training_features[1:2] <- NULL
validation_features[1:2] <- NULL
test_features[2] <- NULL

# Check
print(names(training_features))
print(names(validation_features))
print(names(test_features))

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
