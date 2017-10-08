use v6;

class XML::Writer {

    method serialize($tree?, *%named) {
        my $t;
        my $err = "Please pass exactly one argument to XML::Writer.serialize";
        if defined($tree) {
            die $err unless +%named == 0;
            $t = $tree;
        } else {
            die $err unless +%named == 1;
            $t = %named.pairs.[0];
        }
        die 'The XML tree must have a single root node'
            unless 1 == $t.elems && $.is_element($t);
        $.visit($t.list);
    }

    method is_attribute($x) { $x ~~ Pair && $x.value !~~ Positional };
    method is_element($x)   { $x ~~ Pair && $x.value ~~ Positional };
    method is_text_node($x) { ($x ~~ Str) || ($x ~~ Numeric) };
    method is_node($x)      { $.is_element($x) || $.is_text_node($x) };

    method element($name, @attrs, @children) {
        @children
          ??  $.element_open($name, @attrs)
              ~ $.visit(@children)
              ~ $.element_close($name)
          !!  $.element_empty($name, @attrs);
    }

    method element_open($name, @attrs) {
        sprintf '<%s%s>', $name, $.element_attrs(@attrs);
    }

    method element_close($name) {
        "</$name>";
    }

    method element_empty($name, @attrs) {
        sprintf '<%s%s />', $name, $.element_attrs(@attrs);
    }

    method element_attrs(@attrs) {
        [~] @attrs.flatmap({ sprintf ' %s="%s"', .key, $.escape(.value) });
    }

    method escape($str) {
        my %charmap =
            '>' => '&gt;',
            '<' => '&lt;',
            '"' => '&quot;',
            '&' => '&amp;',
            ;
        $str.subst( rx/ <[<>&"]> /, -> $x { %charmap{~$x} }, :g);
    }

    method visit(@list) {
        my $result = '';
        my $last-newline-since = 0;
        for @list -> $node {
            if $.is_text_node($node) {
                $result ~= $.escape($node);
            }
            else {
                my ($name, $subtree) = $node.kv;
                my @attrs    = grep {$.is_attribute($_) }, $subtree.list;
                my @children = grep {$.is_node($_) },      $subtree.list;
                $result ~= $.element($name, @attrs, @children);
                if $result.chars - $last-newline-since > 70 {
                    $result ~= "\n";
                    $last-newline-since = $result.chars;
                }
            }
        }
        $result;
    }
}

=begin pod

=head1 NAME
XML::Writer - XML generation and handling

=head1 SYNOPSIS
=begin code
use v6;
use XML::Writer;

my $svg = :svg[
    :width(200), :height(200),
    circle => [
        :cx(100), :cy(100), :r(50)
    ],
    text => [
        :x(10), :y(20), "hello"
    ]
];

say XML::Writer.serialize($svg);
=end code

=head1 DESCRIPTION

XML::Writer is a Perl 6 class which outputs XML from a nested data structure
describing the DOM representation of an XML file.

=head1 METHODS
=head2 serialize($hierarchy)

=head1 TESTING
The testing plan of SVG::Tiny seems alluring. Haven't looked closer at it,
though.

=head1 BUGS
Likely several. If any of them bites you, please get in touch and we'll see
what we can do.

=head1 AUTHORS
Carl Mäsak (masak on CPAN github #perl6, cmasak on gmail.com)
significant contributions made by Daniel Schröer and Moritz Lenz.

=end pod

# vim: ft=perl6 sw=4 ts=4 expandtab
