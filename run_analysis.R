#1. Merges the training and the test sets to create one data set.
#get the working directory
path<-getwd()

#read the test data set
f<-paste(path,"/test/X_test.txt",sep="")
testData<-read.table(f)
f<-paste(path,"/test/Y_test.txt",sep="")
testLabel<-read.table(f)
f<-paste(path,"/test/subject_test.txt",sep="")
testSubject<-read.table(f)
nrow(testSubject);nrow(testLabel);nrow(testData)

#read the training data set
f<-paste(path,"/train/X_train.txt",sep="")
trainData<-read.table(f)
f<-paste(path,"/train/Y_train.txt",sep="")
trainLabel<-read.table(f)
f<-paste(path,"/train/subject_train.txt",sep="")
trainSubject<-read.table(f)
nrow(trainSubject);nrow(trainLabel);nrow(trainData)

# join the data, label and subject data sets by rows
joinData<-rbind(trainData,testData)
joinLabel<-rbind(trainLabel,testLabel)
joinSubject<-rbind(trainSubject,testSubject)
dim(joinData);dim(joinLabel);dim(joinSubject)

# 2.Extracts only the measurements on the mean and standard deviation for each measurement. 
f<-paste(path,"/features.txt",sep="")
features<-read.table(f)
meanStdIndices <- grep("mean\\(\\)|std\\(\\)", features[, 2])
length(meanStdIndices)
joinData<-joinData[,meanStdIndices]
dim(joinData)
#modify the column names of JoinData
names(joinData) <- gsub("\\(\\)", "", features[meanStdIndices, 2]) # remove "()"
names(joinData) <- gsub("-", "", names(joinData)) # remove "-" in column names 

#3. Uses descriptive activity names to name the activities in the data set
f<-paste(path,"/activity_labels.txt",sep="")
activityLabels<-read.table(f)
activityLabels[,2]<-gsub("_","",activityLabels[,2]) # remove "_" in 2nd column for all rows
joinLabel[,1]<-activityLabels[joinLabel[, 1], 2]
names(joinLabel) <- "activity"

#4. Appropriately labels the data set with descriptive variable names. 
names(joinSubject)<-"subject"
tidyData<-cbind(joinSubject,joinLabel,joinData) # tidy data set
dim(tidyData)
names(tidyData)
write.table(tidyData,"merged_data.txt", sep="\t") # store the tidy dataset in merged_data.txt file

#5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
library(plyr)
library(reshape)
tidyMeanData<-ddply(melt(tidyData, id.vars=c("subject", "activity")), .(subject, activity), summarise, MeanSamples=mean(value))
names(tidyMeanData) #"subject"     "activity"    "MeanSamples"
nrow(tidyMeanData) # 180
write.table(tidyMeanData,"tidyMeanData.txt", sep="\t") # write to a file