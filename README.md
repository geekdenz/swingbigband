# SwingBig.Band

A MkDocs Material blog site for a jazz big band.

## Run with Docker Compose

```bash
docker compose -f compose.yaml up
```

Open <http://127.0.0.1:8001/>.

To use a different host port:

```bash
SWINGBIG_PORT=8080 docker compose -f compose.yaml up
```

## Deploy to GitHub Pages

This repository includes a GitHub Actions workflow at `.github/workflows/pages.yml`.

1. Push the repository to GitHub.
2. In GitHub, open **Settings > Pages**.
3. Set **Build and deployment > Source** to **GitHub Actions**.
4. Push to the `main` branch, or run the `Deploy GitHub Pages` workflow manually.

If you want the workflow to try enabling Pages for a new repository automatically, add a repository secret named `PAGES_TOKEN` with a token that can write Pages settings. Without that secret, GitHub Pages still needs to be enabled once in **Settings > Pages**.

Optional repository variable:

- `SITE_URL`: the final public URL, such as `https://YOUR_USER.github.io/YOUR_REPO/`.

## Deploy with the Script

```bash
cp example.env .env
$EDITOR .env
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

Use `DEPLOY_MODE=actions` to push `main` and let GitHub Actions publish Pages, or `DEPLOY_MODE=gh-pages` to publish directly with `mkdocs gh-deploy`. Keep `DRY_RUN=true` until the GitHub remote and `SITE_URL` are filled in.

## Build Locally

```bash
python3 -m pip install --target .deps -r requirements.txt
PYTHONPATH=.deps python3 -m mkdocs build --strict
```
