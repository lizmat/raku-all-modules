use v6;
use Test;
use lib "{$?FILE.IO.dirname}/data";
use Text::Markdown::Discount;
use TextMarkdownDiscountTestBoilerplate;


is markdown($simple.from ), $simple.to.trim, 'string to string';
is markdown($simple.md.IO), $simple.to.trim,   'file to string';

{
    my $file = tmpname;
    markdown($simple.from, $file);
    is slurp($file), $simple.to, 'string to file';
    unlink $file;
}

{
    my $file = tmpname;
    markdown($simple.md.IO, $file);
    is slurp($file), $simple.to, 'file to file';
    unlink $file;
}


for {}, {:nolinks}, {:nohtml}, {:nolinks, :nohtml}
{
    my $mod = join '.', sort .keys;
    is markdown($html.from, |$_), $html.to($mod).trim,
       "HTML conversion ({.keys})";
}


done-testing
