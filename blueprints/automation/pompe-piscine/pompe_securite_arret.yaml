blueprint:
  name: "Pompe Piscine — Arrêt sécurité fin HC"
  description: >
    Coupe la pompe quelques minutes avant la fin des Heures Creuses au cas
    où la durée calculée déborderait. Évite de filtrer en HP par accident.
  domain: automation
  source_url: https://github.com/USER/pompe-piscine-ha/blob/main/blueprints/automation/pompe-piscine/pompe_securite_arret.yaml
  input:
    pompe_switch:
      name: Switch pompe
      selector:
        entity:
          domain: switch
    heure_arret:
      name: Heure d'arrêt sécurité
      description: "Quelques minutes avant la fin des HC (ex: 06h25 si HC fin = 06h30)"
      default: "06:25:00"
      selector:
        time:

trigger:
  - platform: time
    at: !input heure_arret

condition:
  - condition: state
    entity_id: !input pompe_switch
    state: "on"

action:
  - service: switch.turn_off
    target:
      entity_id: !input pompe_switch

mode: single
