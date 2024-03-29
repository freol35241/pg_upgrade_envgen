#!/bin/bash
set -e

# Emulate pg_upgrade being the ENTRYPOINT
if [ "$#" -eq 0 ] || [ "${1:0:1}" = '-' ]; then
        set -- pg_upgrade "$@"
fi

# If the user overrides the default usecase, let them (and bail early)
if [ "$1" != 'pg_upgrade' ]; then
        exec "$@"
fi

# Else, lets make sure pg_upgrade runs as expected

# Make sure we use the correct user
if [ "$(id -u)" = '0' ]; then
        mkdir -p "$PGDATAOLD" "$PGDATANEW"
        chmod 700 "$PGDATAOLD" "$PGDATANEW"
        chown postgres .
        chown -R postgres "$PGDATAOLD" "$PGDATANEW"
        # Exec this script again (with a different user)
        exec gosu postgres "${BASH_SOURCE[0]}" "$@"
fi

if [ ! -s "$PGDATANEW/PG_VERSION" ]; then
        PGDATA="$PGDATANEW" eval "initdb $POSTGRES_INITDB_ARGS"
fi

if [ -n "${TIMESCALEDB_VERSION}" ]; then
        timescaledb-tune --quiet --yes --conf-path="${PGDATANEW}/postgresql.conf"
fi

# Run and handle potential failure
if ! eval "$*"; then
        if [ -f "loadable_libraries.txt" ]; then
                cat loadable_libraries.txt
        fi
fi

