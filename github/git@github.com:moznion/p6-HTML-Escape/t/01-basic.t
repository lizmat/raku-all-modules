use v6;
use Test;
use HTML::Escape;

is escape-html('<^o^>'), '&lt;^o^&gt;';
is escape-html("'"),     '&#39;';
is escape-html("\0>"),   "\0&gt;";
is escape-html('`'),     '&#96;';
is escape-html('{}'),    '&#123;&#125;';

done-testing;
