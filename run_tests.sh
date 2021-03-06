#!/bin/bash

# this script runs all tests/test*.sh files using assert.sh (https://github.com/lehmannro/assert.sh)
# and the helper functions bellow

function log_random() {
	now=$(gdate +"%Y-%M-%dT%T.%N" 2>/dev/null || date +"%Y-%M-%dT%T.%N")
	uuid=$( ( uuidgen 2>/dev/null || python  -c 'import uuid; print uuid.uuid1()' ) 2>/dev/null )
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

persistent=$([ "$1" == "-p" ] && echo 1 || echo 0)

set -e

base=$(cd $(dirname $0) && pwd -P)

. $base/tests/assert.sh -v -i

workdir=$(mktemp -d -t forwarder-tests-XXXXXX)

function _cleanup() {
	local status=$?
	if [ $persistent == 1 ]; then
		 echo "Leaving working dir intact: $workdir"
		 exit $tests_suite_status
	fi

	rm -rf $workdir
	if ! [ $tests_suite_status == 0 ]; then
		echo "Tests failed, execute this script with -p option to leave working directory intact"
	fi
	[ $status = "0" ] && exit $tests_suite_status
	exit $status
}

trap '_cleanup' EXIT

export PATH=$base:$PATH

function run_tests() {
	current_dir=$(pwd)
	for test in $(find tests -name 'test*.sh' | sort); do 
		mkdir -p $workdir/$test
		cd $workdir/$test
		echo Running tests/$test ...
		. $base/$test
		assert_end $test
	done
	cd $current_dir

}

run_tests

