use v6;
use Test;
use File::Temp;

plan 19;

use LMDB :ALL;

sub comparer(Str $a, Str $b) { $a.lc cmp $b.lc }

my $dir = tempdir('mdbt*****');
my $Env = LMDB::Env.new($dir):5maxdbs;
{
    ok DB.open(:$Env).stat<entries> == 0,	'No entries';
    lives-ok { $Env.txn.abort },		'Abort';
    # Internal testing
    is $Env._deep, 0;
}
{
    throws-like {
	DB.open(:$Env):name<SOME>;
    }, X::LMDB::LowLevel,
       :message(/NOTFOUND/),:what<db-open>,	'No created yet';

    lives-ok { $Env.txn.commit },		'Commit'
}
{
    my %DB;
    lives-ok {
	%DB := DB.open(:$Env):name<SOME>:create:comparer(&comparer);
    },						'SOME DB Created';
    is %DB.dbi, 2,				'Not MAIN';
    %DB<EV DW CX BY AZ> = <5 4 3 2 1>;
    is %DB.kv.flat, <AZ 1 BY 2 CX 3 DW 4 EV 5>,	'The ordered data';
    ok all(%DB<az by cx dw ev>:exists),		'But is case insentive';
    is %DB<cx>, 3,				'Value right';
    is %DB.elems, 5,				'Count right';

    my %DBR;
    lives-ok {
	%DBR := DB.open(:$Env):name<R>:create:flags(MDB_REVERSEKEY);
    },						'Other Opened';
    ok %DB.Txn === %DBR.Txn,			'Same Txn';

    is %DBR.dbi, 3,				'A new one';
    %DBR<AZ BY CX DW EV> = <1 2 3 4 5>;
    is %DBR.kv.flat, <EV 5 DW 4 CX 3 BY 2 AZ 1>,'Reversed order data';
    is %DBR.elems, 5,				'Count right';

    lives-ok {
	%DB.commit;
    },						'Commited';

    ok not %DBR.Txn,				'Was same';
    is $Env._deep, 0,				'No TXNs';

}
