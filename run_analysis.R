#Charge the necessary packages
library(data.table)
library(dplyr)
#-----------------------------------------------------------------
# 1. Download an charge the necessary files
#-----------------------------------------------------------------

#Verification and creation of the data directory.
if(!file.exists("./data")){
    dir.create("./data")
}else{
    print("Existing directory")
}

#File url is created
url<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

#Destination path is created
path<-"./data/project_data.zip"

#Download the necessary files
download.file(url, destfile = path)

#Unzip the project data folder
unzip(path, exdir = "./data")

#Reading the test data
x_test<-read.table("./data/UCI HAR Dataset/test/X_test.txt")
y_test<-read.table("./data/UCI HAR Dataset/test/y_test.txt")
subject_test<-read.table("./data/UCI HAR Dataset/test/subject_test.txt")

#Reading the train data
x_train<-read.table("./data/UCI HAR Dataset/train/X_train.txt")
y_train<-read.table("./data/UCI HAR Dataset/train/y_train.txt")
subject_train<-read.table("./data/UCI HAR Dataset/train/subject_train.txt")

#Reading the features
features<-read.table("./data/UCI HAR Dataset/features.txt")

#Reading the activity labels
activity_labels<-read.table("./data/UCI HAR Dataset/activity_labels.txt")


#----------------------------------------------------------------------
# 2. Naming dataset columns
#    Appropriately labels the data set with descriptive variable names
#----------------------------------------------------------------------

#Extract the column names
column_names<-features[, 2]

#Assign the colnames to x_test and x_train
names(x_train)<-column_names
names(x_test)<-column_names

#Assign the colnames to y_test and y_train
names(y_train)<-"activityCode"
names(y_test)<-"activityCode"

#Assing th column names to subject_test and subject_train
names(subject_test)<-"subjectId"
names(subject_train)<-"subjectId"

#Assign the column names to activity labels
names(activity_labels)<-c("activityCode","activity")


#-----------------------------------------------------------------
# 3. Merging the data sets
#-----------------------------------------------------------------

#Merging test sets
test<-cbind(subject_test, x_test, y_test)

#Merging train sets
train<-cbind(subject_train, x_train, y_train)

#Merging train and test
full_df<-rbind(test,train)


#-----------------------------------------------------------------
# 4. Extracts the measurements on the mean and standard deviation
#-----------------------------------------------------------------

#extract the column names containing "mean" and "std"
required_names<-grep("[Mm]ean.*|[Ss]td.*",names(full_df), value = TRUE)

#Filter the data frame with the required columns
df_filtred<-full_df[, c("subjectId","activityCode",required_names)]

#----------------------------------------------------------------------
# 5. Descriptive activity names to name the activities in the data set
#----------------------------------------------------------------------
tidy_df<-merge(df_filtred,activity_labels,by = "activityCode")


#--------------------------------------------------------------------------
# 6. Create and save the final tidy data set with the means of each variable
#--------------------------------------------------------------------------

#Create the final data set with the means
final_df<-tidy_df%>%group_by(subjectId, activity)%>%summarise_all(funs(mean))
final_df<-arrange(final_df, subjectId, activityCode)

#Save the data set
write.table(final_df, "tidyDataSet.txt", row.names = F)
