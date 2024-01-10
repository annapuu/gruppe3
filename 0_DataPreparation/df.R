# import library
library("dplyr")

# Step 1: Identify and Handle Missing Values

# load data
df <- read_csv("0_DataPreparation/data.csv")
test_id <- read_csv(("../3_Model/test.csv"))

# delete unnecessary rows without Umsatz-data before 2013-07-01
df <- df %>%
  filter(Datum >= as.Date('2013-07-01'))

# Checking for missing values
missing_values <- sapply(df, function(x) sum(is.na(x)))
print(missing_values)


# Step 2: Delete Rows with Missing Values

# Remove rows with missing values
# but keep the missing values in columns id, Umsatz, Warengruppe as they're needed as test features later on
df <- df[complete.cases(df[, c(2, 5, 6, 7, 8, 9, 10, 11)]), ]
dim(df)

# Check
print(sapply(df, function(x) sum(is.na(x))))


# Step 3: join dataset with the test data variables
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

# put id at the start of the dataset and Warengruppe at third place
df <- df %>% relocate(id)
df <- df %>% relocate(Warengruppe, .after=Datum)

# Check
names(df)

# Specify the path where you want to save the CSV file
csv_file_path <- "../0_DataPreparation/df.csv"

# Set the working directory to the desired location // not needed if the path is specified
# setwd("../gruppe3/0_DataPreparation/")

# Save the processed data as CSV
write.csv(df, csv_file_path, row.names = FALSE)
