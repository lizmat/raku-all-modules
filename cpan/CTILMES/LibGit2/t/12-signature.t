use Test;
use LibGit2;

plan 11;

ok my $sig = Git::Signature.new('John Doe <john@nowhere.com> 1517452791 -0500'),
    'new from buffer';

is $sig.name, 'John Doe', 'name';
is $sig.email, 'john@nowhere.com', 'email';
is $sig.when, DateTime.new('2018-01-31T21:39:51-05:00'), 'when';


ok $sig = Git::Signature.new('Jane Roe', 'jane@nowhere.com'), 'new now';

is $sig.name, 'Jane Roe', 'name';
is $sig.email, 'jane@nowhere.com', 'email';


ok $sig = Git::Signature.new('Fred Smith', 'fred@nowhere.com',
                             DateTime.new('2018-01-31T21:39:51-05:00')),
    'new';

is $sig.name, 'Fred Smith', 'name';
is $sig.email, 'fred@nowhere.com', 'email';
is $sig.when, DateTime.new('2018-01-31T21:39:51-05:00'), 'when';

done-testing;
