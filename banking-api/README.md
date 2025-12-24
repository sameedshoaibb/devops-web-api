# Banking API: Image Building Process and Implementation Guide

## Build Process

### Overview
Started with building the Docker image from the source code. During the build process, several issues were identified and addressed to optimize the container image.

### Problems Identified & Solutions

1. **Base Image Optimization** - Using `node:20.19.6-alpine` for reproducible, secure, and stable builds
2. **Offline Install Issue** - `pnpm install --offline` requires full store (bad practice); resolved in build stages
3. **File Selection** - Now copying only specific files required for the project
4. **Build vs Runtime** - Separated build and run stages with appropriate base images
5. **Dev Dependencies** - Used `pnpm prune --prod` to remove development dependencies from final image
6. **Security** - Changed from root user to unprivileged `appuser`
7. **Layer Optimization** - Reduced unnecessary layers for faster build times
8. **Dependency Caching** - Multiple copy commands cache dependencies independently
9. **Build Context** - Added `.dockerignore` to reduce build context

### Image Statistics

- **Before**: ~300MB
- **After**: ~201MB (25% smaller)
- **Base**: `node:20.19.6-alpine`

### Testing

All the 6 API endpoints are functional:
- User endpoints: GET, POST, PUT, DELETE
- Admin endpoints: GET accounts, DELETE account
- Note: Delete API only works if account balance is zero

### Build Commands

```bash
docker build -t banking-api:v1.0.0 .
docker run -dit -p 4000:4000 banking-api:v1.0.0
docker exec -it <container_id> /bin/sh
```

---

## Deployment Script

The `deploy.sh` in the `scripts/deploy` folder now supports:
- Multiple environments: dev, staging, production
- Enhanced testing and verification capabilities

---

## Design Improvements

### Dockerfile Optimizations

- **25% smaller image** - Multi-stage build removes build tools and temporary files
- **Pinned Node.js version** - `node:20.19.6-alpine` for reproducible builds with zero known vulnerabilities
- **Better layer caching** - Dependencies installed before source code for faster rebuilds
- **Non-root execution** - Container runs under `appuser` for improved security
- **Clean final image** - TypeScript, Prettier, and test frameworks removed
- **pnpm with Corepack** - Faster installs and deterministic package management
- **Clear documentation** - Comments explain each part of the Dockerfile
- **Optimized build context** - `.dockerignore` excludes unnecessary files

---

## Configuration Management

**Current Approach**: Using existing config file for the secrets since the application code doesn't support environment variables.

**Recommendation**: Implement environment variable support in the application code for better cloud-native practices. Application code needs to be modified therefore I didn't tried.

---

## Getting Started

### Prerequisites

- Docker
- Kubernetes cluster (kubectl configured)
- Helm 3.x
- Local build (no container registry used)

### Step 1: Build Docker Image

```bash
cd banking-api
docker build -t banking-api:v1.0.0 .
```

### Step 2: Create Kubernetes Secret

```bash
kubectl create secret generic banking-api-key \
  --from-literal=adminApiKey=sameed \
  -n banking-api
```

**Note:** Secrets are created outside of Helm for security reasons. They are injected into the app at runtime via an init container. For more details, see `helm/README.md`

### Step 3: Deploy Application

Deploy to your desired environment:

**Production:**
```bash
./scripts/deploy/deploy.sh prod
```

**Development:**
```bash
./scripts/deploy/deploy.sh dev
```

**Staging:**
```bash
./scripts/deploy/deploy.sh staging
```

### Step 4: Port Forwarding (for local testing)

```bash
kubectl port-forward -n banking-api svc/banking-api 8181:80 &
```

**Note:** Port forwarding is used for local testing. Ingress was avoided to prevent requiring `/etc/hosts` file modifications with admin privileges.


## Deployment Verification

### Expected Kubernetes Resources

After successful deployment, verify with:
```bash
kubectl get all -n banking-api
```

**Expected Output:**
```
pod/banking-api-5ff446d8ff-8zphv               2/2     Running     0          27m
pod/banking-api-5ff446d8ff-snpqv               2/2     Running     0          27m
pod/banking-api-balance-check-29443586-7gt8t   0/1     Completed   0          7s

NAME                  TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)           AGE
service/banking-api   ClusterIP   10.99.250.178   <none>        80/TCP,4000/TCP   27m

NAME                          READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/banking-api   2/2     2            2           27m

NAME                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/banking-api-5ff446d8ff   2         2         2       27m

NAME                                              REFERENCE                TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/banking-api   Deployment/banking-api   <unknown>/70%   2         5         2          27m

NAME                                      SCHEDULE      SUSPEND   ACTIVE   LAST SCHEDULE   AGE
cronjob.batch/banking-api-balance-check   */1 * * * *   False     0        7s              27m

NAME                                           COMPLETIONS   DURATION   AGE
job.batch/banking-api-balance-check-29443559   0/1           27m        27m
job.batch/banking-api-balance-check-29443584   1/1           4s         2m7s
job.batch/banking-api-balance-check-29443585   1/1           4s         67s
job.batch/banking-api-balance-check-29443586   1/1           4s         7s
```

