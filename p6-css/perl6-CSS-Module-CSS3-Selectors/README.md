# perl6-CSS-Module-CSS3-Selectors
This module extends CSS::Grammar::CSS3, implementing [CSS Selectors Module Level 3](http://www.w3.org/TR/2011/REC-css3-selectors-20110929/). It provides grammar `CSS::Module::CSS3::Selectors` and actions class `CSS::Module::CSS3::Selectors::Actions`.

## Example

```
use CSS::Module::CSS3::Selectors;
my $actions = CSS::Module::CSS3::Selectors::Actions.new;
CSS::Module::CSS3::Selectors.parse('tr:nth-child(2n+1) span[class="example"]', :rule<selectors>, :$actions);
say $/.ast.perl;
```

Some of the key extensions are:

- namespaces: `svg|circle`
- attribute selections: `span[class="example"]`
- additional attribute operators: `^=` (prefix), `$=` (suffix), `*=` (substring)
  [inherited from CSS::Grammar::CSS3: `=` (equals), `~=` (includes), `|=` (dash)]
- structural selectors: `tr:nth-child(2n+1)` `foo:nth-last-child(odd)`
- negation: `body > h2:not(:first-of-type):not(:last-of-type)`

## See Also

- [CSS::Grammar](https://github.com/p6-css/perl6-CSS-Grammar) - base grammars
- [CSS::Module](https://github.com/p6-css/perl6-CSS-Module) - property specific grammars
