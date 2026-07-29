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

DEPLOY_MODE="${DEPLOY_MODE:-actions}"
DRY_RUN="${DRY_RUN:-false}"
SOURCE_BRANCH="${SOURCE_BRANCH:-main}"
GIT_REMOTE="${GIT_REMOTE:-origin}"
SITE_URL="${SITE_URL:-}"
AUTO_COMMIT="${AUTO_COMMIT:-false}"
COMMIT_MESSAGE="${COMMIT_MESSAGE:-Deploy site}"
GH_PAGES_BRANCH="${GH_PAGES_BRANCH:-gh-pages}"
export SITE_URL

MKDOCS=(python3 -m mkdocs)
if [[ -d ".deps" ]]; then
  export PYTHONPATH=".deps${PYTHONPATH:+:$PYTHONPATH}"
fi

if ! "${MKDOCS[@]}" --version >/dev/null 2>&1; then
  echo "MkDocs is not available. Install dependencies first:" >&2
  echo "  python3 -m pip install --target .deps -r requirements.txt" >&2
  exit 1
fi

echo "Building site..."
"${MKDOCS[@]}" build --strict

if [[ "$DRY_RUN" == "true" ]]; then
  echo "DRY_RUN=true, so deployment was skipped."
  exit 0
fi

if ! git remote get-url "$GIT_REMOTE" >/dev/null 2>&1; then
  echo "Git remote '$GIT_REMOTE' is not configured." >&2
  echo "Add it with: git remote add $GIT_REMOTE git@github.com:YOUR_USER/YOUR_REPO.git" >&2
  exit 1
fi

case "$DEPLOY_MODE" in
  actions)
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

    echo "Pushing '$SOURCE_BRANCH' to '$GIT_REMOTE'..."
    git push "$GIT_REMOTE" "$SOURCE_BRANCH"
    ;;

  gh-pages)
    deploy_args=(gh-deploy --strict --force --remote-name "$GIT_REMOTE" --remote-branch "$GH_PAGES_BRANCH" --message "$COMMIT_MESSAGE")

    echo "Deploying directly to '$GH_PAGES_BRANCH' on '$GIT_REMOTE'..."
    "${MKDOCS[@]}" "${deploy_args[@]}"
    ;;

  *)
    echo "Unsupported DEPLOY_MODE '$DEPLOY_MODE'. Use 'actions' or 'gh-pages'." >&2
    exit 1
    ;;
esac
