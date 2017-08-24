#!./test/libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

source "$PWD/concourse-java.sh"

@test "get_revision_from_pom() should get revision" {
	local tmpdir=$(mktemp -d $BATS_TMPDIR/pom.XXXXXX)
	cp test/fixtures/pom_with_revision.xml $tmpdir/pom.xml
	cd $tmpdir
	run get_revision_from_pom
	assert_equal $output "1.0.0-SNAPSHOT"
}

@test "get_revision_from_pom() when no revision should fail" {
	local tmpdir=$(mktemp -d $BATS_TMPDIR/pom.XXXXXX)
	cp test/fixtures/pom_without_revision.xml $tmpdir/pom.xml
	cd $tmpdir
	run get_revision_from_pom
	assert [ "$status" -eq 10 ]
}
