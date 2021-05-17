#!/bin/sh

function test { ../../vib < "$1" | sed 's/^\s*\|[^-~]//g; /^$/d'; }

function check {
	if [ "$(test $1.html)" = "$(cat $1)" ]; then
		echo "Passed $1"
	else
		echo "Failed $1"
		diff -y <(test $1.html) "$1"
	fi
}

check www.google.com
check 1lib.us
check stackoverflow.com
