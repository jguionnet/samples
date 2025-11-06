# KubeVela Power Demo - KubeCon NA 2025

This demo showcases the power and simplicity of KubeVela's unified application delivery model compared to traditional approaches.

## What's Included

### Sample Application
A Python Flask + boto3 Product Catalog API that stores product images in S3:
- REST API endpoints for product management
- S3 integration for image storage
- Health and readiness checks
- Containerized with security best practices

### Two Complete Implementations

#### 1. Traditional Approach (`/comparison/traditional/`)
The conventional way using multiple tools:
- **Terraform** (4 files, 209 lines) - Infrastructure as Code (one-time)
- **Kubernetes Manifests** (5 files, 190 lines) - Application deployment (per-app)
- **GitHub Actions** (1 file, 249 lines) - CI/CD pipeline (per-app)
- **Total**: 10 files, ~648 lines (209 one-time + 439 per-app)

#### 2. KubeVela Approach (`/kubevela/`)
The modern unified approach:
- **Crossplane Components** (2 files, 193 lines) - Infrastructure definition (one-time platform setup)
- **ComponentDefinition** (1 file, 76 lines) - Reusable S3 component (one-time platform setup)
- **Application** (1 file, 171 lines) - Complete application with workflow (per-app)
- **Total**: 4 files, ~440 lines in 1 unified model

## Quick Start

### Prerequisites

Run the environment setup notebook to create the complete demo environment:

```bash
# Run the Jupyter notebook to set up:
# - k3d cluster with local registry
# - Crossplane with AWS provider
# - KubeVela
# - AWS credentials configuration

jupyter notebook 00_Env-setup.ipynb
```

See `00_Env-setup.ipynb` for detailed setup instructions.

### Demo Flow

#### Step 1: Build the Application

```bash
cd app

# Build and push Docker image to local registry
DOCKER_BUILDKIT=0 docker build -t product-catalog-api:v1.0.0 .
docker tag product-catalog-api:v1.0.0 localhost:5000/product-catalog-api:v1.0.0
docker push localhost:5000/product-catalog-api:v1.0.0
```

#### Step 2: Show Traditional Approach (The Pain)

```bash
cd comparison/traditional

# Show the complexity: 11 files across 3 tools
ls terraform/ k8s/ .github/workflows/

# Highlight key files
cat terraform/main.tf              # 97 lines for S3 + IAM
cat k8s/deployment.yaml            # 102 lines with security, resources
cat .github/workflows/deploy.yml   # 210 lines for multi-stage pipeline
```

**Key Pain Points:**
- Three different tools (Terraform, K8s, GitHub Actions)
- Manual coordination between infrastructure and application
- Scattered configuration across 11 files

#### Step 3: Show KubeVela Approach (The Power)

```bash
cd kubevela

# Install Crossplane S3 component (one-time platform setup)
kubectl apply -f crossplane/s3/xrd.yaml
kubectl apply -f crossplane/s3/composition.yaml
vela def apply components/s3/s3-bucket.cue

# Setup AWS credentials in application namespaces
cd .. && ./scripts/setup-aws-credentials.sh && cd kubevela

# Show the single application file
cat application.yaml  # Everything in one place!

# Deploy the application
vela up -f application.yaml

# Check status - workflow deploys to dev and suspends
vela status product-catalog

# View dev deployment
kubectl get pods -n dev
kubectl get hpa -n dev
```

**Workflow Management:**

```bash
# Workflow is now suspended at approval-staging
# Resume to deploy to staging
vela workflow resume product-catalog
sleep 30

# Check staging deployment
kubectl get pods -n staging
kubectl get hpa -n staging
vela status product-catalog

# Workflow is now suspended at approval-prod
# Resume to deploy to production (wait 1 minute for full deployment)
vela workflow resume product-catalog
sleep 60

# Check production deployment
kubectl get pods -n prod
kubectl get hpa -n prod

# Final status - all three environments deployed
vela status product-catalog
```

**Key Advantages to Highlight:**
- Single unified application definition
- Infrastructure as components (S3 bucket)
- Built-in traits (HPA, SecurityContext, Resources)
- Built-in workflow (dev → staging → prod)
- Policy-based environment overrides
- Automatic state management

#### Step 4: Show Environment-Specific Configuration

```bash
# Compare HPA configurations across environments
echo "Dev HPA: min=1, max=3"
echo "Staging HPA: min=2, max=5"
echo "Production HPA: min=3, max=10"

kubectl get hpa -n dev
kubectl get hpa -n staging
kubectl get hpa -n prod
```

## Key Comparison Metrics

### One-Time Platform Setup

| Metric | Traditional | KubeVela | Notes |
|--------|-------------|----------|-------|
| Infrastructure Setup | 209 lines (4 Terraform files) | 269 lines (3 files) | Both are one-time setup |
| State Management | Terraform state files | None | KubeVela uses K8s as state store |

