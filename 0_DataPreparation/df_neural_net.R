# Import libraries
library("readr")
library("dplyr")
library("naniar")
library("zoo")

### Step 1: Load data
df <- read_csv("0_DataPreparation/data.csv")
test_id <- read_csv("3_Model/test.csv")

# Delete unnecessary rows without Umsatz-data before 2013-07-01
df <- df %>%
  filter(Datum >= as.Date('2013-07-01'))

### Step 2: Join dataset with the test data variables
df <- df %>%
  left_join(test_id, by = "Datum")

# Merge id and Warengruppe
df$id <- coalesce(df$id.x, df$id.y)
df$Warengruppe <- coalesce(df$Warengruppe.x, df$Warengruppe.y)

# Remove unneeded columns
df <- subset(df, select = -c(id.x, id.y, Warengruppe.x, Warengruppe.y))

# Put id at the start of the dataset and Warengruppe at the third place
df <- df %>% relocate(id)
df <- df %>% relocate(Warengruppe, .after = Datum)

# Sort data by Warengruppe and then by Datum
df <- df %>% arrange(Warengruppe, Datum)

# Initialize 'Imputation' column with 0
df$Imputation <- 0

### Step 3: Handling of Missing Values

# Checking for missing values
miss_var_summary(df)

# Replace missing values in 'Wettercode' with the last observation carried forward
df$Wettercode <- na.locf(df$Wettercode, na.rm = FALSE)
#df$Imputation[df$Imputation == 0 & !is.na(df$Wettercode)] <- 1

# Replace missing values in 'Bewoelkung' with the last observation carried forward
# 0-8 (8max)
df$Bewoelkung <- na.locf(df$Bewoelkung, na.rm = FALSE)
#df$Imputation[df$Imputation == 0 & !is.na(df$Bewoelkung)] <- 1

# Replace missing values in 'Temperatur' with linear interpolation
df$Temperatur <- zoo::na.approx(df$Temperatur)
#df$Imputation[df$Imputation == 0 & !is.na(df$Temperatur)] <- 1

# Replace missing values in 'Windgeschwindigkeit' with linear interpolation
df$Windgeschwindigkeit <- zoo::na.approx(df$Windgeschwindigkeit)
#df$Imputation[df$Imputation == 0 & !is.na(df$Windgeschwindigkeit)] <- 1


# Calculate the mean of three days before and after for 'Temperatur' and update 'Imputation'
#df$Temperatur <- ifelse(is.na(df$Temperatur),
#                        (lag(df$Temperatur, 3) + lag(df$Temperatur, 2) + lag(df$Temperatur, 1) +
#                           lead(df$Temperatur, 1) + lead(df$Temperatur, 2) + lead(df$Temperatur, 3)) / 6,
#                        df$Temperatur)

# Calculate the mean of three days before and after for 'Windgeschwindigkeit' and update 'Imputation'
# Unit: m/s
#df$Windgeschwindigkeit <- ifelse(is.na(df$Windgeschwindigkeit),
#                                 (lag(df$Windgeschwindigkeit, 3) + lag(df$Windgeschwindigkeit, 2) +
#                                    lag(df$Windgeschwindigkeit, 1) + lead(df$Windgeschwindigkeit, 1) +
#                                   lead(df$Windgeschwindigkeit, 2) + lead(df$Windgeschwindigkeit, 3)) / 6,
#                                 df$Windgeschwindigkeit)

# Checking for missing values after imputation
#csv_file_path <- "0_DataPreparation/df_neural_net_imputation_check.csv"
#write.csv(df, csv_file_path, row.names = FALSE)

# Check
miss_var_summary(df)


# Remove rows with missing values in column id
df <- df[complete.cases(df$id), ]

# Check
miss_var_summary(df)

### Step 4: Save as a csv-file
# Specify the path where you want to save the CSV file
csv_file_path <- "0_DataPreparation/df_neural_net.csv"

# Save the processed data as CSV
write.csv(df, csv_file_path, row.names = FALSE)
miss_var_summary(df)
