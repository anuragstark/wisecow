# Wisecow Application - Kubernetes Deployment Guide

A comprehensive guide for containerizing and deploying the Wisecow application on AWS EKS with automated CI/CD pipeline and TLS support.

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Deployment Methods](#deployment-methods)
- [CI/CD Pipeline](#cicd-pipeline)
- [TLS Configuration](#tls-configuration)
- [Operations & Management](#operations--management)
- [Debugging & Troubleshooting](#debugging--troubleshooting)
- [Performance & Scaling](#performance--scaling)
- [Security](#security)
- [Monitoring](#monitoring)
- [Cleanup](#cleanup)

---

## Architecture Overview

### Technology Stack
- **Container Runtime**: Docker
- **Orchestration**: Kubernetes (AWS EKS)
- **CI/CD**: GitHub Actions
- **TLS**: Let's Encrypt with cert-manager
- **Ingress**: NGINX Ingress Controller
- **Infrastructure**: Terraform
- **Configuration Management**: Ansible

### Key Features
- ✅ Multi-stage Dockerfile with security best practices
- ✅ Non-root user execution with health checks
- ✅ Automated CI/CD pipeline with GitHub Actions
- ✅ TLS termination with Let's Encrypt
- ✅ Infrastructure as Code with Terraform
- ✅ Horizontal pod autoscaling
- ✅ Comprehensive monitoring and logging

---

## Project Structure

```
wisecow/
├── 📄 Dockerfile                    # Container definition
├── 📄 docker-compose.yml           # Local development
├── 📄 Makefile                     # Automation commands
├── 📄 .gitignore                   # Git ignore rules
├── 📄 README.md                    # Documentation
├── 📄 Certificate.TLS.info         # TLS information
├── 📁 Images/                      # Documentation images
├── 📁 k8s/                         # Kubernetes manifests
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   └── cluster-issuer.yaml
├── 📁 terraform/                   # Infrastructure as Code
│   ├── main.tf
│   ├── iam.tf
│   ├── variables.tf
│   └── outputs.tf
├── 📁 ansible/                     # Configuration management
│   └── setup-cluster.yaml
├── 📁 scripts/                     # Utility scripts
│   ├── deploy.sh
│   ├── cleanup.sh
│   ├── monitor.sh
│   └── health-check.sh
└── 📁 .github/workflows/           # CI/CD pipeline
    └── ci-cd.yaml
```

---

## Prerequisites

### Required Tools
Ensure you have the following tools installed:

```bash
# Core tools
aws-cli        # AWS command line interface
kubectl        # Kubernetes command line tool
terraform      # Infrastructure as Code
ansible        # Configuration management
helm           # Kubernetes package manager
docker         # Container runtime
```

### AWS Permissions
Your AWS credentials must have permissions for:
- ✅ EKS cluster management
- ✅ EC2 instance management
- ✅ VPC management
- ✅ IAM role creation

### Environment Setup
```bash
# Configure AWS CLI
aws configure

# Set default region
export AWS_DEFAULT_REGION=us-east-1

# Verify tools
kubectl version --client
terraform version
ansible --version
```

---

## Quick Start

### 🚀 One-Command Deployment

```bash
# Clone repository
git clone https://github.com/anuragstark/wisecow.git
cd wisecow

# Deploy everything
make deploy
```

### 🔧 Essential Commands

```bash
# Health check
make health-check

# Monitor application
make monitor

# Clean up resources
make clean
```

---

## Deployment Methods

### Method 1: Automated Deployment (Recommended)

```bash
# 1. Configure environment variables
export AWS_DEFAULT_REGION=us-east-1

# 2. Update configuration files
# - k8s/ingress.yaml (your domain name)
# - k8s/cluster-issuer.yaml (your email address)
# - .github/workflows/ci-cd.yaml (registry details)

# 3. Run automated deployment
chmod +x scripts/deploy.sh
./scripts/deploy.sh

# 4. Configure DNS
# Point your domain to the LoadBalancer URL
```

### Method 2: Manual Step-by-Step Deployment

#### Step 1: Infrastructure Deployment
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

#### Step 2: Configure Kubernetes
```bash
# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name wisecow-cluster

# Install cluster components
ansible-playbook ansible/setup-cluster.yaml
```

#### Step 3: Deploy Application
```bash
# Apply Kubernetes manifests
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/cluster-issuer.yaml
kubectl apply -f k8s/ingress.yaml
```

#### Step 4: Verify Deployment
```bash
# Check all resources
kubectl get all -n wisecow

# Check certificate status
kubectl get certificates -n wisecow

# Get LoadBalancer URL
kubectl get ingress -n wisecow
```

---

## CI/CD Pipeline

### GitHub Actions Workflow

The automated pipeline includes:

#### 🔨 Build Stage (All Branches)
- Builds Docker image on every push
- Pushes to GitHub Container Registry
- Tags images with branch name and commit SHA

#### 🚀 Deploy Stage (Main Branch Only)
- Updates Kubernetes deployment
- Rolls out new version
- Verifies deployment status

### Required GitHub Secrets

Add these secrets to your GitHub repository:

```yaml
AWS_ACCESS_KEY_ID: your-aws-access-key
AWS_SECRET_ACCESS_KEY: your-aws-secret-key
```

### Workflow Triggers

| Event | Action |
|-------|--------|
| Push to `main` | Full build and deploy |
| Push to `develop` | Build only |
| Pull requests | Build and test |

---

## TLS Configuration

### Automatic Certificate Management

The application uses **Let's Encrypt** for TLS certificates:

1. **cert-manager** provisions certificates automatically
2. **NGINX Ingress** handles TLS termination
3. **Automatic renewal** ensures certificates stay valid

### Domain Configuration

```bash
# 1. Update ingress configuration
vim k8s/ingress.yaml
# Replace 'your-domain.com' with your actual domain

# 2. Update cluster issuer
vim k8s/cluster-issuer.yaml
# Replace email address with your email

# 3. Apply changes
kubectl apply -f k8s/cluster-issuer.yaml
kubectl apply -f k8s/ingress.yaml

# 4. Point DNS to LoadBalancer
kubectl get ingress -n wisecow
```

---

## Operations & Management

### Docker Operations

#### Building and Managing Images
```bash
# Build Docker image
docker build -t ghcr.io/your-username/wisecow:main-$(git rev-parse --short HEAD) .

# Push to registry
docker push ghcr.io/your-username/wisecow:main-$(git rev-parse --short HEAD)

# Tag as latest
docker tag ghcr.io/your-username/wisecow:main-$(git rev-parse --short HEAD) ghcr.io/your-username/wisecow:latest
docker push ghcr.io/your-username/wisecow:latest
```

#### Debugging Containers
```bash
# Inspect image
docker inspect ghcr.io/your-username/wisecow:latest

# Run container interactively
docker run -it --rm --entrypoint /bin/sh ghcr.io/your-username/wisecow:latest

# Test application locally
docker run -p 4499:4499 ghcr.io/your-username/wisecow:latest
curl http://localhost:4499
```

### Kubernetes Operations

#### Deployment Management
```bash
# Update deployment
kubectl rollout restart deployment wisecow-deployment -n wisecow

# Monitor rollout
kubectl rollout status deployment wisecow-deployment -n wisecow

# Check deployment status
kubectl get deployment wisecow-deployment -n wisecow -o yaml
```

#### Scaling Operations
```bash
# Manual scaling
kubectl scale deployment wisecow-deployment -n wisecow --replicas=3

# Auto-scaling
kubectl autoscale deployment wisecow-deployment --cpu-percent=70 --min=3 --max=10 -n wisecow

# Check scaling status
kubectl get hpa -n wisecow
```

#### Pod Management
```bash
# List pods
kubectl get pods -n wisecow

# Describe pod
kubectl describe pod <pod-name> -n wisecow

# Execute into pod
kubectl exec -it <pod-name> -n wisecow -- /bin/bash

# Port forward for testing
kubectl port-forward pod/<pod-name> -n wisecow 4499:4499
```

---

## Debugging & Troubleshooting

### Common Issues and Solutions

#### 1. 🔴 Container Not Starting

**Symptoms**: Pods in `CrashLoopBackOff` or `ImagePullBackOff`

**Debug Steps**:
```bash
# Check pod events
kubectl describe pod <pod-name> -n wisecow

# Check image accessibility
kubectl get pods -n wisecow -o wide

# Test container locally
docker run -it --rm --entrypoint /bin/sh ghcr.io/your-username/wisecow:latest
```

#### 2. 🔴 Application Not Responding

**Symptoms**: Readiness/liveness probe failures

**Debug Steps**:
```bash
# Check if app is listening on port
kubectl exec -it <pod-name> -n wisecow -- netstat -tuln

# Test application manually
kubectl exec -it <pod-name> -n wisecow -- /bin/bash
cd /app && ./wisecow.sh

# Check resource limits
kubectl top pods -n wisecow
```

#### 3. 🔴 Certificate Issues

**Symptoms**: TLS certificate not issuing or expired

**Debug Steps**:
```bash
# Check certificate status
kubectl get certificates -n wisecow
kubectl describe certificate -n wisecow

# Check cert-manager logs
kubectl logs -f deployment/cert-manager -n cert-manager

# Verify DNS propagation
dig your-domain.com +short
```

#### 4. 🔴 LoadBalancer Not Accessible

**Symptoms**: Cannot reach application via external URL

**Debug Steps**:
```bash
# Check service and ingress
kubectl get svc,ingress -n wisecow

# Test internal connectivity
kubectl port-forward svc/wisecow-service -n wisecow 4499:4499

# Check DNS resolution
nslookup your-domain.com
```

### Comprehensive Debugging Commands

#### Application Logs
```bash
# Follow deployment logs
kubectl logs -f deployment/wisecow-deployment -n wisecow

# Get logs from all pods
kubectl logs -l app=wisecow -n wisecow --all-containers=true

# Check specific pod logs
kubectl logs -f <pod-name> -n wisecow
```

#### Service and Network Debugging
```bash
# Check services
kubectl get svc -n wisecow -o wide

# Check endpoints
kubectl get endpoints -n wisecow

# Test network connectivity
kubectl exec -it <pod-name> -n wisecow -- nc -zv <service-name> 4499
```

#### Event Monitoring
```bash
# Get recent events
kubectl get events -n wisecow --sort-by=.metadata.creationTimestamp

# Watch events in real-time
kubectl get events -n wisecow --watch
```

### DNS and Domain Troubleshooting

```bash
# Test DNS resolution
nslookup your-domain.com
dig your-domain.com +short

# Get LoadBalancer IP
kubectl get ingress -n wisecow -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}'

# Test with specific DNS server
dig @8.8.8.8 your-domain.com +short

# Clear DNS cache
sudo systemctl restart systemd-resolved
```

---

## Performance & Scaling

### Resource Optimization

#### Monitor Resource Usage
```bash
# Check pod resource usage
kubectl top pods -n wisecow

# Check node resource usage
kubectl top nodes

# View resource requests/limits
kubectl describe deployment wisecow-deployment -n wisecow | grep -A 5 "Requests\|Limits"
```

#### Horizontal Pod Autoscaling
```bash
# Create HPA
kubectl autoscale deployment wisecow-deployment --cpu-percent=70 --min=3 --max=10 -n wisecow

# Check HPA status
kubectl get hpa -n wisecow

# View HPA details
kubectl describe hpa -n wisecow
```

#### Vertical Pod Autoscaling
```bash
# Install VPA (if not installed)
kubectl apply -f https://github.com/kubernetes/autoscaler/releases/latest/download/vpa-release.yaml

# Create VPA resource
kubectl apply -f - <<EOF
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: wisecow-vpa
  namespace: wisecow
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: wisecow-deployment
  updatePolicy:
    updateMode: "Auto"
EOF
```

---

## Security

### Container Security

#### Security Context
```bash
# Check container security context
kubectl get pod <pod-name> -n wisecow -o jsonpath='{.spec.securityContext}'

# Verify non-root user
kubectl exec -it <pod-name> -n wisecow -- whoami
```

#### Image Security
```bash
# Scan image for vulnerabilities
docker scan ghcr.io/your-username/wisecow:latest

# Check image layers
docker history ghcr.io/your-username/wisecow:latest
```

### Network Security

#### Security Groups (AWS)
```bash
# List security groups
aws ec2 describe-security-groups --group-ids <sg-id>

# Check security group rules
aws ec2 describe-security-groups --group-ids <sg-id> --query 'SecurityGroups[0].IpPermissions'
```

#### Network Policies
```bash
# Check network policies
kubectl get networkpolicies -n wisecow

# Test network connectivity
kubectl exec -it <pod-name> -n wisecow -- nc -zv kubernetes.default.svc.cluster.local 443
```

---

## Monitoring

### Health Checks

#### Application Health
```bash
# Check deployment health
kubectl get deployment wisecow-deployment -n wisecow

# Check pod health
kubectl get pods -n wisecow -o wide

# Test health endpoint
curl -k https://your-domain.com/health
```

#### Cluster Health
```bash
# Check cluster status
kubectl cluster-info

# Check node status
kubectl get nodes

# Check system pods
kubectl get pods --all-namespaces | grep -E "(kube-system|ingress-nginx|cert-manager)"
```

### Logging and Monitoring

#### Centralized Logging
```bash
# Install logging stack (optional)
helm repo add elastic https://helm.elastic.co
helm install elasticsearch elastic/elasticsearch -n logging --create-namespace
helm install kibana elastic/kibana -n logging
```

#### Metrics Collection
```bash
# Install Prometheus and Grafana
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
```

---

## Cleanup

### Application Cleanup

#### Remove Application Resources
```bash
# Delete application
kubectl delete -f k8s/

# Delete namespace
kubectl delete namespace wisecow
```

#### Remove Helm Releases
```bash
# Remove ingress controller
helm uninstall ingress-nginx -n ingress-nginx

# Remove cert-manager
helm uninstall cert-manager -n cert-manager
```

### Complete Infrastructure Cleanup

#### Automated Cleanup
```bash
# Run cleanup script
chmod +x scripts/cleanup.sh
./scripts/cleanup.sh
```

#### Manual Cleanup
```bash
# Remove Terraform infrastructure
cd terraform
terraform destroy -auto-approve

# Remove Docker images
docker rmi ghcr.io/your-username/wisecow:latest
docker system prune -a
```

---

## Development and Testing

### Local Development

#### Build and Test Locally
```bash
# Build image
docker build -t wisecow:local .

# Run locally
docker run -p 4499:4499 wisecow:local

# Test endpoint
curl http://localhost:4499
```

#### Development Workflow
```bash
# Create feature branch
git checkout -b feature/new-feature

# Make changes and test
docker build -t wisecow:test .
docker run -p 4499:4499 wisecow:test

# Commit and push
git add .
git commit -m "Add new feature"
git push origin feature/new-feature
```

### Integration Testing

#### Automated Tests
```bash
# Test health endpoint
curl -k https://your-domain.com/health

# Test main application
curl -k https://your-domain.com

# Load testing
for i in {1..10}; do curl -k https://your-domain.com; done
```

#### Manual Testing
```bash
# Test certificate
openssl s_client -connect your-domain.com:443 -servername your-domain.com

# Test DNS resolution
nslookup your-domain.com

# Test from different locations
curl -I https://your-domain.com
```

---

## Troubleshooting Checklist

### Pre-Deployment Checklist
- [ ] AWS credentials configured and tested
- [ ] Kubernetes cluster accessible
- [ ] Docker image built and pushed successfully
- [ ] Domain DNS properly configured
- [ ] SSL certificates configuration ready
- [ ] All required secrets added to GitHub

### During Deployment Checklist
- [ ] Pods are running and ready
- [ ] Services are accessible internally
- [ ] Ingress controller is working
- [ ] Certificates are issued successfully
- [ ] LoadBalancer is accessible externally
- [ ] DNS resolution is working

### Post-Deployment Checklist
- [ ] Application responds to health checks
- [ ] TLS certificates are valid and auto-renewing
- [ ] Monitoring and logging are functional
- [ ] Scaling works as expected
- [ ] Backup procedures are in place
- [ ] Documentation is updated

---

## Best Practices

### Development
- Use multi-stage Docker builds for smaller images
- Implement proper health checks and readiness probes
- Use non-root users in containers
- Set appropriate resource limits and requests
- Follow GitOps practices with version control

### Operations
- Implement proper monitoring and alerting
- Use Infrastructure as Code for all resources
- Regularly update and patch all components
- Implement proper backup and disaster recovery
- Use secrets management for sensitive data

### Security
- Regularly scan images for vulnerabilities
- Use network policies to restrict traffic
- Implement proper RBAC in Kubernetes
- Use TLS for all communications
- Follow principle of least privilege

---

## Support and Contributing

### Getting Help
1. Check this documentation first
2. Review application logs and events
3. Test with debugging commands provided
4. Check official Kubernetes and AWS documentation
5. Open an issue in the repository with detailed information

### Contributing
1. Fork the repository
2. Create a feature branch
3. Test all changes thoroughly
4. Update documentation as needed
5. Submit a pull request with detailed description

### Resources
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Terraform Documentation](https://www.terraform.io/docs/)

---

**Last Updated**: July 2025  
**Version**: 1.0  
**Maintainer**: Anurag Chauhan (anuragchauhan536@gmail.com)