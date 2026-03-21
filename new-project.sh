#!/usr/bin/env bash
set -euo pipefail

TEMPLATE_REPO="https://github.com/ratpackcp7/cp7-project-template.git"
TEMPLATE_DIR="/home/chris/cp7-project-template"
PROJECTS_DIR="/home/chris/projects"
SCRIPTS_DIR="/home/chris/cp7-bridge/scripts"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()  { echo -e "${CYAN}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[OK]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
err()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }

usage() {
    echo "Usage: new-project.sh <name> <port> [OPTIONS]"
    echo "  --framework fastapi|flask   (default: fastapi)"
    echo "  --deploy systemd|docker     (default: prompt)"
    echo "  --description \"...\"         (default: name)"
    echo "  --no-cloudflare / --no-bridge / --dry-run / --yes"
    exit 1
}

[[ $# -lt 2 ]] && usage

PROJECT_NAME="$1"; PROJECT_PORT="$2"; shift 2
FRAMEWORK="fastapi"; DEPLOY=""; DESCRIPTION="$PROJECT_NAME"
DO_CLOUDFLARE=true; DO_BRIDGE=true; DRY_RUN=false; SKIP_CONFIRM=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --framework)   FRAMEWORK="$2"; shift 2 ;;
        --deploy)      DEPLOY="$2"; shift 2 ;;
        --description) DESCRIPTION="$2"; shift 2 ;;
        --no-cloudflare) DO_CLOUDFLARE=false; shift ;;
        --no-bridge)   DO_BRIDGE=false; shift ;;
        --dry-run)     DRY_RUN=true; shift ;;
        --yes|-y)      SKIP_CONFIRM=true; shift ;;
        *) err "Unknown option: $1"; usage ;;
    esac
done

# Validate
[[ ! "$PROJECT_NAME" =~ ^[a-z][a-z0-9-]*$ ]] && { err "Name must be lowercase alphanumeric with hyphens"; exit 1; }
(( PROJECT_PORT < 1024 || PROJECT_PORT > 65535 )) && { err "Port must be 1024-65535"; exit 1; }
[[ "$FRAMEWORK" != "fastapi" && "$FRAMEWORK" != "flask" ]] && { err "Framework must be fastapi or flask"; exit 1; }

if ss -tlnp 2>/dev/null | grep -q ":${PROJECT_PORT} "; then
    err "Port $PROJECT_PORT already in use"; exit 1
fi

TARGET_DIR="${PROJECTS_DIR}/${PROJECT_NAME}"
[[ -d "$TARGET_DIR" ]] && { err "Directory exists: $TARGET_DIR"; exit 1; }

# Prompt for deploy if not set
if [[ -z "$DEPLOY" ]]; then
    if $SKIP_CONFIRM; then
        DEPLOY="systemd"
        warn "No --deploy specified with --yes, defaulting to systemd"
    else
        echo "Deploy target:  1) systemd  2) docker"
        read -rp "Choose [1/2]: " choice
        case "$choice" in
            1|systemd) DEPLOY="systemd" ;; 2|docker) DEPLOY="docker" ;; *) err "Invalid"; exit 1 ;;
        esac
    fi
fi

FRAMEWORK_DISPLAY="FastAPI"; [[ "$FRAMEWORK" == "flask" ]] && FRAMEWORK_DISPLAY="Flask"

echo ""; echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
info "Project:     $PROJECT_NAME"
info "Port:        $PROJECT_PORT"
info "Framework:   $FRAMEWORK ($FRAMEWORK_DISPLAY)"
info "Deploy:      $DEPLOY"
info "Description: $DESCRIPTION"
info "Directory:   $TARGET_DIR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; echo ""

$DRY_RUN && { warn "Dry run — no changes made"; exit 0; }

if ! $SKIP_CONFIRM; then
    read -rp "Proceed? [y/N]: " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || { info "Aborted"; exit 0; }
fi

# Step 1: Scaffold
info "1/8 Scaffolding..."
if [[ -d "$TEMPLATE_DIR" ]]; then
    cd "$TEMPLATE_DIR" && git pull --quiet 2>/dev/null || true
fi

mkdir -p "$TARGET_DIR"
cp -r "${TEMPLATE_DIR}/${FRAMEWORK}/"* "$TARGET_DIR/"
cp -r "${TEMPLATE_DIR}/${FRAMEWORK}/".[!.]* "$TARGET_DIR/" 2>/dev/null || true
cp -r "${TEMPLATE_DIR}/shared/"* "$TARGET_DIR/"
cp -r "${TEMPLATE_DIR}/shared/".[!.]* "$TARGET_DIR/" 2>/dev/null || true
ok "Scaffolded"

