# SwingBig.Band

A MkDocs Material site for the Manawatū Jazz Club Big Swing Band.

This is the source repository for [swingbig.band](https://swingbig.band/).
GitHub Actions validates and deploys the MkDocs site from `main` to GitHub Pages.

## Run with Docker Compose

```bash
docker compose -f compose.yaml up
```

Open <http://127.0.0.1:8001/>.

To use a different host port:

```bash
SWINGBIG_PORT=8080 docker compose -f compose.yaml up
```

## GitHub Pages deployment

The `validate.yml` workflow strictly builds pushes and pull requests. The
`pages.yml` workflow builds and deploys every push to `main` using GitHub Pages.

CMS changes can be pushed to the `cms-updates` branch. The
`cms-content-pr.yml` workflow opens or updates a pull request into protected
`main`; review and validation happen before deployment.

## Deploy with the Script

```bash
cp example.env .env
$EDITOR .env
chmod +x scripts/deploy.sh
./scripts/deploy.sh --deploy
```

The script runs a strict local build and pushes `main`; the push triggers the
GitHub Pages workflow. `--deploy` explicitly overrides the safe `DRY_RUN=true`
default in `.env`. Run `./scripts/deploy.sh --dry-run` to build without pushing.

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
