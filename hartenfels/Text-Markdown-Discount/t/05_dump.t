use v6;
use Test;
use Text::Markdown::Discount;
use lib "{$?FILE.IO.dirname}/data";
use TextMarkdownDiscountTestBoilerplate;


sub test-dump
{
    my $file = tmpname;
    Text::Markdown::Discount.from-str('', |%_).dump-flags($file);

    my $want = set @_;
    my $got  = $want ∩ set comb /\S+/, slurp $file;
    unless ok $got ~~ $want, "@_[]"
    {
        diag "expected: $want";
        diag "     got: $got";
    }
}


test-dump( 'LINKS',  'IMAGE');
test-dump('!LINKS',  'IMAGE', :!links);
test-dump( 'LINKS', '!IMAGE', :!image);
test-dump('!LINKS', '!IMAGE', :!links, :!image);


done-testing
