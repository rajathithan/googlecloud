# Google Cloud Quick Scripts

```
Shell scripts , python scripts and gcloud commands to administer the google cloud environment.
```

## Inventory collection through cloud shell script

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
      )" | sed 's/[|]/,/g' | tail -n +4 | head -n -1 | sed 's/.$//; s/^.//' > firewalls.csv
```

### Extracting the GCP routes to a CSV file

```
gcloud compute routes list | grep -v default-route | awk {'print $1,",",$2,",",$3,",",$4,",",$5'} > routes.csv
```


### Extracting all the services in a yaml format from a kubernetes environment
```
kubectl get services --all-namespaces | tail -n +2 | awk '{print $1,$2}'  | xargs -n2 sh -c 'kubectl get service $2 -n $1 -o yaml > service-$1-$2.yaml' sh
```

### Extracting all the deployments in a yaml format from a kubernetes environment
```
kubectl get deployments --all-namespaces | tail -n +2 | awk '{print $1,$2}'  | xargs -n2 sh -c 'kubectl get deployment $2 -n $1 -o yaml > deployment-$1-$2.yaml' sh
```

### Extracting the GCP resource names for inventory collection
```
#!/bin/bash
echo "Inventory List"
echo "================================================"
echo "Service-accounts"
echo "================================================"
gcloud iam service-accounts list 
echo "================================================"
echo "List Instances"
echo "================================================"
gcloud compute instances list | tail -n+2 | awk {'print $1'}
echo "================================================"
echo "Networks and Subnetworks"
echo "================================================"
gcloud compute networks list| tail -n+2 | awk '{print $1}'| xargs -n1 sh -c 'echo $1 & gcloud compute networks describe $1 | head -n -2 | grep -A10 -m1 -e "subnetworks:"' sh 
echo "================================================"
echo "Interconnects"
echo "================================================"
gcloud compute interconnects attachments list| tail -n+2 | awk '{print $1}'
echo "================================================"
echo "Cloud Routers"
echo "================================================"
gcloud compute routers list | tail -n+2 | awk {'print $1'}
echo "================================================"
echo "VPN Gateways"
echo "================================================"
gcloud compute target-vpn-gateways list | tail -n+2 | awk {'print $1'}
echo "================================================"
echo "VPN Tunnels"
echo "================================================"
gcloud compute vpn-tunnels list | tail -n+2 | awk {'print $1'}
echo "================================================"
echo "Firewall Rules"
echo "================================================"
gcloud compute firewall-rules list | tail -n+2 | awk {'print $1'}
echo "================================================"
echo "Routes"
echo "================================================"
gcloud compute routes list | tail -n+2 | awk {'print $1'}
echo "================================================"
echo "Load balancers"
echo "================================================"
gcloud compute url-maps list | tail -n+2 | awk {'print $1'}
echo "================================================"
echo "Forwarding rules "
echo "================================================"
gcloud compute forwarding-rules list | tail -n+2 | awk {'print $1'}
echo "================================================"
echo "Backend services"
echo "================================================"
gcloud compute backend-services list | tail -n+2 | awk {'print $1'}
echo "================================================"
echo "Healthchecks"
echo "================================================"
gcloud compute health-checks list
echo "================================================"
echo "Storage Buckets"
echo "================================================"
gsutil list
echo "================================================"
echo "App Engine"
echo "================================================"
gcloud app services list
echo "================================================"
echo "GKE Clusters"
echo "================================================"
gcloud container clusters list | tail -n+2 | awk {'print $1'}
echo "================================================"
echo "GKE NodePools"
echo "================================================"
gcloud container clusters list | tail -n+2 | awk {'print $1,$2'} | xargs -r -n2 sh -c 'gcloud container node-pools list --region $2 --cluster $1' sh
echo "================================================"
echo "GKE Deployments"
echo "================================================"
gcloud container clusters list | tail -n+2 | awk {'print $1,$2'}| xargs -r -n2 sh -c 'echo "===" & echo $1 & gcloud container clusters get-credentials $1 --region $2 & kubectl get deployments --all-namespaces | tail -n +2 ' sh
echo "================================================"
echo "GKE Services"
echo "================================================"
gcloud container clusters list | tail -n+2 | awk {'print $1,$2'}| xargs -r -n2 sh -c 'echo "===" & echo $1 & gcloud container clusters get-credentials $1 --region $2 & kubectl get services --all-namespaces | tail -n +2 ' sh

```
### Extracting Service account and their keys 
```
gcloud iam service-accounts list | tail -n +2 | grep -E -o "\b[A-Za-z0-9._%+-]{0,50}@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b" | xargs -n1 sh -c 'echo $1 & gcloud iam service-accounts keys list --iam-account $1' sh
```
### Extracting the GKE Master Ip
```
export CLUSTER_NAME=clustername
export NODE_TAG=$(gcloud compute instance-templates describe $(gcloud compute instance-templates list --filter=name~gke-${CLUSTER_NAME:0:20} --limit=1 --uri) --format='get(properties.tags.items[0])')
export GKE_MASTER_IP=$(gcloud compute firewall-rules describe ${NODE_TAG/-node/-ssh} --format='value(sourceRanges)')
echo $GKE_MASTER_IP
```

### Get the VM instance Image list

```
gcloud compute instances list | awk '{print $1,$2}' | tail -n +2| xargs -n2 sh -c 'gcloud compute disks describe $1 --zone $2' sh

gcloud compute instances list | awk '{print $1,$2}' | tail -n +2| xargs -n2 sh -c 'gcloud compute disks describe $1 --zone $2 --format="table(name,licenses[0])"' sh

gcloud compute instances list | awk '{print $1,$2}' | tail -n +2| xargs -n2 sh -c 'gcloud compute disks describe $1 --zone $2 --format="table(name,licenses[0])"| tail -n +2' sh

gcloud compute instances list | awk '{print $1,$2}' | tail -n +2| xargs -n2 sh -c 'gcloud compute disks describe $1 --zone $2 --format="table[box,title=VM-Image-list](name,licenses[0])"' sh

```


### Get the VM instance and machine type in box format
```
gcloud compute instances list --format="table[box,title=Compute-Engine-Machine-Types](name,machine_type)"
```


### To restart the pods in crashLoopBackoff 
```
kubectl get po -n default | grep CrashLoopBackOff | awk {'print $1'} | xargs -n2 sh -c 'kubectl delete po $1 -n default' sh

```

### To list pod names and their images
```
kubectl get pods -n default -o=jsonpath='{range .items[*]}{"\n"}{.metadata.name}{","}{range .spec.containers[*]}{.image}{""}{end}{end}' | sort > prod.csv
```
