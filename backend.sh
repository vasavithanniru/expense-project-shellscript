#!/bin/bash

LOG_FOLDER=/var/log/expense
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIME_STAMP=$(date +%F-%H-%M-%S)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME-$TIME_STAMP.log"
mkdir -p $LOG_FOLDER

USERID=$(id -u)
if [ $USERID -ne 0 ]
then
    echo "Run with root prevellege"  | tee -a $LOG_FILE
    exit 1
fi

VALIDATE(){
if [ $1 -ne 0 ]
then
    echo "$2 is...FAILED"  | tee -a $LOG_FILE
    exit 1
else
    echo "$2 is...SUCCESS" | tee -a $LOG_FILE
fi 
}

echo "Script started executing at $(date)" | tee -a $LOG_FILE

dnf module disable nodejs -y  &>>$LOG_FILE
VALIDATE $? "Disabling Nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling Nodejs 20"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing Nodejs"

id expense #to check expense user is exists or not

if [ $? -ne 0 ]
then 
    echo "Expense user is not exists..Creating user"
    useradd expense
else 
    echo "Expense user is already exists..SKIPPING" 
fi 

mkdir -p /app     &>>$LOG_FILE
VALIDATE $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE
VALIDATE $? "Downloding the backend code"

cd /app           &>>$LOG_FILE
rm -rf /app/*     &>>$LOG_FILE
unzip /tmp/backend.zip  &>>$LOG_FILE
VALIDATE $? "unzipping the backend code"

npm install     &>>$LOG_FILE
VALIDATE $? "Installing depensencies"

cp /home/ec2-user/expense-project-shellscript/backend.service /etc/systemd/system/backend.service &>>$LOG_FILE
VALIDATE $? "Copying backend.service"

#Load schema before running backend
dnf install mysql -y  &>>$LOG_FILE
VALIDATE $? "Installing MySQL"

mysql -h mysql.vasavi.online -uroot -pExpenseApp@1 < /app/schema/backend.sql  &>>$LOG_FILE
VALIDATE $? "Loading Schema"

systemctl daemon-reload  &>>$LOG_FILE
VALIDATE $? "Daemon reload"  

systemctl enable backend
VALIDATE $? "Enabling backend"

systemctl restart backend   &>>$LOG_FILE
VALIDATE $? "Restarting backend" 






       

