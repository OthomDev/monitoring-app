My Monitoring app


run:

terraform init

Terraform apply -var-file="dev.tfvars" -auto-approve

aws elbv2 describe-load-balancers --region us-east-1 --query "LoadBalancers[?contains(LoadBalancerName, 'flask-alb-use1')].DNSName" --output text

aws elbv2 describe-load-balancers --region us-east-2 --query "LoadBalancers[?contains(LoadBalancerName, 'flask-alb-use2')].DNSName" --output text

if you want to destroy the infra:

terraform destroy -var-file="dev.tfvars" -auto-approve
