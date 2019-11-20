## Load Dplyr lybrary

library(dplyr)


## Set Working Directory

setwd("C:/Users/CHRISTIAN/Desktop/Coursera/Specialization/1/ProjectETL")

## Check if file is already downloaded, else download It

file <- 'getdata_projectfiles_UCI HAR Dataset.zip'
folder<- 'UCI HAR Dataset'

file.exists(file)

if (!file.exists(file)){
      URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
      download.file(URL, file, method="curl")
      if (!file.exists(folder)) {
            unzip(file)
            
      }
} 


## Read files into dataframes


features <- read.table(paste(getwd(),folder,"features.txt",sep="/"), 
                       col.names = c("id","feature"))
activities <- read.table(paste(getwd(),folder,"activity_labels.txt",sep="/"),
                         col.names = c("id", "activity"))


SubjectTest <- read.table(paste(getwd(),folder,"test","subject_test.txt",sep="/"), 
                           col.names = "subject")
DataTest <- read.table(paste(getwd(),folder,"test","X_test.txt",sep="/"))
LabelsTest <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "activity")


SubjectTrain <- read.table(paste(getwd(),folder,"train","subject_train.txt",sep="/"), 
                          col.names = "subject")
DataTrain <- read.table(paste(getwd(),folder,"train","X_train.txt",sep="/"))
LabelsTrain <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "activity")

## Concatenate Features and Ids because some are duplicated

features$concat <- paste(features$id,features$feature,sep="-")

### Set Data column names

colnames(DataTest)<-features$concat
colnames(DataTrain)<-features$concat

## Combine Test, Training and Subject data

Data<- rbind(DataTest,DataTrain)
Labels<-rbind(LabelsTest,LabelsTrain)
Subject<-rbind(SubjectTest,SubjectTrain)

Data<-cbind(Subject,Labels,Data)

## Select Mean and Standar Deviation Columns


Data<-select(Data,subject,activity,matches('(mean\\()|(std\\()'))

## Set appropirate column names

colnames(Data)<-gsub("Acc", "accelerometer", colnames(Data))
colnames(Data)<-gsub("Gyro", "gyroscope", colnames(Data))
colnames(Data)<-gsub("Mag", "magnitude", colnames(Data))
colnames(Data)<-gsub("^t", "time", colnames(Data))
colnames(Data)<-gsub("^f", "frequency", colnames(Data))
colnames(Data)<-gsub("tBody", "TimeBody", colnames(Data))
colnames(Data)<-gsub("-mean()", "Mean", colnames(Data), ignore.case = TRUE)
colnames(Data)<-gsub("-std()", "STD", colnames(Data), ignore.case = TRUE)



## Set activity names

Data<-left_join(Data,activities,c('activity'='id'))
Data$activity<-Data$activity.y
Data<-select(Data,-activity.y)


## Calculate average of each variable for each activity and each subject

Data <- group_by(Data,activity,subject)
Tidy<- summarise_all(Data,funs(mean))

write.table(Tidy,paste(getwd(),"TidyHAR.txt",sep="/"), 
          row.names = FALSE)
