# DevOps Technical Test 2026

## Overvieww

This repository contains the implementation of a **cloud-native microservice platform**
designed to demonstrate modern DevOps best practices, including:

- Containerized application
- CI/CD pipelines
- Infrastructure as Code (IaC)
- Kubernetes orchestration
- Perimeter security
- Observability by default
- Secure secret management
- Multi-cluster ready architecture

The solution prioritizes **simplicity, reliability, and scalability**, while remaining
extensible to enterprise-grade environments.

```
                        ┌────────────────────┐
                        │     Internet       │
                        └─────────┬──────────┘
                                  │
                          ┌───────▼────────┐
                          │   Cloudflare   │
                          │  (DNS + TLS +  │
                          │   WAF Basic)   │
                          └───────┬────────┘
                                  │
                    ┌─────────────▼────────────────┐
                    │ GKE Gateway API (L7 External) │
                    │ gke-l7-global-external-managed│
                    └─────────────┬────────────────┘
                                  │
                        ┌─────────▼─────────┐
                        │   HTTPRoute       │
                        │ Host-based routing│
                        └─────────┬─────────┘
                                  │
                      ┌───────────▼────────────┐
                      │ Kubernetes Service     │
                      │ devops-test-api        │
                      └───────────┬────────────┘
                                  │
                      ┌───────────▼────────────┐
                      │   GKE   Pods   │
                      │   (FastAPI App)        │
                      └───────────┬────────────┘
                                  │
            ┌─────────────────────▼─────────────────────┐
            │ Google Cloud Observability                 │
            │ - Cloud Monitoring (metrics & alerts)     │
            │ - Cloud Logging (logs)                     │
            │ - Grafana                       │
            └───────────────────────────────────────────┘


├── app/                    # Application source code
│   ├── main.py
│   ├── requirements.txt
│   ├── cloudbuild.yaml     # CI/CD pipeline
│   └── Dockerfile
├── gitops/
│   └──  keda/              # KEDA
│         └── api-scaler.yaml
├── helm/                   # Helm charts for Kubernetes
│   └── devops-test-api/ 
│         └── templates/
├── infra/                  # Infrastructure as Code
│   ├── envs/
│   |   └── prod/
│   |   └── staging/
│   ├── modules/
│   |    └── artifact-registry/
│   |    └── gke-cluster/
│   |    └── network/
│   |    └── node-pool/
|
├── ejec.ps1                  # Traffic test    
└── README.md

```
## Tools

| Area            | Tool                         | Justification |
|-----------------|------------------------------|---------------|
| APP             | python + FastApi             | Functional Api ready libraries |
| CI/CD           | Cloud Build                  | Native, secure, minimal ops |
| IaC             | Terraform                     |Declarative, environment-agnostic |
| Orchestration   | GKE Autopilot                | Reduced ops, production-ready Cost-efficient, secure, no node management |
|Packaging        | Helm                         | Reusable, environment-driven deployments|
| Networking      | Gateway API                  | Kubernetes-native, future-proof |
| Edge Security   | Cloudflare                   | TLS, CDN, DDoS protection |
| Autoscaling     | KEDA                         | Event-driven, scale-to-zero capable|
| Observability   | Cloud Monitoring & Logging + grafana  | Zero-maintenance, integrated |
| Secrets         | Secret Manager + WI          | No plaintext secrets |
---

##  Deployment from Scratch

### Prerequisites

- Google Cloud Project
- Billing enabled
- gcloud CLI installed
- kubectl installed
- Helm installed
- Terraform installed
- Cloud Build enabled


# DEPLOY FORM SCRATCH
## Authenticate Locally:
##1. Google Cloud Project Setup
- gcloud auth login
- gcloud auth application-default login



## Create and configure the project:

- gcloud projects create devops-test-2026
- gcloud config set project devops-test-2026

**Enable required services:**

- gcloud services enable: 
    - container.googleapis.com
    - cloudbuild.googleapis.com 
    - artifactregistry.googleapis.com 
    - secretmanager.googleapis.com

**Verify active project:**

- gcloud config get-value project

##2. Infrastructure Provisioning (Terraform)

**Terraform Initialization:**
- cd infra/terraform
- terraform init -reconfigure
- terraform validate
- terraform apply

**Cluster Strategy:**
For real validation, GKE Autopilot was used to avoid quota issues on new projects.

The Terraform design supports:
- Autopilot clusters (used)
- Standard clusters with node pools (future-ready)

This allows environment-based flexibility without refactoring infrastructure code.

##3. Artifact Registry Configuration

Create and expose an Artifact Registry repository (via Terraform).

**Example output:**
- us-east1-docker.pkg.dev/devops-test-2026/prod-repo

**Authenticate Docker:**

- gcloud auth configure-docker us-east1-docker.pkg.dev


**Verify:**
- cat ~/.docker/config.json

##4. Application Containerization.
The application image:
- Runs as non-root

- Exposes /health

