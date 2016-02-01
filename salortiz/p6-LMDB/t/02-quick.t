use v6;
use Test;
use File::Temp;

plan 3;

use LMDB;

my $dir = tempdir('mdbt*****');
{
    my %DB;

    lives-ok { %DB := LMDB::DB.open(path => $dir); }, 'Opened';

    %DB<A B C D E> = <a b c d e>;

    is %DB.kv.flat, <A a B b C c D d E e>, 'All in';

    lives-ok { %DB.commit },		'Commited'
}
