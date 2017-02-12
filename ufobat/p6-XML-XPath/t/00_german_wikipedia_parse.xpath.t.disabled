use v6.c;

use Test;
use XML::XPath;
use XML::XPath::Expr;
use XML::XPath::Step;
use XML::XPath::NodeTest;

plan 17;

my $x = XML::XPath.new;
my $expression;

$expression = "/dok";
is-deeply $x.parse-xpath($expression),
XML::XPath::Expr.new(
    operator => '',
    operand  => XML::XPath::Step.new(
        axis => 'self',
        test => XML::XPath::NodeTest.new(value => 'dok'),
    )
), $expression;

$expression = "/*";
is-deeply $x.parse-xpath($expression),
XML::XPath::Expr.new(
    operator => '',
    operand  => XML::XPath::Step.new(
        axis => 'self',
        test => XML::XPath::NodeTest.new(value => '*'),
    )
), $expression;

$expression = "//dok/kap";
is-deeply $x.parse-xpath($expression),
XML::XPath::Expr.new(
    operator => '',
    operand  => XML::XPath::Step.new(
        axis => 'descendant-or-self',
        test => XML::XPath::NodeTest.new(value => 'dok'),
        next => XML::XPath::Step.new(
            axis => 'child',
            test => XML::XPath::NodeTest.new(value => 'kap'),
        )
    )
), $expression;

$expression = "//dok/kap[1]";
is-deeply $x.parse-xpath($expression),
XML::XPath::Expr.new(
    operator => '',
    operand  => XML::XPath::Step.new(
        axis => 'descendant-or-self',
        test => XML::XPath::NodeTest.new(value => 'dok'),
        next => XML::XPath::Step.new(
            axis       => 'child',
            test       => XML::XPath::NodeTest.new(value => 'kap'),
            predicates => [
                           XML::XPath::Expr.new(
                               operator => '',
                               operand  => XML::XPath::Expr.new(
                                   operand => 1,
                               ),
                           ),
                       ],
        )
    )
), $expression;

$expression = "//kap[@title='Nettes Kapitel']/pa";
is-deeply $x.parse-xpath($expression),
XML::XPath::Expr.new(
    operator => '',
    operand  => XML::XPath::Step.new(
        axis => 'descendant-or-self',
        test => XML::XPath::NodeTest.new(value => 'kap'),
        predicates => [
                       XML::XPath::Expr.new(
                           operator => '=',
                           operand  => XML::XPath::Step.new(
                               axis => 'attribute',
                               test => XML::XPath::NodeTest.new(value => 'title'),
                           ),
                           other-operand => XML::XPath::Expr.new(
                               operator => '',
                               operand  => XML::XPath::Expr.new(
                                   operand => 'Nettes Kapitel',
                               )
                           ),
                       ),
                   ],
        next => XML::XPath::Step.new(
            axis => 'child',
            test => XML::XPath::NodeTest.new(value => 'pa'),
        ),
    )
), $expression;

$expression = "//kap/pa[2]";
is-deeply $x.parse-xpath($expression),
XML::XPath::Expr.new(
    operator => '',
    operand  => XML::XPath::Step.new(
        axis => 'descendant-or-self',
        test => XML::XPath::NodeTest.new(value => 'kap'),
        next => XML::XPath::Step.new(
            axis => 'child',
            test => XML::XPath::NodeTest.new(value => 'pa'),
            predicates => [
                           XML::XPath::Expr.new(
                               operator => '',
                               operand  => XML::XPath::Expr.new(
                                   operand => 2,
                               ),
                           ),
                       ],
        )
    )
), $expression;

$expression = "//kap[2]/pa[@format='bold'][2]";
is-deeply $x.parse-xpath($expression),
XML::XPath::Expr.new(
    operator => '',
    operand  => XML::XPath::Step.new(
        axis => 'descendant-or-self',
        test => XML::XPath::NodeTest.new(value => 'kap'),
        predicates => [
                       XML::XPath::Expr.new(
                           operator => '',
                           operand  => XML::XPath::Expr.new(
                               operand => 2,
                           ),
                       ),
                   ],
        next => XML::XPath::Step.new(
            axis       => 'child',
            test       => XML::XPath::NodeTest.new(value => 'pa'),
            predicates => [
                       XML::XPath::Expr.new(
                           operator => '=',
                           operand => XML::XPath::Step.new(
                               axis => 'attribute',
                               test => XML::XPath::NodeTest.new(value => 'format'),
                           ),
                           other-operand => XML::XPath::Expr.new(
                               operator => '',
                               operand  => XML::XPath::Expr.new(
                                   operand => 'bold',
                               )
                           ),
                       ),
                       XML::XPath::Expr.new(
                           operator => '',
                           operand => XML::XPath::Expr.new(
                               operand => 2,
                           )
                       ),
                       ]
        ),
    )
), $expression;

