#!/usr/bin/env bats

load "../bats-helpers/bats-support/load"
load "../bats-helpers/bats-assert/load"

setup() {
    REPO_ROOT="$( cd "$( dirname "$BATS_TEST_FILENAME" )"/.. >/dev/null 2>&1 && pwd )"
}

teardown() {
    (docker image ls -aq | xargs docker rmi) || :
}


@test "no input" {
    bats_require_minimum_version 1.5.0
    run ! docker build $REPO_ROOT
}

@test "11-to-13-bullseye" {
    bats_require_minimum_version 1.5.0
    run docker build --no-cache \
        --build-arg DEBIAN_VERSION=bullseye \
        --build-arg PG_FROM_VERSION=11 \
        --build-arg PG_TO_VERSION=13 \
        $REPO_ROOT

    echo $output
    assert_equal "$status" 0
}

@test "11-to-15-bullseye" {
    bats_require_minimum_version 1.5.0
    run docker build --no-cache \
        --build-arg DEBIAN_VERSION=bullseye \
        --build-arg PG_FROM_VERSION=11 \
        --build-arg PG_TO_VERSION=15 \
        $REPO_ROOT

    echo $output
    assert_equal "$status" 0
}

@test "11-to-13-buster-tsdb2.3.0" {
    bats_require_minimum_version 1.5.0
    run docker build --no-cache \
        --build-arg DEBIAN_VERSION=buster \
        --build-arg PG_FROM_VERSION=11 \
        --build-arg PG_TO_VERSION=13 \
        --build-arg TIMESCALEDB_VERSION=2.3.0 \
        $REPO_ROOT

    echo $output
    assert_equal "$status" 0
}

@test "12-to-15-bullseye-tsdb2.10" {
    bats_require_minimum_version 1.5.0
    run docker build --no-cache --progress=plain \
        --build-arg DEBIAN_VERSION=bullseye \
        --build-arg PG_FROM_VERSION=12 \
        --build-arg PG_TO_VERSION=15 \
        --build-arg TIMESCALEDB_VERSION=2.10 \
        $REPO_ROOT

    echo $output
    assert_equal "$status" 0

}


