#!/bin/bash

# Params
ACTION=$1
NAME=$2
FILE=$3

# Functions
f_status () {
    STATUS=$(aws firehose describe-delivery-stream --delivery-stream-name ${NAME} 2> /dev/null | jq -r '.DeliveryStreamDescription.DeliveryStreamStatus')
}

f_wait () {
    while [ ${STATUS} != $1 ]; do
        sleep 10
        f_status
    done
}

f_create() {
    sleep 10

    # Create KDS if doesn't exit
    f_status
    if [ -z ${STATUS} ]; then 
        aws firehose create-delivery-stream --cli-input-json file://${FILE}
        f_status
        f_wait ACTIVE
    fi
}

f_delete() {
    f_status
    if [ ! -z ${STATUS} ]; then

        if [ ${STATUS} == 'ACTIVE' ]; then
            aws firehose delete-delivery-stream --delivery-stream-name ${NAME}
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