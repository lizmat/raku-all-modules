#!/usr/bin/env perl6

# these tests check for conformance with error handling as outline in
# http://www.w3.org/TR/2011/REC-CSS2-20110607/syndata.html#parsing-errors

use Test;
use JSON::Tiny;

use CSS::Writer;

my $css-writer = CSS::Writer.new;
my $css-writer_2 = CSS::Writer.new( :color-names );
my $css-writer_3 = CSS::Writer.new( :color-values );

for 't/write-ast.json'.IO.lines {

    next if .substr(0,2) eq '//';

    my $test = from-json($_);
    my $css = $test<css>;
    my %node = %( $test<ast> );
    my $opt = $test<opt> // {};

    if my $skip = $opt<skip> {
        skip $skip;
        next;
    }

    is $css-writer.write( |%node ), $css, "serialize {%node.keys} to: $css"
        or diag {node => %node}.perl;

    if my $color-masks-css = $test<color-masks> {
        temp $css-writer.color-masks = True;
        is $css-writer.write( |%node ), $color-masks-css, "serialize (:color-masks) {%node.keys} to: $color-masks-css"
            or diag {node => %node}.perl;
    }

    if my $color-names-css = $test<color-names> {
        is $css-writer_2.write( |%node ), $color-names-css, "serialize (:color-names) {%node.keys} to: $color-names-css"
            or diag {node => %node}.perl;
    }

    if my $color-values-css = $test<color-values> {
        is $css-writer_3.write( |%node ), $color-values-css, "serialize (:color-values) {%node.keys} to: $color-values-css"
            or diag {node => %node}.perl;
    }

}

done;
