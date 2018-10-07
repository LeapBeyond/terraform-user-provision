#!/usr/bin/env bash

if [ $# -lt 1 ]
then
    echo "$0 Usage: $0 bucket"
    exit 1
fi

BUCKET=$1

echo "******** Update host ********"
yum update -y -q

echo "******** create users ********"
groupadd -f users

for USER in $(aws s3 ls s3://$BUCKET/users/ | sed 's/^ *PRE //' | sed 's/\///')
do
    if [ $(grep -c -e "^$USER:" /etc/passwd) -eq 0 ]
    then
        echo "--> adding $USER"

        # create user and force them to choose a password on login

        useradd --shell /bin/bash -G users $USER
        passwd -d $USER
        chage -d 0 $USER

        # install their public key

        mkdir -p /home/$user/.ssh
        aws s3 cp s3://$BUCKET/users/$USER/$USER.pub /home/$USER/.ssh/authorized_keys

        # clean up the user home directory

        chmod 700 /home/$USER/.ssh
        chmod 600 /home/$USER/.ssh/*
        chown -R $USER:$USER /home/$USER/.ssh
    else
        echo "$USER already exists"
    fi
done
