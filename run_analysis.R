## Getting and Cleaning Data - Week 3
##
## Create one R script called run_analysis.R that does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

setwd("UCI HAR Dataset")

if (! require("data.table")) {
    install.packages("data.table")
}

require("data.table")

# Get the list of all features - For X training and test set
features <- read.table("features.txt")[,2]

# Get the logical state of column to extract from X training and test set
# based on mean/std measurement
extract_features <- grepl("mean|std", features)

# Get the X_test, X_train data
X_test <- read.table("test/X_test.txt")
names(X_test) = features
X_test = X_test[,extract_features]

X_train <- read.table("train/X_train.txt")
names(X_train) = features
X_train = X_train[,extract_features]

# Get the list of activity names - For Y training and test set
# to extend a column
activity_labels <- read.table("activity_labels.txt")[,2]

# Get the Y_test, Y_train and process it with activity data
# by extending a column.
Y_test <- read.table("test/y_test.txt")
Y_train <- read.table("train/y_train.txt")

Y_test[,2] = activity_labels[Y_test[,1]]
names(Y_test) = c("Activity_ID", "Activity_Label")
Y_train[,2] = activity_labels[Y_train[,1]]
names(Y_train) = c("Activity_ID", "Activity_Label")

# Get the subject test data to bind with X_test and Y_test
subject_test <- read.table("test/subject_test.txt")
names(subject_test) = "subject"

# Bind test data - (subject_test, Y_test, X_test)
test_data <- cbind(as.data.table(subject_test), Y_test, X_test)

# Get the subject train data to bind with X_train and Y_train
subject_train <- read.table("train/subject_train.txt")
names(subject_train) <- "subject"

# Bind train data - (subject_train, Y_train, X_train)
train_data <- cbind(as.data.table(subject_train), Y_train, X_train)

# Merge test and train data
collective_data <- rbind(test_data, train_data)
head(collective_data)

if (! require("reshape2")) {
    install.packages("reshape2")
}
require("reshape2")

# Melt the data from wide to long format with extracted features
# as variable.
id_labels <- c("subject", "Activity_ID", "Activity_Label")
var_labels <- setdiff(colnames(data), id_labels)
melt_data <- melt(collective_data, id = id_labels, measure.vars = var_labels)
head(melt_data)

# Convert to wide format with dcast to get the mean of features
# with id as (subject + Activity_Label)
tidy_data <- dcast(melt_data, subject + Activity_Label ~ variable, mean)

write.table(tidy_data, file = "../tidy_data.txt", row.name=FALSE)
