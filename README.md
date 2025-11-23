# Multi-Service Cloud Deployment Project

This project delivers a complete cloud-ready multi-service application powered by Terraform, Ansible, Jenkins, and Docker, deployed on AWS EC2 with monitoring via CloudWatch.  
The stack includes a frontend web app, backend Node.js API, MongoDB database, Redis cache, and an Nginx reverse proxy—all orchestrated through Docker Compose and automated end-to-end.

---

## Tech Stack

### DevOps & Infrastructure

- **Terraform** — Provision AWS infrastructure (VPC, subnets, security groups, EC2, IAM, ECR).
- **Ansible** — Configure the EC2 instance, install dependencies, deploy Docker stack.
- **Jenkins** — CI/CD pipeline to build, test, push images to ECR, and trigger deployment.
- **Docker + Docker Compose** — Container runtime for all services.
- **AWS EC2** — Compute environment for hosting multi-service containers.
- **AWS CloudWatch** — Metrics and logs for operational observability.

### Application Stack

- **Frontend:** Static web (HTML/CSS/JS or SPA framework)
- **Backend API:** Node.js + Express (controllers, models, routes, utils)
- **Database:** MongoDB
- **Cache Layer:** Redis
- **Reverse Proxy:** Nginx

---

## Project Goal

The project aims to create a fully automated, production-ready cloud deployment workflow for a multi-service web application. The focus is on delivering a scalable, modular, and maintainable environment following DevOps best practices:

- Automated infrastructure provisioning  
- Configuration management  
- CI/CD pipeline  
- Container-based app delivery  
- Cloud-level observability  

---

## System Architecture

```text
                 ┌───────────────┐
                 │   Jenkins CI   │
                 └──────┬────────┘
                        │
                        ▼
        Build → Docker Images → Push to AWS ECR
                        │
                        ▼
       ┌────────────────────────────────────┐
       │            Terraform               │
       │  Creates EC2, VPC, IAM, SG, ECR    │
       └────────────────────────────────────┘
                        │
                        ▼
              ┌─────────────────┐
              │   Ansible       │
              │ Installs Docker │
              │ Deploys Compose │
              └─────────────────┘
                        │
                        ▼
       ┌───────────────────────────────────────┐
       │              EC2 Host                  │
       │     Nginx → API → Redis → Mongo        │
       └───────────────────────────────────────┘
```

---

## Process Flow

### 1. Infrastructure Provisioning (Terraform)

Terraform creates:

- VPC, subnets, route tables  
- EC2 instance  
- Security groups  
- IAM roles + instance profile  
- ECR repositories  

Terraform also outputs inventory details for Ansible.

---

### 2. Configuration & Deployment (Ansible)

Ansible:

- Connects to EC2 over SSH  
- Installs:
  - Docker  
  - Docker Compose  
- Logs into ECR  
- Deploys all services using `docker-compose.yml`  

---

### 3. CI/CD Automation (Jenkins)

Jenkins pipeline stages:

1. Pull latest code  
2. Build Docker images  
3. Run tests  
4. Tag & push images to ECR  
5. Trigger Ansible deployment  

---

### 4. Application Runtime (Docker Compose)

Services defined in `docker-compose.yml`:

- `frontend`  
- `api`  
- `mongo`  
- `redis`  
- `nginx-proxy`  

All containers run on the EC2 host.

---

### 5. Monitoring (CloudWatch)

CloudWatch provides:

- EC2 metrics (CPU, network, disk, status checks)  
- Optional log forwarding from Nginx / app via CloudWatch Agent  

---

## Repository Structure

```text
/infra/
  terraform/     # Terraform IaC config
  ansible/       # Ansible roles & playbooks

/app/
  frontend/      # Web UI
  api/           # Node.js backend
  docker-compose.yml
  nginx.conf

/Jenkinsfile     # CI/CD pipeline
```

---

## Setup Guide

### 1. Clone the Repository

```bash
git clone https://github.com/your/repo.git
cd repo
```

---

## Terraform Setup

### 2. Initialize Terraform

```bash
cd infra/terraform
terraform init
```

### 3. Validate & Plan

```bash
terraform validate
terraform plan
```

### 4. Apply Infrastructure

```bash
terraform apply -auto-approve
```

Record the output values:

- EC2 public IP  
- SSH key path  
- ECR URLs  

---

## Ansible Deployment

### 5. Update Inventory

Use Terraform output to populate:

- `infra/ansible/inventory`

### 6. Run Ansible Playbook

```bash
cd infra/ansible
ansible-playbook site.yml
```

---

## Docker Commands (on EC2)

### Start Containers

```bash
docker compose -f /opt/multi-service/docker-compose.yml up -d
```

### Check Running Services

```bash
docker ps
```

### View Logs

```bash
docker logs <container_name>
```

### Rebuild & Restart

```bash
docker compose down
docker compose up -d --build
```

---

## Jenkins Pipeline

Optionally trigger the Jenkins pipeline via CLI:

```bash
jenkins-cli build multi-service-pipeline
```

The `Jenkinsfile` manages:

- Build & tag images  
- Push to ECR  
- Run Ansible for deployment  

---

## Accessing the Application

### Frontend

```text
http://<EC2_PUBLIC_IP>
```

### Backend API

```text
http://<EC2_PUBLIC_IP>/api
```

---

## Monitoring via CloudWatch

CloudWatch automatically tracks:

- CPU Utilization  
- Network I/O  
- Disk I/O  
- EC2 health status  

(Optional) You can forward Docker and application logs to CloudWatch using the CloudWatch Agent.

---

## Conclusion

This project demonstrates a robust, cloud-native DevOps pipeline combining provisioning, configuration management, CI/CD, container orchestration, and observability—suited for production-style workloads and scalable multi-service applications.