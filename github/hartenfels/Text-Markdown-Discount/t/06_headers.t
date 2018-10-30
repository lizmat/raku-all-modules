use v6;
use Test;
use lib "{$?FILE.IO.dirname}/data";
use Text::Markdown::Discount;
use TextMarkdownDiscountTestBoilerplate;

{
    my $result = Text::Markdown::Discount.from-str(q:to/END/);
        % Delectus velit quo
        % Crawford Mayert
        % 2017-08-15T00:18:36.850Z
        content
        END

    is $result.title,  'Delectus velit quo';
    is $result.author, 'Crawford Mayert';
    is $result.date,   '2017-08-15T00:18:36.850Z';
    is $result.to-str, '<p>content</p>';
}

{
    my $result = Text::Markdown::Discount.from-str(q:to/END/);
        content with no headers
        END

    is $result.title,  Str;
    is $result.author, Str;
    is $result.date,   Str;
    is $result.to-str, '<p>content with no headers</p>';
}

done-testing;
