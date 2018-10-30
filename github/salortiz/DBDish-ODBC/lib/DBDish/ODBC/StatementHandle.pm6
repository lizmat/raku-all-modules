use v6;
need DBDish;

unit class DBDish::ODBC::StatementHandle does DBDish::StatementHandle;
use DBDish::ODBC::Native;
use NativeCall;

has SQLDBC $!conn is required;
has SQLSTMT $!sth is required;
has Str $!statement;
has @!param-type;
has $!field_count;

method !handle-error($rep) {
    $rep ~~ ODBCErr ?? self!set-err(|$rep) !! $rep
}

method !get-meta {
    with self!handle-error($!sth.NumResultCols) -> $fc {
	for ^$fc {
	    my $meta = $!sth.DescribeCol($_+1);
	    @!column-name.push($meta<name>);
	    @!column-type.push($meta<type>);
	}
	$!field_count = $fc;
    } else { .fail }
}

submethod BUILD(:$!conn!, :$!parent!,
    :$!sth!, :$!statement = '', :$!RaiseError
) {
    unless $!statement { # Prepared
	with self!handle-error($!sth.NumParams) -> $params {
	    for ^$params {
		with self!handle-error: $!sth.DescribeParam($_+1) {
		    @!param-type.push: $_;
		} else { .fail }
	    }
	}
	else { .fail }
	self!get-meta;
    }
}

method execute(*@params) {
    self!enter-execute(@params.elems, @!param-type.elems);

    my @bufs; # For preserve in scope our buffers till Execute
    my Buf[int64] $SoI .= allocate(+@params);
    for @params.kv -> $k, $v {
	if $v.defined {
	    my $param = ($v ~~ Blob) ?? $v !! (~$v).encode;
	    @bufs.push($param);
	    $SoI[$k] = $param.bytes;
	    self!handle-error($!sth.BindParameter($k+1, @!param-type[$k], $param, $SoI));
	} else {
	    $SoI[$k] = SQL_NULL_DATA;
	    self!handle-error($!sth.BindParameter($k+1, @!param-type[$k], Buf, $SoI));
	}
    }

    without self!handle-error: $!statement
	?? $!sth.ExecDirect($!statement)
	!! $!sth.handle-res($!sth.Execute) { .fail }

    self!get-meta without $!field_count;

    my $rows = $!sth.RowCount;
    # TODO, not all ODBC drivers returns a sensible RowCount for SELECT
    self!done-execute($rows, $!field_count);
}

method _row(:$hash) {
    my $list = ();
    if $!field_count -> $cols {
	given $!sth.Fetch {
	    when SQL_SUCCESS {
		$list = do for ^$cols {
		    my $type = @!column-type[$_]; my $raw = $type ~~ Buf;
		    my $value = do with $!sth.GetData($_ + 1, :$raw) {
			$raw ?? $_ !! .$type
		    } else { $type }
		}
	    }
	    when SQL_NO_DATA { self.finish }
	}
    }
    $list;
}

method _free {
    with $!sth {
	.dispose;
	$_ = Nil;
    }
}

method finish {
    with $!sth {
	.CloseCursor if $!field_count;
    }
    $!Finished = True;
}
