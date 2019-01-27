#! /usr/bin/env sh

main()
{
	readonly TEST=$1

	cd -- "$(CDPATH="" cd -- "$(dirname -- "$0")" && pwd)" || exit 2

	# Extend the PATH
	export PATH=/opt/rakudo-pkg/bin/:$HOME/.perl6/bin:$PATH

	# Check what we're going to test
	case "$TEST" in
		bootstrap:*) sh "./tests/bootstrap.sh" "$TEST" ;;
		prove)       sh "./tests/prove.sh"             ;;
		api)         sh "./tests/api.sh"               ;;
		*)
			printf "%s is not a valid test" "$TEST"
			exit 3
	esac
}

main "$@"
