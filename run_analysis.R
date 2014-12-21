# You should create one R script called run_analysis.R that does the following. 
# 1 - Merges the training and the test sets to create one data set.
# 2 - Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3 - Uses descriptive activity names to name the activities in the data set
# 4 - Appropriately labels the data set with descriptive variable names. 
# 5 - From the data set in step 4, creates a second, independent tidy data set with the
# average of each variable for each activity and each subject.

# Cleaning the workspace
rm(list=ls())

# Downloading the dataset from the web and unzipping in a created directory
download.file("http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", destfile="couseproject.zip", mode="wb")
unzip("couseproject.zip", exdir="Dataset")

# Reading the downloaded tables y combining them in new tables (deleting old tables that won't be used anymore)
TrainingX <- read.csv("Dataset/UCI HAR Dataset/train/X_train.txt", sep="", header=FALSE)
TestingX <-  read.csv("Dataset/UCI HAR Dataset/test/X_test.txt", sep="", header=FALSE)
TrainingY<-read.table("Dataset/UCI HAR Dataset/train/y_train.txt",header=FALSE)
TestingY<-read.table("Dataset/UCI HAR Dataset/test/y_test.txt",header=FALSE)
TrainingS<-read.table("Dataset/UCI HAR Dataset/train/subject_train.txt",header=FALSE)
TestingS<-read.table("Dataset/UCI HAR Dataset/test/subject_test.txt",header=FALSE)

testing<-cbind(TestingX, TestingY, TestingS)
training<-cbind(TrainingX, TrainingY, TrainingS)
rm(list=c("TrainingX","TestingX","TrainingY","TestingY","TrainingS","TestingS"))

# Reading variable names y activity labels from downloaded txt files
features<-read.table("Dataset/UCI HAR Dataset/features.txt",header=FALSE)
features<-as.character(features[,2])
features<-as.character(c(features,"Y","S"))

activityLabels<-read.table("Dataset/UCI HAR Dataset/activity_labels.txt",header=FALSE)

# Creating a big data set with all the data and naming the columns

dataset<-rbind(training, testing)
names(dataset)<-features

# Selecting the desired variables and creating a new dataset only with the selected variables
selected_features <- grepl("mean|std", features)

clean_dataset<-dataset[,selected_features]
clean_dataset<-cbind(clean_dataset,dataset[,562], dataset[,563])
colnames<-names(clean_dataset)
colnames[80]<-"Y"
colnames[81]<-"Subject"

# Changing variable names for more suitable names

colnames = gsub('-mean', 'Mean', colnames)
colnames = gsub('-std', 'Std', colnames)
colnames = gsub('[-()]', '', colnames)

activities<-activityLabels[,2]

clean_dataset[,82] = activities[clean_dataset[,80]]
colnames[82]<-"Activity"
colnames(clean_dataset)<-colnames


# Calculating the mean of each subset of the data
if (!require("data.table")) {
        install.packages("data.table")
}
require(data.table)
tabla <- data.table(clean_dataset)
tabla_final = aggregate(tabla, by=list(activity = tabla$Activity, subject=tabla$Subject), mean)

# Writing a txt file with the tidy data
write.table(tabla_final, file = "tidy_table.txt", sep=";", row.name=FALSE)

# Cleaning the workspace, only keeping the tidy table
rm(list=setdiff(ls(), "tabla_final"))
