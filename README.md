# Flask CI/CD Pipeline using GitHub Actions, Docker, Amazon ECR, EC2 (SSM), and MongoDB Atlas

## Project Overview

This project demonstrates a complete Continuous Integration and Continuous Deployment (CI/CD) pipeline for a Python Flask application using **GitHub Actions**.

Whenever code is pushed to the **main** branch, GitHub Actions automatically:

- Checks out the source code
- Installs Python dependencies
- Runs unit tests using pytest
- Builds a Docker image tagged with the Git commit SHA
- Pushes the Docker image to Amazon Elastic Container Registry (ECR)
- Deploys the latest image to an Amazon EC2 instance using AWS Systems Manager (SSM)
- Performs a deployment health check
- Sends an email notification indicating whether the deployment succeeded or failed

---

# Architecture

```
Developer
    |
    | Git Push
    |
    V
GitHub Repository
    |
    V
GitHub Actions
    |
    |---- Checkout Source
    |
    |---- Install Dependencies
    |
    |---- Run Pytest
    |
    |---- Build Docker Image
    |
    |---- Push Image to Amazon ECR
    |
    |---- Deploy to EC2 using AWS SSM
    |
    |---- Health Check
    |
    |---- Email Notification
    |
    V
Amazon EC2
    |
Docker Container
    |
Flask Application
    |
MongoDB Atlas
```

---

# Technologies Used

- Python 3.14
- Flask
- Flask-PyMongo
- PyMongo
- MongoDB Atlas
- Docker
- Amazon Elastic Container Registry (ECR)
- Amazon EC2
- AWS Systems Manager (SSM)
- GitHub Actions
- Pytest
- Gunicorn

---

# Project Structure

```
.
├── .github
│   └── workflows
│       └── ci-cd.yml
│
├── templates
│   ├── base.html
│   ├── index.html
│   ├── add_student.html
│   └── update_student.html
│
├── app.py
├── test_app.py
├── Dockerfile
├── .dockerignore
├── requirements.txt
├── .gitignore
├── .env.example
│
├── Screenshots
│   ├── Failure
│   ├── Success
│
└── README.md
```

---

# Application Features

- View Students
- Add Student
- Update Student
- Delete Student
- Health Endpoint

```
GET /health
```

Returns

```json
{
    "status":"healthy",
    "database": "Connected",
}
```

---

# Prerequisites

Before running this project, create the following AWS resources manually.

---

# AWS Infrastructure

## 1. Create Amazon ECR Repository

Repository Name

```
student-registration-app
```

Region

```
ap-south-1
```
<img width="817" height="280" alt="image" src="https://github.com/user-attachments/assets/f748aa9d-8cf2-4601-8aa2-1c87c3fd6923" />

---

### Security Group

Allow

```
5000
```

for Flask

and

```
22 only if SSH access is required.
```



<img width="1016" height="375" alt="image" src="https://github.com/user-attachments/assets/cf0c7c7c-8010-4af5-b5bf-3663a257d4d9" />

---
## 2. Create EC2 Instance

Operating System

```
Amazon Linux 2023
```
<img width="980" height="171" alt="image" src="https://github.com/user-attachments/assets/b6d956d4-542b-474e-b180-70337523a126" />

---

### Install Docker

```bash
sudo yum update -y

sudo yum install docker -y

sudo systemctl enable docker

sudo systemctl start docker

sudo usermod -aG docker ec2-user

newgrp docker
```

### Verify IAM Permissions

```bash
aws sts get-caller-identity
```

### Verify ECR Access

```bash
aws ecr describe-repositories --region ap-south-1
```

Verify

```bash
docker --version
```

---

### Install AWS CLI

```bash
aws --version
```

### Install SSM Agent

Amazon Linux 2023 already includes the SSM Agent.

Verify

```bash
sudo systemctl status amazon-ssm-agent
```

---

### Attach IAM Role

Attach an IAM Role containing

