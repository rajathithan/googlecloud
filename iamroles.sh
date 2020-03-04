#!/bin/bash
# Script to export IAM roles and users to a csv file
# Rajathithan Rajasekar - 03/03/2020
prjs=( $(gcloud projects list | tail -n +2 | awk {'print $1'}) )
for i in "${prjs[@]}"
	do
		echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
		echo "Collecting IAM roles & users for Project: $i"
		echo $(gcloud projects get-iam-policy $i --format="table(bindings)[0]" | sed -e 's/^\w*\ *//'|tail -c +2 |python reformat.py $i >> iamlist.csv)			
done

