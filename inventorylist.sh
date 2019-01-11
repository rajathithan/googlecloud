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
gcloud compute interconnects list| tail -n+2 | awk '{print $1}'
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
