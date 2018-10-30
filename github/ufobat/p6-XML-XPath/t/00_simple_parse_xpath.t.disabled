use v6.c;

use Test;
use XML::XPath;
use XML::XPath::Expr;
use XML::XPath::Step;
use XML::XPath::NodeTest;

plan 3;

my $x = XML::XPath.new;
my $expression;

$expression = "/aaa";
is-deeply $x.parse-xpath($expression),
XML::XPath::Expr.new(
    operator => '',
    operand  => XML::XPath::Step.new(
        axis => 'self',
        test => XML::XPath::NodeTest.new(value => 'aaa'),
    )
), $expression;

$expression = "/aaa/bbb";
is-deeply $x.parse-xpath($expression),
XML::XPath::Expr.new(
    operator => '',
    operand  => XML::XPath::Step.new(
        axis => 'self',
        test => XML::XPath::NodeTest.new(value => 'aaa'),
        next => XML::XPath::Step.new(
            axis => 'child',
            test => XML::XPath::NodeTest.new(value => 'bbb'),
        )
    )
), $expression;

$expression = "/aaa/bbb/ccc";
is-deeply $x.parse-xpath($expression),
XML::XPath::Expr.new(
    operator => '',
    operand  => XML::XPath::Step.new(
        axis => 'self',
        test => XML::XPath::NodeTest.new(value => 'aaa'),
        next => XML::XPath::Step.new(
            axis => 'child',
            test => XML::XPath::NodeTest.new(value => 'bbb'),
            next => XML::XPath::Step.new(
                axis => 'child',
                test => XML::XPath::NodeTest.new(value => 'ccc'),
            )
        )
    )
), $expression;

