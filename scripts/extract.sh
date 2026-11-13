#!/bin/sh
# Rasterise the portfolio PDF into src/assets. Re-run when the PDF changes.
# ponytail: stand-in until proper Illustrator exports replace these files.
set -e
cd "$(dirname "$0")/.."
PDF=${1:-"portfo/ARCH Portfolio_MarcelaLuna_2026_v8.pdf"}
OUT=src/assets

page() { pdftoppm -png -singlefile -f "$1" -l "$1" -r "$2" "$PDF" "$3"; }
crop() { pdftoppm -png -singlefile -f "$1" -l "$1" -r "$2" -x "$3" -y "$4" -W "$5" -H "$6" "$PDF" "$7"; }

# slug : divider page : first spread : last spread
for p in basin:3:4:5 grain:6:7:12 agora:13:14:17 hub:18:19:21; do
  IFS=: read -r slug div first last <<EOF
$p
EOF
  mkdir -p "$OUT/$slug"
  crop "$div" 300 3000 645 1440 1185 "$OUT/$slug/sketch"
  n=1
  for i in $(seq "$first" "$last"); do
    page "$i" 200 "$OUT/$slug/$(printf %02d $n)"
    n=$((n + 1))
  done
done

crop 1 400 760 500 1740 2240 "$OUT/cover"
crop 22 800 2640 2680 1320 1256 "$OUT/back"
