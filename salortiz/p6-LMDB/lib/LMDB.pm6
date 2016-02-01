use v6;

use NativeCall :ALL;

unit module LMDB:ver<0.0.1>;

sub MyLibName {
    %*ENV<LIBLMDB> || guess_library_name(('lmdb',v0.0.0));
}

constant LIB = &MyLibName;

my enum  EnvFlag is export(:flags) (
    MDB_FIXEDMAP    => 0x01,
    MDB_NOSUBDIR    => 0x4000,
    MDB_NOSYNC	    => 0x10000,
    MDB_RDONLY	    => 0x20000,
    MDB_NOMETASYNC  => 0x40000,
    MDB_WRITEMAP    => 0x80000,
    MDB_MAPASYNC    => 0x100000,
    MDB_NOTLS	    => 0x200000,
    MDB_NOLOCK	    => 0x400000,
    MDB_NORDAHEAD   => 0x800000
);

my enum DbFlag is export(:flags) (
    MDB_REVERSEKEY  => 0x02,
    MDB_DUPSORT	    => 0x04,
    MDB_INTEGERKEY  => 0x08,
    MDB_DUPFIXED    => 0x10,
    MDB_INTEGERDUP  => 0x20,
    MDB_REVERSEDUP  => 0x40,
    MDB_CREATE	    => 0x40000
);

my enum cursor-op is export (
    'MDB_FIRST',	  # Position at first key/data item
    'MDB_FIRST_DUP',      # Position at first data item of current key.
			  #    Only for #MDB_DUPSORT
    'MDB_GET_BOTH',       # Position at key/data pair. Only for #MDB_DUPSORT
    'MDB_GET_BOTH_RANGE', # position at key, nearest data. Only for #MDB_DUPSORT
    'MDB_GET_CURRENT',    # Return key/data at current cursor position
    'MDB_GET_MULTIPLE',   # Return key and up to a page of duplicate data items
                          # from current cursor position. Move cursor to prepare
			  #    for #MDB_NEXT_MULTIPLE. Only for #MDB_DUPFIXED
    'MDB_LAST',           # Position at last key/data item
    'MDB_LAST_DUP',       # Position at last data item of current key.
                          #    Only for #MDB_DUPSORT
    'MDB_NEXT',           # Position at next data item
    'MDB_NEXT_DUP',       # Position at next data item of current key.
			  #    Only for #MDB_DUPSORT
    'MDB_NEXT_MULTIPLE',  # Return key and up to a page of duplicate data items
			  #    from next cursor position. Move cursor to prepare
			  #    for #MDB_NEXT_MULTIPLE. Only for #MDB_DUPFIXED
    'MDB_NEXT_NODUP',     # Position at first data item of next key
    'MDB_PREV',           # Position at previous data item
    'MDB_PREV_DUP',       # Position at previous data item of current key.
			  #     Only for #MDB_DUPSORT
    'MDB_PREV_NODUP',     # Position at last data item of previous key
    'MDB_SET',            # Position at specified key
    'MDB_SET_KEY',        # Position at specified key, return key + data
    'MDB_SET_RANGE'       # Position at first key greater than or equal to
                          # specified key.
);

my enum errors is export (
    MDB_SUCCESS		=> 0,
    MDB_KEYEXIST	=> -30799,
    MDB_NOTFOUND	=> -30798,
    MDB_PAGE_NOTFOUND	=> -30797,
    MDB_CORRUPTED	=> -30796,
    MDB_PANIC		=> -30795,
    MDB_VERSION_MISMATCH => -30794,
    MDB_INVALID		=> -30793,
    MDB_MAP_FULL	=> -30792,
    MDB_DBS_FULL	=> -30791,
    MDB_READERS_FULL	=> -30790,
    MDB_TLS_FULL	=> -30789,
    MDB_TXN_FULL	=> -30788,
    MDB_CURSOR_FULL	=> -30787,
    MDB_PAGE_FULL	=> -30786,
    MDB_MAP_RESIZED	=> -30785,
    MDB_INCOMPATIBLE	=> -30784,
    MDB_BAD_RSLOT	=> -30783,
    MDB_BAD_TXN		=> -30782,
    MDB_BAD_VALSIZE	=> -30781,
    MDB_BAD_DBI		=> -30780,
);

