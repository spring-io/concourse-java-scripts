#!/bin/bash
set -e

export TERM=dumb

pushd git-repo
	./test.sh
popd