#!/bin/bash
r="\e[31m"
g="\e[32m"
y="\e[33m"
n="\e[0m"
user_id=$(id -u)
log_folder="/var/log/catalogue_log"
script_name=$(echo $0 | cut -d "." -f1)
script_file="$log_folder/$script_name.log"
script_dir=$(pwd)
mkdir -p $log_folder
checkroot(){
    if [ $user_id -ne 0 ]
    then 
        echo -e "$r Please run with sudo access $n"
        exit 1
    else
        echo -e "$g You are in root access $n"
    fi
}
validate(){
    if [ $? -ne 0 ]
    then
        echo -e "$r $2 failed $n"
        exit 1
    else
        echo -e "$g $2 is successful $n"
    fi

}
id roboshop &>>$script_file
if [ $? -ne 0 ]
then
    echo -e "$y creating roboshop user $n"
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$script_file
    validate $? "creating roboshop user"
else
    echo -r "$g roboshop user already exixts $n"
fi
checkroot
dnf module disable nodejs -y &>>$script_file
validate $? "disabling nodejs"
dnf module enable nodejs:20 -y &>>$script_file
validate $? "enabling nodejs 20"
dnf install nodejs -y &>>$script_file
validate $? "installing nodejs"

mkdir -p /app &>>$script_file
validate $? "creating application directory"
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$script_file
validate $? "downloading catalogue content"
cd /app &>>$script_file
validate $? "changing directory to application directory"
unzip /tmp/catalogue.zip &>>$script_file
validate $? "unzipping catalogue content"
npm install &>>$script_file
validate $? "installing nodejs dependencies"
cp /$script_dir/catalogue.service /etc/systemd/system/catalogue.service &>>$script_file
validate $? "copying catalogue systemd service file"
systemctl daemon-reload &>>$script_file
validate $? "reloading systemd daemon"
systemctl enable catalogue &>>$script_file
validate $? "enabling catalogue services"
systemctl start catalogue &>>$script_file
validate $? "starting catalogue service"
cp /$script_dir/mongo.repo /etc/yum.repos.d/mongo.repo &>>$script_file
validate $? "copying mongo repo file"
dnf install mongodb-mongosh -y &>>$script_file
validate $? "installing mongodb client"
status=$(mongosh --host mongodb.jeev.shop --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $status -lt 0]
then
    echo -e "$y Importing catalogue schema to mongodb $n"
    mongosh --host mongodb.jeev.shop < /app/db/master-data.js &>>$script_file
    validate $? "loading catalogue schema to mongodb"
else
    echo -e "$g catalogue schema is already present in mongodb $n"
fi