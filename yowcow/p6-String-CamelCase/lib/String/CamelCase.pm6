use v6;

unit module String::CamelCase;

class String::CamelCase::Util {

    my regex camelized-block { ^^ (.+?) <before <:Lu>> };

    method parse-camelized(Str $given) returns Array {
        my $result = $given ~~ &camelized-block;
        $result ?? [ ~$result, |self.parse-camelized(substr $given, $result.to) ]
                !! [ ~$given ];
    }

    method filter-camelized(@elems, Int $from = 0) returns Array {

        return @elems if @elems.elems - 1 <= $from;

        if @elems[ $from ] ~~ m{ ^^ <:Lu>+ $$ } && @elems[ $from + 1 ] !~~ m{ ^^ <:Lu> <:Ll> } {

            @elems[ $from ] ~= @elems.splice($from + 1, 1)[0];

            return self.filter-camelized(
                @elems,
                $from
            );
        }
        else {
            return self.filter-camelized(
                @elems,
                $from + 1
            );
        }
    }
}


sub camelize(Str $given) is export(:DEFAULT) returns Str {
    $given.split(/\-|_/).map(-> $word { $word.tclc }).join;
}

sub decamelize(Str $given, Str $expr = '-') is export(:DEFAULT) returns Str {
    String::CamelCase::Util.filter-camelized(
        String::CamelCase::Util.parse-camelized($given)
        ).map(-> $word { $word.lc }).join($expr);
}

sub wordsplit(Str $given) is export(:DEFAULT) returns Array {
    [ String::CamelCase::Util.filter-camelized(
        String::CamelCase::Util.parse-camelized($given)
        ).map(-> $word { $word.split(/\-|_/) }).flat ];
}

=begin pod

=head1 NAME

String::CamelCase - Camelizes and decamelizes given string

=head1 SYNOPSIS

  use String::CamelCase;

=head1 DESCRIPTION

String::CamelCase is a module to camelize and decamelize a string.

=head1 FUNCTIONS

=head2 camelize (Str) returns Str

    camelize("hoge_fuga");
    # => "HogeFuga"

    camelize("hoge-fuga");
    # => "HogeFuga"

=head2 decamelize (Str $string, [Str $connector = '-']) returns Str

    decamelize("HogeFuga");
    # => hoge-fuga

    decamelize("HogeFuga", "_");
    # => hoge_fuga

=head2 wordsplit (Str $string) returns Array

    wordsplit("HogeFuga");
    # => ["Hoge", "Fuga"]

    wordsplit("hoge-fuga");
    # => ["hoge", "fuga"]

=head1 AUTHOR

Yoko Ohyama <yowcow@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2015 yowcow

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
