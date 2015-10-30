use v6;

unit class Text::LTSV;

has $.nl = "\n";

multi method stringify(Pair @key-values) returns Str {
    return @key-values.map(-> $kv { $kv.key ~ ':' ~ $kv.value }).join("\t");
}

multi method stringify(Array[Pair] @multi-key-values) returns Str {
    return @multi-key-values.map(-> @key-values { self.stringify(@key-values) })
        .join($.nl);
}

=begin pod

=head1 NAME

Text::LTSV - LTSV (Labeled Tab Separated Value) toolkit

=head1 SYNOPSIS

    use Text::LTSV;

    my $ltsv = Text::LTSV.new;

    ## one line
    $ltsv.stringify(Array[Pair].new(
        'foo'  => 'bar',
        'buz'  => 'qux',
        'john' => 'paul',
    )); # => "foo:bar\tbuz:qux\tjohn:paul"

    ## multiple lines
    $ltsv.stringify(Array[Array[Pair]].new(
        Array[Pair].new('foo' => 'bar'),
        Array[Pair].new('buz' => 'qux'),
    )); # => "foo:bar\nbuz:qux"

    ## With parser
    use Text::LTSV::Parser;
    my $parser = Text::LTSV::Parser.new;
    $ltsv.stringify($parser.parse-line("foo:bar\tbuz:qux\tjohn:paul\n")); # => "foo:bar\tbuz:qux\tjohn:paul"
    $ltsv.stringify($parser.parse-text("foo:bar\tbuz:qux\njohn:paul\tgeorge:ringo\n")); # => "foo:bar\tbuz:qux\njohn:paul\tgeorge:ringo"

=head1 DESCRIPTION

Text::LTSV is a builder for L<LTSV (Labeled Tab Separated Values)|http://ltsv.org/>.

=head1 METHODS

=head2 C<multi method stringify(Pair @key-values) returns Str>

Stringify LTSV as one line.

=head2 C<multi method stringify(Array[Pair] @multi-key-values) returns Str>

Stringify LTSV as multiple lines. You can specify new line character by C<$.nl>.
Default C<$.nl> is C<"\n">;

=head1 SEE ALSO

=item L<Text::LTSV::Parser>

=head1 AUTHOR

moznion <moznion@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2015 moznion

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

