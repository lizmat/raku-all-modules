use v6;
need DBDish;

unit class DBDish::ODBC::Connection does DBDish::Connection;
need DBDish::ODBC::StatementHandle;
use DBDish::ODBC::Native;

has SQLDBC $!conn;
has Str $.fconn-str;

submethod BUILD(:$!conn!, :$!fconn-str!, :$!parent!, :$!RaiseError) { };

method !handle-error($rep) {
    $rep ~~ ODBCErr ?? self!set-err(|$rep) !! $rep
}

method prepare(Str $statement, *%args) {
    with SQLSTMT.Alloc($!conn) -> $sth {
	self!handle-error: $sth.Prepare($statement);
	DBDish::ODBC::StatementHandle.new(
	    :$sth, :$!conn, :parent(self), :$.RaiseError
	)
    } else { .fail }
}

# The named 'rows' is only a testing helper, don't depend on it
method execute(Str $statement, :$rows) {
    my $sth = SQLSTMT.Alloc($!conn);
    my $st = DBDish::ODBC::StatementHandle.new(
	:$sth, :$!conn, :parent(self), :$.RaiseError, :$statement
    );
    with $st.execute {
	if $rows {
	    LEAVE { $st.dispose };
	    my @r = $st.allrows;
	} else {
	    $_;
	}
    } else { .fail }
}

method ping {
    True; # TODO
}

method _disconnect {
    with $!conn {
	.Disconnect;
	.dispose;
	$_ = Nil;
    }
}
