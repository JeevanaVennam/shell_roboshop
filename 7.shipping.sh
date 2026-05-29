#!/bin/bash
user_id=$(id -u)
r="\e[31m"
g="\e[32m"
y="\e[33m"
n="\e[0m"
log_folder="/var/log/shipping_log"
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
dnf install maven -y &>>$script_file
validate $? "installing maven"
mkdir -p /app &>>$script_file
validate $? "creating application directory"
curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$script_file
validate $? "downloading shipping content"
cd /app &>>$script_file
validate $? "changing directory to application directory"
rm -rf /app/* &>>$script_file
validate $? "clearing application directory"
unzip /tmp/shipping.zip &>>$script_file
validate $? "unzipping shipping content"
mv clean package &>>$script_file
validate $? "packaging the application"
mv target/shipping-1.0.jar shipping.jar &>>$script_file
validate $? "moving jar file"
cp /$script_dir/shipping.service /etc/systemd/system/shipping.service &>>$
validate $? "copying shipping service file"
systemctl daemon-reload &>>$script_file
validate $? "relaoding systemd daemon files"
systemctl enable shipping &>>$script_file
validate $? "enabling shipping service"
systemctl start shipping &>>$script_file
validate $? "starting shipping service"
echo -e "$g Shipping setup completed and script execution is successful $n"
   