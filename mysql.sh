#!/bin/bash

LOGS_FOLDER=/var/log/expense
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIME_STAMP=$(date +%F-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIME_STAMP.log"
mkdir -p /var/log/expense

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USERID=$(id -u)

if [ $USERID -ne 0 ]
then
    echo "Run the script with root prevellege" | tee -a $LOG_FILE
    exit 1
fi  

VALIDATE(){
    if [ $1 -ne 0 ]
    then    
        echo "$2 is....FAILED" | tee -a $LOG_FILE
    else
        echo "$2 is...SUCCESS"  | tee -a $LOG_FILE
    fi     
}

echo "Script started executing at $(date)" | tee -a $LOG_FILE

dnf install mysql-server -y
VALIDATE $? "MySQL server installation"  | tee -a $LOG_FILE

systemctl enable mysqld
VALIDATE $? "enabled MySQL server" | tee -a $LOG_FILE

systemctl start mysqld
VAIDATE $? "Started MySQL server"  | tee -a $LOG_FILE

mysql -h mysql.vasavi.onlin -u root -pExpenseApp@1 -e 'show database;'

if [ $? -ne 0 ]
then    
    echo "MySQL root password is not setup.. Setting up now"  &>> $LOG_FILE
    mysql_secure_installation --set-root-pass ExpenseApp@1
else
    echo "MySQL pasword is already setup...SKIPPING"  | tee -a $LOG_FILE
fi      
