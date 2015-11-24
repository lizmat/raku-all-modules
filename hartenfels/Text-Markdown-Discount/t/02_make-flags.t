use v6;
use Test;
use Text::Markdown::Discount;

my &f := &Text::Markdown::Discount::make-flags;
my %f := %Text::Markdown::Discount::discount-flags;


is f({}), 0, 'no flags';

is f({ :strict}), %f<STRICT>, 'single positive flag is set';
is f({:!strict}), 0,          'single negated positive flag is unset';

is f({ :links}), 0,           'single negative flag is unset';
is f({:!links}), %f<NOLINKS>, 'single negated negative flag is set';

is f({ :nolinks}), %f<NOLINKS>, 'single negative flag with no is set';
is f({:!nolinks}), 0,           'single negated negative flag with no is unset';


is f({:!links, :image, :nohtml, :!noext, :strict, :!cdata}),
   %f<NOLINKS> +| %f<NOHTML> +| %f<STRICT>,
   'multiple non-zero flags get ORed together';

is f({:LINKS(Any), :ImAgE(1), :NOhtml, :noexT(''), :STRICT('y'), :cdata(0)}),
   %f<NOLINKS> +| %f<NOHTML> +| %f<STRICT>,
   'case and actual value of flags does not matter';


throws-like { f({:nonexistent}) }, X::Text::Markdown::Discount::Flag,
            'single nonexistent flag dies';

throws-like { f({:strict, :nonexistent}) }, X::Text::Markdown::Discount::Flag,
            'nonexistent flag amongst real flag dies';


done-testing
