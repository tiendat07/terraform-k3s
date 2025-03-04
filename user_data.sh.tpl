#!/bin/bash
set -x

apt-get update
apt-get install -y curl
curl -sfL https://get.k3s.io | K3S_URL=https://localhost:6443 K3S_TOKEN=${k3s_token} sh -s - agent