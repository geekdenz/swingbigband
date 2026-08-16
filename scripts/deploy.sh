#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ -f ".env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source ".env"
  set +a
else
  echo "Missing .env. Copy example.env to .env and fill in your values." >&2
  exit 1
fi

DRY_RUN="${DRY_RUN:-false}"
SOURCE_BRANCH="${SOURCE_BRANCH:-main}"
GIT_REMOTE="${GIT_REMOTE:-origin}"
SITE_URL="${SITE_URL:-}"
AUTO_COMMIT="${AUTO_COMMIT:-false}"
COMMIT_MESSAGE="${COMMIT_MESSAGE:-Deploy site}"
export SITE_URL

case "${1:-}" in
  --deploy)
    DRY_RUN=false
    ;;
  --dry-run)
    DRY_RUN=true
    ;;
  "")
    ;;
  --help|-h)
    echo "Usage: $0 [--deploy|--dry-run]"
    echo "  --deploy   Build strictly and push the source branch to trigger GitHub Pages."
    echo "  --dry-run  Build strictly without pushing (default follows DRY_RUN in .env)."
    exit 0
    ;;
  *)
    echo "Unknown option: $1" >&2
    echo "Usage: $0 [--deploy|--dry-run]" >&2
    exit 2
    ;;
esac

MKDOCS=(python3 -m mkdocs)
if [[ -d ".deps" ]]; then
  export PYTHONPATH=".deps${PYTHONPATH:+:$PYTHONPATH}"
fi

if ! "${MKDOCS[@]}" --version >/dev/null 2>&1; then
  echo "MkDocs is not available. Install dependencies first:" >&2
  echo "  python3 -m pip install --target .deps -r requirements.txt" >&2
  exit 1
fi

BUILD_DIR="$(mktemp -d "${TMPDIR:-/tmp}/swingbigband-deploy.XXXXXX")"
cleanup() {
  rm -rf -- "$BUILD_DIR"
}
trap cleanup EXIT

echo "Building site..."
"${MKDOCS[@]}" build --strict --site-dir "$BUILD_DIR"

if [[ "$DRY_RUN" == "true" ]]; then
  echo "DRY_RUN=true, so deployment was skipped."
  exit 0
fi

if ! git remote get-url "$GIT_REMOTE" >/dev/null 2>&1; then
  echo "Git remote '$GIT_REMOTE' is not configured." >&2
  echo "Add it with: git remote add $GIT_REMOTE git@github.com:YOUR_USER/YOUR_REPO.git" >&2
  exit 1
fi

current_branch="$(git branch --show-current)"
if [[ "$current_branch" != "$SOURCE_BRANCH" ]]; then
  echo "Expected branch '$SOURCE_BRANCH', but current branch is '$current_branch'." >&2
  exit 1
fi

if [[ "$AUTO_COMMIT" == "true" ]]; then
  git add .
  if ! git diff --cached --quiet; then
    git commit -m "$COMMIT_MESSAGE"
  fi
elif ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Working tree has uncommitted changes. Commit them or set AUTO_COMMIT=true." >&2
  exit 1
fi

echo "Pushing source branch '$SOURCE_BRANCH' to '$GIT_REMOTE'..."
git push "$GIT_REMOTE" "$SOURCE_BRANCH"
echo "GitHub Actions will build this commit and deploy it to GitHub Pages."
