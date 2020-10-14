# run_analysis.R


library(reshape2)


# get dataset from web
CleanDataDir <- "./CleansedData"
rawDataUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
rawDataDFn <- paste(CleanDataDir, "/", "CleansedData.zip", sep = "")
dataDir <- "./data"

# check if local directory created. Download dataset into specified directory
if (!file.exists(CleanDataDir)) {
    dir.create(CleanDataDir)
    download.file(url = rawDataUrl, destfile = rawDataDFn)
}
if (!file.exists(dataDir)) {
    dir.create(dataDir)
    unzip(zipfile = rawDataDFn, exdir = dataDir)
}


# train data
x_train <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/train/X_train.txt"))
y_train <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/train/Y_train.txt"))
subject_train <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/train/subject_train.txt"))

# test data
x_test <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/test/X_test.txt"))
y_test <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/test/Y_test.txt"))
subject_test <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/test/subject_test.txt"))

# merge {train, test} data
x_data <- rbind(x_train, x_test)
y_data <- rbind(y_train, y_test)
subject_data <- rbind(subject_train, subject_test)


# load feature & activity info
# feature info
feature <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/features.txt"))

# activity labels
activity_label <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/activity_labels.txt"))
activity_label[,2] <- as.character(activity_label[,2])

# extract feature cols & names named 'mean, std'. Rename column name 'mean', 'std' to 'Mean', 'Standard' respectively
selectedCols <- grep("-(mean|std).*", as.character(feature[,2]))
selectedColNames <- feature[selectedCols, 2]
selectedColNames <- gsub("-mean", "Mean", selectedColNames)
selectedColNames <- gsub("-std", "Standard", selectedColNames)
selectedColNames <- gsub("[-()]", "", selectedColNames)


#extract merged data by cols & using descriptive name
x_data <- x_data[selectedCols]
allData <- cbind(subject_data, y_data, x_data)
colnames(allData) <- c("Subject", "Activity", selectedColNames)

allData$Activity <- factor(allData$Activity, levels = activity_label[,1], labels = activity_label[,2])
allData$Subject <- as.factor(allData$Subject)


#generate tidy data set
meltedData <- melt(allData, id = c("Subject", "Activity"))
tidyDataSet <- dcast(meltedData, Subject + Activity ~ variable, mean)

write.table(tidyDataSet, "./tidy_dataset.txt", row.names = FALSE, quote = FALSE)