- AmazonSSMManagedInstanceCore
- AmazonEC2ContainerRegistryPowerUser
- CloudWatchAgentServerPolicy

> Note:
> The assignment recommends AmazonEC2ContainerRegistryReadOnly.
>
> AmazonEC2ContainerRegistryPowerUser was used because the EC2 instance was also used during testing and image management.

<img width="1014" height="395" alt="image" src="https://github.com/user-attachments/assets/63b585cc-ae55-4d95-8a3d-a0a76aa0c34e" />

---
### Verify SSM

<img width="933" height="249" alt="image" src="https://github.com/user-attachments/assets/78ad70a4-938a-4c4d-acc0-b0ab7d77be77" />

---
# MongoDB Atlas Setup

## Create Cluster

Create a free M0 Cluster.

---

## Create Database User

Create a username and password.

Example

```
Username:
student_user

Password:
********
```

---

## Network Access

Allow

```
0.0.0.0/0
```

or add the EC2 Public IP.

---

## Obtain Connection String

Example

```
mongodb+srv://username:password@student-cluster.mongodb.net/<db_name>?retryWrites=true&w=majority
```

---

# Environment Variables

Create

```
.env
```

```
MONGO_URI=your_mongodb_connection_string

SECRET_KEY=your_secret_key
```

---

# Run Project Locally

Clone

```bash
git clone <repository-url>

cd flask_Practice
```

---

Create Virtual Environment

Windows

```bash
python -m venv venv

venv\Scripts\activate
```

Linux

```bash
python3 -m venv venv

source venv/bin/activate
```

---

Install Dependencies

```bash
pip install -r requirements.txt
```

---

Run Application

```bash
python app.py
```

<img width="651" height="109" alt="image" src="https://github.com/user-attachments/assets/9232bc5f-8cee-4499-b3b1-f91b38f0e339" />

Open

```
http://localhost:5000
```
<img width="1125" height="307" alt="image" src="https://github.com/user-attachments/assets/ad921156-03e9-4768-920a-d8273d8e3d96" />

### Test CRUD Operations

```
Add Student
```

<img width="1125" height="284" alt="image" src="https://github.com/user-attachments/assets/5c2caaeb-5a29-44de-8908-5f3f94a96b43" />

```
Edit Student
```

<img width="1125" height="292" alt="image" src="https://github.com/user-attachments/assets/48407545-483f-44cb-95b6-a814a59eecfa" />

```
Delete Student
```

<img width="1125" height="269" alt="image" src="https://github.com/user-attachments/assets/78951bb8-5d21-43e1-bbab-6a45c1015e10" />

---

# Run Tests

## Add a Health Check Endpoint in app.py

```bash
@app.route("/health")
def health():
    try:
        # Verify MongoDB connection
        mongo.cx.admin.command("ping")

        return {
            "status": "healthy",
            "database": "connected"
        }, 200

    except Exception as e:
        return {
            "status": "unhealthy",
            "database": "disconnected",
            "error": str(e)
        }, 500

```
## Update the Test Cases in test_app.py

```
def test_health_endpoint(client):
    """Test health endpoint"""
    response = client.get("/health")
    assert response.status_code == 200
    json_data = response.get_json()
    assert json_data["status"] == "healthy"
    assert json_data["database"] == "connected"

```

### Open	 http://localhost:5000/health

<img width="558" height="288" alt="image" src="https://github.com/user-attachments/assets/6313884c-c0ba-427b-935e-629415e88f69" />

```bash
pytest
```

Expected

```
5 passed
```

<img width="1125" height="197" alt="image" src="https://github.com/user-attachments/assets/264a0fbe-a987-4c66-b6c3-9c43701162db" />


---


# Docker

## Create Dockerfile
## Create .dockerignore
## Build Image

```bash
docker build -t student-registration-app .
```

---

Run Container

```bash
docker run -d \
-p 5000:5000 \
-e MONGO_URI="<connection_string>" \
-e SECRET_KEY="<secret>" \
student-registration-app
```

