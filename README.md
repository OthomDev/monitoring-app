My Monitoring app



Flask Application Deployment on AWS with Terraform
Overview
This project deploys a Flask web application on AWS using Terraform. It provisions EC2 instances in two AWS regions (us-east-1 and us-east-2) and uses an Application Load Balancer (ALB) to distribute traffic. Security groups manage access control, ensuring secure communication.

Infrastructure Components
EC2 Instances: Two instances per region run the Flask application.
Load Balancer (ALB): Distributes traffic evenly across instances.
Security Groups: Allow SSH (port 22) for administration and HTTP (port 4000) for the application.
Networking: Uses AWS's default VPC with dynamically assigned subnets.





run:

terraform init

Terraform apply -var-file="dev.tfvars" -auto-approve

aws elbv2 describe-load-balancers --region us-east-1 --query "LoadBalancers[?contains(LoadBalancerName, 'flask-alb-use1')].DNSName" --output text

aws elbv2 describe-load-balancers --region us-east-2 --query "LoadBalancers[?contains(LoadBalancerName, 'flask-alb-use2')].DNSName" --output text

if you want to destroy the infra:

terraform destroy -var-file="dev.tfvars" -auto-approve

