# g55 full-stack deployment

This Compose project runs the complete CampusFix application: PostgreSQL, the Express backend, and the Vite frontend served by Nginx. Keep `fl-front`, `pf-backend`, `pf-db`, and `pf-deploy` as sibling directories. The database uses the initialization script in `pf-deploy/_entrypoint`; the backend applies migrations before starting.

## First installation (PowerShell)

From this folder, copy the template once and fill in the real OAuth credentials:

```powershell
Copy-Item deploy.env.example .env
```

Set unique strong values for `POSTGRES_PASSWORD`, `POSTGRES_APP_PASSWORD`, and `JWT_SECRET` (at least 32 characters). Set Google and CMU client IDs/secrets. Keep secrets only in this deployment `.env` or the backend `.env`, never in frontend `VITE_*` variables or Git.

Register these exact callback URLs in the OAuth provider consoles:

- Google Web OAuth Authorized redirect URI: `http://localhost:6013/auth/google/callback`
- CMU OAuth redirect URI: `http://localhost:6013/api/auth/callback` (the frontend callback uses port 6013)

For SSH tunnel access, keep the callback URLs on `localhost:6013`. For public access by domain, put an HTTPS reverse proxy in front of the loopback-bound frontend and update `FRONTEND_URL`, `GOOGLE_REDIRECT_URI`, and `CMU_OAUTH_REDIRECT_URI` to the public HTTPS URLs. Redirect URLs must match character for character. For Google OAuth testing mode, add the user accounts as test users.

Build and start all three services:

```powershell
docker compose up -d --build
docker compose ps
docker compose logs -f backend
```

Open `http://localhost:6013`. Check `http://localhost:6013/api/health` for `database: connected`. The frontend binds to server loopback port 6013, and PostgreSQL is private to the Compose network.

## Updating and stopping

```powershell
docker compose up -d --build
docker compose down
```

`docker compose down` keeps the named `${PROJECT_NAME}-pf-data` volume. `docker compose down -v` deletes it and permanently removes database contents. Keep a database backup before removing the volume.

## Deploy through SSH

On the server, clone or copy all four sibling repositories, configure `.env` from `deploy.env.example`, and set strong database passwords and a random JWT secret. Set the Google and CMU callback URLs to `http://localhost:6013/...` when accessing through a local SSH tunnel, then register the same URLs with each OAuth provider.

Start the stack on the server:

```bash
cd /path/to/pf-deploy
docker compose up -d --build
docker compose ps
```

From your computer, forward local port 6013 to the server. The SSH daemon port is 6013 as requested.

```bash
ssh -p 6013 -N -L 6013:127.0.0.1:6013 USER@SERVER
```

Open `http://localhost:6013`. The web service is bound to loopback, and the database is not published to the network.

## Separate development services

See each repository README for running PostgreSQL, the backend, and frontend independently. Use the development callbacks there (`localhost:3001` for Google's backend callback and `localhost:5173` for CMU's frontend callback) and register those exact URLs with the providers.
