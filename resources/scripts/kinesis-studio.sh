#!/bin/bash

# Params
ACTION=$1
NAME=$2
FILE=$3

# Functions
f_status () {
    STATUS=$(aws kinesisanalyticsv2 describe-application --application-name ${NAME} 2> /dev/null | jq -r '.ApplicationDetail.ApplicationStatus')
}

f_wait () {
    while [ ${STATUS} != $1 ]; do
        sleep 10
        f_status
    done
}

f_create() {
    sleep 10

    # Create KDA if doesn't exit
    f_status
    if [ -z ${STATUS} ]; then 
        aws kinesisanalyticsv2 create-application --cli-input-json file://${FILE}
    fi

    # Start KDA if READY
    f_status
    if [ ${STATUS} == 'READY' ]; then 
        aws kinesisanalyticsv2 start-application --application-name ${NAME}
        f_status
        f_wait RUNNING
    fi
}

f_delete() {
    f_status
    if [ ! -z ${STATUS} ]; then 

        # Stop KDA
        if [ ${STATUS} == 'RUNNING' ]; then
            aws kinesisanalyticsv2 stop-application --application-name ${NAME}
            f_wait READY
        fi

        # Delete KDA and associated ENIs
        f_status
        if [ ${STATUS} == 'READY' ]; then 
            aws kinesisanalyticsv2 describe-application --application-name ${NAME} | jq '.ApplicationDetail.CreateTimestamp' | xargs -n1 -I {} aws kinesisanalyticsv2 delete-application --application-name ${NAME} --create-timestamp {}
            aws ec2 describe-network-interfaces --filters 'Name=description,Values=*'${NAME}'*' | jq -r '.NetworkInterfaces[].NetworkInterfaceId' | xargs -n1 -I {} aws ec2 delete-network-interface --network-interface-id {}
        fi
    fi
}

# Start
if [ ${ACTION} == 'create' ]; then
    f_delete
    f_create
elif [ ${ACTION} == 'delete' ]; then
    f_delete
fi