#!/usr/bin/env bash
set -euo pipefail

echo "[INFO] apt update"
sudo apt update

echo "[INFO] install mysql server"
sudo DEBIAN_FRONTEND=noninteractive apt install -y mysql-server

echo "[INFO] start mysql service"
sudo systemctl start mysql

echo "[INFO] enable mysql service"
sudo systemctl enable mysql

echo "[INFO] mysql status"
sudo systemctl --no-pager --full status mysql || true