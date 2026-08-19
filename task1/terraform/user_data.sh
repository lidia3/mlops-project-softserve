#!/bin/bash

set -e

echo "===== UPDATE SYSTEM ====="
apt-get update -y

echo "===== INSTALL DEPENDENCIES ====="
apt-get install -y \
  ca-certificates \
  curl \
  python3 \
  python3-venv \
  python3-pip \
  git

echo "===== INSTALL DOCKER ====="

install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc

chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  > /etc/apt/sources.list.d/docker.list

apt-get update -y

apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

echo "===== ENABLE DOCKER ====="

systemctl enable docker
systemctl start docker

usermod -aG docker ubuntu

echo "===== CREATE PROJECT DIRECTORY ====="

mkdir -p /home/ubuntu/mlops-churn/{src,configs,tests,models,notebooks,mlflow,pipeline}

chown -R ubuntu:ubuntu /home/ubuntu/mlops-churn

echo "===== CREATE PYTHON VENV ====="

sudo -u ubuntu python3 -m venv /home/ubuntu/mlops-venv

sudo -u ubuntu /home/ubuntu/mlops-venv/bin/pip install --upgrade pip

sudo -u ubuntu /home/ubuntu/mlops-venv/bin/pip install \
  mlflow \
  scikit-learn \
  xgboost \
  pandas \
  numpy

echo "===== INSTALLATION COMPLETE ====="

docker --version
docker compose version
python3 --version
