class Bencode {

method bencode($string) {
	encode($string);
}

sub encode($var) {
	given $var.WHAT.gist {
		when "(Str)" {
		   "{$var.chars}" ~ ":" ~ "$var";
}
		when "(Int)" {
			"i{$var}e";
		}
		when "(Array)" {
   	   my $res;
		   for 0..$var.elems-1 -> $v {
			  		$res ~= "{encode($var[$v])}";
			 }
			 "l" ~ $res ~ "e" ;
    }
		when "(Hash)" {
			 my $res;
			 my @a = $var.keys;
			 for 0..$var.elems-1 -> $v {
				   $res ~= "{encode(@a[$v])}" ~ "{encode($var{@a[$v]})}";
			}
			"d" ~ $res ~ "e";
		}
	}
}

method bdecode($string) {
        my @chunks = split('', $string);
	      @chunks.shift;
	      @chunks.pop;
        my $root = dechunk(@chunks);
        return $root;
}

sub dechunk(@a) {
        my $chunks = @a;

        my $item = shift($chunks);
        if $item eq 'd' {
                $item = shift($chunks);
                my %hash;
                while $item ne 'e' {
                        unshift($chunks, $item);
                        my $key = dechunk($chunks);
                        %hash{$key} = dechunk($chunks);
                        $item = shift($chunks);
                }
                return %hash;
        }
        if $item eq 'l' {
                $item = shift($chunks);
                my @list;
                while $item ne 'e' {
                        unshift($chunks, $item);
                        push @list, dechunk($chunks);
                        $item = shift($chunks);
                }
                return @list;
        }
        if $item eq 'i' {
                my $num;
                $item = shift($chunks);
                while $item ne 'e' {
                        $num ~= $item;
                        $item = shift($chunks);
                }
                return $num;
        }
        if $item ~~ /\d/ {
                my $num;
                while $item ~~ /\d/ {
                        $num ~= $item;
                        $item = shift($chunks);
                }
                my $line = '';
                for 1 .. $num {
                        $line ~= shift($chunks);
                }
                return $line;
        }
        return $chunks;
}
}
