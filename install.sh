# ══════════════════════════════════════════════════════════════
# ESPHome — Sonde température piscine
# ESP32 + DS18B20 dans doigt de gant inox 1/2" sur PVC 63mm
# ══════════════════════════════════════════════════════════════

esphome:
  name: sonde-piscine
  friendly_name: Sonde Piscine

esp32:
  board: esp32dev
  framework:
    type: arduino

logger:

api:
  encryption:
    key: !secret esphome_api_key

ota:
  - platform: esphome
    password: !secret esphome_ota_password

wifi:
  ssid: !secret wifi_ssid
  password: !secret wifi_password
  ap:
    ssid: "Sonde-Piscine Fallback"
    password: "piscine1234"

captive_portal:

# Résistance pull-up 4.7kΩ entre GPIO4 et 3.3V obligatoire
one_wire:
  - platform: gpio
    pin: GPIO4

sensor:
  - platform: dallas_temp
    # Adresse récupérée dans les logs ESPHome au 1er boot
    # Chercher "Found sensor with address" puis copier l'adresse ici
    address: 0x0000000000000000
    name: "Temperature piscine"
    update_interval: 30s
    accuracy_decimals: 1
    filters:
      - median:
          window_size: 5
          send_every: 5
          send_first_at: 1

  - platform: uptime
    name: "Sonde piscine uptime"

binary_sensor:
  - platform: status
    name: "Sonde piscine statut"
