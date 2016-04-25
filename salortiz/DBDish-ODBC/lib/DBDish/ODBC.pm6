use v6;
need DBDish;

unit class DBDish::ODBC:auth<salortiz>:ver<0.0.5> does DBDish::Driver;
use DBDish::ODBC::Native;
need DBDish::ODBC::Connection;

has SQLENV $!Env;

submethod BUILD(:$!Env!, :$!parent, :$!RaiseError) { };

method new(*%args) {
    with SQLENV.Alloc {
	self.bless(:Env($_), |%args);
    }
    else { .fail }
}

method !chkerr($rep) is hidden-from-backtrace {
    $rep ~~ ODBCErr ?? self!conn-error(:errstr($rep[1]), :code($rep[0])) !! $rep;
}

proto method connect($dsn?, *%args) { * };

#For when a Connection string available
multi method connect(:$conn-str!, :$RaiseError = $!RaiseError, *%args) {
    my $conn = SQLDBC.Alloc($!Env);
    with self!chkerr: $conn.Connect($conn-str, Str, Str, Str) {
	DBDish::ODBC::Connection.new(:$conn, :fconn-str($_), :$RaiseError,
	    :parent(self), |%args
	);
    }
    else { .fail }
}

# When dns, user and pass available, positional
multi method connect(
    $dsn, $user = "", $pass = "", :$RaiseError = $!RaiseError, *%args
) {
    my $conn = SQLDBC.Alloc($!Env);
    with self!chkerr: $conn.Connect(Str, $dsn, $user, $pass) {
	DBDish::ODBC::Connection.new(:$conn, :fconn-str($_), :$RaiseError,
	    :parent(self), |%args
	);
    }
    else { .fail }
}

# Generic one
multi method connect(:$RaiseError = $!RaiseError, *%args) {
    my $conn-str = %args.pairs.map( {"{.key}={.value}" }).join(';');
    self.connect(:$conn-str, :$RaiseError);
}

method drivers() {
    my $s = SQL_FETCH_FIRST;
    gather loop {
	given $!Env.Drivers($s) {
	    when ODBCErr {
		last if .<code> == SQL_NO_DATA;
		self!chkerr($_);
	    }
	    default {
		take Pair.new(.[0], Map.new(
		    .[1].split("\0").list.map({.chars??|(.split('='))!!|()}).list
		));
	    }
	}
	$s = SQL_FETCH_NEXT;
    }
}

method data-sources($dir is copy = SQL_FETCH_FIRST) {
    gather loop {
	given $!Env.DataSources($dir) {
	    when ODBCErr {
		last if .<code> == SQL_NO_DATA;
		self!chkerr($_);
	    }
	    default {
		take Pair.new(.[0], .[1]);
	    }
	}
	$dir = SQL_FETCH_NEXT;
    }
}
