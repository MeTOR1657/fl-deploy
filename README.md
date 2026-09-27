# CampusFix deployment

This compose project builds the frontend and backend from sibling repositories and runs them with PostgreSQL:

- `../pf-front` — Vite production build served by Nginx on port 6000 inside the network.
- `../pf-backend` — Express API on port 3000; database migrations run before the API starts.
- `../pf-db` — PostgreSQL data model and schema source; `./_entrypoint` initializes the PostgreSQL application user.

## Deploy

Keep `pf-front`, `pf-backend`, `pf-db`, and `pf-deploy` as sibling directories. From `pf-deploy`, create `.env` from `deploy.env.example` if it does not already exist:

```powershell
Copy-Item deploy.env.example .env
```

Set strong values for `POSTGRES_PASSWORD`, `POSTGRES_APP_PASSWORD`, and `JWT_SECRET` in `.env`. `JWT_SECRET` must contain at least 32 characters. Then run:

```powershell
docker compose up -d --build
docker compose ps
```

For Google sign-in, set `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` in `.env`. In Google Cloud Console, add this exact **Authorized redirect URI** to the OAuth client:

```text
http://localhost:6055/auth/google/callback
```

If `FRONTEND_PORT` changes, update both `GOOGLE_REDIRECT_URI` in `.env` and the authorized redirect URI in Google Cloud Console to `http://localhost:<FRONTEND_PORT>/auth/google/callback`. Google OAuth cannot complete until the provider has that exact URI registered. If the consent screen is in testing mode, add the Google accounts you will use as test users.

Open `http://localhost:3000` (or the port configured by `FRONTEND_PORT`). The frontend sends API requests through Nginx to the backend on the private Compose network. PostgreSQL is available on the host at `POSTGRES_PORT`.

Follow startup with `docker compose logs -f backend` to confirm migrations finish and the API starts. To update after pulling changes, run `docker compose up -d --build` again.

Database contents persist in the `${PROJECT_NAME}-pf-data` volume. Stop the services with `docker compose down`; this keeps the volume. Removing the volume deletes the database data.
