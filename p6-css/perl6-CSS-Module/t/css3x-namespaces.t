#!/usr/bin/env perl6

use Test;

use CSS::Module::CSS3::Namespaces;
use CSS::Grammar::Test;
use CSS::Writer;

my $actions = CSS::Module::CSS3::Namespaces::Actions.new;
my $writer = CSS::Writer.new;

for (
    at-decl => {input => '@namespace empty "";',
                ast => :namespace-rule{ :ns-prefix<empty>, :url(""), :at-keyw<namespace>},
    },
    at-decl => {input => '@NAMESPACE "";',
                ast => :namespace-rule{ :url(""), :at-keyw<namespace>},
    },
    at-decl => {input => '@namespace "http://www.w3.org/1999/xhtml";',
                ast => :namespace-rule{ :url<http://www.w3.org/1999/xhtml>, :at-keyw<namespace>},
    },
    at-decl => {input => '@namespace svg "http://www.w3.org/2000/svg";',
                ast => :namespace-rule{ :ns-prefix<svg>, :url<http://www.w3.org/2000/svg>, :at-keyw<namespace>},
    },
    stylesheet => {input => '@namespace toto url(http://toto.example.org);',
                ast => :stylesheet[{ :namespace-rule{ :ns-prefix<toto>, :url<http://toto.example.org>, :at-keyw<namespace>}}],
    },
    ) {
    my $rule = .key;
    my $expected = .value;
    my $input = $expected<input>;

    CSS::Grammar::Test::parse-tests(CSS::Module::CSS3::Namespaces, $input,
				    :$rule,
				    :$actions,
				    :suite<css3-namespaces>,
                                    :$writer,
				    :$expected );
}

done;
