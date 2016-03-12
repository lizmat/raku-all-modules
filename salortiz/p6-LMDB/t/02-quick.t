use v6;
use Test;
use File::Temp;

plan 14;

use LMDB :ALL;

my $dir = tempdir('mdbt*****');
my $Env;
{
    my %DB;

    throws-like {
	DB.open;
    }, X::LMDB::MutuallyExcludedArgs,	'No args provided';

    lives-ok { %DB := DB.open(path => $dir) }, 'Opened';

    %DB<A B C D E> = <a b c d e>;

    is %DB.kv.flat, <A a B b C c D d E e>,     'All in';

    ok all(%DB<A B C D E>:exists),	'exists works';
    ok all(%DB<F G>:!exists),		'!exists works';

    for %DB {
	ok .key.lc eq .value,		"Iterating over $_"
    };

    $Env = %DB.Env;
    ok $Env,				'Env retrieved';

    lives-ok { %DB.commit },		'Commited'
}
{
    throws-like {
	DB.open(Env => $Env, path => $dir);
    }, X::LMDB::MutuallyExcludedArgs,	'Both args provided';

    my %DB;
    lives-ok { %DB := DB.open(Env => $Env):ro }, 'Opened (Read-Only)';
}
