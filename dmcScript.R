# Business Analytics
# Data Mining Cup Template

# The caret package is used (http://topepo.github.io/caret/index.html)
install.packages("caret")
library(caret)
install.packages("e1071")
library(e1071)


# For reasons of traceability you must use a fixed seed
set.seed(42) # do NOT CHANGE this seed


######################################################
# 1. Build a Team in the DMC Manager
# https://dmc.dss.in.tum.de/dmc/
# Login with TUM login data ("TUM-Kennung")
#
# Found or join a team (size: 1-4 students)


######################################################
# 2. Load & Explore the Training Data Set
training_data = read.csv("training.csv", sep=",")

# Explore the data set...


######################################################
# 3. Data Preparation
# (using both training and test data)
# do NOT DELETE any instances in the test data
test_data = read.csv("test.csv", sep=",")
test_data

# Prepare the data for training...
names(training_data)

# Replace N/A with mode
#test_data$family_status[is.na(test_data$family_status)] = "married"

# data$edu is ordinal
training_data$edu = ordered(training_data$edu)
test_data$edu = ordered(test_data$edu)

# Interestingly without pay is only once, we remove it
table(test_data$workclass, useNA="always")
table(training_data$workclass, useNA="always")
training_data$workclass = factor(training_data$workclass, labels=c("?","fed","loc","pri","sel","selnot","state","with"))
test_data$workclass = factor(test_data$workclass, labels=c("?","fed","loc","pri","sel","selnot","state"))
id = training_data$id[training_data$workclass == 'with']
training_data = training_data[!(training_data$workclass == 'with'),]
training_data$workclass <- factor(training_data$workclass)

table(training_data$workclass)

# Gender is nominal
training_data$gender = factor(training_data$gender, labels=c("w","m"))
test_data$gender = factor(test_data$gender, labels=c("w","m"))

# Origin is also nominal
training_data$origin = factor(training_data$origin, labels=c("native american","asian","black","other","white"))
test_data$origin = factor(test_data$origin, labels=c("native american","asian","black","other","white"))

table(test_data$origin, useNA="always")
table(training_data$origin, useNA="always")

training_data$origin[(training_data$origin=="native american")] = "other"
training_data$origin[(training_data$origin=="black")] = "other"
test_data$origin[(test_data$origin=="native american")] = "other"
test_data$origin[(test_data$origin=="black")] = "other"

test_data$origin = factor(test_data$origin)
training_data$origin = factor(training_data$origin)
table(test_data$origin)

table(test_data$education, useNA="always")
table(training_data$education, useNA="always")

educationVec <- c("pre-school","pre-school","pre-school","pre-school","pre-school","pre-school","pre-school",
                 "assoc","assoc","uni","uni","grad","uni","uni","uni","uni")

training_data$education = factor(training_data$education, labels=educationVec)
test_data$education = factor(test_data$education, labels=educationVec)

table(training_data$income[training_data$education=="grad"])
      
table(test_data$relationship, useNA="always")
table(training_data$relationship, useNA="always")

######################################################
# 4. Training & Evaluation

# Train a model "model"...

tc <- trainControl("repeatedcv", number=40, repeats=40, classProbs=TRUE, savePred=T) 
InTrain<-createDataPartition(y=training_data$income,p=0.3,list=FALSE)
training1<-training_data[InTrain,]

# Missing family status causes drop from 14 % -> 17%
rf_model<-train(income~age+as.factor(gender)+as.factor(origin)+as.factor(education)+as.ordered(edu)+rating+gain+loss+hours_weekly,data=training_data,method="rf",
                trControl=trainControl(method="cv",number=5),
                prox=TRUE,allowParallel=TRUE)
print(rf_model)
print(rf_model$finalModel)

######################################################
# 5. Predict Classes in Test Data

prediction_classes = predict.train(object=rf_model, newdata=test_data, na.action=na.pass)
predictions = data.frame(id=test_data$id, prediction=prediction_classes)
predictions


######################################################
# 6. Export the Predictions
write.csv(predictions, file="predictions_atum_4.csv", row.names=FALSE)


######################################################
# 7. Upload the Predictions and the Corresponding R Script on DMC Manager
# https://dmc.dss.in.tum.de/dmc/
# Login with TUM login data ("TUM-Kennung")
#
# Maxium number of submissions: 10
#
# Possible errors that could occur:
# - Wrong column names
# - Unknown IDs (if not in Test Data)
# - Missing IDs (if in Test Data but not in Predictions)
# - Wrong file format