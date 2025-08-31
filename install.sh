#!/usr/bin/env bash

PG_EXTENSIONS_DIR=$(pg_config --sharedir)/extension

shopt -s nullglob
for fn in *sql *.control; do
    ln=${fn/%.pgsql/.sql}

    printf "%-24s => pg-extension-dir/%s\n%b" "$fn" "$ln" '\x1b[2m'
    (set -x; ln -f $fn "$PG_EXTENSIONS_DIR/$ln")
    printf "%b" '\x1b[0m'
done

echo
echo "Installation was successful"