#!/usr/bin/env perl6

use Test;

use CSS::Module::CSS3::Colors;
use CSS::Grammar::Test;
use CSS::Writer;

my $actions = CSS::Module::CSS3::Colors::Actions.new;
my $writer = CSS::Writer.new;

for (
    term   => {input => 'rgb(70%, 50%, 10%)',
               ast =>   :rgb[ :num(179), :num(128), :num(26) ],
    },
    term   => {input => 'rgba(100%, 128, 0%, 0.1)',
               ast => :rgba[ :num(255), :num(128), :num(0), :num(.1) ],
    },
    term   => {input => 'hsl(120, 100%, 50%)',
               ast => :hsl[ :num(120), {percent => 100}, {percent => 50} ],
    },
    term   => {input => 'hsla( 180, 100%, 50%, .75 )',
               ast => :hsla[ :num(180), {percent => 100}, {percent => 50}, :num(.75) ],
    },
    # clipping of out-of-range values
    term   => {input => 'rgba(101%, 50%, -5%, +1.1)',
               ast => :rgba[ :num(255), :num(128), :num(0), :num(1) ],
               writer => {
                   # writer converts rgba(...,1) to rgb(...)
                   ast => :rgb[ :num(255), :num(128), :num(0) ],
                   token => {type => 'color', units => 'rgb'},
               },
    },
    term   => {input => 'hsl(120, 110%, -50%)',
               ast => :hsl[ :num(120), :percent(100), :percent(0) ],
    },
    term   => {input => 'hsla( 180, -100%, 150%, 1.75 )',
               ast => :hsla[ :num(180), {percent => 0}, {percent => 100}, :num(1) ],
    },
    # a few invalid cases
    term  => {input => 'rgba(10%,20%,30%)',
              ast => Mu,
              warnings => rx{^usage\: \s rgba\(},
    },
    term  => {input => 'hsl(junk)',
              ast => Mu,
              warnings => rx{^usage\: \s hsl\(},
    },
    term  => {input => 'hsla()',
              ast => Mu,
              warnings => rx{^usage\: \s hsla\(},
    },
    color => {input => 'orange', ast => :rgb[ :num(255), :num(165), :num(0) ]},
    color => {input => 'hotpink', ast => :rgb[ :num(255), :num(105), :num(180) ]},
    color => {input => 'lavenderblush', ast => :rgb[ :num(255), :num(240), :num(245) ]},
    color => {input => 'currentcolor', ast => :color<currentcolor>},
    color => {input => 'transparent', ast => :color<transparent>},
# http://www.w3.org/TR/2011/REC-css3-color-20110607
# @color-profile is in the process of being dropped
##    at-rule => {input => '@color-profile { name: acme_cmyk; src: url(http://printers.example.com/acmecorp/model1234); }',
##                ast => {"declarations" => [{"ident" => "name", "expr" => ["keyw" => "acme_cmyk"]},
##                                           {"ident" => "src", "expr" => ["term" => "http://printers.example.com/acmecorp/model1234"]}}],
##                        '@' => "color-profile"},
##    },
    ) {
    my $rule = .key;
    my %expected = @( .value );
    my $input = %expected<input>;

    CSS::Grammar::Test::parse-tests(CSS::Module::CSS3::Colors, $input,
				    :$rule,
				    :$actions,
				    :suite<css3-color>,
                                    :$writer,
				    :%expected );
}

done;
