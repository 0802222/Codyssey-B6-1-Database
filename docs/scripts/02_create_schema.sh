#!/usr/bin/env bash
set -euo pipefail

DB_NAME="${1:?DB_NAME is required}"
PROJECT_DIR="${2:?PROJECT_DIR is required}"
SCHEMA_FILE="${PROJECT_DIR}/docs/sql/schema.sql"
SCRIPT_NAME="$(basename "$0" .sh)"

log() {
  local level="$1"
  shift
  echo "[${SCRIPT_NAME}][${level}] $*"
}

if [[ ! -f "${SCHEMA_FILE}" ]]; then
  echo "[${SCRIPT_NAME}][ERROR] schema file not found: ${SCHEMA_FILE}" >&2
  exit 11
fi

log "INFO" "create database: ${DB_NAME}"
sudo mysql <<SQL
DROP DATABASE IF EXISTS \`${DB_NAME}\`;
CREATE DATABASE \`${DB_NAME}\`;
USE \`${DB_NAME}\`;
SOURCE ${SCHEMA_FILE};
SQL

sudo mysql -u root "${DB_NAME}" -e "SHOW TABLES;"

log "DONE" "schema created"