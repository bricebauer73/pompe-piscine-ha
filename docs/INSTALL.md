# Installation manuelle détaillée

## Détecter votre type d'installation HA

| Type | Comment savoir | Chemin config |
|---|---|---|
| **HA OS** | Page d'accueil HA → Paramètres → Système → "Home Assistant Operating System" | `/config` |
| **HA Supervised** | Sur Debian/Ubuntu avec supervisor installé | `/usr/share/hassio/homeassistant` |
| **HA Container** (Docker) | `docker ps` montre `homeassistant` | volume monté |
| **HA Core** | Installation via `pip install` dans un venv | `~/.homeassistant` |

Si vous avez accès à l'interface HA → Paramètres → Système → "À propos" indique le type d'installation.

---

## Étape 1 — Package YAML

Copier `packages/pompe_piscine.yaml` vers `<HA_CONFIG>/packages/pompe_piscine.yaml`.

Si le dossier `packages/` n'existe pas, le créer.

Dans `configuration.yaml`, ajouter sous la section `homeassistant:` :

```yaml
homeassistant:
  packages: !include_dir_named packages
```

---

## Étape 2 — Blueprints

Copier les 3 fichiers de `blueprints/automation/pompe-piscine/` vers `<HA_CONFIG>/blueprints/automation/pompe-piscine/`.

Ou utiliser l'import direct depuis HA :

1. Paramètres → Automatisations → Blueprints → Importer
2. Coller l'URL GitHub du blueprint, par exemple :
   ```
   https://github.com/USER/pompe-piscine-ha/blob/main/blueprints/automation/pompe-piscine/pompe_demarrage_hc.yaml
   ```

---

## Étape 3 — ESPHome

Si vous utilisez le **module ESPHome** dans HA :

1. Ouvrir l'add-on ESPHome
2. Cliquer "+" pour ajouter un nouvel appareil
3. Copier le contenu de `esphome/sonde_temperature.yaml`
4. Compiler et flasher (USB ou OTA)
5. Répéter pour `esphome/pzem_pompe.yaml`

Sinon, copier les fichiers dans `<HA_CONFIG>/esphome/`.

⚠️ **Adresse DS18B20** : au 1er boot, chercher dans les logs ESPHome :
```
[D][dallas.sensor:083]: Found sensor with address 0x1234567890ABCDEF
```
Puis remplacer `0x0000000000000000` dans le yaml.

---

## Étape 4 — Redémarrer HA

Paramètres → Système → Redémarrer

---

## Étape 5 — Créer les automations depuis les blueprints

Paramètres → Automatisations → ➕ Créer → Créer depuis blueprint

1. **Pompe Piscine — Démarrage Heures Creuses**
   - Switch pompe : `switch.pompe_piscine`
   - Sensor température : `sensor.temperature_piscine`
   - Heure début HC : `22:30:00`
   - Durée HC max : `8`
   - Température minimale : `12`

2. **Pompe Piscine — Complément Heures Pleines**
   - Switch pompe : `switch.pompe_piscine`
   - Sensor température : `sensor.temperature_piscine`
   - Heure complément : `10:00:00`
   - Durée HC déjà effectuée : `8`
   - Température seuil : `16`

3. **Pompe Piscine — Arrêt sécurité fin HC**
   - Switch pompe : `switch.pompe_piscine`
   - Heure d'arrêt sécurité : `06:25:00`

---

## Étape 6 — Dashboard

1. Tableau de bord → mode édition (icône crayon)
2. ⋮ → Éditeur de configuration brute (`Raw configuration editor`)
3. Ajouter une nouvelle vue, coller le contenu de `lovelace/piscine_dashboard.yaml`

---

## Vérifications

Après redémarrage HA, vérifier que ces entités existent dans Outils de développement → États :

- `switch.pompe_piscine`
- `sensor.temperature_piscine`
- `sensor.pompe_puissance`
- `sensor.pompe_energie`
- `sensor.tarif_edf`
- `sensor.pompe_cout_jour`
- `input_number.tarif_hc`
- `input_number.tarif_hp`