my class MDB-val is repr('CStruct') {
    has size_t		$.mv_size;
    has CArray[uint8]	$.mv_buff;

    submethod BUILD(CArray[uint8] :$mv_buff) {
	$!mv_size = $mv_buff.elems;
	$!mv_buff := $mv_buff;
    }
    method new-from-buf(Blob $b) {
	self.bless(mv_buff => CArray[uint8].new($b.list));
    }
    method new-from-str(Str $str) {
	self.new-from-buf($str.encode('utf8'));
    }
    method new-from-any(Any $any) {
	given $any {
	    when Mu  { ::?CLASS.new }
	    when Buf { ::?CLASS.new-from-buf($any); }
	    default  { ::?CLASS.new-from-str(~$any); }
	}
    }
    method Blob() {
	Blob.new($!mv_buff[0 .. ($!mv_size-1)]);
    }
    method Str() {
	self.Blob.decode('utf8');
    }
}

my class MDB-stat is repr('CStruct') {
    has uint32 $.ms_psize;
    has uint32 $.ms_depth;
    has size_t $.ms_branch_pages;
    has size_t $.ms_leaf_pages;
    has size_t $.ms_overflow_pages;
    has size_t $.ms_entries;
}

my class MDB-envinfo is repr('CStruct') {
    has Pointer $.me_mapaddr;
    has size_t  $.me_mapsize;
    has size_t  $.me_last_pgno;
    has size_t  $.me_last_txnid;
    has uint32  $.me_maxreaders;
    has uint32  $.me_numreaders;
}


my sub mdb_strerror(int32) returns Str is native(LIB) { * };

package GLOBAL::X::LMDB {
# Our exceptions
    our class TerminatedTxn is Exception is export {
	method message() { 'Terminated Transaction' }
    }


    our class LowLevel is Exception is export {
#   For errors reported by the lowlevel C library
	has Int $.code;
	has Str $.what;
	submethod BUILD(:$!code, :$!what) { };
	method message() {
	    my $msg;
	    $msg ~= "{$!what}: ";
	    $msg ~= mdb_strerror($!code);
	}
    }
}

my sub mdb_version(Pointer[int32] is rw, Pointer[int32] is rw, Pointer[int32] is rw)
    returns Str is native(LIB) { ... };

our sub version() {
    my $res = mdb_version(
	my Pointer[int32] $mayor .= new,
	my Pointer[int32] $minor .= new,
	my Pointer[int32] $patch .= new
    );
    $res;
}

our role dbi { }; # Used as a guard

