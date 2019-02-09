use v6.c;

use Map::Agnostic:ver<0.0.2>:auth<cpan:ELIZABETH>;

role Map::Ordered:ver<0.0.2>:auth<cpan:ELIZABETH>
  does Map::Agnostic
{
    has %!indices;  # handles <EXISTS-KEY>   # alas, not supported for role yet
    has Str @!keys;
    has Mu  @!values;

#--- Mandatory method required by Map::Agnostic --------------------------------
    method INIT-KEY(Str() $key, \value) {
        my int $index = @!values.elems;
        %!indices.BIND-KEY(  $key, $index);
        @!keys   .BIND-POS($index, $key);
        @!values .BIND-POS($index, value<>);
    }
    method AT-KEY(\key) {
        with %!indices.AT-KEY(key) {
            @!values.AT-POS($_)
        }
        else {
            Nil
        }
    }
    method EXISTS-KEY(\key) { %!indices.EXISTS-KEY(key) }

    method keys() { @!keys }

#---- Methods needed for consistency -------------------------------------------
    method gist() {
        '{' ~ self.pairs.map( *.gist).join(", ") ~ '}'
    }

    method Str() {
        self.pairs.join(" ")
    }

    method perl() {
        self.perlseen(self.^name, {
          ~ self.^name
          ~ '.new('
          ~ self.pairs.map({$_<>.perl}).join(',')
          ~ ')'
        })
    }

#---- Optional methods for performance -----------------------------------------
    method values()   { @!values }
    method pairs() {
        @!keys.map: { Pair.new($_, @!values.AT-POS(%!indices.AT-KEY($_))) }
    }
}

=begin pod

=head1 NAME

Map::Ordered - role for ordered Maps

=head1 SYNOPSIS

  use Map::Ordered;

  my %m is Map::Ordered = a => 42, b => 666;

=head1 DESCRIPTION

Exports a C<Map::Ordered> role that can be used to indicate the implementation
of a C<Map> in which the keys are ordered the way the C<Map> got initialized.

Since C<Map::Ordered> is a role, you can also use it as a base for creating
your own custom implementations of maps.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Map-Ordered .
Comments and Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018, 2019 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: ft=perl6 expandtab sw=4
