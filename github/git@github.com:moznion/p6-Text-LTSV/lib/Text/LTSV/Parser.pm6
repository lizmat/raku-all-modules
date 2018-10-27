use v6;
use Text::LTSV;

unit class Text::LTSV::Parser;

has $.nl = "\n";

method parse-line(Text::LTSV::Parser:D: Str $line) returns Array[Pair] {
    my Pair @kvs;
    my %key-bag;
    my $index = 0;

    $line.chomp.split("\t")
        .map(-> $kv { $kv.split(':', 2) })
        .map(-> [$k?, $v?] {
            next unless $k;
            unless $v {
                warn sprintf('Odd number of elements of contents (key: %s)', $k);
                next;
            }
            @kvs.push($k => $v);

            if %key-bag{$k} {
                %key-bag{$k}.push($index);
            } else {
                %key-bag{$k} = [$index];
            }

            $index++;
        });

    # for duplicated key handling
    # distinct and keep order
    %key-bag.grep(-> $bag { $bag.value.elems >= 2 })
        .map(-> $bag {
            my @indexes = |$bag.value;
            @kvs[@indexes[0]] = @kvs[@indexes[*-1]];

            for @indexes[1..*-1] -> $index {
                @kvs[$index] = Nil;
            }
        });

    @kvs = @kvs.grep({ .defined });
    return @kvs;
}

method parse-text(Text::LTSV::Parser:D: Str $text) returns Array[Array[Pair]] {
    my Array[Pair] @kvs;

    $text.split($.nl)
        .map(-> $line {
            next unless $line;
            @kvs.push(self.parse-line($line))
        });
    return @kvs;
}

=begin pod

=head1 NAME

Text::LTSV::Parser - LTSV (Labeled Tab Separated Value) parser

=head1 SYNOPSIS

    use Text::LTSV::Parser;

    ## Single line
    my $parser = Text::LTSV::Parser.new;
    my $ltsv-line = "foo:bar\tbuz:qux\tjohn:paul";
    my %ltsv = $parser.parse-line($ltsv-line); # {:buz("qux"), :foo("bar"), :john("paul")}

    ## Multi line
    my $ltsv-text = "foo:bar\tbuz:qux\njohn:paul\tgeorge:ringo\n";
    my @ltsvs = $parser.parse-text($ltsv-text); # Array[Array[Pair]]
    for @ltsvs -> $ltsv {
        say $ltsv.perl; # 1st: Array[Pair].new("foo" => "bar", "buz" => "qux")
                        # 2nd: Array[Pair].new("john" => "paul", "george" => "ringo")
    }

=head1 DESCRIPTION

Text::LTSV::Parser is a parser for L<LTSV (Labeled Tab Separated Values)|http://ltsv.org/>.

=head1 METHODS

=head2 C<parse-line(Text::LTSV::Parser:D: Str $line) returns Array[Pair]>

Parse one line as LTSV.

=head2 C<parse-text(Text::LTSV::Parser:D: Str $text) returns Array[Array[Pair]]>

Parse multiple lines as LTSV. You can specify new line character to separate lines by C<$.nl>.
Default C<$.nl> is C<"\n">;

=head1 TODO

=item Support want_fields

=item Support ignore_fields

=head1 SEE ALSO

=item L<Text::LTSV>

=head1 AUTHOR

moznion <moznion@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2015 moznion

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

