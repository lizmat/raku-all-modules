use v6;
use Test;
use File::Temp;

plan 64;

use-ok 'LMDB';

{
    my $a = LMDB::version;
    like $a, /^LMDB/, "Version $a";
}

{
    use LMDB :flags;
    throws-like {
	LMDB::Env.new('NoSuChDiR');
    }, X::LMDB::LowLevel,		'Directory must exists';

    my $dir = tempdir('mdbt****');
    ok { $dir.IO ~~ :d },		"Created $dir";

    # For author tests
    #$dir = './foo';

    throws-like {
	LMDB::Env.new: $dir, flags => MDB_RDONLY;
    }, X::LMDB::LowLevel,		'For RO must exists';

    my $lmdb = LMDB::Env.new($dir);
    ok $lmdb.defined,			'create environment succeed';
    isa-ok $lmdb, LMDB::Env,		'Is a LMDB::Env';

    is $dir, $lmdb.get-path,		'Can get-path';
    ok "$dir/data.mdb".IO ~~ :e,	'Data file created';
    ok "$dir/lock.mdb".IO ~~ :e,	'Lock file created';

    # Basic environment info from native mdb_env_info
    isa-ok (my $info = $lmdb.info), Map, 'Info is-a Map';
    my %info = $info;
    for <mapaddr mapsize last_pgno last_txnid maxreaders numreaders> {
	ok %info{$_}:exists,		"Info has $_"
    }

    # Expected defaults
    is %info<mapsize>, 1024 * 1024,	'Stock mapsize';
    is %info<maxreaders>, 126,		'Default maxreders';
    is %info<numreaders>, 0,		'No current readers';
    isa-ok %info<mapaddr>, 'NativeCall::Types::Pointer', 'Is a Pointer';
    ok not %info<mapaddr>.defined,	'Not mapfixed';

    # Need a Transaction
    my $Txn = $lmdb.begin-txn;
    ok ?$Txn,				'Alive Txn';
    isa-ok $Txn, LMDB::Env::Txn;

    # This is a simple db, only one unamed db allowed
    # so test some Failure handling
    {
	my $dbi = $Txn.db-open(name => 'NAMED');
	ok not $dbi.defined,		    'Should fail';
	is $dbi.WHAT, Failure,		    'Failure reported';
	ok $dbi.Int ~~ Int,		    'Now handled';
	my $e = $dbi.exception;
	ok $e ~~ X::LMDB::LowLevel,	    'right exception type';
	like $e.message,  /MDB_DBS_FULL/,   'Expected';
	is $e.what, 'db-open',		    'Indeed';
    }

    # Lowlevel open
    my $dbi = $Txn.db-open;
    ok $dbi.defined,			    "DB Opened, handler: $dbi";
    isa-ok $dbi, Int but LMDB::dbi,	    'A guarded Int';

    ok $Txn.put($dbi, 'aKey', 'aValue'),    'basic put works';

    my $unicode = "♠♡♢♣"; # U+2660 .. U+2663
    ok $Txn.put($dbi, 'uKey', $unicode),    'Unicode put works';

    is $Txn.get($dbi, 'aKey'), 'aValue',    'Can get the value';
    is $Txn.get($dbi, 'uKey'), $unicode,    'unicode too';

    # This works too, API closer to C
    $Txn.get($dbi, 'aKey', my $val);
    is $val, 'aValue',			    'The same';

    { # Test generic buf
	use experimental :pack;
	my @items = 'Anita', 0x10000, 'deadbeaf';
	ok $Txn.put($dbi, 'vKey', pack('A5 L H*', @items)),   'With a buf';

	my $buf = $Txn.get($dbi, 'vKey').Blob;
	ok $buf ~~ Blob,		    'A blob';
	is $buf.unpack('A5 L H*'), @items,  'Round-tripped';
    }

    is $Txn.stat($dbi)<entries>, 3,	'All in';

    ok $Txn.commit,			'Commited';
    ok !$Txn,				'Terminated';

    throws-like {
        $Txn.commit;
    }, X::LMDB::TerminatedTxn,		"Can't commit a terminated Txn";

    $Txn = $lmdb.begin-txn;
    ok ?$Txn,				'Alive';

    # Now test the high level
    my $DB = $Txn.opened($dbi);

    my %H := $DB;
    ok %H.defined,			'hash bindable';
    isa-ok %H, LMDB::Env::DB;

    is %H.elems, 3,			'elems';
    is +%H, 3,				'Numeric context';
    is Int(%H), 3,			'As Int';
    ok %H,				'As Bool';

    is %H<aKey>, 'aValue',		'Get';
    ok %H<uKey>:exists,			'Exists';
    ok %H<uKey>:delete,			'Delete';
    ok not $%<uKey>:exists,		'Deleted';

    # Testing direct Buf access
    is %H<vKey>.mv_buff[9..12]
	.map({($_ % 0x100).fmt('%x')})
       .join,	    <deadbeaf>,		'Woow!';

    isa-ok %H.pairs, Seq,		'pairs returns Seq';
    ok %H.pairs.is-lazy,		'a lazy one';

    isa-ok %H.keys, Seq,		'keys returns Seq';
    ok %H.keys.is-lazy,			'a lazy one';

    isa-ok %H.values, Seq,		'values returns Seq';
    ok %H.values.is-lazy,		'a lazy one';

    isa-ok %H.kv, Seq,			'kv returns Seq';
    ok %H.kv.is-lazy,			'a lazy one';

    diag 'To be continued...';
}