- Is Kubernetes-ready

- Delegates scaling to the platform

**Build & Push (manual validation)**
- docker build -t devops-demo-api:1.0.0 .
- docker tag devops-demo-api:1.0.0 \ us-east1-docker.pkg.dev/devops-test-2026/prod-repo/devops-demo-api:1.0.0

- docker push us-east1-docker.pkg.dev/devops-test-2026/prod-repo/devops-demo-api:1.0.0

##5. Kubernetes Access

**Fetch cluster credentials:**

- gcloud container clusters list
- gcloud container clusters get-credentials prod-cluster \ --region us-east1 \ --project devops-test-2026

**If required:**

- gcloud components install gke-gcloud-auth-plugin

**Avoid extra costs by destroying the infra:**
        cd infra/terraform
        terraform destroy -var="project_id=$PROJECT_ID" -var="region=$REGION" -auto-approve


##6. Application Deployment (Helm)

Helm Design Principles:

- Environment-agnostic
- No hardcoded values
- Compatible with Gateway API
- Cloud-agnostic at Kubernetes level
- Reusable across regions and clusters
- _helpers.tpl is used only for: Names, Labels and Helpers  avoiding collisions between releases, clusters, and environments.

**Render & Install**

**Validate templates:**

        helm template devops-test-api ./helm/devops-test-api


**Install:**

        helm install devops-test-api ./helm/devops-test-api \
        --namespace prod \
        --create-namespace


Verify:

        kubectl get pods -n prod


**Test locally:**

        kubectl port-forward svc/devops-test-api-devops-test-api 8080:80 -n prod
        curl http://localhost:8080/health


Readiness and liveness probes prevented traffic until the application was healthy, demonstrating resilience by design.

##7. CI/CD – Cloud Build (GitOps-style)
- Cloud Build Service Account Permissions

        PROJECT_ID=devops-test-2026
        PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")


**Grant permissions:**

        gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:$PROJECT_NUMBER@cloudbuild.gserviceaccount.com" \
        --role="roles/container.developer"

        gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:$PROJECT_NUMBER@cloudbuild.gserviceaccount.com" \
        --role="roles/artifactregistry.writer"

**Link k8s SA with GCP SA for Workload identity when needed: pulling images from GCP** 
        gcloud iam service-accounts add-iam-policy-binding   devops-test-api@devops-test-2026.iam.gserviceaccount.com   --role roles/iam.workloadIdentityUser   --member "serviceAccount:devops-test-2026.svc.id.goog[prod/devops-test-api-sa]" 


**Verify:**

        gcloud projects get-iam-policy devops-test-2026 \
        --flatten="bindings[].members" \
        --filter="bindings.members:cloudbuild" \
        --format="table(bindings.role)"

## Cloud Build Pipeline

Cloud Build trigger runs:

- Docker build
- Image push
- Helm upgrade

Authentication is handled automatically by gcr.io/cloud-builders/helm.

    steps:
    - name: gcr.io/cloud-builders/docker
    dir: app
    args:
        - build
        - -t
        - us-east1-docker.pkg.dev/$PROJECT_ID/prod-repo/devops-demo-api:$SHORT_SHA
        - .

    - name: gcr.io/cloud-builders/docker
    args:
        - push
        - us-central1-docker.pkg.dev/$PROJECT_ID/prod-repo/devops-demo-api:$SHORT_SHA

    - name: gcr.io/cloud-builders/helm
    env:
        - CLOUDSDK_CONTAINER_CLUSTER=prod-cluster
        - CLOUDSDK_COMPUTE_REGION=us-central1
    args:
        - upgrade
        - --install
        - devops-test-api
        - ./helm/devops-test-api
        - --namespace
        - prod
        - --create-namespace
        - --set
        - image.repository=us-east1-docker.pkg.dev/$PROJECT_ID/prod-repo/devops-demo-api
        - --set
        - image.tag=$SHORT_SHA

##8. Networking – Gateway API + Cloudflare

**Enable Gateway API:**

        gcloud container clusters update prod-cluster \
        --region us-central1 \
        --gateway-api=standard


**Verify:**

    kubectl get gatewayclass

**Gateway & HTTPRoute**

**Apply manifests:**

        kubectl apply -f infra/networking/gateway.yaml
        kubectl apply -f infra/networking/httproute.yaml

**Get public IP:**

        kubectl get gateway -n prod


**Cloudflare Edge Security**

- DNS A record → Gateway IP
- SSL Mode: Full (Strict)
- Always Use HTTPS
- Automatic HTTPS Rewrites
- Optional HSTS (6 months)

TLS is terminated at Cloudflare. Kubernetes remains certificate-free.

**HTTPRoute Backend Fix**

Helm creates services using:

        <release-name>-<chart-name>
Correct backend reference:

        backendRefs:
        - name: devops-test-api-devops-test-api
            port: 80


**Validate:**

        kubectl get httproute devops-api-route -n prod -o yaml


