#!/usr/bin/env bash

PG_EXTENSIONS_DIR=$(pg_config --sharedir 2>/dev/null)/extension

create_hard_links() {
    if [[ -z "$PG_EXTENSIONS_DIR" ]] || ! [[ -d "$PG_EXTENSIONS_DIR" ]]; then 
        echo 'We could not locate the extension directory for the Postgres' >&2
        return 1; 
    fi

    shopt -s nullglob
    for fn in *sql *.control; do
        ln=${fn/%.pgsql/.sql}

        printf "%-24s => pg-extension-dir/%s\n%b" "$fn" "$ln" '\x1b[2m'
        (set -x; ln -f $fn "$PG_EXTENSIONS_DIR/$ln")
        printf "%b" '\x1b[0m'
    done

    return 0
}

echo
create_hard_links || error=$?
echo

if [[ -z "$error" ]]; then
    echo "Installation was successful ✅"
else
    echo "Installation aborted ❌ [code:$error]"
fi

