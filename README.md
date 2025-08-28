# DevOps Starter: GitHub → Jenkins → Docker → Kubernetes (k8s)

A tiny, production-style pipeline for **freshers** to practice real-world DevOps with
GitHub, Jenkins, Docker, and Kubernetes.

## What you get
- Minimal Flask API (`/` and `/health`)
- `Dockerfile` with a test stage and a production runtime stage
- `Jenkinsfile` (Declarative) that:
  - Builds & tests the image
  - Builds a runtime image
  - Pushes to a container registry (Docker Hub by default)
  - Deploys to Kubernetes and waits for rollout
- Kubernetes manifests (`k8s/deployment.yaml`, `k8s/service.yaml`)

---

## Prerequisites
- GitHub repo for this project
- Jenkins agent with **Docker** and **kubectl** installed
- A container registry account (e.g., **Docker Hub**)
- A Kubernetes cluster (**minikube** is perfect for local)
- Jenkins credentials configured:
  - `dockerhub-creds` — Username/Password credentials for Docker Hub
  - `kubeconfig` — Secret file credential containing kubeconfig for your cluster

---

## 1) Clone & push
```bash
git init
git remote add origin <YOUR_GITHUB_REPO_URL>
git add .
git commit -m "DevOps starter: GitHub->Jenkins->Docker->k8s"
git push -u origin main
```

## 2) Jenkins job (Multibranch or Pipeline)
- Point Jenkins to your GitHub repo so it picks up the `Jenkinsfile`.
- (Optional) Add a GitHub webhook to trigger builds on push.

### Required Jenkins Credentials
- **dockerhub-creds**: your Docker Hub login (Username with write access; Password or token)
- **kubeconfig**: upload your kubeconfig file (e.g., from `~/.kube/config`), name the credential `kubeconfig`

---

## 3) Configure environment in Jenkins (if needed)
You can keep default placeholders or edit the `Jenkinsfile`:
- `IMAGE_REPO`: set to `docker.io/<your-dockerhub-username>/devops-sample`
- `KUBE_NAMESPACE`: default `demo`

---

## 4) First local run (optional, for confidence)
### Build & run with Docker
```bash
docker build --target test -t devops-sample:test .
docker build -t devops-sample:local .
docker run -p 5000:5000 devops-sample:local
# Visit: http://localhost:5000/  and  http://localhost:5000/health
```

### Run on minikube (optional local k8s)
```bash
# Ensure your current kube context points to minikube
kubectl get nodes
kubectl create namespace demo || true

# Replace the image placeholder and apply manifests
export IMG=devops-sample:local
sed "s|IMAGE_PLACEHOLDER|$IMG|g" k8s/deployment.yaml | kubectl -n demo apply -f -
kubectl -n demo apply -f k8s/service.yaml

kubectl -n demo rollout status deploy/devops-sample
# Get a URL
minikube service devops-sample -n demo --url
```

---

## 5) Jenkins pipeline stages (what happens on CI/CD)
1. **Checkout**: Pulls code from GitHub
2. **Build & Test**: Builds an image that runs unit tests during the build (`--target test`)
3. **Build Image**: Builds the final runtime image
4. **Push Image**: Logs into Docker Hub and pushes `IMAGE_REPO:BUILD_NUMBER`
5. **Deploy to K8s**: Ensures namespace exists, applies manifests with the new image, and waits for rollout

---

## 6) Verify the deployment
```bash
kubectl -n demo get pods,svc
# If using minikube:
minikube service devops-sample -n demo --url
```

---

## 7) Clean up (optional)
```bash
kubectl delete namespace demo
```

---

## Troubleshooting Tips
- If `kubectl` commands fail in Jenkins, double-check the `kubeconfig` credential and the active context.
- If Docker push fails, confirm the credential ID and that `IMAGE_REPO` points to a repo you own.
- If the Service is `NodePort` on minikube, use `minikube service` to open it in a browser.
- Look at `kubectl describe pod <pod>` for container errors (image pull, port binding, etc.).
- Adjust resources in the Deployment if pods are evicted or stuck pending.
