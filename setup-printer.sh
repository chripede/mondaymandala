#!/usr/bin/env bash
set -euo pipefail

# Start CUPS daemon
cupsd

# Vent til CUPS er klar
until lpstat -H > /dev/null 2>&1; do sleep 1; done

# Tilføj printer hvis den ikke allerede findes
if ! lpstat -p mondaymandala > /dev/null 2>&1; then
  lpadmin -p mondaymandala \
    -v "${PRINTER_URI}" \
    -m everywhere \
    -E
  lpoptions -d mondaymandala
fi

# Start Flask
exec python -m flask run --host=0.0.0.0
