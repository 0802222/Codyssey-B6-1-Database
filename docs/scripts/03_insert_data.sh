#!/usr/bin/env bash
set -euo pipefail

DB_NAME="${1:?DB_NAME is required}"
PROJECT_DIR="${2:?PROJECT_DIR is required}"
DATA_FILE="${PROJECT_DIR}/docs/sql/data.sql"
SCRIPT_NAME="$(basename "$0" .sh)"

log() {
  local level="$1"
  shift
  echo "[${SCRIPT_NAME}][${level}] $*"
}

if [[ ! -f "${DATA_FILE}" ]]; then
  echo "[ERROR] data file not found: ${DATA_FILE}" >&2
  exit 12
fi

log "INFO" "insert sample data into ${DB_NAME}"
sudo mysql -u root "${DB_NAME}" < "${DATA_FILE}"

log "DONE" "sample data inserted"