#!./test/libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

source "$PWD/concourse-java.sh"

@test "run_maven() should show limited output" {
	cd test/mock/mvnw/success
	run run_maven clean install
	local lineCount=$( echo "$output" | wc -l)
	assert [ "${lines[0]}" = "./mvnw clean install" ]
	assert_equal $lineCount 13
}

@test "run_maven() when fails should show tail" {
	cd test/mock/mvnw/failure
	run run_maven clean install
	local lineCount=$( echo "$output" | wc -l)
	assert [ "${lines[0]}" = "./mvnw clean install" ]
	assert_equal $lineCount 789
}
