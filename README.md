# CampusFix deployment (FSG 13)

This Compose project pulls the published backend and frontend images and runs PostgreSQL. It binds the frontend to server loopback port 6013 so the FSG HTTPS reverse proxy can serve it at `https://fsg13.cpecmu.com`. The only local file you need to edit on the server is `.env`.

## Prepare `.env`

Copy `deploy.env.example` to `.env`, then set unique values for the database passwords and `JWT_SECRET`, along with the Google and CMU OAuth credentials. Use at least 32 random characters for the database passwords and JWT secret. `POSTGRES_APP_PASSWORD` must contain only letters and numbers because it is embedded in the PostgreSQL connection URL.

The defaults target `https://fsg13.cpecmu.com`. If the OAuth provider settings do not already include these URLs, register them exactly:

- Google authorized redirect URI: `https://fsg13.cpecmu.com/auth/google/callback`
- CMU OAuth redirect URI: `https://fsg13.cpecmu.com/api/auth/callback`

## Deploy on the server

Copy this deployment folder to the server. The existing HTTPS reverse proxy for `fsg13.cpecmu.com` must forward requests to `http://127.0.0.1:6013`; the Compose stack does not bind the host's shared ports 80 or 443. Then run:

```sh
docker compose config --quiet
docker compose pull
docker compose up -d
docker compose ps
docker compose logs -f backend
```

The frontend is reachable from the host only at `127.0.0.1:6013`; PostgreSQL is private to the Compose network. The reverse proxy handles public HTTPS and certificates.

The backend applies database migrations before starting. Check the application at `https://fsg13.cpecmu.com` and its database health at `https://fsg13.cpecmu.com/api/health`.

## Updating and stopping

```sh
docker compose pull
docker compose up -d
docker compose down
```

`docker compose down` preserves PostgreSQL data and uploads in named volumes. Do not run `docker compose down -v` unless you intend to delete them.

## Building and publishing a frontend image

The deploy compose file only pulls published images. To create a frontend image that accepts OAuth values from `.env` at container startup, use the build override from a checkout that also has the original frontend image available:

```sh
docker compose -f docker-compose.yml -f docker-compose.frontend-build.yml build frontend
docker compose -f docker-compose.yml -f docker-compose.frontend-build.yml push frontend
```
