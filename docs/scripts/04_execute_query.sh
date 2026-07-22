#!/usr/bin/env bash
set -euo pipefail

DB_NAME="${1:?DB_NAME is required}"
PROJECT_DIR="${2:?PROJECT_DIR is required}"
QUERY_FILE="${PROJECT_DIR}/docs/sql/query.sql"
SCRIPT_NAME="$(basename "$0" .sh)"

log() {
  local level="$1"
  shift
  echo "[${SCRIPT_NAME}][${level}] $*"
}

if [[ ! -f "${QUERY_FILE}" ]]; then
  echo "[${SCRIPT_NAME}][ERROR] query file not found: ${QUERY_FILE}" >&2
  exit 13
fi

log "INFO" "execute queries in ${DB_NAME}"
sudo mysql -u root \
  --table \
  --column-names \
  "${DB_NAME}" < "${QUERY_FILE}"

log "DONE" "queries executed"