ARG PG_TO_VERSION
ARG DEBIAN_VERSION=bullseye

FROM postgres:${PG_TO_VERSION}-${DEBIAN_VERSION} as base

ARG PG_TO_VERSION
ARG PG_FROM_VERSION

RUN sed -i 's/$/ '${PG_FROM_VERSION}'/' /etc/apt/sources.list.d/pgdg.list

RUN apt-get update && apt-get install -y --no-install-recommends \
    postgresql-${PG_FROM_VERSION} \
    wget \
    && rm -rf /var/lib/apt/lists/*

ENV PGBINOLD /usr/lib/postgresql/${PG_FROM_VERSION}/bin
ENV PGBINNEW /usr/lib/postgresql/${PG_TO_VERSION}/bin

ENV PGDATAOLD /var/lib/postgresql/${PG_FROM_VERSION}/data
ENV PGDATANEW /var/lib/postgresql/${PG_TO_VERSION}/data

RUN mkdir -p "$PGDATAOLD" "$PGDATANEW" \
    && chown -R postgres:postgres /var/lib/postgresql

# TimescaleDB

ARG TIMESCALEDB_VERSION
ENV TIMESCALEDB_VERSION = ${TIMESCALEDB_VERSION}
RUN if [[ -n "$TIMESCALEDB_VERSION" ]] ; \
    then \
    echo Installing TimescaleDB==${TIMESCALEDB_VERSION} ... && \
    apt-get update && \
    wget --no-check-certificate --quiet -O - https://packagecloud.io/install/repositories/timescale/timescaledb/script.deb.sh | bash && \
    apt-get update && \
    apt-get install -y --no-install-recommends timescaledb-2-postgresql-${PG_FROM_VERSION}=${TIMESCALEDB_VERSION}'*' timescaledb-2-loader-postgresql-${PG_FROM_VERSION}=${TIMESCALEDB_VERSION}'*' && \
    apt-get install -y --no-install-recommends timescaledb-2-postgresql-${PG_TO_VERSION}=${TIMESCALEDB_VERSION}'*' timescaledb-2-loader-postgresql-${PG_TO_VERSION}=${TIMESCALEDB_VERSION}'*' && \
    rm -rf /var/lib/apt/lists/* \
    ; fi

# PostGIS

ARG POSTGIS_VERSION
ENV POSTGIS_VERSION=${POSTGIS_VERSION}
RUN if [[ -n "$POSTGIS_VERSION" ]] ; \
    then \
    echo Installing PostGIS==${POSTGIS_VERSION} ... && \
    apt-get update && \
    wget --no-check-certificate --quiet -O - https://salsa.debian.org/postgresql/postgresql-common/raw/master/pgdg/apt.postgresql.org.sh | bash && \
    apt-get update && \
    apt-get install -y --no-install-recommends postgis postgresql-${PG_TO_VERSION}-postgis-${POSTGIS_VERSION} && \
    apt-get install -y --no-install-recommends postgis postgresql-${PG_FROM_VERSION}-postgis-${POSTGIS_VERSION} && \
    rm -rf /var/lib/apt/lists/* \
    ; fi


WORKDIR /var/lib/postgresql

COPY --chmod=775 docker-upgrade /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/docker-upgrade"]

# Default to pg_upgrade
CMD ["pg_upgrade"]