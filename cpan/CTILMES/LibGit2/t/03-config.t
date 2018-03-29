use Test;
use File::Temp;
use LibGit2;

my ($config_file, $filehandle) = tempfile;

ok my $config = Git::Config.new, 'new';

lives-ok { $config.add-file-ondisk($config_file, GIT_CONFIG_LEVEL_APP) },
    'add-file-ondisk';

lives-ok { $config.set('foo.bar', 'this') }, 'set string';
lives-ok { $config.set('a.b', True)       }, 'set bool true';
lives-ok { $config.set('a.c', False)      }, 'set bool false';
lives-ok { $config.set('b.d', 27)         }, 'set int';

ok my $conf2 = Git::Config.new, 'second config';

lives-ok { $conf2.add-file-ondisk($config_file, GIT_CONFIG_LEVEL_APP) },
    'add-file-ondisk';

ok my $entry = $conf2.get-entry('foo.bar'), 'get-entry';
is $entry.name, 'foo.bar', 'entry name';
is $entry.value, 'this', 'entry value';
is $entry.level, GIT_CONFIG_LEVEL_APP, 'entry level';

my %config = $conf2.get-all.map({ $_.name => $_.value });

is %config<foo.bar>, 'this', 'get string';
is %config<a.b>, 'true', 'get bool true';
is %config<a.c>, 'false', 'get bool false';
is %config<b.d>, 27, 'get int';

is $conf2<foo.bar>, 'this', 'associative get';
is $conf2<missing.config>, Nil, 'associate get missing';

is $conf2<foo.bar>:exists, True, 'associative exists';
is $conf2<missing.config>:exists, False, 'associative exists missing';

is $conf2<foo.bar>:delete, 'this', 'associative delete';
is $conf2<missing.config>:delete, Nil, 'associative delete missing';

is $conf2<foo.bar>, Nil, 'associative deleted';

done-testing;

