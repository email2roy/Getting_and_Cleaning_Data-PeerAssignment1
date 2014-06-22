# file locations
test.data.path="test/X_test.txt"
test.activity.path="test/y_test.txt"
test.subject.path="test/subject_test.txt"
train.data.path="train/X_train.txt"
train.activity.path="train/y_train.txt"
train.subject.path="train/subject_train.txt"
activity.label.path="activity_labels.txt"

# Filter all measurments with mean or std only
is.mean.or.std <- function(column){
        if (grepl(".*mean\\(\\)|.*std\\(\\)",column)){
                return ("numeric")
        }else{
                return("NULL")
        }
}

# This function will read data of the fpath and only features required
# (to save memory)
# assume 
read.only.required <- function(datapath, activitypath, subjectpath, features, activitymap){
        
        # Load Data
        data <- read.table(datapath, header=F, colClasses=features$required, col.names=features$Name)
        
        # Add Subject column
        data.subject <- read.table(subjectpath, header=F, col.names=c("SubjectID"))
        data$SubjectID <- data.subject$SubjectID
        
        # Add Activity column
        data.activity <- read.table(activitypath, header=F, col.names=c("ActivityID"))
        data$ActivityID <- data.activity$ActivityID
        
        # Using merge to get activity ID -> activity Name
        merged.data <- merge(data,activity.map, all=TRUE)
        
        # Return the final data set
        merged.data
}

# Prepare the features mapping, only get those means and stds
features <- read.table("features.txt", header=F, as.is=T, col.names=c("ID", "Name"))
features$required <- sapply(features$Name, FUN=is.mean.or.std)

# Prepare the activity mapping
activity.map <- read.table(activity.label.path, header=F, col.names=c("ActivityID", "Activity"))
activity.map$Activity <- as.factor(activity.map$Activity)

# get decorated test data
test.data <- read.only.required(test.data.path, 
                                test.activity.path,
                                test.subject.path,
                                features,
                                activity.map)


# get decorated train data
train.data <- read.only.required(train.data.path, 
                                 train.activity.path,
                                 train.subject.path,
                                 features,
                                 activity.map)
        
# Append test data/train data
merged.data <- rbind(test.data, train.data)

# Calculate average of each variable for each activity and each subject. 
library(data.table)
my.data.table <- data.table(merged.data)
my.mean.data <- my.data.table[, lapply(.SD, mean), by=c("SubjectID", "Activity")]
my.mean.data <- my.mean.data[order(my.mean.data$SubjectID),]
write.table(my.mean.data, "tidy.data.mean.txt", sep="\t")

