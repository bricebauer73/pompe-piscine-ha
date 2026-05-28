#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════
# install.sh — Pompe Piscine HA
# Auto-détecte le type d'install HA et copie les fichiers
# ══════════════════════════════════════════════════════════════

set -e

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

ok()   { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
err()  { echo -e "${RED}✗${NC} $1"; exit 1; }
info() { echo -e "${CYAN}→${NC} $1"; }

cat << 'BANNER'
╔══════════════════════════════════════════════════╗
║   POMPE PISCINE HA — Installeur                  ║
║   Hayward SP1622XE251 | Heures Creuses EDF      ║
╚══════════════════════════════════════════════════╝
BANNER

# ── Détection HA ─────────────────────────────────────────────
HA_TYPE=""
HA_CONFIG=""

if [ -f "/config/configuration.yaml" ]; then
  HA_TYPE="HA OS / Supervised / Container"
  HA_CONFIG="/config"
elif [ -f "$HOME/.homeassistant/configuration.yaml" ]; then
  HA_TYPE="HA Core (venv)"
  HA_CONFIG="$HOME/.homeassistant"
elif [ -f "/usr/share/hassio/homeassistant/configuration.yaml" ]; then
  HA_TYPE="HA Supervised"
  HA_CONFIG="/usr/share/hassio/homeassistant"
else
  warn "Type HA non détecté"
  echo -n "Chemin vers le dossier HA (contenant configuration.yaml) : "
  read -r HA_CONFIG
  [ -f "$HA_CONFIG/configuration.yaml" ] || err "configuration.yaml introuvable"
  HA_TYPE="Personnalisé"
fi

ok "Installation détectée : $HA_TYPE"
ok "Config HA : $HA_CONFIG"

# ── Backup ──────────────────────────────────────────────────
TS=$(date +%Y%m%d_%H%M%S)
BACKUP="$HA_CONFIG/backups/pompe_piscine_$TS"
mkdir -p "$BACKUP"
cp "$HA_CONFIG/configuration.yaml" "$BACKUP/" 2>/dev/null || true
ok "Backup → $BACKUP"

# ── Package ─────────────────────────────────────────────────
mkdir -p "$HA_CONFIG/packages"
cp packages/pompe_piscine.yaml "$HA_CONFIG/packages/"
ok "Package installé → packages/pompe_piscine.yaml"

# ── configuration.yaml ──────────────────────────────────────
CONF="$HA_CONFIG/configuration.yaml"
if grep -qE "^\s*packages:\s*!include" "$CONF" 2>/dev/null; then
  warn "'packages:' déjà présent — vérifier manuellement"
elif grep -qE "^homeassistant:" "$CONF"; then
  sed -i.bak '/^homeassistant:/a\  packages: !include_dir_named packages' "$CONF"
  ok "Ajout 'packages:' sous 'homeassistant:'"
else
  cat >> "$CONF" << 'YAML_EOF'

homeassistant:
  packages: !include_dir_named packages
YAML_EOF
  ok "Bloc 'homeassistant.packages' ajouté"
fi

# ── Blueprints ──────────────────────────────────────────────
BP_DIR="$HA_CONFIG/blueprints/automation/pompe-piscine"
mkdir -p "$BP_DIR"
cp blueprints/automation/pompe-piscine/*.yaml "$BP_DIR/"
ok "Blueprints installés → blueprints/automation/pompe-piscine/"

# ── ESPHome ─────────────────────────────────────────────────
for d in "/config/esphome" "$HA_CONFIG/esphome"; do
  if [ -d "$d" ]; then
    cp esphome/sonde_temperature.yaml "$d/"
    cp esphome/pzem_pompe.yaml "$d/"
    ok "Configs ESPHome → $d"
    warn "Mettre à jour l'adresse DS18B20 dans sonde_temperature.yaml après 1er boot"
    break
  fi
done

# ── Récap ───────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}━━ Installation terminée ━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BOLD}Étapes restantes (manuelles) :${NC}"
echo ""
echo -e "  ${CYAN}1.${NC} Flasher Sonoff POW R3 (Tasmota)"
echo -e "     https://tasmota.github.io/install/"
echo ""
echo -e "  ${CYAN}2.${NC} Compiler/Flasher les ESP32 via ESPHome"
echo -e "     - sonde_temperature.yaml (DS18B20)"
echo -e "     - pzem_pompe.yaml (PZEM-004T)"
echo ""
echo -e "  ${CYAN}3.${NC} Redémarrer Home Assistant"
echo -e "     Paramètres → Système → Redémarrer"
echo ""
echo -e "  ${CYAN}4.${NC} Créer les 3 automations depuis les blueprints"
echo -e "     Paramètres → Automatisations → ➕ Créer depuis blueprint"
echo -e "     - Pompe Piscine — Démarrage Heures Creuses"
echo -e "     - Pompe Piscine — Complément Heures Pleines"
echo -e "     - Pompe Piscine — Arrêt sécurité fin HC"
echo ""
echo -e "  ${CYAN}5.${NC} Importer le dashboard"
echo -e "     Tableau de bord → ⋮ → Éditeur YAML → coller :"
echo -e "     lovelace/piscine_dashboard.yaml"
echo ""
echo -e "${YELLOW}Tarifs EDF par défaut : HC = 0.1828 €/kWh | HP = 0.2516 €/kWh${NC}"
echo -e "${YELLOW}(modifiables directement depuis le dashboard)${NC}"
