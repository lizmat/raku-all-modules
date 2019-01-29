# UNIX::Privileges #

A module for handling UNIX privileges

## Example ##

Synopsis:

	use UNIX::Privileges;

	UNIX::Privileges::userinfo($user);
	UNIX::Privileges::chown($user, $file);
	UNIX::Privileges::drop($user);
	UNIX::Privileges::chroot($directory);

Example usage:

	use UNIX::Privileges;

	UNIX::Privileges::chown("nobody", "test.txt");
	UNIX::Privileges::drop("nobody");

Example with a chroot:

	use UNIX::Privileges;

	my $user = UNIX::Privileges::userinfo("nobody");
	UNIX::Privileges::chown($user, "/tmp/test.txt");
	UNIX::Privileges::chroot("/tmp");
	# once in the chroot access to the system password file is lost
	# therefore UNIX::Privileges::drop("nobody") will no longer work
	# as the system cannot find the uid or gid of "nobody" anymore
	# fortunately we already have this information in the $user var
	# that we defined above by calling UNIX::Privileges::userinfo
	# just remember you have to do this *before* creating the chroot
	UNIX::Privileges::drop($user);

## Installation

Assuming ypu have a working Rakudo Perl 6 installation you can install
this with *zef* :

    zef install UNIX::Privileges

Some of the tests won't be run unless they are run as 'root', and you
may not be comfortable running a remote installer with escalated
privileges, so you may want to checkout or otherwise download this
package, run the 'root' tests with something like:

   sudo zef test .

(assuming that the Rakudo toolchain is in the global PATH.)


## Support

Please send any suggestions or patches via https://github.com/jonathanstowe/p6-unix-privileges/issues

## License & Copyright

This is free software, please see the [LICENCE](LICENCE) file in the distribution.

© carlin 2015
© Jonathan Stowe 2017 - 2019
