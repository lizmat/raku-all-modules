use v6;

use lib;
use Growl::GNTP;

my $a = Growl::GNTP.new;
$a.register(
    application   => 'gntp-send',
    notifications => [
		{name => 'default'},
    ]
);
$a.notify(
	application => 'gntp-send',
	name        => 'default',
	title       => 'blah',
	text        => 'BLAH',
);
