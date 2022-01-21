#!/bin/bash
# Created by Marcio Gustavo Chahad 
# GET INSTANCES PUBLIC IP
nmap (){
    # Collecting Public IPs from instances EC2
    aws ec2 describe-instances --query "Reservations[*].Instances[*].PublicIpAddress" --output=text >> reports/public_ip_"$PROFILE".txt

    # Running Nmap Scan on the Public IPs
    for IP in `cat reports/public_ip_"$PROFILE".txt`; do 
    sudo nmap -sV "$IP" -Pn --open -oX reports/"$PROFILE"-"$IP".xml; done

    # Creating file with Public IP with open ports
    egrep "hostname name|portid" reports/"$PROFILE"-*.xml | awk '{print $2,$3}' | sed 's/"//g' | cut -d ">" -f1 | sed 's/ /,/g' | sed 's/,type=PTR\///g' >> reports/"$PROFILE"-final-report.txt
}

# Deleting Report Files
rm -rf reports/*

# Running nmap function
while true; do
    for PROFILE in `cat profiles.txt`; do
        export AWS_PROFILE="$PROFILE"
        nmap;
    done
    exit 0
done