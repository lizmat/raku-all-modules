use v6.c;

my $DATA;
module P5__DATA__:ver<0.0.1>:auth<cpan:ELIZABETH> {

    my $handle;
    my $lock = Lock.new;
    my sub term:<DATA>(--> IO::Handle:D) {
        sub findDATA() {

            $handle = callframe(4).file.IO.open(:r, :!chomp);

            loop {
                with $handle.get -> $line {
                    my $pos;
                    $pos = $_ with $line.index('__DATA__');
                    $pos = $_ with $line.index('__END__');
                    with $pos {
                        with $line.index('#') -> $comment {
                            return $handle if $comment > $pos;
                        }
                        else {
                            return $handle if $pos == 0;
                        }
                    }
                }
                else {
                    return $handle;
                }
            }
        }

        $lock.protect: { $handle // findDATA }
    }

    $DATA := &term:<DATA>;
}

sub EXPORT(|) {
    role Data {
        token term:sym<p5end>  {
            ^^ \h*
            '__END__' <pod_newline>
            $<finish> = .*
        }
        token term:sym<p5data> {
            ^^ \h*
            '__DATA__' <pod_newline>
            $<finish> = .*
        }
    }

    $*LANG.define_slang('MAIN', $*LANG.slang_grammar('MAIN').^mixin(Data));

    { '&DATA' => $DATA }
}

=begin pod

=head1 NAME

P5__DATA__ - Implement Perl 5's __DATA__ and related functionality

=head1 SYNOPSIS

  use P5__DATA__; # exports DATA and a slang

=head1 DESCRIPTION

This module tries to mimic the behaviour of C<__DATA__> and C<__END__> and
the associated C<DATA> file handle of Perl 5 as closely as possible.

=head1 ORIGINAL PERL 5 DOCUMENTATION


    Text after __DATA__ may be read via the filehandle "PACKNAME::DATA", where
    "PACKNAME" is the package that was current when the __DATA__ token was
    encountered. The filehandle is left open pointing to the line after
    __DATA__. The program should "close DATA" when it is done reading from it.
    (Leaving it open leaks filehandles if the module is reloaded for any
    reason, so it's a safer practice to close it.) For compatibility with
    older scripts written before __DATA__ was introduced, __END__ behaves like
    __DATA__ in the top level script (but not in files loaded with "require"
    or "do") and leaves the remaining contents of the file accessible via
    "main::DATA".

=head1 PORTING CAVEATS

__END__ functions in the same was as __DATA__.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5__DATA__ . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
