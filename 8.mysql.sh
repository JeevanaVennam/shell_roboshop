#!/bin/bash
user_id=$(id -u)
r="\e[31m"
g="\e[32m"
y="\e[33m"
n="\e[0m"
log_folder="/var/log/mysql_log"
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
echo "Please enter mysql root password"
read -s mysql_root_password
dnf install mysql-server -y $>>$script_file
validate $? "installing mysql server"

systemctl enable mysqld &>>$script_file
validate $? "enabling mysql service"

systemctl start mysqld &>>$script_file
validate $? "starting mysql service"

mysql_secure_installation --set-root-pass $mysql_root_password &>>$script_file
validate $? "setting mysql root password"

end_time=$(date +%s)
total_time=$(($end_time - $start_time))
echo -e "$g Script execution completed successfully, $y time taken: $total_time seconds $n" | tee -a $script_file