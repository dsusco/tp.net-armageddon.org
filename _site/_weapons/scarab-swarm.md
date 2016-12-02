---
name: Scarab Swarm
modes:
  -
    range: 30cm
    firepower: AP5+/AT5+
    special_rules:
      - ignore-cover
  -
    boolean: and
    range: (15cm)
    firepower: Small Arms
    special_rules:
      - extra-attacks-1
      - ignore-cover
  -
    boolean: or
    range: (bc)
    firepower: Assault Weapons
    special_rules:
      - extra-attacks-1
      - ignore-cover
---