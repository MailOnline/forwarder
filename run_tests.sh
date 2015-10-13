#!/bin/bash

# this script runs all tests/test*.sh files using assert.sh (https://github.com/lehmannro/assert.sh)
# and the helper functions bellow

function log_random() {
	now=$(gdate +"%Y-%M-%dT%T.%N" 2>/dev/null || date +"%Y-%M-%dT%T.%N")
	uuid=$( ( uuidgen 2>/dev/null || python  -c 'import uuid; print uuid.uuid1(), "(from python)"' ) 2>/dev/null )
	echo $uuid > .last_uuid
	echo $now > .last_timestamp
	echo "$now And this is a UUID just to ensure this line is unique: $uuid"
}

function last_uuid() {
	cat .last_uuid
}

function last_timestamp() {
	cat .last_timestamp
}

function count_bytes() {
	echo $(cat $1 | wc -c | xargs)
}

function count_lines() {
	echo $(cat $1 | wc -l | xargs)
}

set -e

base=$(cd $(dirname $0) && pwd -P)

. $base/tests/assert.sh -v -i

workdir=$(mktemp -d -t forwarder-tests)
trap "[ -d $workdir ] && echo Tests failed, so not cleaning workdir: $workdir" EXIT

export PATH=$base:$PATH

function run_tests() {
	current_dir=$pwd
	for test in $(find tests -name 'test*.sh'); do 
		mkdir -p $workdir/$test
		cd $workdir/$test
		. $base/$test
	done
	cd $pwd

	assert_end forwarder 
}

run_tests

[ $tests_suite_status == 0 ] && rm -rf $workdir
