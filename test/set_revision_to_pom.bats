#!./test/libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

source "$PWD/concourse-java.sh"

@test "set_revision_to_pom() should set revision" {
	local tmpdir=$(mktemp -d $BATS_TMPDIR/pom.XXXXXX)
	cp test/fixtures/pom_with_revision.xml $tmpdir/pom.xml
	cd $tmpdir
	run set_revision_to_pom "2.3.4-SNAPSHOT"
	cat pom.xml
	grep -q "2\.3\.4-SNAPSHOT" pom.xml
}

@test "set_revision_to_pom() when missing version argument should fail" {
	local tmpdir=$(mktemp -d $BATS_TMPDIR/pom.XXXXXX)
	cp test/fixtures/pom_with_revision.xml $tmpdir/pom.xml
	cd $tmpdir
	run set_revision_to_pom
	assert_output "missing set_revision_to_pom() argument"
	assert [ "$status" -eq 1 ]
}


@test "set_revision_to_pom() when pom has not revision tag should fail" {
	local tmpdir=$(mktemp -d $BATS_TMPDIR/pom.XXXXXX)
	cp test/fixtures/pom_without_revision.xml $tmpdir/pom.xml
	cd $tmpdir
	run set_revision_to_pom "2.3.4-SNAPSHOT"
	assert_output "missing revision tag"
	assert [ "$status" -eq 1 ]
}
