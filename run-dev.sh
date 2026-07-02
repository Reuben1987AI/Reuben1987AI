#!/usr/bin/env bash
# Boot a local, isolated preview of the GitHub profile README using grip in Docker.
# grip live-reloads the browser whenever README.md changes.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

IMAGE="reuben-profile-preview:latest"
PORT="${PORT:-5000}"

echo "Building preview image..."
docker build -q -f Dockerfile.preview -t "$IMAGE" .

# Pass through a GitHub token if present: raises grip's render rate limit.
TOKEN_ARGS=()
if [ -n "${GITHUB_TOKEN:-${GH_TOKEN:-}}" ]; then
  TOKEN_ARGS=(-e GITHUB_TOKEN="${GITHUB_TOKEN:-$GH_TOKEN}")
fi

echo "Serving README.md at http://localhost:${PORT}  (Ctrl+C to stop)"
docker run --rm -it \
  -p "${PORT}:5000" \
  -v "$SCRIPT_DIR":/doc:rw \
  "${TOKEN_ARGS[@]}" \
  "$IMAGE"
