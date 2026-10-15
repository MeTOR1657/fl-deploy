# g55 full-stack deployment

This Compose project runs the complete CampusFix application: PostgreSQL, the Express backend, and the Vite frontend served by Nginx. Keep `pf-front`, `pf-backend`, `pf-db`, and `pf-deploy` as sibling directories. The database uses the initialization script in `pf-deploy/_entrypoint`; the backend applies migrations before starting.

## First installation (PowerShell)

From this folder, copy the template once and fill in the real OAuth credentials:

```powershell
Copy-Item deploy.env.example .env
```

Set unique strong values for `POSTGRES_PASSWORD`, `POSTGRES_APP_PASSWORD`, and `JWT_SECRET` (at least 32 characters). Set Google and CMU client IDs/secrets. Keep secrets only in this deployment `.env` or the backend `.env`, never in frontend `VITE_*` variables or Git.

Register these exact callback URLs in the OAuth provider consoles:

- Google Web OAuth Authorized redirect URI: `http://localhost:6055/auth/google/callback`
- CMU OAuth redirect URI: `http://localhost:3000/api/auth/callback` (the frontend is also exposed on port 3000 for the registered CMU callback)

For a server deployment, replace `localhost` with the public HTTPS hostname and update `FRONTEND_URL`, `GOOGLE_REDIRECT_URI`, and `CMU_OAUTH_REDIRECT_URI` to match. Redirect URLs must match character for character. For Google OAuth testing mode, add the user accounts as test users.

Build and start all three services:

```powershell
docker compose up -d --build
docker compose ps
docker compose logs -f backend
```

Open `http://localhost:6055`. Check `http://localhost:6055/api/health` for `database: connected`. The backend container connects to database host `db:5432`; host tools can connect through `localhost:5432`.

## Updating and stopping

```powershell
docker compose up -d --build
docker compose down
```

`docker compose down` keeps the named `${PROJECT_NAME}-pf-data` volume. `docker compose down -v` deletes it and permanently removes database contents. Keep a database backup before removing the volume.

## Separate development services

See each repository README for running PostgreSQL, the backend, and frontend independently. Use the development callbacks there (`localhost:3001` for Google's backend callback and `localhost:5173` for CMU's frontend callback) and register those exact URLs with the providers.
