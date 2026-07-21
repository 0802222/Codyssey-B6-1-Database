#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
DB_NAME="codyssey_mission_db"

echo "[INFO] install mysql"
bash "${SCRIPT_DIR}/01_install_mysql.sh"

echo "[INFO] create schema"
bash "${SCRIPT_DIR}/02_create_schema.sh" "${DB_NAME}" "${PROJECT_DIR}"

echo "[INFO] insert sample data"
bash "${SCRIPT_DIR}/03_insert_data.sh" "${DB_NAME}" "${PROJECT_DIR}"

echo "[INFO] execute core queries"
bash "${SCRIPT_DIR}/04_execute_query.sh" "${DB_NAME}" "${PROJECT_DIR}"

echo "[INFO] provisioning complete"