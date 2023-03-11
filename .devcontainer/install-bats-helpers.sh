#!/bin/bash

[ -d bats-helpers ] && rm -rf bats-helpers

mkdir -p bats-helpers

git clone --depth 1 https://github.com/bats-core/bats-support.git bats-helpers/bats-support || true
git clone --depth 1 https://github.com/bats-core/bats-assert.git bats-helpers/bats-assert || true
git clone --depth 1 https://github.com/bats-core/bats-file.git bats-helpers/bats-file || true