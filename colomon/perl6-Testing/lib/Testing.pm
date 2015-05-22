module Testing:ver<0.0.1>:auth<cpan:DCONWAY>;

# Track how many tests to report...
my $test_count = 0;

# Are we skipping this file?
my $skip_all    = 0;
my $skip_reason = '';

# Template to ensure everything lines up:
my $TEMPLATE = '%-13s';

multi sub OK ($have is copy,
              Mu $want? is copy = Mu,
              :$desc, :$SKIP, :$TODO
) is export {
    # Have we given up?
    return if $skip_all;

    # Accumulate diagnostics as we go and print at the end
    my $diagnostics = "\n";

    # Count this test...
    $test_count++;

    # Do the test(s)...
    my $succeeded = $SKIP || ($want.defined ?? $have ~~ $want !! ?$have);

    # Report what happened...
    if $succeeded {
        printf $TEMPLATE, "ok $test_count";
    }
    else {
        printf $TEMPLATE, "not ok $test_count";
        my $caller = callframe(1);
        $diagnostics ~= sprintf($TEMPLATE, '#') ~ "  at $caller.file() line $caller.line()\n"
                      ~ "#   have: $have.perl()\n";
        $diagnostics ~= "#   want: $want.perl()\n" if $want.defined;
    }

    # Describe the test (if possible)...
    if $desc.chars  { print "- $desc" }

    # Report ignorable tests...
    if    $SKIP.defined  { print "  # SKIP " ~ ($SKIP ~~ 1 ?? "" !! $SKIP) }
    elsif $TODO.defined  { print "  # TODO " ~ ($TODO ~~ 1 ?? "" !! $TODO) }

    print $diagnostics;
}

multi sub OK (:$have,
              :$want,
              :$desc,
              :$SKIP,
              :$TODO
) is export {
    OK($have, $want, :$desc, :$SKIP, :$TODO);
}

sub COMM ($diagnostic = '') is export {
    say "# $_" for $diagnostic.split("\n");
}

# Fake an input stream...
sub IN (*@lines is copy, :$term-input-ok = False) is export {
    return $*IN if $term-input-ok and ($*IN & $*OUT) ~~ :t;

    @lines.chomp;
    return ( class {
        also is IO::Handle;
        multi method get()                  { return @lines.shift; }
        multi method close()                { @lines = () }
        multi method lines($limit = @lines) { @lines.splice(0,$limit); }
        multi method getc()                 { self.read(1) }

        multi method eof() { return @lines == 0 }
        multi method t()   { return 0 }
        multi method r()   { return 1 }
        multi method d()   { return 0 }
        multi method e()   { return 1 }
        multi method f()   { return 1 }
        multi method s()   { return @lines.join("\n").chars }
        multi method l()   { return 0 }
        multi method z()   { return !self.s }

        multi method read(Int $bytes_needed is copy) {
            fail if !@lines;
            my $text = @lines.join("\n");
            my $read = $text.substr(0, $bytes_needed);
            my $remainder = substr($text,$bytes_needed);
            @lines = $remainder.defined && $remainder.chars
                        ?? $remainder.split("\n")
                        !! ();
            return $read;
        }

        multi method slurp() {
            my $slurp = @lines.join("\n");
            self.close;
            return $slurp;
        }
    } ).new;
}

sub SKIP ($reason = '') is export {
    $skip_all    = 1;
    $skip_reason = $reason;
}

END {
    print "1..$test_count";
    print "  # Skipped: $skip_reason" if $skip_reason;
    print "\n";
}
