## Tests in ASUS GX 10
[![Docker](https://github.com/alarmed-ground/dgx-spark/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/alarmed-ground/dgx-spark/actions/workflows/docker-publish.yml)

## Kubernetes deployment

To deploy k8s, I have used `microk8s` offered by ubuntu for quick bring up and testing.

Steps involved to setup the environment is as follows

1. `sudo snap install microk8s --classic --channel=1.32`
2. To enable dashboard, `microk8s enable dashboard`
3. To get the secret of the dashboard, `microk8s kubectl describe secret -n kube-system microk8s-dashboard-token`
4. Add Prometheus helm charts for monitoring, `microk8s helm repo add prometheus-community https://prometheus-community.github.io/helm-charts`
5. Install Prometheus, `microk8s helm install prometheus prometheus-community/prometheus`
6. Configure NVIDIA CTK runtime, `sudo nvidia-ctk runtime configure --runtime=containerd`
7. Restart `containerd`, `sudo systemctl restart containerd`
8. Verify container runtime is properly configured at `cat /etc/containerd/config.toml`
9. Add NVIDIA GPU operator repositories, `microk8s helm repo add nvidia https://helm.ngc.nvidia.com/nvidia`
10. Install NVIDIA GPU Operator, `microk8s helm install --wait --generate-name  -n gpu-operator --create-namespace  nvidia/gpu-operator --version=v25.10.0`
11. Deploy vLLM using `vllm-sprak.yaml` (Make changes to API key, namespace and model to be loaded)

## Docker deployment

1. DGX OS is preconfigured with docker, NVIDIA CTK
2. If docker is not installed, follow these steps
```
sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1)
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
```
# Add the repository to Apt sources:
```
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
sudo apt update`
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```
3. With the `docker-compse.yaml` in the repository, will bring up all the necessary pods to serve the intrallm with  `docker compose up` command. Ensure the directories and models are in place before executing the command.
