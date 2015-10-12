#!/bin/bash

# this script runs all tests/test*.sh files using assert.sh (https://github.com/lehmannro/assert.sh)

set -e

base=$(dirname $0)/tests

. $base/assert.sh

sender=$base/../sender
workdir=$(mktemp -d -t forwarder-tests)
trap "[ -d $workdir ] && echo Tests failed, so not cleaning workdir: $workdir" EXIT

assert_raises "$sender | grep Usage: &> /dev/null"

for test in $(find tests -name 'test*.sh'); do 
	cd $(dirname $test)
	. $(basename $test)
	cd --
done

assert_end forwarder 
[ $tests_suite_status == 0 ] && rm -rf $workdir
