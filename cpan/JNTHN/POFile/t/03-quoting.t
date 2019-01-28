use v6;
use Test;
use POFile :quoting;

is po-unquote(｢\t\"\\\n｣), ｢\t"\\n｣, 'Unquoting works';
is po-quote(｢\t"\\n\｣), ｢\t\"\\\n\\｣, 'Quoting works';

done-testing;
