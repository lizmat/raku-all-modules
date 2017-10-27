#! /usr/bin/env sh

main()
{
	cd .. || exit 2

	prove -e "perl6 -Ilib" t
}

main "$@"
