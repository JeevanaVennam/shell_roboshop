#!/bin/bash
r="\e[31m"
g="\e[32m"
y="\e[33m"
n="\e[0m"
user_id=$(id -u)
log_folder="/var/log/redis.log"
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
dnf module disable redis -y &>>$script_file
validate $? "disabling redis"
dnf module enable redis:7 -y &>>$script_file
validate $? "enabling redis 7"
dnf install redis -y &>>$script_file
validate $? "installing redis"
systemctl enable redis &>>$script_file
validate $? "enabling redis service"
systemctl start redis &>>$script_file
validate $? "starting redis service"
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf
validate $? "allowing remote connection to redis"
systemctl restart redis &>>$script_file
validate $? "restarting redis service"
