# SwingBig.Band

A MkDocs Material blog site for a jazz big band.

This repository is the **private canonical content repository**. Markdown,
MkDocs configuration, source assets, and history stay private. A server-side
publisher builds it and replaces the contents of a separate public repository
with generated HTML/assets only.

## Run with Docker Compose

```bash
docker compose -f compose.yaml up
```

Open <http://127.0.0.1:8001/>.

To use a different host port:

```bash
SWINGBIG_PORT=8080 docker compose -f compose.yaml up
```

## Private validation

GitHub Actions strictly builds pushes and pull requests. It does not deploy this
private source repository to Pages.

CMS changes are pushed to the private `cms-updates` branch. The
`cms-content-pr.yml` workflow opens or updates a pull request into protected
`main`; review and validation happen before publication.

## Public deployment

The private CMS repository contains the production publisher. After private
`main` is approved, the server:

1. clones private `main` into a temporary directory;
2. runs `mkdocs build --strict`;
3. clones the public output repository;
4. deletes its previous generated files;
5. copies only the generated site, `.nojekyll`, and optional `CNAME`;
6. pushes public `main` using a one-hour GitHub App installation token.

Configure GitHub Pages in the public output repository to deploy branch `main`,
folder `/ (root)`. Complete server, GitHub App, security, backup, and recovery
instructions are in `docs/PRODUCTION_DEPLOYMENT.md` of the private CMS repository.

## Deploy with the Script

```bash
cp example.env .env
$EDITOR .env
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

This script validates and pushes private source `main`. It never writes generated
output into this repository or directly to Pages. Keep `DRY_RUN=true` until the
private remote and `SITE_URL` are correct.

## Build Locally

```bash
python3 -m pip install --target .deps -r requirements.txt
PYTHONPATH=.deps python3 -m mkdocs build --strict
```

## Serve Locally

```bash
./serve.sh
```

The script creates or reuses `.deps`, installs changed requirements, and starts
the live-reloading site at <http://127.0.0.1:8001/>. Override the listener when
needed:

```bash
SWINGBIG_SERVE_ADDR=0.0.0.0:8080 ./serve.sh
```

Set `SWINGBIG_REFRESH_DEPS=true` to force a dependency refresh. Additional
arguments are passed to `mkdocs serve`.