$expression = "child::*";
is-deeply $x.parse-xpath($expression),
XML::XPath::Expr.new(
    operator => "",
    operand  => XML::XPath::Step.new(
        axis => "child",
        test => XML::XPath::NodeTest.new(value => '*'),
    )
), $expression;

$expression = "child::pa";
is-deeply $x.parse-xpath($expression),
XML::XPath::Expr.new(
    operator => "",
    operand  => XML::XPath::Step.new(
        axis => "child",
        test => XML::XPath::NodeTest.new(value => 'pa'),
    )
), $expression;

$expression = "child::text()";
is-deeply $x.parse-xpath($expression),
XML::XPath::Expr.new(
    operator => "",
    operand  => XML::XPath::Step.new(
        axis => "child",
        test => XML::XPath::NodeTest.new(
            type  => "text",
        ),
    ),
), $expression;

$expression = ".";
is-deeply $x.parse-xpath($expression),
XML::XPath::Expr.new(
    operator => "",
    operand  => XML::XPath::Step.new(
        axis => "self",
        test => XML::XPath::NodeTest.new(),
    ),
), $expression;

$expression = "./*";
is-deeply $x.parse-xpath($expression),
XML::XPath::Expr.new(
    operator => "",
    operand  => XML::XPath::Step.new(
        axis => "self",
        test => XML::XPath::NodeTest.new(),
        next => XML::XPath::Step.new(
            axis => "child",
            test => XML::XPath::NodeTest.new(
                type => "node",
                value => "*"
            ),
        ),
    )
), $expression;
$expression = "./pa";
is-deeply $x.parse-xpath($expression),
XML::XPath::Expr.new(
    operator => "",
    operand  => XML::XPath::Step.new(
        axis => "self",
        test => XML::XPath::NodeTest.new(),
        next => XML::XPath::Step.new(
            axis => "child",
            test => XML::XPath::NodeTest.new(
                value => "pa"
            ),
        ),
    ),
), $expression;

$expression = "pa";
is-deeply $x.parse-xpath($expression),
XML::XPath::Expr.new(
    operator => "",
    operand  => XML::XPath::Step.new(
        axis => "child",
        test => XML::XPath::NodeTest.new(
            value => "pa"
        ),
    ),
), $expression;

#use Data::Dump;
#my $xpath = $x.parse-xpath($expression);
#say Dump $xpath, :skip-methods(True);

$expression = "attribute::*";
is-deeply $x.parse-xpath($expression),
XML::XPath::Expr.new(
    operator => "",
    operand  => XML::XPath::Step.new(
        axis => "attribute",
        test => XML::XPath::NodeTest.new(
            value => "*"
        ),
    ),
), $expression;

$expression = "namespace::*";
is-deeply $x.parse-xpath($expression),
XML::XPath::Expr.new(
    operator => "",
    operand  => XML::XPath::Step.new(
        axis => "namespace",
        test => XML::XPath::NodeTest.new(
            value => "*"
        ),
    ),
), $expression;

$expression = "//kap[1]/pa[2]/text()";
is-deeply $x.parse-xpath($expression),
XML::XPath::Expr.new(
    operator => "",
    operand  => XML::XPath::Step.new(
        axis => "descendant-or-self",
        test => XML::XPath::NodeTest.new(value => "kap"),
        predicates => [
                       XML::XPath::Expr.new(
                           operator => "",
                           operand  => XML::XPath::Expr.new(
                               operand => 1,
                           ),
                       )
                   ],
        next => XML::XPath::Step.new(
            axis => "child",
            test => XML::XPath::NodeTest.new(value => "pa"),
            predicates => [
                           XML::XPath::Expr.new(
                               operator => "",
                               operand  => XML::XPath::Expr.new(
                                   operand => 2,
                               ),
                           )
                       ],
            next => XML::XPath::Step.new(
                axis => "child",
                test => XML::XPath::NodeTest.new(type => "text", value => Str),
            )
        ),
    ),
), $expression;

