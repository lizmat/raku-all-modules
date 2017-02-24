#!/usr/bin/env perl6

use Test;

use CSS::Module::CSS3;
use CSS::Grammar::Test;
use CSS::Writer;

my $grammar = CSS::Module::CSS3.module.grammar;
my $actions = CSS::Module::CSS3.module.actions.new;
my $writer = CSS::Writer.new;

for (
    {:rule<at-decl>, :input('@namespace empty "";'),
     :ast(:at-rule{ :ns-prefix<empty>, :url(""), :at-keyw<namespace>}),
    },
    {:rule<at-decl>, :input('@NAMESPACE "";'),
     :ast(:at-rule{ :url(""), :at-keyw<namespace>}),
    },
    {:rule<at-decl>, :input('@namespace "http://www.w3.org/1999/xhtml";'),
     :ast(:at-rule{ :url<http://www.w3.org/1999/xhtml>, :at-keyw<namespace>}),
    },
    {:rule<at-decl>, :input('@namespace svg "http://www.w3.org/2000/svg";'),
     :ast(:at-rule{ :ns-prefix<svg>, :url<http://www.w3.org/2000/svg>, :at-keyw<namespace>}),
    },
    {:rule<stylesheet>, :input('@namespace toto url(http://toto.example.org);'),
     :ast(:stylesheet[{ :at-rule{ :ns-prefix<toto>, :url<http://toto.example.org>, :at-keyw<namespace>}}]),
    },
) -> % ( :$rule!, :$input!, *%expected ) {

    CSS::Grammar::Test::parse-tests($grammar, $input,
				    :$rule,
				    :$actions,
				    :suite<css3-namespaces>,
                                    :$writer,
				    :%expected );
}

done-testing;
