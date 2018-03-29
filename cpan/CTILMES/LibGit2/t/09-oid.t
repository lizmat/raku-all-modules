use Test;
use LibGit2;

plan 7;

ok my $oid = Git::Oid.new, 'new';

is $oid, '0000000000000000000000000000000000000000', 'Str';

is $oid.is-zero, True, 'is-zero';

ok $oid = Git::Oid.new('0123456789abcdef0123456789abcdef01234567'),
    'new from string';

is $oid, '0123456789abcdef0123456789abcdef01234567', 'round trip';

is $oid.is-zero, False, 'is not zero';

throws-like { $oid = Git::Oid.new('0123456789abcdef0123456789abcdef0123456') },
    X::Git, 'bad oid string', message => /:s unable to parse/;

done-testing;
