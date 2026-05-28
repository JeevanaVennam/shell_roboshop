#!/bin/bash
r="\e[31m"
g="\e[32m"
y="\e[33m"
n="\e[0m"
user_id=$(id -u)
log_folder="/var/log/fornt_log"
script_name=$(echo $0 | cut -d "." -f1)
script_file="$log_folder/$script_name.log"
script_dir=$(pwd)
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
        echo -e "$r $1 failed $n"s
        exit 1
    else
        echo "$g $1 is succesful $n"
    fi

}
checkroot
dnf module disable nginx -y &>>$script_file
validate $? "disabling nginx"
dnf module enable nginx:1.24 -y &>>$script_file
validate $? "enabling nginx 1.24"
dnf install nginx -y &>>$script_file
validate $? "installing nginx"
systemctl enable nginx &>>$script_file
validate $? "enabling nginx service"
systemctl start nginx &>>$script_file
validate $? "starting nginx service"
rm -rf /usr/share/nginx/html/* &>>$script_file
validate $? "removing default nginx content"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$script_file
validate $? "downloading frontend content"
cd /usr/share/nginx/html &>>$script_file
validate $? "changing directory to nginx html"
unzip /tmp/frontend.zip &>>$script_file
validate $? "unzipping frontend content"
cp /$script_dir/nginx.conf /etc/nginx/nginx.conf &>>$script_file
validate $? "copying nginx configuration file"
systemctl restart nginx &>>$script_file
validate $? "restarting nginx service" 
echo -e "$g Frontend setup completed and script execution is successful $n"