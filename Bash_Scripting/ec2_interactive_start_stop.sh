#!/bin/bash
echo "Welocome to the AWS interactive EC2 start/stop shell"
echo "-----------------------------------------------------"
echo "Do you want to start or stop EC2 instance(s)?"
echo "-------OPTIONS-------"
echo "1. Press 1 to start"
echo "2. Press 2 to stop"
echo "---------------------"
read instance_action
if [ $instance_action -eq 1 ]; then
    echo "You selected instance start action"
    action="start-instances"
elif [ $instance_action -eq 2 ]; then
    echo "You selected instance stop action"
    action="stop-instances"
else
    echo "Oophs!!! Please enter the valid option"
    exit
fi
#echo $action
#echo "Do you wanted to start or stop EC2 instance using IP or Instance ID?"
#echo "=======OPTIONS======="
#echo "1. Press 1 to start/stop EC2 instance using the EC2 Instance ID(s)"
#echo "2. Press 2 to start/stop EC2 instance using EC2 private IP address(es)"
#echo "====================="
#read instance_action_type
#if [ $instance_action_type -eq 1 ]; then
#    echo "You selected start/stop EC2 instance using the EC2 Instance ID(s)"
#    ins_type="ID(s)"
#elif [ $instance_action_type -eq 2 ]; then
#    echo "You selected start/stop EC2 instance using the EC2 private IP address(es)"
#    ins_type="private IP address(es)"
#else
#    echo "Oophs!!! Please enter the valid option"
#fi
read -a instance_parm -p "Enter the EC2 instance ID(s) or Private IP address(es):"
instance_state_change(){
    #echo $action $1
    aws ec2 $action --instance-ids $1 --output table
    echo "----------------------------------------------------------------------------------------"
}
for element in "${instance_parm[@]}"; do
    #echo "Element ${element}"
    if [[ ${element} =~ ^i-[A-Za-z0-9]* ]]; then
        instance_state_change ${element}
    else
        if [[ ${element} =~ ^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$ ]]; then
            instance_id=$(aws ec2 describe-instances --filter Name=private-ip-address,Values=${element} | grep 'InstanceId' | awk -F'"' '{print $4}')
            if [[ -z ${instance_id} ]]; then
                echo "Entered IP address ${element} is not found in AWS"
            else
                echo "Entered IP address ${element} is found on AWS, starting the instance"
                instance_state_change $instance_id
            fi
        else
            echo "Entered IP address ${element} is invalid!!!"
        fi
    fi
done