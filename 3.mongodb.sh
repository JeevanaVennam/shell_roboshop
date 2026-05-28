#!/bin/bash
user_id=$(id -u)
r="\e[31m"
g="\e[32m"
y="\e[33m"
n="\e[0m"
log_folder="/var/log/mongodb.log"
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
cp /$script_dir/mongo.repo /etc/yum/yum.repos.d/mongo.repo &>>$script_file
validate $? "copying mongo repo file"
dnf install mongodb-org -y &>>$script_file
validate $? "installing mongodb"
systemctl enable mongod &>>$script_file
validate $? "enabling mongodb service"
systemctl start mongod &>>$script_file
validate $? "starting mongodb service"
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>$script_file
validate $? "allowing remote connection to mongodb"
systemctl restart mongod &>>$script_file
validate $? "restarting mongodb service"