#!/bin/bash

LOG_FOLDER=/var/log/expense
mkdir -p $LOG_FOLDER
SCRIPT_NAME=(echo $0 | cut -d "." -f1)
TIME_STAMP=$(date +%F-%H-%M-%S)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME-$TIME_STAMP.log"

USERID=$(id -u)

if [ $USERID -ne 0 ]
then    
    echo "Run with root prevellege"
    exit 1
fi

VALIDATE(){
if [ $1 -ne 0 ]
then
    echo "$2 is...FAILED..Check it"
    exit 1
else
    echo "$2 is...SUCCESS"
fi  
}

dnf install nginx -y
VALIDATE $? "Nginx installation"

systemctl enable nginx -y
VALIDATE $? "Enabling nginx"     

systemctl start nginx -y
VALIDATE $? "Starting nginx"

rm -rf /usr/share/nginx/html/*
VALIDATE $? "Removing default content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
VALIDATE $? "Downloading frontend code"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip
VALIDATE $? "Unzipping frontend code"




