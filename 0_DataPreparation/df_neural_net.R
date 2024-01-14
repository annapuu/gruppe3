# import library
library("readr")
library("dplyr")
library(naniar)
library(zoo)


### Step 1: Load data

# load data
df <- read_csv("0_DataPreparation/data.csv")
test_id <- read_csv("3_Model/test.csv")

# delete unnecessary rows without Umsatz-data before 2013-07-01
df <- df %>%
  filter(Datum >= as.Date('2013-07-01'))


### Step 2: Join dataset with the test data variables
df <- df %>%
  left_join(test_id, by = "Datum")

# Check
names(df)

# merge id and Warengruppe
df$id <- coalesce(df$id.x, df$id.y)
df$Warengruppe <- coalesce(df$Warengruppe.x, df$Warengruppe.y)

# Check
names(df)

# Remove unneeded columns
df <- subset(df, select = -c(id.x, id.y, Warengruppe.x, Warengruppe.y))

# Check
names(df)

# Put id at the start of the dataset and Warengruppe at third place
df <- df %>% relocate(id)
df <- df %>% relocate(Warengruppe, .after=Datum)

# Check
names(df)


### Step 3: Handling of Missing Values

# Checking for missing values
miss_var_summary(df)
# -> delete: id, Warengruppe
#  -> Bewoelkung: take value of the day before
#  -> Temperatur: mean of three days before and after
# -> Windgeschwindigkeit: mean of three days before and after
# -> Wettercode: take value of the day before
# Replace missing values in 'Bewoelkung' with the value of the day before
df$Bewoelkung <- ifelse(is.na(df$Bewoelkung), lag(df$Bewoelkung), df$Bewoelkung)

# Replace missing values in 'Temperatur' with the mean of three days before and after
df$Temperatur <- ifelse(is.na(df$Temperatur),
                        (lag(df$Temperatur, 1) + df$Temperatur + lead(df$Temperatur, 1)) / 3,
                        df$Temperatur)

# Replace missing values in 'Windgeschwindigkeit' with the mean of three days before and after
df$Windgeschwindigkeit <- ifelse(is.na(df$Windgeschwindigkeit),
                                 (lag(df$Windgeschwindigkeit, 1) + df$Windgeschwindigkeit + lead(df$Windgeschwindigkeit, 1)) / 3,
                                 df$Windgeschwindigkeit)
miss_var_summary(df)
# Replace missing values in 'Wettercode' with the value of the day before
df$Wettercode <- ifelse(is.na(df$Wettercode), lag(df$Wettercode), df$Wettercode)

# Remove rows with missing values
# but keep the missing values in columns id, Umsatz, Warengruppe as they're needed as test features later on
df <- df[complete.cases(df[, c(2, 5, 6, 7, 8, 9, 10, 11)]), ]
dim(df)

# Check
print(sapply(df, function(x) sum(is.na(x))))


### Step 4: Save as csv-file
# Specify the path where you want to save the CSV file
csv_file_path <- "0_DataPreparation/df_neural_net.csv"

# Save the processed data as CSV
write.csv(df, csv_file_path, row.names = FALSE)
miss_var_summary(df)
miss_var_summary(data)