our class Env {
    class MDB_env is repr('CPointer') is Any {
	sub mdb_env_create(Pointer[MDB_env] is rw)
	    returns int32 is native(LIB) { * };
	method new() {
	    if mdb_env_create(my Pointer[MDB_env] $p .= new) -> $code {
		X::LMDB::LowLevel.new(:$code, :what<Can't create>).fail;
	    }
	    $p.deref
	}
    }

    sub mdb_env_close(MDB_env) is native(LIB) { };

    our class Txn { ... };
    trusts Txn;

    has MDB_env $!env;
    method !env { $!env };

    has Txn @.txns;

    our class DB { ... };

    submethod BUILD(
	Str :$path,
	Int :$size = 1024 * 1024,
	Int :$maxdbs,
	Int :$maxreaders,
	Int :$flags
    ) {
	sub mdb_env_set_mapsize(MDB_env, size_t)
	    returns int32 is native(LIB) { };
	sub mdb_env_set_maxreaders(MDB_env, uint32)
	    returns int32 is native(LIB) { };
	sub mdb_env_set_maxdbs(MDB_env, uint32)
	    returns int32 is native(LIB) { };
	sub mdb_env_open(MDB_env, Str , uint32, int32)
	    returns int32 is native(LIB) { };

	$!env = MDB_env.new;
	mdb_env_set_mapsize($!env, $size);
	mdb_env_set_maxreaders($!env, $maxreaders) if $maxreaders;
	mdb_env_set_maxdbs($!env, $maxdbs) if $maxdbs;
	if mdb_env_open($!env, $path, $flags || 0, 0o777) -> $code {
	    X::LMDB::LowLevel.new(:$code, what => "Can't open $path").fail;
	}
	self;
    }

    multi method new(Str $path, |args) {
	self.new(:$path, |args);
    }

    method stat(Env:D:) {
	sub mdb_env_stat(MDB_env, MDB-stat)
	    returns int32 is native(LIB) { * };
	mdb_env_stat($!env, my MDB-stat $a .= new);
	Map.new: $a.^attributes.map: { .name.substr(5) => .get_value($a) };
    }

    method info(Env:D:) {
	sub mdb_env_info(MDB_env, MDB-envinfo)
	    returns int32 is native(LIB) { * };
	mdb_env_info($!env, my MDB-envinfo $a .= new);
	Map.new: $a.^attributes.map: { .name.substr(5) => .get_value($a) };
    }

    method get-path(Env:D:) {
	sub mdb_env_get_path(MDB_env, Pointer[Str] is rw)
	    returns int32 is native(LIB) { * };
	mdb_env_get_path($!env, my Pointer[Str] $p .= new);
	$p.deref;
    }

    method begin-txn(Int :$flags = 0) {
	Txn.new(Env => self, :$flags);
    }

    our class Txn {
	 class MDB_txn is repr('CPointer') is Any {
	    sub mdb_txn_begin(MDB_env, MDB_txn, uint64, Pointer[MDB_txn] is rw)
		returns int32 is native(LIB) { * };
	    method new($env, MDB_txn $parent, $flags) {
		my Pointer[MDB_txn] $p .= new;
		if mdb_txn_begin($env, $parent, $flags, $p) -> $code {
		    X::LMDB::LowLevel.new(:$code, :what<Can't create>).fail;
		}
		$p.deref;
	    }
	}

	has Env $!Env;
	has MDB_txn $!txn;
	method !txn { $!txn };
	class Cursor { ... };
	trusts Cursor;

	multi method Bool(::?CLASS:D:) { $!txn.defined };  # Still alive?

	submethod BUILD(:$!Env, Int :$flags = 0) {
	    my MDB_txn $parent;
	    $!txn = MDB_txn.new($!Env!Env::env, $parent, $flags);
	}

	method commit(::?CLASS:D: --> True) {
	    sub mdb_txn_commit(MDB_txn)
		returns int32 is native(LIB) { * };

	    X::LMDB::TerminatedTxn.new.fail unless $!txn;
	    if mdb_txn_commit($!txn) -> $code {
		X::LMDB::LowLevel.new(:$code, :what<commit>).fail;
	    }
	    $!txn = Nil;
	}

	method abort(::?CLASS:D: --> True) {
	    sub mdb_txn_abort(MDB_txn)
		returns int32 is native(LIB) { * };

	    X::LMDB::TerminatedTxn.new.fail unless $!txn;
	    if mdb_txn_abort($!txn) -> $code {
		X::LMDB::LowLevel.new(:$code, :what<abort>).fail;
	    }
	    $!txn = Nil;
	}


	method db-open(Str :$name, Int :$flags) {
	    sub mdb_dbi_open(MDB_txn, Str is encoded('utf8'), uint64, Pointer[int32] is rw)
		returns int32 is native(LIB) { * };

	    X::LMDB::TerminatedTxn.new.fail unless $!txn;
	    my Pointer[int32] $rp .= new;
	    if mdb_dbi_open($!txn, $name, $flags || 0, $rp) -> $code {
		X::LMDB::LowLevel.new(:$code, :what<db-open>).fail;
	    }
	    $rp.Int but dbi;
	}

	method open(Str :$name, Int :$flags) {
	    DB.new(Txn => self, dbi => self.db-open(:$name, :$flags));
	}

	method opened(dbi $dbi) {
	    DB.new(Txn => self, :$dbi);
	}

	sub mdb_put(MDB_txn, uint32, MDB-val, MDB-val, int32)
	    returns int32 is native(LIB) { * };

	multi method put(::?CLASS:D: dbi $dbi, Str $key, Buf $val) {
	    X::LMDB::TerminatedTxn.new.fail unless $!txn;
	    if mdb_put($!txn, $dbi,
		       MDB-val.new-from-str($key), MDB-val.new-from-buf($val),
		       0
	    ) -> $code { X::LMDB::LowLevel.new(:$code, :what<put>).fail }
	    $val;
	}
	multi method put(::?CLASS:D: dbi $dbi, Str $key, Str $val) {
	    X::LMDB::TerminatedTxn.new.fail unless $!txn;
	    if mdb_put($!txn, $dbi,
		       MDB-val.new-from-str($key), MDB-val.new-from-str($val),
		       0
	    ) -> $code { X::LMDB::LowLevel.new(:$code, :what<put>).fail }
	    $val;
	}

	sub mdb_get(MDB_txn, uint32, MDB-val, MDB-val)
	    returns int32 is native(LIB) { * };

	multi method get(::?CLASS:D: dbi $dbi, Str $key) {
	    X::LMDB::TerminatedTxn.new.fail unless $!txn;
	    my $res = MDB-val.new;
	    if mdb_get($!txn, $dbi, MDB-val.new-from-str($key), $res) -> $code {
		X::LMDB::LowLevel.new(:$code, :what<get>).fail;
	    }
	    $res;
	}
	multi method get(::?CLASS:D: dbi $dbi, Str $key, Any $val is rw) {
	    X::LMDB::TerminatedTxn.new.fail unless $!txn;
	    my $res = MDB-val.new;
	    if mdb_get($!txn, $dbi, MDB-val.new-from-str($key), $res) -> $code {
		X::LMDB::LowLevel.new(:$code, :what<get>).fail;
	    }
	    $val = $res;
	}

	method del(::?CLASS:D: dbi $dbi, Str $key, Any $val = Nil --> True) {
	    sub mdb_del(MDB_txn, uint32, MDB-val, MDB-val)
		returns int32 is native(LIB) { * };
	    X::LMDB::TerminatedTxn.new.fail unless $!txn;
	    my $match = MDB-val.new-from-any($val);
	    if mdb_del($!txn, $dbi, MDB-val.new-from-str($key), $match) -> $code {
		X::LMDB::LowLevel.new(:$code, :what<del>).fail;
	    }
	}

	method stat(::?CLASS:D: dbi $dbi) {
	    sub mdb_stat(MDB_txn, uint32, MDB-stat)
		returns int32 is native(LIB) { * };

	    X::LMDB::TerminatedTxn.new.fail unless $!txn;
	    if mdb_stat($!txn, $dbi, my MDB-stat $a .= new) -> $code {
		X::LMDB::LowLevel.new(:$code, :what<stat>).fail;
	    }
	    Map.new: $a.^attributes.map: { .name.substr(5) => .get_value($a) };
	}

	method cursor-open(::?CLASS:D: dbi $dbi) {
	    Cursor.new(Txn => self, :$dbi);
	}

	class Cursor does Iterator {
	    class MDB_cursor is repr('CPointer') is Any {
		sub mdb_cursor_open(MDB_txn, int32, Pointer[MDB_cursor] is rw)
		    returns int32 is native(LIB) { * };
		method new($txn, $dbi) {
		    my Pointer[MDB_cursor] $c .= new;
		    if mdb_cursor_open($txn, $dbi, $c) -> $code {
			X::LMDB::LowLevel.new(:$code, :what<Can't create>).fail;
		    }
		    $c.deref;
		}
	    }

	    has Txn $!Txn;
	    has MDB_cursor $!cursor;
	    has int $!itermode;

	    submethod BUILD(Txn :$!Txn, dbi :$dbi) {
		$!cursor = MDB_cursor.new($!Txn!Txn::txn, $dbi);
	    }

	    # For positional args
	    multi method new(Txn $Txn, Int $dbi) {
		self.new(:$Txn, :$dbi);
	    }

	    method get($key is rw, $data is rw, Int $op, :$im) {
		sub mdb_cursor_get(MDB_cursor $c, MDB-val $k, MDB-val $d, int32 $op)
		    returns int32 is native(LIB) { * };
		my $k = MDB-val.new-from-any($key);
		my $d = MDB-val.new-from-any($data);
		if mdb_cursor_get($!cursor, $k, $d, $op) -> $code {
		    X::LMDB::LowLevel.new(:$code, :what<cursor_get>).fail;
		}
		$key = ~$k; $data = $d;
		$!itermode = False unless $im;
	    }

	    # Iterator role methods
	    method pull-one() {
		my ($key, $data);
		try {
		    if ($!itermode) {
			self.get($key, $data, MDB_FIRST);
			$!itermode = True;
		    } else {
			self.get($key, $data, MDB_NEXT, :im);
		    }
		    CATCH {
			if $_.code == MDB_NOTFOUND {
			    $!itermode = False;
			    return IterationEnd;
			}
			$_.fail;
		    }
		}
		( $key.Str => $data );
	    }
	    method is-lazy	{ True };
	    # Avoid read all the DB!
	    method sink-all	{ $!itermode = False; IterationEnd }
	}
    }

    # A high level class that encapsulates a Txn and a dbi
    class DB does Associative does Iterable {
	has Txn $.Txn handles <commit abort>;
	has dbi $.dbi;

	multi method AT-KEY(::?CLASS:D: $key) {
	    my \SELF = self;
	    #note "Atkey";
	    Proxy.new(
		FETCH => method () {
		    (my \v = SELF.Txn.get(SELF.dbi, $key)).defined;
		    v;
		},
		STORE => method ($val) { SELF.Txn.put(SELF.dbi, $key, $val) }
	    )
	}

	multi method EXISTS-KEY(::?CLASS:D: $key) {
	    $!Txn.get($!dbi, $key).defined;
	}

	multi method DELETE-KEY(::?CLASS:D: $key) {
	    $!Txn.del($!dbi, $key)
	}

	method elems(::?CLASS:D:)   { $!Txn.stat($!dbi)<entries> }
	method Int(::?CLASS:D:)	    { self.elems }
	method Numeric(::?CLASS:D:) { self.elems }
	method Bool(::?CLASS:D:)    { self.elems > 0 }

	method pairs(::?CLASS:D:) {
	    Seq.new($!Txn.cursor-open($!dbi));
	}

	method keys(::?CLASS:D:)    { self.pairs.map: { .key } }
	method values(::?CLASS:D:)  { self.pairs.map: { .value } }
	method kv(::?CLASS:D:)	    { self.pairs.map: { |(.key, .value) } }

	method iterator(::?CLASS:D:) { self.pairs.iterator; }

	method open(::?CLASS:U:
	    Str :$path!,
	    Str :$name,
	    Int :$flags = 0,
	    Bool :$create,
	    Bool :$ro
	) {
	    $flags |= MDB_RDONLY if $ro;
	    my $Txn = Env.new(:$path, :$flags)
		.begin-txn(
		    flags => $flags & MDB_RDONLY ?? MDB_RDONLY !! 0
		);
	    $Txn.open(:$name, :$flags, :$create);
	}
    }
}

constant DB = Env::DB;
