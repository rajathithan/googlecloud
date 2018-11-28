# Google Cloud Quick Scripts

```
Scripts related to google cloud
```

## Inventoy collection through cloud shell script

### Iterate through projects and run an extraction script

```
#!/bin/bash
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

```

### Get all the networks, subnetworks , cidr ranges and gateway ip address from a google project

```
#!/bin/bash
netw=( $(gcloud compute networks list| tail -n +2 | awk '{print $1}') )
for i in "${netw[@]}"
do
	echo "======================================================================"
	echo ""
	echo "Network: $i"
	echo "-------"
	echo ""
	tempsub=( $(gcloud compute networks describe $i | head -n -2 | grep -A10 -m1 -e "subnetworks:" | grep -v "subnetworks:" ) )
	for s in "${tempsub[@]}"
	do
		if [ $s != '-' ];
		then
		strl=($(echo $s | tr '/' "\n"))
		sub=${strl[$(expr ${#strl[@]} - 1)]}
		reg=${strl[$(expr ${#strl[@]} - 3)]}
		echo "Subnetwork: $sub"
		echo "Region: $reg"
		echo $(gcloud compute networks subnets describe $sub --region $reg | grep 'Range\|gatewayAddress')
		echo "*************"
		echo ""
		fi
	done
done

```




