#!/bin/bash

# ============================================================================
# Concourse Java Support (https://github.com/philwebb/concourse-java-scripts/)
#
# Importing scripts should use as follows:
#
#     #!/bin/bash
#     set -e
#     source <folder>/concourse-java.sh
#
# ============================================================================

# Setup Maven and Gradle symlinks for caching
setup_symlinks() {
	if [[ -d $PWD/maven && ! -d $HOME/.m2 ]]; then
		ln -s "$PWD/maven" "$HOME/.m2"
	fi
	if [[ -d $PWD/gradle && ! -d $HOME/.gradle ]]; then
		ln -s "$PWD/gradle" "$HOME/.gradle"
	fi
}

# Cleanup a local maven repo. For example `cleanup_maven_repo "org.springframework.boot"`
cleanup_maven_repo() {
	M2_LOCAL_REPO=${M2_LOCAL_REPO:-/${HOME}/.m2/repository}
	[[ -n $1 ]] || { echo "missing cleanup_maven_repo() argument" >&2; return 1; }
	local repoPath
	repoPath="${M2_LOCAL_REPO}"/$(echo "$1" | tr . /)
	if [[ -d "$repoPath" ]]; then
		echo "Cleaning local maven repo \"$1\""
		rm -fr "$repoPath" 2> /dev/null || :
	fi
}

# Run maven, tailing relevant output and printing the last part of the log on error
run_maven() {
	echo "./mvnw $*" > build.log
	( ( tail -n 0 -q -f build.log & echo $! >&3 ) 3>pid | grep -v --color=never "\] \[INFO\]\|Building\ jar" | grep --color=never "\[INFO.*---\|Building\ \|SUCCESS\|Total\ time\|Finished\ at\|Final\ Memory" & )
	echo "./mvnw $*"
	./mvnw "$@" >> build.log 2>&1 || (kill "$(<pid)" && sleep 1 && tail -n 3000 build.log && exit 1)
	kill "$(<pid)"
	sleep 1
}

# Get the revision from a POM file
get_revision_from_pom() {
	xmllint --xpath '/*[local-name()="project"]/*[local-name()="properties"]/*[local-name()="revision"]/text()' pom.xml
}