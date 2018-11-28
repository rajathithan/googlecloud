#!/bin/bash
#Shell script to iterate through google projects
#Author - Rajathithan Rajasekar

if [ -z "$1" ]
then
echo "No Arguments Supplied !! , exiting, provide the program name to run"
else
	prjs=( $(gcloud projects list | tail -n +2 | awk {'print $1'}) )
	for i in "${prjs[@]}"
		do
			echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
			echo "Setting Project: $i"
			echo $(gcloud config set project $i)
			source $1	
		done
fi