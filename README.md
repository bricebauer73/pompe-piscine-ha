# 🏊 Pompe Piscine HA

Automatisation complète pour pompe de piscine **Hayward SP1622XE251** (1550W, 230V) avec Home Assistant. Filtration optimisée Heures Creuses EDF, mesure de la vraie consommation, suivi des coûts.

[![hacs_badge](https://img.shields.io/badge/HACS-Custom-orange.svg)](https://github.com/hacs/integration)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## 📦 Contenu

- **3 Blueprints** automations (HACS-compatible)
- **Package** YAML tout-en-un (sensors, utility_meter, input_number, recorder)
- **2 configs ESPHome** (DS18B20 + PZEM-004T)
- **Dashboard Lovelace** complet (jauges, coûts, historique 30j)
- **Script d'installation** auto-détection

---

## 🔧 Matériel requis

| Composant | Prix | Rôle |
|---|---|---|
| Sonoff POW R3 | ~20€ | On/Off pompe (commande bobine contacteur) |
| Contacteur DIN 2P 25A AC3 | ~12€ | Commute la pompe (isolation 230V) |
| Disjoncteur bipolaire 16A C | ~8€ | Protection moteur |
| ESP32 + PZEM-004T | ~15€ | Mesure conso réelle (W, kWh) |
| ESP32 + DS18B20 + doigt de gant 1/2" 100mm | ~18€ | Température eau dans PVC 63mm |
| Collier prise en charge Ø63 × 1/2" FITT | ~8€ | Fixation sonde sur PVC |
| Divers (résistance 4.7kΩ, téflon, câble) | ~5€ | Connectique |

**Total ~ 86 €**

---

## 🚀 Installation

### Option A — Via HACS (recommandé)

1. Dans HACS : **Intégrations → ⋮ → Dépôts personnalisés**
2. URL : `https://github.com/USER/pompe-piscine-ha`
3. Catégorie : **Intégration**
4. Installer les **3 blueprints** depuis HA → Paramètres → Automatisations → Blueprints

### Option B — Script d'installation

```bash
git clone https://github.com/USER/pompe-piscine-ha.git
cd pompe-piscine-ha
bash install.sh
```

Le script :
- Détecte le type d'installation HA (OS / Container / Core)
- Backup automatique de `configuration.yaml`
- Copie le package dans `packages/`
- Ajoute `packages: !include_dir_named packages` si absent
- Copie les blueprints
- Copie les configs ESPHome (si répertoire détecté)

### Option C — Installation manuelle

Voir [`docs/INSTALL.md`](docs/INSTALL.md) pour le détail étape par étape.

---

## 📐 Schéma de câblage

```
[Tableau 230V]──[Disjoncteur 16A]──┬── circuit commande ──[Sonoff POW R3]──[Bobine contacteur]
                                    │
                                    └── circuit puissance ──[Contacts NO contacteur]──[Pince CT PZEM]──[POMPE]
```

Voir [`docs/SCHEMA.md`](docs/SCHEMA.md) pour le schéma détaillé.

---

## 🧠 Logique de filtration

| Température eau | Durée totale | HC (22h30→06h30) | HP (10h00→) |
|---|---|---|---|
| ≤ 12°C | Pompe arrêtée | — | — |
| 14°C | 7h | 7h ✅ 100% HC | — |
| 16°C | 8h | 8h ✅ 100% HC | — |
| 20°C | 10h | 8h | 2h |
| 26°C | 13h | 8h | 5h |
| 30°C | 15h | 8h | 7h |

Règle : **durée filtration (h) = température eau (°C) ÷ 2**

---

## ⚙️ Configuration post-installation

### 1. Sonoff POW R3 → Tasmota

Flasher via [Tasmota Web Installer](https://tasmota.github.io/install/) puis intégrer via MQTT (auto-découverte).

### 2. ESP32 sondes → ESPHome

```bash
# Compile + flash via dashboard ESPHome
sonde_temperature.yaml  → ESP32 + DS18B20
pzem_pompe.yaml         → ESP32 + PZEM-004T
```

⚠️ Récupérer l'adresse DS18B20 dans les logs ESPHome au 1er boot, puis l'écrire dans `sonde_temperature.yaml`.

### 3. Créer les automations depuis les blueprints

Paramètres → Automatisations → ➕ → **Créer une automatisation depuis un blueprint**

| Blueprint | Param principal |
|---|---|
| Démarrage Heures Creuses | heure: 22:30, durée HC: 8h, temp min: 12°C |
| Complément Heures Pleines | heure: 10:00, seuil: 16°C |
| Arrêt sécurité fin HC | heure: 06:25 |

### 4. Tarifs EDF

Modifiables directement depuis le dashboard (carte Coûts) :
- HC : **0.1828 €/kWh** (défaut)
- HP : **0.2516 €/kWh** (défaut)

---

## 📊 Entités créées

```yaml
# Switches
switch.piscine_sonoff_10027646ab             # On/Off via Sonoff

# Sensors mesure
sensor.pompe_puissance           # Puissance instantanée (W)
sensor.pompe_courant             # Courant (A)
sensor.pompe_tension             # Tension (V)
sensor.pompe_energie             # Énergie cumulée (kWh)
sensor.temperature_piscine       # T° eau (°C)

# Sensors calculés
sensor.tarif_edf                 # HC ou HP courant
sensor.pompe_ratio_hc            # Ratio temps HC/HP
sensor.pompe_duree_filtration    # T°/2 (heures)
sensor.pompe_cout_jour           # Coût journalier (€)
sensor.pompe_cout_semaine        # Coût hebdomadaire
sensor.pompe_cout_mois           # Coût mensuel
sensor.pompe_cout_annuel_projete # Projection annuelle

# Utility meters
sensor.pompe_energie_jour
sensor.pompe_energie_semaine
sensor.pompe_energie_mois

# Inputs (paramètres modifiables)
input_number.tarif_hc
input_number.tarif_hp
```

---

## 📜 Licence

MIT

---

## 🤝 Contributions

PRs bienvenues. Pour les bugs, ouvrir une issue avec :
- Version HA
- Type d'installation (OS / Core / Container)
- Logs HA pertinents
