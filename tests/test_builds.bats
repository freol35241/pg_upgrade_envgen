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
    run ! docker build "$REPO_ROOT"
}

@test "parametric test builds" {

    COMBINATIONS=(
        "bullseye 11 13"
        "buster 11 13"
    )

    final_status=0

    for element in "${COMBINATIONS[@]}"; do
        # shellcheck disable=SC2162
        read -a combo <<< "$element"  # uses default whitespace IFS
        DEBIAN_VERSION=${combo[0]} PG_FROM_VERSION=${combo[1]} PG_TO_VERSION=${combo[2]} TIMESCALEDB_VERSION=${combo[3]} POSTGIS_VERSION=${combo[4]} run bats -t tests/parametric_tests/test_build.bats

        for line in "${lines[@]}"; do
            echo "# ${line}" >&3
        done
        echo "#" >&3

        final_status=$(("$final_status" + "$status"))
    done

    assert_equal "$final_status" 0

}
