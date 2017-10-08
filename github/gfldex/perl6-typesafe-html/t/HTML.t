use v6;
use Test;
use Typesafe::HTML;

plan 3;

my $p-o = HTML.new(q{<p id="<h1>">});
my $p-c = HTML.new(q{</p>});

is ($p-o ~ q{<h1>} ~ $p-c), q{<p id="<h1>">&lt;h1></p>}, 'basic concatanation test';

is ('<&Hello' ~ HTML.new(q{<br>}) ~ 'Camelia!&>'), q{&lt;&amp;Hello<br>Camelia!&amp;>}, 'html in the middle';

is HTML.new.WHAT, HTML, 'empty constructor';
