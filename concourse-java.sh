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

# Update the revision tag in a POM file
set_revision_to_pom() {
	[[ -n $1 ]] || { echo "missing set_revision_to_pom() argument" >&2; return 1; }
	grep -q "<revision>.*</revision>" pom.xml || { echo "missing revision tag" >&2; return 1; }
	sed -ie "s|<revision>.*</revision>|<revision>${1}</revision>|" pom.xml > /dev/null
}

# Get the next milestone release for the given number by inspecting current tags
get_next_milestone_release() {
	[[ -n $1 ]] || { echo "missing get_next_milestone_release() version argument" >&2; return 1; }
	get_next_tag_based_release "$1" "M"
}

# Get the next RC release for the given number by inspecting current tags
get_next_rc_release() {
	[[ -n $1 ]] || { echo "missing get_next_rc_release() version argument" >&2; return 1; }
	get_next_tag_based_release "$1" "RC"
}

# Get the next release for the given number
get_next_release() {
	[[ -n $1 ]] || { echo "missing get_next_release() version argument" >&2; return 1; }
	if [[ $1 =~ ^(.*)\.BUILD-SNAPSHOT$ ]]; then
		local join="."
	else
		local join="-"
	fi
	local version
	local result
	version=$( strip_snapshot_suffix "$1" )
	if [[ -n $2 ]]; then
	  result="${version}${join}${2}"
	else
	  result="${version}"
	fi
	echo $result
}

# Get the next milestone or RC release for the given number by inspecting current tags
get_next_tag_based_release() {
	[[ -n $1 ]] || { echo "missing get_next_tag_based_release() version argument" >&2; return 1; }
	[[ -n $2 ]] || { echo "missing get_next_tag_based_release() tag type argument" >&2; return 1; }
	if [[ $1 =~ ^(.*)\.BUILD-SNAPSHOT$ ]]; then
		local join="."
	else
		local join="-"
	fi
	local version
	local last
	version=$( strip_snapshot_suffix "$1" )
	git fetch --tags --all > /dev/null
	last=$( git tag --list "v${version}${join}${2}*" | sed -E "s/^.*${2}([0-9]+)$/\1/g" | sort -rn | head -n1 )
	if [[ -z $last ]]; then
		last="0"
	fi
	last="${version}${join}${2}${last}"
	bump_version_number "$last"
}

# Bump version number by incrementing the last numeric, RC or M token
bump_version_number() {
	local version=$1
	[[ -n $version ]] || { echo "missing bump_version_number() argument" >&2; return 1; }
	if [[ $version =~ ^(.*(\.|-)([A-Za-z]+))([0-9]+)$ ]]; then
		local prefix=${BASH_REMATCH[1]}
		local suffix=${BASH_REMATCH[4]}
		(( suffix++ ))
		echo "${prefix}${suffix}"
		return 0;
	fi
	local suffix
	if [[ $version =~ ^(.*)(\-SNAPSHOT)$ ]]; then
		version=${BASH_REMATCH[1]}
		suffix="-SNAPSHOT"
	fi
	tokens=(${version//\./ })
	local bumpIndex
	for i in "${!tokens[@]}"; do
		if [[ "${tokens[$i]}" =~ ^[0-9]+$ ]] ; then
			bumpIndex=$i
		fi
	done
	[[ -n $bumpIndex ]] || { echo "unsupported version number" >&2; return 1; }
	(( tokens[bumpIndex]++ ))
	local bumpedVersion
	IFS=. eval 'bumpedVersion="${tokens[*]}"'
	echo "${bumpedVersion}${suffix}"
}

# Remove any "-SNAPSHOT" or ".BUILD-SNAPSHOT" suffix
strip_snapshot_suffix() {
	[[ -n $1 ]] || { echo "missing get_relase_version() argument" >&2; return 1; }
	if [[ $1 =~ ^(.*)\.BUILD-SNAPSHOT$ ]]; then
		echo "${BASH_REMATCH[1]}"
	elif [[ $1 =~ ^(.*)-SNAPSHOT$ ]]; then
		echo "${BASH_REMATCH[1]}"
	else
		echo "$1"
	fi
}