**Test:**

        curl -ki -H "Host: devopstestapi2026.online" http://34.149.84.31/health

##9. Autoscaling – KEDA

**Install KEDA:**

        helm repo add kedacore https://kedacore.github.io/charts
        helm repo update
        helm install keda kedacore/keda --namespace keda --create-namespace


**Verify:**

        kubectl get crd | grep keda

**Apply keda-trigger-auth.yaml**
**permissions:**
        gcloud iam service-accounts create devops-test-api-sa  --project devops-test-2026

         gcloud projects add-iam-policy-binding devops-test-2026 --member="serviceAccount:devops-test-api-sa@devops-test-2026.iam.gserviceaccount.com" --role="roles/monitoring.viewer" 

        kubectl apply -f infra/keda/keda-trigger-auth.yaml

**Apply scaler:**

        kubectl apply -f api-scaler.yaml


**Watch scaling:**

        kubectl get pods -n staging -w

## 10. Observability

**Install Grafana to the project**

        helm repo add grafana https://grafana.github.io/helm-charts
        helm upgrade --install grafana grafana/grafana `
        --namespace monitoring --create-namespace `
        --set persistence.enabled=true


- Metrics: Cloud Monitoring
- Logs: Cloud Logging
- Alerts: Cloud Monitoring Alert Policies

**Enable managed Prometheus:**

        gcloud container clusters update staging-prod \
        --enable-managed-prometheus \
        --zone us-central1

**Getting user:**
        $secret = kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}"
        [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($secret))

**Access Grafana:**
        kubectl port-forward -n monitoring svc/grafana 3000:80


## QUICK SUMMARY

### Application

    - Framework: FastAPI
    - Endpoints:
    - /health → health check (used by Kubernetes probes)
    - /transaction → example business endpoint
    - Logging: stdout/stderr (Cloud Logging compatible)
    - Health Probes: Liveness & Readiness enabled

### Containerization

    - Non-root container
    - Slim Python base image
    - Optimized Dockerfile
    - Kubernetes-friendly port (8080)

###  CI/CD Pipeline (Cloud Build)

The CI pipeline is implemented using Google Cloud Build.

###  Pipeline Stages

1. Build

        - Docker image build
        - Image tagged with commit SHA

2. Push

        - Push to Artifact Registry

3. Scan

        - Automatic vulnerability scanning (Artifact Registry)

4. Deploy

        - Helm-based deployment to GKE (staging - prod)

        Document: cloudbuild.yaml

### Security
        Container Security

        Artifact Registry vulnerability scanning enabled

        Pipeline ready to block vulnerable images

        Perimeter Security

###  Cloudflare:

        DNS management

        CDN

        TLS termination

        Basic protection (Free plan)

### Gateway API:

        Kubernetes-native traffic management

        Advanced WAF rules are not enabled due to plan limitations.
        Default Cloudflare protections are active.

        Secrets Management

        Secrets are never stored in plaintext inside the repository.

        Implemented Strategy

        This project is designed to integrate with Google Secret Manager using
        Workload Identity, which is the recommended and secure approach for
        GKE Autopilot.

###  Design Overview

        Secrets are stored in Google Secret Manager

        Pods authenticate using Workload Identity

        Secrets are injected at runtime as:
            Environment variables
            Or mounted volumes

        No secrets are committed to Git

        Pod (Kubernetes Service Account)
        ↓ Workload Identity
        Google Service Account
        ↓
        Google Secret Manager


### Using Google Secret Manager avoids:

        Plaintext secrets in Git

        Manual secret rotation

        Configuration drift across clusters

        This approach scales naturally across environments and regions.

###  Infrastructure as Code (IaC)
        Terraform

        Remote backend (GCS)

Modular structure:

        Network

        GKE

        Environment-based (staging - prod)

        Designed for multi-cluster / multi-region

        Kubernetes

        GKE Autopilot (managed operations)

        GKE Manually managed

        Helm for application deployment

        GitOps-compatible structure

### Observability (By Default)
        Active Stack

        Google Cloud Monitoring

        Google Cloud Logging

        Unified dashboards:

        API latency

        Error rates

        Pod health

        Alerting supported

        Grafana


## Multi-Cluster Strategy

This implementation runs two clusters running in different regions:
stagging-cluster = us-central1
prod-cluster = us-east1

### Strategy

- Each cluster runs its own Gateway API and application stack.
- Traffic is routed at the edge using Cloudflare DNS:
  - Geo-based routing
  - Health-based failover
- Each cluster exposes a Google Cloud Load Balancer managed by Gateway API.
- No hard dependency exists between clusters.

### Benefits

- Independent deployments per cluster
- Failure isolation
- Horizontal scalability across regions
- Zero application changes required

 ### Deployment Instructions (From Scratch)

        Provision infrastructure using Terraform

        Configure Artifact Registry

        Push application code to GitHub

        Cloud Build trigger executes CI/CD

        Application is deployed automatically to GKE


