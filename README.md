# kubernetes-example-application

An example Kubernetes application

## Install mise

```bash
curl https://mise.run | sh
```

## Install dependencies

```bash
mise install
```

## Setup KinD

```bash
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
  - containerPort: 32443
    hostPort: 8443
    protocol: TCP
EOF
```

## Install Traefik

```bash
helm repo add traefik https://helm.traefik.io/traefik --force-update
helm upgrade --install traefik traefik/traefik -n traefik --create-namespace --set service.type=NodePort --set ports.websecure.nodePort=32443
```

## Install cert-manager

```bash
helm repo add jetstack https://charts.jetstack.io --force-update
helm upgrade --install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.18.0 --set crds.enabled=true
```

## Create a TLS certificate

```bash
cat <<EOF | kubectl apply -f -
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned-issuer
spec:
  selfSigned: {}
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: traefik-tls
  namespace: traefik
spec:
  secretName: traefik-tls
  privateKey:
    algorithm: RSA
    encoding: PKCS1
    size: 2048
  duration: 2160h
  renewBefore: 360h
  isCA: false
  usages:
    - server auth
    - client auth
  subject:
    organizations:
      - cert-manager
  commonName: traefik.kubernetes.local
  dnsNames:
    - traefik.kubernetes.local
    - "*.traefik.svc.cluster.local"
  emailAddresses:
    - gawbul@gmail.com
  issuerRef:
    name: selfsigned-issuer
    kind: ClusterIssuer
    group: cert-manager.io
EOF
```

## Create an image pull secret

**NB:** Ensure your token has repo read and package read permissions.

```bash
kubectl create secret docker-registry ghcr-image-pull-secret --docker-server=https://ghcr.io --docker-username=<REPLACE_WITH_GITHUB_USERNAME> --docker-password=<REPLACE_WITH_GITHUB_TOKEN> --docker-email=<REPLACE_WITH_GITHUB_EMAIL>
```

## Run application

```bash
skaffold run
```

## Set your hostname

```bash
echo "127.0.0.1 kubernetes.localhost" | sudo tee -a /etc/hosts
```

## Test it works

```bash
curl -k https://kubernetes.localhost:8443/kubernetes-example-application
```
