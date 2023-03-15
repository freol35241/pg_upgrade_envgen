#!/usr/bin/env bats

load "../bats-helpers/bats-support/load"
load "../bats-helpers/bats-assert/load"
load "../bats-helpers/bats-file/load"

setup() {
    REPO_ROOT="$( cd "$( dirname "$BATS_TEST_FILENAME" )"/.. >/dev/null 2>&1 && pwd )"
    TMP_DIR="$(temp_make)"
    OLD="${TMP_DIR}/old/data"
    NEW="${TMP_DIR}/new/data"
    mkdir -p "$OLD"
    mkdir -p "$NEW"
}

teardown() {
    rm -rf "$TMP_DIR"
    (docker ps -aq | xargs docker stop | xargs docker rm) || :
    (docker image ls -aq | xargs docker rmi) || :
}

@test "pg11-to-pg13-NO-pg_upgrade" {

    # Start a container running the old postgres instance
    docker run -d \
        --name pg_old \
        -e POSTGRES_HOST_AUTH_METHOD=trust \
        -v "$OLD":/var/lib/postgresql/data \
        "postgres:11"

    echo 'Container with old postgres instance started!'

    # Give it some slack time to start approprietly
    sleep 5

    # Input som data
    docker exec \
        -u postgres \
	    pg_old \
	    pgbench -i -s 10

    echo 'Data inputted using pgbench...'

    docker stop pg_old && docker rm pg_old

    # Start a container running the new postgres instance but try to mount the OLD directory
    docker run -d \
        --name pg_new \
        -e POSTGRES_HOST_AUTH_METHOD=trust \
        -v "$OLD":/var/lib/postgresql/data \
        "postgres:13"

    # Give it some slack time to start approprietly
    sleep 5

    echo 'Started! Check that it fails...'

    run docker logs pg_new
    echo "$output"

    assert_equal "$( docker container inspect -f '{{.State.Status}}' pg_new )" "exited"

}

@test "pg11-to-pg13" {

    # Start a container running the old postgres instance
    docker run -d \
        --name pg_old \
        -e POSTGRES_HOST_AUTH_METHOD=trust \
        -v "$OLD":/var/lib/postgresql/data \
        "postgres:11"

    echo 'Container with old postgres instance started!'

    # Give it some slack time to start approprietly
    sleep 5

    # Input som data
    docker exec \
        -u postgres \
	    pg_old \
	    pgbench -i -s 10

    echo 'Data inputted using pgbench...'

    docker stop pg_old && docker rm pg_old

    echo 'Old instance terminated.'

    # Build the pg_upgrade environment
    run docker build --no-cache \
        --tag pg_upgrade_env \
        --build-arg DEBIAN_VERSION=bullseye \
        --build-arg PG_FROM_VERSION=11 \
        --build-arg PG_TO_VERSION=13 \
        "$REPO_ROOT"

    echo "$output"
    assert_equal "$status" 0

    echo 'pg_upgrade_envgen has been run successfully!'

    # Run pg_upgrade using the built pg_upgrade_env
    run docker run --rm \
	    -v "$OLD":/var/lib/postgresql/11/data \
	    -v "$NEW":/var/lib/postgresql/13/data \
	    pg_upgrade_env

    echo "$output"
    assert_equal "$status" 0

    echo 'pg_upgrade ran successfully! Starting container with new postgres instance!'

    # Start a container running the new postgres instance
    docker run -d \
        --name pg_new \
        -e POSTGRES_HOST_AUTH_METHOD=trust \
        -v "$NEW":/var/lib/postgresql/data \
        "postgres:13"

    # Give it some slack time to start approprietly
    sleep 5

    echo 'Started! Checking for successful boot...'

    run docker logs pg_new

    echo "$output"
    assert_equal "$( docker container inspect -f '{{.State.Status}}' pg_new )" "running"

}
