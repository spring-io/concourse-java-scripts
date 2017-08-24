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
