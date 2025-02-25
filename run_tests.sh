#!/bin/bash

. prepare_tests_env.sh

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

function _run_tests() {
  for test in $(find tests -name $1 | sort); do
    countOnly=$((countOnly+1))
    mkdir -p $workdir/$test
    cd $workdir/$test
    echo Running tests/$test ...
    . $base/$test
    assert_end $test
  done
}

function run_tests() {
	current_dir=$(pwd)
	_run_tests 'only-test*.sh'
	cd $current_dir
  find $workdir -mindepth 1 -maxdepth 1 | read || _run_tests 'test*.sh'
	cd $current_dir
}

run_tests

