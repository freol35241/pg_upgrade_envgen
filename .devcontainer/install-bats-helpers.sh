#!/bin/bash

mkdir -p bats-helpers

git clone --depth 1 https://github.com/bats-core/bats-support.git bats-helpers/bats-support || true
git clone --depth 1 https://github.com/bats-core/bats-assert.git bats-helpers/bats-assert || true
git clone --depth 1 https://github.com/ztombol/bats-file.git bats-helpers/bats-file || true