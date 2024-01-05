
# Step 1: Identify and Handle Missing Values
df<-data
# Checking for missing values
missing_values <- sapply(df, function(x) sum(is.na(x)))
print(missing_values)


# Step 2: Delete Rows with Missing Values

# Remove rows with missing values
df <- df[complete.cases(df), ]
dim(df)

# Specify the path where you want to save the CSV file
csv_file_path <- "df.csv"

# Set the working directory to the desired location
setwd("/Users/fatihanisa/Desktop/Machine learning/data science/gruppe3/0_DataPreparation/")

# Save the processed data as CSV
write.csv(df, csv_file_path, row.names = FALSE)