---

## API Testing

### Endpoint 1: Health Check (Ping)

```bash
curl -s http://localhost:8181/ping
```
**Note:** We are using nginx reverse proxy to route the request to our backend-api.

### Endpoint 2: Create Account (Admin Only)

```bash
curl -s -X POST http://localhost:8181/admin/account \
  -H "x-api-key: sameed" \
  -H "Content-Type: application/json" \
  -d '{"accountId":"test1","password":"pass123"}'
```

**Note:** Admin API key is injected during runtime from the Kubernetes secret.

### Endpoint 3: Get Account Info

```bash
curl -s -X POST http://localhost:8181/account/test1/info \
  -H "Content-Type: application/json" \
  -d '{"password":"pass123"}'
```

### Endpoint 4: Deposit Funds

```bash
curl -s -X POST http://localhost:8181/account/test1/deposit \
  -H "Content-Type: application/json" \
  -d '{"password":"pass123","amount":5000}'
```

### Endpoint 5: Withdraw Funds

```bash
curl -s -X POST http://localhost:8181/account/test1/withdraw \
  -H "Content-Type: application/json" \
  -d '{"password":"pass123","amount":41500}'
```

### Endpoint 6: List All Accounts (Admin Only)

```bash
curl -s -H "x-api-key: sameed" http://localhost:8181/admin/accounts
```

**Note:** Delete API only works if account balance is zero.

---

## DevOps Challenge

After running all the endpoints, we will have the data to see the results.

### 1. Nginx Proxy - Slow Request Logging

View slow requests (requests taking > 0.001 seconds):

```bash
kubectl exec -n banking-api deploy/banking-api -c nginx-proxy -- tail -5 /var/log/nginx/slow_requests.log
```

**Implementation Details:**
- Threshold: 0.001 seconds (1ms)
- Requests exceeding this threshold are logged with timing information
- This threshold was chosen because I was not able to replicate 1 sec as a slow requests in a test environment

**Sample Output:**
```
[SLOW_REQUEST] [25/Dec/2025:16:43:38 +0000] Remote: 127.0.0.1 | Request: POST /account/test1/withdraw HTTP/1.1 | Status: 200 | Time: 0.002 s
[SLOW_REQUEST] [25/Dec/2025:16:43:39 +0000] Remote: 127.0.0.1 | Request: POST /account/test1/deposit HTTP/1.1 | Status: 200 | Time: 0.002 s
[SLOW_REQUEST] [25/Dec/2025:16:43:40 +0000] Remote: 127.0.0.1 | Request: POST /account/test1/withdraw HTTP/1.1 | Status: 200 | Time: 0.002 s
[SLOW_REQUEST] [25/Dec/2025:16:43:42 +0000] Remote: 127.0.0.1 | Request: POST /account/test1/withdraw HTTP/1.1 | Status: 200 | Time: 0.002 s
[SLOW_REQUEST] [25/Dec/2025:16:43:47 +0000] Remote: 127.0.0.1 | Request: GET /admin/accounts HTTP/1.1 | Status: 200 | Time: 0.002 s
```

### 2. CronJob - Balance Check Status

The CronJob runs every minute to check for accounts with critically low balance (threshold: -10,000).

**View CronJob logs:**
```bash
kubectl logs -n banking-api -l job-type=cronjob --tail=10
```

**Sample Output:**
```
[2025-12/25 16:43:01] Starting balance check (threshold: -10000)
OK: No accounts found with critically low balance
[2025-12/25 16:44:00] Starting balance check (threshold: -10000)
ALERT: One or more accounts have a very low balance (below -10000)
Alert email: alert@example.org
[2025-12/25 16:45:00] Starting balance check (threshold: -10000)
ALERT: One or more accounts have a very low balance (below -10000)
Alert email: alert@example.org
```

---

## Additional Deployment Commands

**Preview changes before deploying:**
```bash
./scripts/deploy/deploy.sh prod diff
```

**Validate Helm chart:**
```bash
./scripts/deploy/deploy.sh prod lint
```

**Generate manifest without deploying:**
```bash
./scripts/deploy/deploy.sh prod template
```

**Uninstall deployment:**
```bash
./scripts/deploy/deploy.sh prod uninstall
```