# Step 2: Replace placeholders
info "2/8 Replacing placeholders..."
find "$TARGET_DIR" -type f \( -name "*.py" -o -name "*.md" -o -name "*.txt" \
    -o -name "*.yml" -o -name "*.yaml" -o -name "*.service" -o -name "*.html" \
    -o -name "*.env*" -o -name "Dockerfile" \) | while read -r f; do
    sed -i \
        -e "s/PROJECT_NAME/${PROJECT_NAME}/g" \
        -e "s/PROJECT_PORT/${PROJECT_PORT}/g" \
        -e "s/PROJECT_DESCRIPTION/${DESCRIPTION}/g" \
        -e "s/FRAMEWORK_NAME/${FRAMEWORK_DISPLAY}/g" \
        -e "s/DEPLOY_TARGET/${DEPLOY}/g" \
        "$f"
done
[[ -f "${TARGET_DIR}/systemd/PROJECT_NAME.service" ]] && \
    mv "${TARGET_DIR}/systemd/PROJECT_NAME.service" "${TARGET_DIR}/systemd/${PROJECT_NAME}.service"
ok "Placeholders replaced"

# Step 3: .env
info "3/8 Creating .env..."
[[ -f "${TARGET_DIR}/.env.template" ]] && cp "${TARGET_DIR}/.env.template" "${TARGET_DIR}/.env"
# Fix HOST for Docker (containers need 0.0.0.0, not 127.0.0.1)
if [[ "$DEPLOY" == "docker" && -f "${TARGET_DIR}/.env" ]]; then
    sed -i 's/HOST=127.0.0.1/HOST=0.0.0.0/' "${TARGET_DIR}/.env"
fi
ok ".env created"

# Step 4: Data dir
info "4/8 Creating data/ + setting ACLs..."
mkdir -p "${TARGET_DIR}/data"
# Set ACLs so claude-agent can write to the project
if id claude-agent &>/dev/null; then
    setfacl -R -m u:claude-agent:rwX "${TARGET_DIR}" 2>/dev/null || true
    setfacl -R -d -m u:claude-agent:rwX "${TARGET_DIR}" 2>/dev/null || true
    ok "ACLs set for claude-agent"
fi

# Step 5: Deps
if [[ "$DEPLOY" == "systemd" ]]; then
    info "5/8 Creating venv..."
    python3 -m venv "${TARGET_DIR}/venv"
    "${TARGET_DIR}/venv/bin/pip" install --quiet --upgrade pip
    "${TARGET_DIR}/venv/bin/pip" install --quiet -r "${TARGET_DIR}/requirements.txt"
    ok "Dependencies installed"
else
    info "5/8 Docker verified"
fi

# Step 6: Deploy
if [[ "$DEPLOY" == "systemd" ]]; then
    info "6/8 Installing systemd service..."
    mkdir -p "$HOME/.config/systemd/user"
    cp "${TARGET_DIR}/systemd/${PROJECT_NAME}.service" "$HOME/.config/systemd/user/"
    systemctl --user daemon-reload
    systemctl --user enable "${PROJECT_NAME}"
    systemctl --user start "${PROJECT_NAME}"
    ok "Service started"
else
    info "6/8 Building Docker..."
    cd "$TARGET_DIR" && docker compose up -d --build
    ok "Container started"
fi

# Step 7: Cloudflare
if $DO_CLOUDFLARE && [[ -x "${SCRIPTS_DIR}/cf-tunnel.sh" ]]; then
    info "7/8 Cloudflare route..."
    "${SCRIPTS_DIR}/cf-tunnel.sh" add "${PROJECT_NAME}.cp7.dev" "http://localhost:${PROJECT_PORT}" 2>/dev/null && \
        ok "https://${PROJECT_NAME}.cp7.dev" || warn "Route failed (add manually)"
else
    info "7/8 Skipping Cloudflare"
fi

# Step 8: Health check
info "8/8 Health check..."
sleep 2
ATTEMPTS=0
while (( ATTEMPTS < 5 )); do
    if curl -sf "http://localhost:${PROJECT_PORT}/health" >/dev/null 2>&1; then
        ok "Health: $(curl -sf http://localhost:${PROJECT_PORT}/health)"
        break
    fi
    ((ATTEMPTS++)); sleep 2
done
(( ATTEMPTS >= 5 )) && warn "Health check failed — check logs"

echo ""; echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}${PROJECT_NAME} created${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Dir:   $TARGET_DIR"
echo "  Local: http://localhost:${PROJECT_PORT}"
$DO_CLOUDFLARE && echo "  URL:   https://${PROJECT_NAME}.cp7.dev"
echo ""
echo "  Next: edit SPEC.md, replace example model in database.py, build routes"
[[ "$DEPLOY" == "systemd" ]] && echo "  Logs:  journalctl --user -u ${PROJECT_NAME} -f"
[[ "$DEPLOY" == "docker" ]] && echo "  Logs:  cd $TARGET_DIR && docker compose logs -f"
echo ""
