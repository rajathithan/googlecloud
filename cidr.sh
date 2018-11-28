
#!/bin/bash
#Shell script to extract networks, subnetworks, cidr ranges and gateway ip address from a google project
#Author - Rajathithan Rajasekar

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

