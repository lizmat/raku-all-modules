use v6;

unit module String::CamelCase;

our sub camelize(Str $given) is export(:DEFAULT) returns Str {
    $given.split(/\-|_/).map(-> $word { $word.tclc }).join;
}

our sub decamelize(Str $given is copy, Str $expr = '-') is export(:DEFAULT) returns Str {
    my Str ($p0, $p1, $p2, $p3, $t);

    $given ~~ s:g!
        (<-[a..z A..Z]>?)
        (<[A..Z]>*)
        (<[A..Z]>)
        (<[a..z]>?)
    !{
        ($p0, $p1, $p2, $p3) = (~$0, ~$1.lc, ~$2.lc, ~$3);
        $t = $p0.chars || $/.from == 0 ?? $p0 !! $expr;
        $t ~= $p3 ?? $p1 ?? "{$p1}{$expr}{$p2}{$p3}" !! "{$p2}{$p3}" !! "{$p1}{$p2}";
        $t;
    }!;

    $given;
}

our sub wordsplit(Str $given) is export(:DEFAULT) returns List {
    $given.split(/
        <[_ \- \s]>+
        | "\b"
        | <?after <-[A ..Z]>> <?before <:Lu>>
        | <?after <:Lu>> <?before <:Lu> <:Ll>>
    /, :skip-empty);
}

=begin pod

=head1 NAME

String::CamelCase - Camelizes and decamelizes given string

=head1 SYNOPSIS

  use String::CamelCase;

=head1 DESCRIPTION

String::CamelCase is a module to camelize and decamelize a string.

=head1 FUNCTIONS

Following functions are exported:

=head2 camelize (Str) returns Str

    camelize("hoge_fuga");
    # => "HogeFuga"

    camelize("hoge-fuga");
    # => "HogeFuga"

=head2 decamelize (Str, [Str $expr = '-']) returns Str

    decamelize("HogeFuga");
    # => hoge-fuga

    decamelize("HogeFuga", "_");
    # => hoge_fuga

=head2 wordsplit (Str) returns List

    wordsplit("HogeFuga");
    # => ["Hoge", "Fuga"]

    wordsplit("hoge-fuga");
    # => ["hoge", "fuga"]

=head1 SEE ALSO

L<String::CamelCase|http://search.cpan.org/dist/String-CamelCase/lib/String/CamelCase.pm>

=head1 AUTHOR

Yoko Ohyama <yowcow@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2015 yowcow

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
