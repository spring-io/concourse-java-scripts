#!./test/libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

source "$PWD/concourse-java.sh"

@test "cleanup_maven_repo() should delete folder" {
 	local tmpdir=$(mktemp -d $BATS_TMPDIR/m2repo.XXXXXX)
 	mkdir -p "$tmpdir/com/example/foo"
 	touch "$tmpdir/com/example/foo/bar"
	run call_cleanup_maven_repo $tmpdir "com.example.foo"
	assert [ ! -f $tmpdir/com/example/foo/bar ]
}

@test "cleanup_maven_repo() when folder does not exist should continue" {
 	local tmpdir=$(mktemp -d $BATS_TMPDIR/m2repo.XXXXXX)
 	mkdir -p "$tmpdir/com/example/foo"
 	touch "$tmpdir/com/example/foo/bar"
	run call_cleanup_maven_repo $tmpdir "com.example.baz"
	assert [ -f $tmpdir/com/example/foo/bar ]
}

@test "cleanup_maven_repo() when argument is missing should fail" {
 	local tmpdir=$(mktemp -d $BATS_TMPDIR/m2repo.XXXXXX)
	run call_cleanup_maven_repo $tmpdir
	assert [ "$status" -eq 1 ]
  	assert_output "missing cleanup_maven_repo() argument"
}

call_cleanup_maven_repo() {
	M2_LOCAL_REPO=$1
	cleanup_maven_repo $2
}