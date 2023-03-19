#!/usr/bin/env bats

load "../../bats-helpers/bats-support/load"
load "../../bats-helpers/bats-assert/load"

setup() {
    REPO_ROOT="$( cd "$( dirname "$BATS_TEST_FILENAME" )"/../.. >/dev/null 2>&1 && pwd )"
}

teardown() {
    (docker image ls -aq | xargs docker rmi) || :
}

@test "test-build [DEBIAN_VERSION=$DEBIAN_VERSION, PG_FROM_VERSION=$PG_FROM_VERSION, PG_TO_VERSION=$PG_TO_VERSION, TIMESCALEDB_VERSION=$TIMESCALEDB_VERSION, POSTGIS_VERSION=$POSTGIS_VERSION]" {
    bats_require_minimum_version 1.5.0
    run docker build --no-cache \
        --build-arg DEBIAN_VERSION="$DEBIAN_VERSION" \
        --build-arg PG_FROM_VERSION="$PG_FROM_VERSION" \
        --build-arg PG_TO_VERSION="$PG_TO_VERSION" \
        --build-arg TIMESCALEDB_VERSION="$TIMESCALEDB_VERSION" \
        --build-arg POSTGIS_VERSION="$POSTGIS_VERSION" \
        "$REPO_ROOT"

    echo "$output"
    assert_equal "$status" 0
}
