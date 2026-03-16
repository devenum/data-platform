# Superset
export FLASK_APP="superset.app:create_app()"
export SUPERSET_SECRET_KEY="$(openssl rand -base64 42)"
export SUPERSET_CONFIG_PATH=/superset_config.py
superset db upgrade
superset fab create-admin \
  --username admin \
  --firstname admin \
  --lastname admin \
  --email admin@admin.com
superset init
