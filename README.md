# Nginx SSL Gateway for Supabase Kong

This repository runs an Nginx reverse proxy with SSL termination in front of an already-running Kong instance from a Supabase local stack.

## What it does

- terminates TLS in Nginx
- proxies all traffic to Kong on the shared Docker network
- uses certificates from an external host path
- reloads Nginx automatically when cert files change
- is ready for Portainer stack deployment
- keeps future multi-tenant files in place, but commented out

## Project structure

```text
.
├── .env.example
├── .gitattributes
├── .github/
│   └── workflows/
│       └── deploy-portainer.yml
├── .gitignore
├── docker-compose.yml
├── README.md
└── nginx/
    ├── nginx.conf
    ├── start.sh
    └── templates/
        └── conf.d/
            ├── 00-default.conf.template
            ├── 10-main.conf.template
            └── 20-tenant1.conf.template
```
## Notes on ```nginx.conf```
Must handle 'Access-Control-Allow-Origin', see example.

## Configuration

Copy `.env.example` to `.env` and adjust values.

```env
SERVICE_NETWORK=supabase_default
SSL_PORT=8443
SSL_CERTS_PATH=/home/docker/certs

KONG_UPSTREAM=kong:8000

CERT_FILE=/etc/nginx/certs/fullchain.pem
KEY_FILE=/etc/nginx/certs/privkey.pem
CERT_CHECK_INTERVAL=60
```

## Certificate expectations

The active config expects these files on the host:

```text
/home/docker/certs/fullchain.pem
/home/docker/certs/privkey.pem
```

They are mounted into the container here:

```text
/etc/nginx/certs/
```

If your filenames differ, change `CERT_FILE` and `KEY_FILE` in `.env`.

## Automatic certificate reload

The startup script renders the Nginx templates, starts Nginx, then checks the cert and key modification times every `CERT_CHECK_INTERVAL` seconds.

When either file changes it:

1. runs `nginx -t`
2. reloads Nginx with `nginx -s reload` if config is valid

That means cert renewal does not require a container restart.

## Portainer deployment

### Option A: Web editor stack

Use this when you want to paste the compose directly into Portainer.

1. Create a new stack in Portainer.
2. Paste the contents of `docker-compose.yml`.
3. Make sure the files from the `nginx/` directory are available on the target host and mounted with the same relative paths, or switch to a Git-based stack instead.
4. Define the environment variables from `.env.example` inside Portainer.
5. Deploy the stack.

For this repo, a Git-based stack is usually easier because it keeps the compose and Nginx files together.

### Option B: Git repository stack

1. Push this repository to GitHub.
2. In Portainer, create a new stack.
3. Choose the repository deployment option.
4. Point Portainer to the repo URL.
5. Set the compose path to `docker-compose.yml`.
6. Add the required environment variables in Portainer:
   - `SERVICE_NETWORK`
   - `SSL_PORT`
   - `SSL_CERTS_PATH`
   - `KONG_UPSTREAM`
   - `CERT_FILE`
   - `KEY_FILE`
   - `CERT_CHECK_INTERVAL`
7. Deploy the stack.

### Notes for Portainer

- `SERVICE_NETWORK` must already exist because this compose uses an external network.
- The repo files should be checked out on the Portainer side if you use Git deployment.
- The cert path must exist on the Docker host running the container.
- This stack does not start Kong. It only proxies to an existing Kong instance.

## GitHub Actions auto-deploy

This repo includes `.github/workflows/deploy-portainer.yml`.

It triggers a Portainer stack webhook when you push to `main` or run the workflow manually.

### Set up the webhook

1. Open your stack in Portainer.
2. Enable stack webhook.
3. Copy the webhook URL.

### Add the GitHub secret

In GitHub repository settings, add this secret:

- `PORTAINER_WEBHOOK_URL`

After that, every push to `main` will ask Portainer to redeploy the stack.

## Windows notes

If you build this repo on Windows and deploy to Linux:

- keep shell files with LF line endings
- do not rely on executable bits from Windows

This repo handles that by:
- forcing LF with `.gitattributes`
- running `chmod +x /start.sh && /start.sh` inside the container

## Future multi-tenant support

The repo already contains commented templates for later expansion:

- `00-default.conf.template`
- `20-tenant1.conf.template`

You can enable them later by uncommenting the template blocks and corresponding environment variables in the compose and `.env`.

## Basic flow

```text
Client -> Nginx (TLS) -> Kong -> Supabase services
```
