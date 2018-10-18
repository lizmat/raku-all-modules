=begin pod

=head1 NAME

Text::Spintax

=head1 SYNOPSIS

A parser and renderer for spintax formatted text.

    use Text::Spintax;

    my $node = Text::Spintax.new.parse('This {is|was|will be} some {varied|random} text');
    my $text = $node.render;

=head1 DESCRIPTION

Text::Spintax implements a parser and renderer for spintax formatted text. Spintax is a commonly used method for generating "randomized" text. For example,

    This {is|was} a test

would be rendered as

    * This is a test
    * This was a test

Spintax can be nested indefinitely, for example:

    This is nested {{very|quite} deeply|deep}.

would be rendered as

    * This is nested very deeply.
    * This is nested quite deeply.
    * This is nested deep.

=head1 AUTHOR

Dale Evans, C<< <daleevans@github> >> http://devans.mycanadapayday.com

=head1 BUGS

Please report any bugs or feature requests at L<https://github.com/daleevans/perl6-Text-Spintax/issues>

=head1 SUPPORT

You can find documentation for this module with the p6doc command.

    p6doc Text::Spintax

=end pod

class Text::Spintax:ver<0.01>
{

    class NullNode {
        method render {
            return "";
        }
    }

    class SequenceNode {
        has @.children;
        method render {
            return @!children>>.render.join("");
        }
    }

    class TextNode {
        has $.text;
        method render {
            return $!text;
        }
    }

    class SpinNode {
        has @.children;
        method render {
            my @opt_children = @!children[0].children;
            return @opt_children[@opt_children.elems.rand.truncate].render;
        }
    }

#| a parser and renderer for spintax formatted text built using Perl6 grammar
    grammar Spintax {
        token TOP {
            <sequence>
        }
        token text { <-[\{\}|]>+ }
        token lpar { \{ }
        token rpar { \} }
        token pipe { \| }
        token sequence {
            <renderable>*
        }
        token renderable {
            [
            | <text>
            | <spin>
            ]
        }
        token spin {
            <junk=.lpar> <opts> <junk=.rpar>
        }
        token opts {
            [
            <sequence> <junk=.pipe>
            ]*
            <sequence>
        }
        rule chunk {
            <text>|<opt>
        }
    }

    class Spinaction {
        method TOP($/) {
            my $seq = $<sequence>;
            make SequenceNode.new(children => $<sequence>.ast);
        }
        method sequence($/) {
            my @children = $<renderable>>>.ast;
            my $seq =  SequenceNode.new(children => @children);
            make $seq;
        }
        method renderable($/) {
            my @children;
            if ($<spin>.ast) {
                @children.push($<spin>.ast);
            }
            if ($<text>.ast) {
                @children.push($<text>.ast);
            }
            make SequenceNode.new(children => @children);
        }
        method lpar($/) {
            make NullNode.new;
        }
        method rpar($/) {
            make NullNode.new;
        }
        method pipe($/) {
            make NullNode.new;
        }
        method text($/) {
            my $text = ~$/;
            make TextNode.new(text => ~$/);
        }
        method opts($/) {
            my @children = $<sequence>».ast;
            make SequenceNode.new(children => @children);
        }
        method spin($/) {
            my @children = $<opts>.ast;
            make(SpinNode.new(children => @children));
        }
    }

    method parse ($text) {
        my $actions = Spinaction.new;
        my $match = Spintax.parse($text, :$actions);
        return $match.ast;
    }

}
