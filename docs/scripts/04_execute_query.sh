#!/usr/bin/env bash
set -euo pipefail

DB_NAME="${1:?DB_NAME is required}"
PROJECT_DIR="${2:?PROJECT_DIR is required}"
QUERY_FILE="${PROJECT_DIR}/docs/sql/query.sql"

if [[ ! -f "${QUERY_FILE}" ]]; then
  echo "[ERROR] query file not found: ${QUERY_FILE}" >&2
  exit 13
fi

echo "[INFO] execute queries in ${DB_NAME}"
sudo mysql -u root \
  --table \
  --column-names \
  "${DB_NAME}" < "${QUERY_FILE}"

echo "[INFO] queries executed"