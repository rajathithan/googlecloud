# Google Cloud Quick Scripts

```
Shell scripts , python scripts and gcloud commands to administer the google cloud environment.
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



### Extracting the GCP firewall rules to a CSV file

```
gcloud compute firewall-rules list --format="table[box](
          name,
          network,
          direction,
          priority,
          sourceRanges.list():label=SRC_RANGES,
          destinationRanges.list():label=DEST_RANGES,
          allowed[].map().firewall_rule().list():label=ALLOW,
          denied[].map().firewall_rule().list():label=DENY,
          sourceTags.list():label=SRC_TAGS,
          sourceServiceAccounts.list():label=SRC_SVC_ACCT,
          targetTags.list():label=TARGET_TAGS,
          targetServiceAccounts.list():label=TARGET_SVC_ACCT,
          disabled
      )" | sed 's/[|]/,/g' | sed 's/[+]//g' | sed 's/[---]//g' |perl -pe 's/\d\K[,]/  /g' | perl -pe 's/\w\K[,]/  /g' > firewalls.csv
```

### Extracting the GCP routes to a CSV file

```
gcloud compute routes list | grep -v default-route | awk {'print $1,",",$2,",",$3,",",$4,",",$5'} > routes.csv
```

