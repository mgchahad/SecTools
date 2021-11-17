#!/bin/bash
# Created By Marcio Gustavo Chahad - Version 1.1 - 09/11/2021

# Variables
IAM_ID_FILE=iam_access_keys.txt
CLOUDTRAIL_JSON_FILE=cloudtrail_iam_events.json

# Setting AWS Profile
echo -e "Please, set the AWS profile: "
read PROFILE

export AWS_PROFILE="$PROFILE"

if [ -f "$IAM_ID_FILE" ] ; then
    rm "$IAM_ID_FILE"
fi

# Collecting Access Keys from usernames
for USERNAMES in `aws iam list-users | grep "UserName" | awk '{print $2}' | cut -d "\"" -f2`; do \
    aws iam list-access-keys --user-name "$USERNAMES" | grep "AccessKeyId" | awk '{print $2}' | cut -d "\"" -f2 >> iam_access_keys.txt; done

if [ -f "$CLOUDTRAIL_JSON_FILE" ] ; then
    rm "$CLOUDTRAIL_JSON_FILE"
fi

# Creating Cloudtrail IAM Events Report
for ACCESS_KEY in $(cat iam_access_keys.txt); do \
    aws cloudtrail lookup-events --max-results 10 --lookup-attributes AttributeKey=AccessKeyId,AttributeValue="$ACCESS_KEY" | jq >> cloudtrail_iam_events.json; done

# Applying filter on report
cat cloudtrail_iam_events.json| grep "CloudTrailEvent" | cut -d "{" -f3 | cut -d "\\" -f26,28,22,24,30,32,42,44,46,48 | sed -e 's/\"/ /g' | sed -e 's/\\/ /g' >> filtered_report_"$PROFILE"_$(date +%Y-%m-%d-%H:%M:%S).txt
