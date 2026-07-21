#!/usr/bin/env bash
set -euo pipefail

DB_NAME="${1:?DB_NAME is required}"
PROJECT_DIR="${2:?PROJECT_DIR is required}"
SCHEMA_FILE="${PROJECT_DIR}/docs/sql/schema.sql"

if [[ ! -f "${SCHEMA_FILE}" ]]; then
  echo "[ERROR] schema file not found: ${SCHEMA_FILE}" >&2
  exit 11
fi

echo "[INFO] reset database: ${DB_NAME}"
sudo mysql <<SQL
DROP DATABASE IF EXISTS \`${DB_NAME}\`;
CREATE DATABASE \`${DB_NAME}\`;
USE \`${DB_NAME}\`;
SOURCE ${SCHEMA_FILE};
SQL

echo "[INFO] verify tables"
sudo mysql -u root "${DB_NAME}" -e "SHOW TABLES;"

echo "[INFO] schema created"