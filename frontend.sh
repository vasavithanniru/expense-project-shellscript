#!/bin/bash

LOG_FOLDER=/var/log/expense
mkdir -p $LOG_FOLDER
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIME_STAMP=$(date +%F-%H-%M-%S)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME-$TIME_STAMP.log"

USERID=$(id -u)

if [ $USERID -ne 0 ]
then    
    echo "Run with root prevellege" | tee -a $LOG_FILE
    exit 1
fi

VALIDATE(){
if [ $1 -ne 0 ]
then
    echo "$2 is...FAILED..Check it"  | tee -a $LOG_FILE
    exit 1
else
    echo "$2 is...SUCCESS" | tee -a $LOG_FILE
fi  
}

echo "Script started executing at $(date)"

dnf install nginx -y  &>>$LOG_FILE
VALIDATE $? "Nginx installation"

systemctl enable nginx    &>>$LOG_FILE
VALIDATE $? "Enabling nginx"     

systemctl start nginx    &>>$LOG_FILE
VALIDATE $? "Starting nginx"

rm -rf /usr/share/nginx/html/*  &>>$LOG_FILE
VALIDATE $? "Removing default content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip  &>>$LOG_FILE
VALIDATE $? "Downloading frontend code"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip  &>>$LOG_FILE
VALIDATE $? "Unzipping frontend code"

cp /home/ec2-user/expense-project-shellscript/expense.conf /etc/nginx/default.d/expense.conf  &>>$LOG_FILE
VALIDATE $? "Copying frontend code" 

systemctl restart nginx  &>>$LOG_FILE
VALIDATE $? "Restarting Nginx"