---

# GitHub Secrets

Store the following secrets in

```
Repository

Settings

Secrets and Variables

Actions
```

| Secret | Description |
|---------|-------------|
| AWS_ACCESS_KEY_ID | AWS Access Key |
| AWS_SECRET_ACCESS_KEY | AWS Secret Access Key |
| AWS_REGION | AWS Region |
| AWS_ACCOUNT_ID | AWS Account ID |
| ECR_REPOSITORY | ECR Repository Name |
| EC2_INSTANCE_ID | EC2 Instance ID |
| MONGO_URI | MongoDB Connection String |
| SECRET_KEY | Flask Secret Key |
| SMTP_USERNAME | Email Username |
| SMTP_PASSWORD | Email Password |
| SMTP_SERVER | SMTP Server Name |
| SMTP_PORT | SMTP Server Port |
| EMAIL_TO | Recipient Email |


### Verify Sensitive Files Are Not Tracked

```
git ls-files
```
---

# CI/CD Pipeline

## Create the Workflow Directory and workflow file

```
.github/
└── workflows/
    └── ci-cd.yml
```

### Test Deployment failure by making temporarily changes in code. Check email for Failure Email Notification.

### Restore the change and test Deployment Success. Check email for Success Email Notification.

## Checkout

Checks out the latest source code.

---

## Install

Installs all Python packages from

```
requirements.txt
```

---

## Test

Runs

```bash
pytest
```

If any test fails

- Docker Image is NOT built
- Image is NOT pushed
- Deployment does NOT occur

---

## Build

Builds Docker Image

Tag

```
github.sha
```

Example

```
529cbe218e891386f1d54fdac62cc2e947bc6804
```

---

## Push

Logs in to Amazon ECR

Pushes image

```
AWS_ACCOUNT_ID.dkr.ecr.ap-south-1.amazonaws.com/student-registration-app:<commit-sha>
```

---

## Deploy

Deployment is performed using

```
AWS Systems Manager (SSM)
```

Deployment Steps

- Login to ECR
- Pull latest Docker Image
- Stop old container
- Remove old container
- Start new container
- Pass environment variables
- Verify application

---

# Why SSM instead of SSH?

Deployment uses AWS Systems Manager (SSM) because

- No SSH keys required
- No inbound port 22 required
- More secure
- Fully managed by AWS
- Suitable for production deployments

---

# Health Check

Pipeline verifies deployment using

```
GET /health
```

Only when the endpoint returns success is the deployment considered successful.

---

# Email Notification

Pipeline sends an email after every execution.

## Success Email

Contains

- Build Status
- Branch
- Commit SHA
- Docker Image Tag
- EC2 Instance
- Pipeline URL

---

## Failure Email

Contains

- Failed Stage
- Branch
- Commit SHA
- Pipeline URL

---

# Manual Deployment

Login to ECR

```bash
aws ecr get-login-password --region ap-south-1 \
| docker login \
--username AWS \
--password-stdin <account>.dkr.ecr.ap-south-1.amazonaws.com
```

Pull Image

```bash
docker pull IMAGE_URI
```

Stop Existing Container

```bash
docker stop flask-app
```

Remove Container

```bash
docker rm flask-app
```

Run New Container

```bash
docker run -d \
--name flask-app \
-p 5000:5000 \
-e MONGO_URI="<mongodb-uri>" \
-e SECRET_KEY="<secret>" \
IMAGE_URI
```

---

# Health Check

```bash
curl http://localhost:5000/health
```

Expected

```json
{
    "status":"healthy",
    "database": "Connected",
}
```

---

# Assignment Deliverables

- Flask Application
- Dockerfile
- Unit Tests
- GitHub Actions Workflow
- Amazon ECR Deployment
- EC2 Deployment using AWS SSM
- MongoDB Atlas Integration
- Email Notifications
- Updated README

---

# Author

Seema Kanwar
