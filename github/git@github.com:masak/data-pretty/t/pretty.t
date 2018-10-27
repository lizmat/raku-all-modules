use Data::Pretty;
use Test;

# arrays
is [1, 2, 3].gist, '[1, 2, 3]', "pretty arrays";
is [1, [2, 3]].gist, '[1, [2, 3]]', "pretty nested arrays";

# parcels
is (1, 2, 3).gist, '(1, 2, 3)', "pretty parcels";
is list(1, 2, 3).gist, '(1, 2, 3)', "pretty list() parcels";

# hashes
is { foo => 2 }.gist, '{"foo" => 2}', "pretty hashes";
is hash("foo", 2).gist, '{"foo" => 2}', "pretty hash() hashes";

# subs
is sub foo {}.gist, '&foo', "pretty subs";
is sub {}.gist, '&<anon>', "pretty anon subs";

# regexes
is /abc/.gist, '<regex>', "pretty regexes";

done;
