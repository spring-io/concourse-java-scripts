#!./test/libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

source "$PWD/concourse-java.sh"

@test "setup_symlinks() should symlink home .m2 to maven" {
 	local tmpdir=$(mktemp -d $BATS_TMPDIR/slinks.XXXXXX)
	mkdir -p "$tmpdir/symlink_pwd/maven"
	mkdir -p "$tmpdir/symlink_home"
	run call_setup_symlinks $tmpdir
	touch "$tmpdir/symlink_home/.m2/foo"
	assert [ -f "$tmpdir/symlink_pwd/maven/foo" ]
}

@test "setup_symlinks() should symlink home .gradle to gradle" {
 	local tmpdir=$(mktemp -d $BATS_TMPDIR/slinks.XXXXXX)
	mkdir -p "$tmpdir/symlink_pwd/gradle"
	mkdir -p "$tmpdir/symlink_home"
	run call_setup_symlinks $tmpdir
	touch "$tmpdir/symlink_home/.gradle/foo"
	assert [ -f "$tmpdir/symlink_pwd/gradle/foo" ]
}

@test "setup_symlinks() when has no local maven should not add .m2 symlink" {
 	local tmpdir=$(mktemp -d $BATS_TMPDIR/slinks.XXXXXX)
	mkdir -p "$tmpdir/symlink_pwd"
	mkdir -p "$tmpdir/symlink_home"
	run call_setup_symlinks $tmpdir
	assert [ ! -d "$tmpdir/symlink_home/.m2" ]
}

@test "setup_symlinks() when has no local gradle should not add .gradle symlink" {
 	local tmpdir=$(mktemp -d $BATS_TMPDIR/slinks.XXXXXX)
	mkdir -p "$tmpdir/symlink_pwd"
	mkdir -p "$tmpdir/symlink_home"
	run call_setup_symlinks $tmpdir
	assert [ ! -d "$tmpdir/symlink_home/.gradle" ]
}

@test "setup_symlinks() when already has .m2 should not add symlink" {
 	local tmpdir=$(mktemp -d $BATS_TMPDIR/slinks.XXXXXX)
	mkdir -p "$tmpdir/symlink_pwd/maven"
	mkdir -p "$tmpdir/symlink_home/.m2"
	run call_setup_symlinks $tmpdir
	touch "$tmpdir/symlink_home/.m2/foo"
	assert [ ! -f "$tmpdir/symlink_pwd/maven/foo" ]
}

@test "setup_symlinks() when already has .gradle should not add symlink" {
 	local tmpdir=$(mktemp -d $BATS_TMPDIR/slinks.XXXXXX)
	mkdir -p "$tmpdir/symlink_pwd/gradle"
	mkdir -p "$tmpdir/symlink_home/.gradle"
	run call_setup_symlinks $tmpdir
	touch "$tmpdir/symlink_home/.gradle/foo"
	assert [ ! -f "$tmpdir/symlink_pwd/gradle/foo" ]
}

call_setup_symlinks() {
	cd "$1/symlink_pwd"
	export HOME="$1/symlink_home"
	setup_symlinks
}