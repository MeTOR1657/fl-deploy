#!/bin/bash
set -euo pipefail

echo "Initializing PostgreSQL database and application role."

psql \
  --set=ON_ERROR_STOP=1 \
  --username "$POSTGRES_USER" \
  --dbname "$POSTGRES_DB" \
  --set=POSTGRES_DB="$POSTGRES_DB" \
  --set=app_user="$POSTGRES_APP_USER" \
  --set=app_password="$POSTGRES_APP_PASSWORD" <<'EOSQL'
REVOKE CONNECT ON DATABASE :"POSTGRES_DB" FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM PUBLIC;

SELECT format('CREATE ROLE %I LOGIN PASSWORD %L', :'app_user', :'app_password')
WHERE NOT EXISTS (
  SELECT 1 FROM pg_catalog.pg_roles WHERE rolname = :'app_user'
)
\gexec

SELECT format('ALTER ROLE %I WITH LOGIN PASSWORD %L', :'app_user', :'app_password')
\gexec

CREATE SCHEMA IF NOT EXISTS drizzle AUTHORIZATION :"app_user";
ALTER SCHEMA public OWNER TO :"app_user";
ALTER DATABASE :"POSTGRES_DB" OWNER TO :"app_user";
GRANT ALL ON DATABASE :"POSTGRES_DB" TO :"app_user";
GRANT ALL ON SCHEMA public TO :"app_user";
GRANT ALL ON SCHEMA drizzle TO :"app_user";

ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO :"app_user";
ALTER DEFAULT PRIVILEGES IN SCHEMA drizzle GRANT ALL ON TABLES TO :"app_user";
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO :"app_user";
ALTER DEFAULT PRIVILEGES IN SCHEMA drizzle GRANT ALL ON SEQUENCES TO :"app_user";
EOSQL
