#!/bin/bash
user_id=$(id -u)
r="\e[31m"
g="\e[32m"
y="\e[33m"    
n="\e[0m"
log_folder="/var/log/cart_log"
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
checkroot
id roboshop &>>$script_file
if [ $? -ne 0 ]
then 
echo -e "$y creating roboshop user $n"
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$script_file
validate $? "creating roboshop user"
else
echo -e "$y roboshop user already exists $n"
fi
dnf module disable nodejs -y &>>$script_file
validate $? "diabling nodejs"
dnf module enable nodejs:20 -y &>>$script_file
validate $? "enabling nodejs 20"
dnf install nodejs -y &>>$script_file
validate $? "installing nodejs"
mkdir -p /app &>>$script_file
validate $? "creating application directory"
curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$script_file
validate $? "downloading cart content"
cd /app &>>$script_file
validate $? "changing directory to application directory"
rm -rf /app/* &>>$script_file
validate $? "clearing application directory"
unzip /tmp/cart.zip &>>$script_file
validate $? "unzippping cart content"
npm install &>>$script_file
validate $? " installing nodejs dependencies"
cp /$script_dir/cart.service /etc/systemd/system/cart.service &>>$script_file
validate $? "copying cart service file"
systemctl daemon-reload &>>$script_file
validate $? "reloading systemd daemon"
systemctl enable cart &>>$script_file
validate $? "enabling cart service"
systemctl start cart &>>$script_file
validate $? "starting cart service"

