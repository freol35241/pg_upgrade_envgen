# pg_upgrade_envgen
Environment generator for containerized use of pg_upgrade.

Much inspiration has been drawn from https://github.com/tianon/docker-postgres-upgrade

No prebuilt images are available since the Dockerfile provided in this repo is heavily customizable using [build_args](https://docs.docker.com/engine/reference/commandline/build/#build-arg) during build time, hence catering for a large number of usecases. The best way of utilizing this repository is therefore through `docker compose`, see the example below.

## Example

```yaml
version: '3.8'

services:
    pg_upgrade:
        build:
            context: https://github.com/freol35241/pg_upgrade_envgen.git
            args:
                - DEBIAN_VERSION=buster         # Optional (defaults to 'bullseye')
                - PG_FROM_VERSION=11
                - PG_TO_VERSION=13
                - TIMESCALEDB_VERSION=2.3.0     # Optional
                - POSTGIS_VERSION=2.5           # Optional

        volume:
            - <your-old-installation-data-directoyry>:/var/lib/postgresql/11/data
            - <empty-data-directory-for-new-installation>:/var/lib/postgresql/13/data
```

Steps to upgrade:

1. Make sure to stop your existing database container
2. Run `docker compose run --rm pg_upgrade` using a `docker-compose.yml` file similar to the one above and keep an eye on the output (this may take a while depending on your database size)
3. Start your new database container (with the new Postgresql version)

## Performance
See [this](https://github.com/tianon/docker-postgres-upgrade/blob/master/README.md) for background.

### Example

Assuming a directory layout as follows:

```console
$ find DIR -mindepth 2 -maxdepth 2
DIR/11/data
DIR/13/data
```

The above example can then be modified as:

```yaml
version: '3.8'

services:
    pg_upgrade:
        build:
            context: https://github.com/freol35241/pg_upgrade_envgen.git
            args:
                - DEBIAN_VERSION=buster         # Optional (defaults to 'bullseye')
                - PG_FROM_VERSION=11
                - PG_TO_VERSION=13
                - TIMESCALEDB_VERSION=2.3.0     # Optional
                - POSTGIS_VERSION=2.5           # Optional

        volume:
            - DIR:/var/lib/postgresql
```

And run as `docker compose run --rm pg_upgrade --link`
