#!/usr/bin/env bash
# Build all custom MCP tool server Docker images.
# Discovers folders automatically — each subfolder with a Dockerfile gets built as mcp/<name>.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
built_tags=()

for dir in "${SCRIPT_DIR}"/*/; do
    [ -f "${dir}/Dockerfile" ] || continue
    name="$(basename "${dir}")"
    # The employees database is Compose-managed infrastructure, not an MCP image.
    [ "$name" = "employees-db" ] && continue
    tag="mcp/${name}"
    built_tags+=("$tag")
    echo "=== Building ${tag} from ${name}/ ==="
    docker build -t "${tag}" "${dir}"
    echo ""
done

echo "All images built successfully."
printf 'REPOSITORY\tTAG\tSIZE\n'
for tag in "${built_tags[@]}"; do
    docker images "$tag" --format "{{.Repository}}\t{{.Tag}}\t{{.Size}}"
done