### Per-Application Deployment

| Metric | Traditional | KubeVela | Improvement |
|--------|-------------|----------|-------------|
| Files | 6 | 1 | 83% fewer |
| Lines of Code | ~439 | ~171 | 61% fewer |
| Tools | 2 (K8s, GHA) | 1 (KubeVela) | 50% fewer |
| Configuration Overhead | K8s manifests + CI/CD | Single application.yaml | Unified |
| Workflow | External (249 lines GHA) | Built-in | No external CI/CD |
| Multi-Environment | Duplicate pipeline stages | Policy overrides | DRY principle |

## Demo Talking Points

### 1. Per-Application Simplification
- **Traditional**: 6 files, 439 lines per app (K8s manifests + GitHub Actions)
- **KubeVela**: 1 file, 171 lines per app (application.yaml only)
- **Result**: 83% fewer files, 61% less code per application

### 2. Infrastructure as Reusable Components
- **Traditional**: 209 lines of Terraform (one-time, but requires state management)
- **KubeVela**: 269 lines (one-time platform setup, no state files)
- **Result**: Infrastructure becomes reusable components, referenced in 6 lines per app

### 3. Unified Application Model
- **Traditional**: Separate K8s manifests (190 lines) + CI/CD pipeline (249 lines)
- **KubeVela**: Single application.yaml with built-in workflow
- **Result**: Everything in one place - app, infrastructure, and deployment workflow

### 4. No External CI/CD Needed
- **Traditional**: 249-line GitHub Actions workflow per app
- **KubeVela**: Built-in multi-environment workflow with approval gates
- **Result**: Progressive delivery without external orchestration

### 5. Multi-Environment Made Easy
- **Traditional**: Duplicate pipeline stages or complex conditionals
- **KubeVela**: Policy-based overrides (dev: 1-3 pods, staging: 2-5, prod: 3-10)
- **Result**: Single source of truth, environment-specific configs via policies

## Documentation

- [DEMO_PLAN.md](DEMO_PLAN.md) - Complete demo plan and architecture
- [docs/COMPARISON.md](docs/COMPARISON.md) - Detailed side-by-side comparison
- [app/README.md](app/README.md) - Application documentation

## Troubleshooting

### Workflow Resume

Always use the application name, not the step name:
```bash
# ✓ CORRECT
vela workflow resume product-catalog

# ✗ WRONG
vela workflow resume approval-staging
```

### AWS Credentials

If pods fail with `NoCredentialsError`, run:
```bash
./scripts/setup-aws-credentials.sh
```

### Image Pull Issues

If pods are in `ImagePullBackOff`:
```bash
# Verify registry and image
k3d registry list
curl http://localhost:5000/v2/_catalog

# Rebuild and push
cd app
DOCKER_BUILDKIT=0 docker build -t product-catalog-api:v1.0.0 .
docker tag product-catalog-api:v1.0.0 localhost:5000/product-catalog-api:v1.0.0
docker push localhost:5000/product-catalog-api:v1.0.0
```

## Cleanup

```bash
# Delete KubeVela application
vela delete product-catalog

# Delete application namespaces
kubectl delete namespace dev staging prod

# Or for traditional approach
cd comparison/traditional
kubectl delete -f k8s/
terraform destroy
```

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│              KubeVela Application                       │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  Components:                                            │
│    ├─ product-api (webservice)                         │
│    │   - Flask + boto3                                 │
│    │   - Port 8080                                     │
│    └─ product-images (simple-s3)                       │
│        - S3 bucket for images                          │
│                                                          │
│  Traits:                                                │
│    ├─ hpa (min:2, max:10)                             │
│    ├─ security-context (non-root, read-only FS)       │
│    └─ resource (CPU/memory limits)                     │
│                                                          │
│  Workflow:                                              │
│    ├─ deploy-dev ──> test-dev ───┐                    │
│    ├─ approval-staging (suspend) │                     │
│    ├─ deploy-staging ──> verify  │                     │
│    ├─ approval-prod (suspend)    │                     │
│    └─ deploy-prod ──> verify     │                     │
│                                                          │
│  Policy:                                                │
│    ├─ multi-env (dev/staging/prod)                    │
│    └─ environment-specific overrides                   │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

## Success Metrics

After this demo, the audience will understand:

1. ✅ KubeVela reduces complexity (64% fewer files)
2. ✅ Infrastructure can be treated as application components
3. ✅ Workflows eliminate external CI/CD complexity
4. ✅ Traits provide reusable cross-cutting concerns
5. ✅ Developers focus on business value, not infrastructure details
6. ✅ Platform teams can provide opinionated, secure defaults

## Contact

For questions or feedback about this demo, please open an issue in the repository.

## License

This demo is provided as-is for educational purposes.
