use v6;

use Test;

use File::Temp;

use Proc::More :ALL;

plan 129;

my token num { \d+ [ \. \d* ]? }
my token typr { :i real ':' }
my token typu { :i user ':' }
my token typs { :i sys ':' }
my token typ { <typr> | <typu> | <typs> }
my token s { :i <num> s }
my token h { :i <num> h <num> m <num> s }
my token H { <num> ':' <num> ':' <num> }

my token an { <typr> \s* <num> ';' \s* <typu> \s* <num> ';' \s* <typs> \s* <num> }
my token as { <typr> \s* <s> ';' \s* <typu> \s* <s> ';' \s* <typs> \s* <s> }
my token ah { <typr> \s* <h> ';' \s* <typu> \s* <h> ';' \s* <typs> \s* <h> }
my token aH { <typr> \s* <H> ';' \s* <typu> \s* <H> ';' \s* <typs> \s* <H> }

my token list { <num> \s* <h> \s* <num> \s* <h> \s* <num> \s* <h> }

my $prog = q:to/HERE/;
my $i = 0;
for 1..100 {
    $i += 2;
}
HERE

my ($prog-file, $fh) = tempfile;
$fh.print: $prog;
$fh.close;

my $cmd = "perl6 $prog-file";

my ($res, $typ, $fmt);
my $debug = 0;

my @typ = <a all r real u user s sys>;
my @fmt = ['s', 'seconds', 'h', 'hms', ':', 'h:m:s'];
my $tn = 0; # for debugging, test number, check a bad or unknown command

dies-ok { $res = time-command 'fooie', :$fmt };
say "debug: test { ++$tn }" if $debug;

# check the default for both args
lives-ok { $res = time-command $cmd };
say "debug: test { ++$tn }; \$res = '$res'" if $res && $debug;
like $res, &num;
say "debug: test { ++$tn }; \$res = '$res'" if $res && $debug;

# need a subroutine to check $res with like
sub check($res, :$typ = False, :$fmt = False, :$list = False) {
    # list overrides all
    if $list {
        like $res, &list;
        return;
    }

    if !$fmt {
        if !$typ ~~ /^a/ {
            like $res, &num;
        }
        elsif $typ ~~ /^a/ {
            like $res, &an;
        }
        elsif $typ ~~ /^r/ {
            like $res, &num;
        }
        elsif $typ ~~ /^u/ {
            like $res, &num;
        }
        elsif $typ ~~ /^s/ {
            like $res, &num;
        }
    }
    elsif $fmt ~~ /^s/ {
        if !$typ {
            like $res, &s;
        }
        elsif $typ ~~ /^a/ {
            like $res, &as;
        }
        elsif $typ ~~ /^r/ {
            like $res, &s;
        }
        elsif $typ ~~ /^u/ {
            like $res, &s;
        }
        elsif $typ ~~ /^s/ {
            like $res, &s;
        }
    }
    elsif $fmt ~~ /':'/ {
        if !$typ {
            like $res, &H;
        }
        elsif $typ ~~ /^a/ {
            like $res, &aH;
        }
        elsif $typ ~~ /^r/ {
            like $res, &H;
        }
        elsif $typ ~~ /^u/ {
            like $res, &H;
        }
        elsif $typ ~~ /^s/ {
            like $res, &H;
        }
    }
    elsif $fmt ~~ /^h/ {
        if !$typ {
            like $res, &h;
        }
        elsif $typ ~~ /^a/ {
            like $res, &h;
        }
        elsif $typ ~~ /^a/ {
            like $res, &ah;
        }
        elsif $typ ~~ /^r/ {
            like $res, &h;
        }
        elsif $typ ~~ /^u/ {
            like $res, &h;
        }
        elsif $typ ~~ /^s/ {
            like $res, &h;
        }
    }
}

# check the default for the fmt arg
for @typ -> $typ {
    lives-ok { $res = time-command $cmd, :$typ };
    say "debug: test { ++$tn }; \$typ = '$typ'; \$res = '$res'" if $debug;
    check $res, :$typ;
    say "debug: test { ++$tn }" if $debug;
}


# check the default for the typ arg
for @fmt -> $fmt {
    lives-ok { $res = time-command $cmd, :$fmt };
    say "debug: test { ++$tn }; \$fmt = '$fmt'; \$res = '$res'" if $debug;
    check $res, :$fmt;
    say "debug: test { ++$tn }" if $debug;
}

# check all arg combinations
for @typ -> $typ {
    for @fmt -> $fmt {
        lives-ok { $res = time-command $cmd, :$typ, :$fmt };
        say "debug: test { ++$tn }; \$typ = '$typ'; \$fmt = '$fmt'; \$res = '$res'" if $debug;
        check $res, :$typ, :$fmt;
        say "debug: test { ++$tn }" if $debug;
    }
}

# check the :$list param
$fmt = 's';
$typ = 's';
my $list = True;
my @res;
lives-ok { @res = time-command $cmd, :$typ, :$fmt, :$list };
$res = join ' ', @res;
say "debug: test { ++$tn }; \$typ = '$typ'; \$fmt = '$fmt', \$list = '$list'; \$res = '$res'" if $debug;
check $res, :$typ, :$fmt, :$list;
say "debug: test { ++$tn }" if $debug;
