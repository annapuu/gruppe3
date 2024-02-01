# Data Preparation

**[Preparing the dataset](data.R):** Importing the data, joining the datasets, creating new variables and saving as a csv-file
- feiertage.csv -> [Creating Feiertage data](feiertage.R)
- kiwo.csv
- schulferien.csv
- train_kaggle.csv
- wetter.csv
- [Saved file with all variables](data.csv)


**[Handling missing values for the neural net](df_neural_net.R):** Joining with test data, deleting unneeded data, handling missing values and saving as a csv-file
- [Saved file for neural net](df_neural_net.csv)


**[Preparing the dataset for the neural net](neural-net-data-preparation.R):** Sorting the dataset by date, creating features and labels, splitting the them into training, validation and test data and saving them as a csv-file in a separate folder
- [Folder with the six prepared csv-files](https://github.com/annapuu/gruppe3/tree/main/csv_df_neural_net)
  - test_features.csv
  - test_labels.csv
  - training_features.csv
  - training_labels.csv
  - validation_features.csv
  - validation_labels.csv
