#!/bin/bash

VPC_ID="vpc-id"
PROFILE="aws-profile-name"
REGION="aws-region"

echo "=== Checking resources inside VPC: $VPC_ID ==="

# Check Network Interfaces (ENIs) 「Lambda functions, NAT Gateways, Elastic Load Balancers (ALB/NLB), RDS instances, EFS Mount Targets, VPN connections」
echo -e "\n--- Network Interfaces ---"
aws ec2 describe-network-interfaces \
    --profile $PROFILE --region $REGION \
    --filters "Name=vpc-id,Values=$VPC_ID" \
    --query "NetworkInterfaces[].{ID:NetworkInterfaceId,Type:InterfaceType,Desc:Description}" \
    --output table

# Check Subnets
echo -e "\n--- Subnets ---"
aws ec2 describe-subnets \
    --profile $PROFILE --region $REGION \
    --filters "Name=vpc-id,Values=$VPC_ID" \
    --query "Subnets[].SubnetId" \
    --output table

# Check Internet Gateways
echo -e "\n--- Internet Gateways ---"
aws ec2 describe-internet-gateways \
    --profile $PROFILE --region $REGION \
    --filters "Name=attachment.vpc-id,Values=$VPC_ID" \
    --query "InternetGateways[].InternetGatewayId" \
    --output table

# Check NAT Gateways
echo -e "\n--- NAT Gateways ---"
aws ec2 describe-nat-gateways \
    --profile $PROFILE --region $REGION \
    --filter "Name=vpc-id,Values=$VPC_ID" \
    --query "NatGateways[].NatGatewayId" \
    --output table

# Check RDS Instances
echo -e "\n--- RDS Instances ---"
aws rds describe-db-instances \
    --profile $PROFILE --region $REGION \
    --query "DBInstances[?DBSubnetGroup.VpcId=='$VPC_ID'].DBInstanceIdentifier" \
    --output table

# Check Load Balancers (ALB/NLB)
echo -e "\n--- ALB/NLB ---"
aws elbv2 describe-load-balancers \
    --profile $PROFILE --region $REGION \
    --query "LoadBalancers[?VpcId=='$VPC_ID'].LoadBalancerName" \
    --output table

# Check Classic Load Balancers
echo -e "\n--- Classic Load Balancers ---"
aws elb describe-load-balancers \
    --profile $PROFILE --region $REGION \
    --query "LoadBalancerDescriptions[?VPCId=='$VPC_ID'].LoadBalancerName" \
    --output table

# Check Lambda functions with VPC config
echo -e "\n--- Lambda Functions in VPC ---"
for fn in $(aws lambda list-functions --profile $PROFILE --region $REGION --query "Functions[].FunctionName" --output text); do
    VPC=$(aws lambda get-function-configuration --function-name "$fn" --profile $PROFILE --region $REGION --query "VpcConfig.VpcId" --output text)
    if [[ "$VPC" == "$VPC_ID" ]]; then
        echo "$fn"
    fi
done

# Check VPC Endpoints
echo -e "\n--- VPC Endpoints ---"
aws ec2 describe-vpc-endpoints \
    --profile $PROFILE --region $REGION \
    --filters "Name=vpc-id,Values=$VPC_ID" \
    --query "VpcEndpoints[].VpcEndpointId" \
    --output table

# Check EKS Clusters
echo -e "\n--- EKS Clusters ---"
for cluster in $(aws eks list-clusters --profile $PROFILE --region $REGION --query "clusters[]" --output text); do
    cluster_vpc=$(aws eks describe-cluster --name "$cluster" --profile $PROFILE --region $REGION --query "cluster.resourcesVpcConfig.vpcId" --output text)
    if [[ "$cluster_vpc" == "$VPC_ID" ]]; then
        echo "$cluster"
    fi
done

# Check ElastiCache Clusters
echo -e "\n--- ElastiCache Clusters ---"
aws elasticache describe-cache-clusters \
    --profile $PROFILE --region $REGION \
    --query "CacheClusters[?VpcId=='$VPC_ID'].CacheClusterId" \
    --output table

# Check Redshift Clusters
echo -e "\n--- Redshift Clusters ---"
aws redshift describe-clusters \
    --profile $PROFILE --region $REGION \
    --query "Clusters[?VpcId=='$VPC_ID'].ClusterIdentifier" \
    --output table

# *** VPC Peering Connections ***
echo -e "\n--- VPC Peering Connections ---"
aws ec2 describe-vpc-peering-connections \
    --profile $PROFILE --region $REGION \
    --filters "Name=requester-vpc-info.vpc-id,Values=$VPC_ID" "Name=accepter-vpc-info.vpc-id,Values=$VPC_ID" \
    --query "VpcPeeringConnections[].VpcPeeringConnectionId" \
    --output table

echo -e "\n=== Resource check complete ==="
