#!/usr/bin/env bash

PG_EXTENSIONS_DIR=$(pg_config --sharedir 2>/dev/null)/extension

# DEPRECATED
create_hard_links() {
    if [[ -z "$PG_EXTENSIONS_DIR" ]] || ! [[ -d "$PG_EXTENSIONS_DIR" ]]; then 
        echo 'We could not locate the extension directory for the Postgres' >&2
        return -1; 
    fi

    shopt -s nullglob
    local error=0
    local char, string
    for fn in *sql *.control; do
        ln=${fn/%.pgsql/.sql}

        (set -x; ln -f $fn "$PG_EXTENSIONS_DIR/$ln")
        
        if ! [[ "$fn" -ef "$ln" ]]; then
            char='<'
            string='not '
            error=$(( error + 1 ))
        else
            char='='
            string=''
        fi

        printf "%-${1:-24}s %c> pg-extension-dir/%s (%slinked) \n%b" "$fn" "$char" "$ln" "$string" '\x1b[2m'
        printf "%b" '\x1b[0m'
    done

    return $error
}

get_control_file() {
    shopt -s failglob nocaseglob
    echo *.control
}

get_sql_files() {
    if [[ -z "$1" ]]; then return -1; fi
    local pattern=${1}*.sql

    shopt -s failglob nocaseglob
    echo $pattern
}

install_from_cwd() {
    if [[ -z "$PG_EXTENSIONS_DIR" ]] || ! [[ -d "$PG_EXTENSIONS_DIR" ]]; then 
        echo 'We could not locate the extension directory for the Postgres' >&2
        return -1; 
    fi

    declare -a matches
    local fn
    local error=0

    if matches=( $(get_control_file 2>/dev/null) ); then 
        if [[ ${#matches[@]} -ne 1 ]]; then
            echo "${#matches[@]} control files found in $(pwd), aborting..."
            return -1
        fi
    else
        echo "No control file found in $(pwd), aborting..."
        return -1
    fi

    fn=${matches[0]}

    printf "Installing '$PG_EXTENSIONS_DIR/$fn'...\n"

    # This is to defeat the hardlinking from before
    ( rm "$PG_EXTENSIONS_DIR/$fn" && \
        cat "$fn" | sed '$a\directory='"$(pwd)" > "$PG_EXTENSIONS_DIR/$fn" ) || return -2;

    # Delete any remnant SQL files in the extensions directory
    if matches=( $(get_sql_files "$PG_EXTENSIONS_DIR/${fn%.control}" 2>/dev/null) ); then 
        for fn in ${matches[@]}; do
            printf '%b%c Deleting file %s...%b\n' '\x1b[2m' '-' "$fn" '\x1b[22m'
            rm "$fn" || error=$(( error + 1 ))
        done
    fi

    return $error
}

echo
# DEPRECATED
# create_hard_links || error=$?
install_from_cwd || error=$?
echo

if [[ -z "$error" ]]; then
    echo "Installation was successful ✅"
else
    echo "Installation failed ❌ [code:$error]"
fi