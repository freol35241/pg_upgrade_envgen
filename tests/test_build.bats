#!/usr/bin/env bats

setup() {
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )"/.. >/dev/null 2>&1 && pwd )"
}

teardown() {
    docker image prune --force
}


@test "no input" {
    bats_require_minimum_version 1.5.0
    run ! docker build $DIR
}

@test "11-to-13-bullseye" {
    bats_require_minimum_version 1.5.0
    run docker build --no-cache \
        --build-arg PG_TO_VERSION=13 \
        --build-arg PG_FROM_VERSION=11 \
        $DIR

    echo $output
    [ "$status" -eq 0 ]
}

@test "11-to-15-bullseye" {
    bats_require_minimum_version 1.5.0
    run docker build --no-cache \
        --build-arg PG_TO_VERSION=15 \
        --build-arg PG_FROM_VERSION=11 \
        $DIR

    echo $output
    [ "$status" -eq 0 ]
}

