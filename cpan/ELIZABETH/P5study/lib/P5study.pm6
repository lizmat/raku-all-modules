use v6.c;

unit module P5study:ver<0.0.3>:auth<cpan:ELIZABETH>;

proto sub study(|) is export {*}
multi sub study()   { }
multi sub study(\a) { }

=begin pod

=head1 NAME

P5study - Implement Perl 5's study() built-in

=head1 SYNOPSIS

  use P5study; # exports study()

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<study> function of Perl 5
as closely as possible.

=head1 ORIGINAL PERL 5 DOCUMENTATION

    study SCALAR
    study   Takes extra time to study SCALAR ($_ if unspecified) in
            anticipation of doing many pattern matches on the string before it
            is next modified. This may or may not save time, depending on the
            nature and number of patterns you are searching and the
            distribution of character frequencies in the string to be
            searched; you probably want to compare run times with and without
            it to see which is faster. Those loops that scan for many short
            constant strings (including the constant parts of more complex
            patterns) will benefit most. (The way "study" works is this: a
            linked list of every character in the string to be searched is
            made, so we know, for example, where all the 'k' characters are.
            From each search string, the rarest character is selected, based
            on some static frequency tables constructed from some C programs
            and English text. Only those places that contain this "rarest"
            character are examined.)

            For example, here is a loop that inserts index producing entries
            before any line containing a certain pattern:

                while (<>) {
                    study;
                    print ".IX foo\n"    if /\bfoo\b/;
                    print ".IX bar\n"    if /\bbar\b/;
                    print ".IX blurfl\n" if /\bblurfl\b/;
                    # ...
                    print;
                }

            In searching for "/\bfoo\b/", only locations in $_ that contain
            "f" will be looked at, because "f" is rarer than "o". In general,
            this is a big win except in pathological cases. The only question
            is whether it saves you more time than it took to build the linked
            list in the first place.

            Note that if you have to look for strings that you don't know till
            runtime, you can build an entire loop as a string and "eval" that
            to avoid recompiling all your patterns all the time. Together with
            undefining $/ to input entire files as one record, this can be
            quite fast, often faster than specialized programs like fgrep(1).
            The following scans a list of files (@files) for a list of words
            (@words), and prints out the names of those files that contain a
            match:

                $search = 'while (<>) { study;';
                foreach $word (@words) {
                    $search .= "++\$seen{\$ARGV} if /\\b$word\\b/;\n";
                }
                $search .= "}";
                @ARGV = @files;
                undef $/;
                eval $search;        # this screams
                $/ = "\n";        # put back to normal input delimiter
                foreach $file (sort keys(%seen)) {
                    print $file, "\n";
                }

=head1 PORTING CAVEATS

Currently, C<study> is a no-op in Perl 6.  As it is in more recent Perl 5's.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5study . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
