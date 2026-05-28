#!/bin/bash
user_id=$(id -u)
r="\e[31m"
g="\e[32m"
y="\e[33m"
n="\e[0m"
log_folder="/var/log/user_log"
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
        echo -e "$g you are in root access $n"
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
    echo -e "$y roboshop user already exists $n"
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
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$script_file
validate $? "downloading user content"
cd /app &>>$script_file
validate $? "changing directory to application directory"
unzip /tmp/catalogue.zip &>>$script_file
validate $? "unzipping user content"
npm install &>>$script_file
validate $? "installing nodejs dependencies"
cp /$script_dir/user.service /etc/systemd/system/user.service &>>$script_file
validate $? "copying user systemd service file"
systemctl daemon-reload &>>$script_file
validate $? "reloading systemd daemon"
systemctl enable user &>>$script_file
validate $? "enabling user service"
systemctl start user &>>$script_file
validate $? "starting user service"