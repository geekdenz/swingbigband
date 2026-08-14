#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPS_DIR="$PROJECT_DIR/.deps"
REQUIREMENTS_FILE="$PROJECT_DIR/requirements.txt"
REQUIREMENTS_MARKER="$DEPS_DIR/.requirements.sha256"
SERVE_ADDR="${SWINGBIG_SERVE_ADDR:-127.0.0.1:8001}"
REFRESH_DEPS="${SWINGBIG_REFRESH_DEPS:-false}"

if [[ ! -f "$REQUIREMENTS_FILE" || ! -f "$PROJECT_DIR/mkdocs.yml" ]]; then
  echo "This script must be located in the SwingBig.Band MkDocs project root." >&2
  exit 1
fi

if [[ ! "$SERVE_ADDR" =~ ^[^:[:space:]]+:[0-9]+$ ]]; then
  echo "SWINGBIG_SERVE_ADDR must use HOST:PORT format." >&2
  exit 1
fi

requirements_hash="$(python3 -c 'import hashlib, pathlib, sys; print(hashlib.sha256(pathlib.Path(sys.argv[1]).read_bytes()).hexdigest())' "$REQUIREMENTS_FILE")"
export PYTHONPATH="$DEPS_DIR${PYTHONPATH:+:$PYTHONPATH}"

install_dependencies=false
if [[ "$REFRESH_DEPS" == "true" || ! -d "$DEPS_DIR" ]]; then
  install_dependencies=true
elif [[ -f "$REQUIREMENTS_MARKER" ]] && [[ "$(<"$REQUIREMENTS_MARKER")" != "$requirements_hash" ]]; then
  install_dependencies=true
elif ! python3 -m mkdocs --version >/dev/null 2>&1; then
  install_dependencies=true
fi

if [[ "$install_dependencies" == "true" ]]; then
  echo "Installing MkDocs dependencies into $DEPS_DIR ..."
  mkdir -p "$DEPS_DIR"
  python3 -m pip install --upgrade --target "$DEPS_DIR" -r "$REQUIREMENTS_FILE"
fi

printf '%s\n' "$requirements_hash" > "$REQUIREMENTS_MARKER"

cd "$PROJECT_DIR"
echo "Serving SwingBig.Band at http://$SERVE_ADDR/"
exec python3 -m mkdocs serve --strict --dev-addr "$SERVE_ADDR" "$@"
