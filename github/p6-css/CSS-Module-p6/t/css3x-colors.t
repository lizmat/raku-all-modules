#!/usr/bin/env perl6

use Test;

use CSS::Module::CSS3;
use CSS::Grammar::Test;
use CSS::Writer;

my $grammar = CSS::Module::CSS3.module.grammar;
my $actions = CSS::Module::CSS3.module.actions.new;
my $writer = CSS::Writer.new;

for (
    { :rule<term>, input => 'rgb(70%, 50%, 10%)',
               ast =>   :rgb[ :num(179), :num(128), :num(26) ],
    },
    { :rule<term>, input => 'rgba(100%, 128, 0%, 0.1)',
               ast => :rgba[ :num(255), :num(128), :num(0), :num(.1) ],
    },
    { :rule<term>, input => 'hsl(120, 100%, 50%)',
               ast => :hsl[ :num(120), :percent(100), :percent(50) ],
    },
    { :rule<term>, input => 'hsla( 180, 100%, 50%, .75 )',
               ast => :hsla[ :num(180), :percent(100), :percent(50), :num(.75) ],
    },
    # clipping of out-of-range values
    { :rule<term>, input => 'rgba(101%, 50%, -5%, +1.1)',
               ast => :rgba[ :num(255), :num(128), :num(0), :num(1) ],
               :writer{
                   # writer converts rgba(...,1) to rgb(...)
                   ast => :rgb[ :num(255), :num(128), :num(0) ],
                   { :rule<token>, type => 'color', units => 'rgb'},
               },
    },
    { :rule<term>, input => 'hsl(120, 110%, -50%)',
               ast => :hsl[ :num(120), :percent(100), :percent(0) ],
    },
    { :rule<term>, input => 'hsla( 180, -100%, 150%, 1.75 )',
               ast => :hsla[ :num(180), :percent(0), :percent(100), :num(1) ],
    },
    # a few invalid cases
    { :rule<term>, input => 'rgba(10%,20%,30%)',
              ast => Mu,
              warnings => rx{^usage\: \s rgba\(},
    },
    { :rule<term>, input => 'hsl(junk)',
              ast => Mu,
              warnings => rx{^usage\: \s hsl\(},
    },
    { :rule<term>, input => 'hsla()',
              ast => Mu,
              warnings => rx{^usage\: \s hsla\(},
    },
    { :rule<color>, input => 'orange', ast => :rgb[ :num(255), :num(165), :num(0) ]},
    { :rule<color>, input => 'hotpink', ast => :rgb[ :num(255), :num(105), :num(180) ]},
    { :rule<color>, input => 'lavenderblush', ast => :rgb[ :num(255), :num(240), :num(245) ]},
    { :rule<color>, input => 'currentcolor', ast => :keyw<currentcolor>},
    { :rule<color>, input => 'transparent', ast => :keyw<transparent>},
# http://www.w3.org/TR/2011/REC-css3-color-20110607
# @color-profile is in the process of being dropped
##    { :rule<at-rule>, input => '@color-profile { name: acme_cmyk; src: url(http://printers.example.com/acmecorp/model1234); }',
##                ast => {"declarations" => [{"ident" => "name", "expr" => ["keyw" => "acme_cmyk"]},
##                                           {"ident" => "src", "expr" => ["term" => "http://printers.example.com/acmecorp/model1234"]}}],
##                        '@' => "color-profile"},
##    },
    ) -> % ( :$rule!, :$input!, *%expected) {

    CSS::Grammar::Test::parse-tests($grammar, $input,
				    :$rule,
				    :$actions,
				    :suite<css3-color>,
                                    :$writer,
				    :%expected );
}

done-testing;
