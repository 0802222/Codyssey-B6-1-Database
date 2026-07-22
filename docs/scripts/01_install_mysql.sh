#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="$(basename "$0" .sh)"

log() {
  local level="$1"
  shift
  echo "[${SCRIPT_NAME}][${level}] $*"
}

log "INFO" "apt-get update"
sudo apt-get update -q

log "INFO" "install mysql server"
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -q mysql-server

log "INFO" "start mysql service"
sudo systemctl start mysql

log "INFO" "check mysql running status"
if systemctl is-active --quiet mysql; then
  log "DONE" "mysql is running"
else
  log "ERROR" "mysql is not running"
  exit 1
fi

log "DONE" "mysql installation completed"