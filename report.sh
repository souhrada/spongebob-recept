#!/bin/bash
# Sesbírá fakta o tvém systému do souboru report_JMENO.txt
# Spouštěj přes sudo: sudo ./report.sh
if [ "$EUID" -ne 0 ]; then echo "Spusť to přes sudo: sudo ./report.sh"; exit 1; fi

read -rp "Tvoje jméno (bez mezer a diakritiky, např. jan_novak): " name
RECIPE=/home/spongebob/recept_na_krabi_hambac.txt
BONUS="$(dirname "$(readlink -f "$0")")/bonus_odpoved.txt"
OUT="report_${name}.txt"

{
  echo "### NAME";  echo "$name"
  echo "### USERS"
  for u in spongebob patrik sepiak sandy; do
    if getent passwd "$u" >/dev/null; then
      home=$(getent passwd "$u" | cut -d: -f6)
      [ -d "$home" ] && hd=yes || hd=no
      echo "$u|$(getent passwd "$u" | cut -d: -f5 | cut -d, -f1)|$home|$hd|$(id -gn "$u")|$(id -nG "$u")"
    fi
  done
  echo "### GROUPS"
  for g in krusty_krab zatisi_bikin klarinet skafandr; do
    getent group "$g" >/dev/null && echo "$g"
  done
  echo "### RECIPE_STAT"
  stat -c '%U:%G %a' "$RECIPE" 2>/dev/null
  echo "### RECIPE_CONTENT"
  cat "$RECIPE" 2>/dev/null
  echo "### BONUS"
  [ -f "$BONUS" ] && cat "$BONUS"
  echo "### END"
} > "$OUT"

# Vrátí report studentovi, který spustil sudo (jinak by patřil rootovi)
if [ -n "$SUDO_USER" ]; then
  chown "$SUDO_USER:$(id -gn "$SUDO_USER")" "$OUT"
fi

echo "Hotovo! Odevzdej soubor: $OUT"
