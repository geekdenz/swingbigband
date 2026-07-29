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

## Build Locally

```bash
python3 -m pip install --target .deps -r requirements.txt
PYTHONPATH=.deps python3 -m mkdocs build --strict
```
