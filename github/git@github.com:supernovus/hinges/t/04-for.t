use v6;
use Test;
use Hinges;

plan 2;

todo('Hinges::Stream.render not implemented yet', 2);
{
    my Hinges::MarkupTemplate $template .= new('<html>
  <h1 pe:for="@list">$_</h1>
</html>
');
    is $template.generate( '@list' => <foo bar baz> ).render('html',
                           :doctype(Hinges::DocType::HTML5)),
       '<!DOCTYPE html>
<html>
  <h1>foo</h1>
  <h1>bar</h1>
  <h1>baz</h1>
</html>
', 'for loop with loop variable $_ works';
}

{
    my Hinges::MarkupTemplate $template .= new('<html>
  <h1 pe:for="@list -> $item">$item</h1>
</html>
');
    is $template.generate( '@list' => <foo bar baz> ).render('html',
                           :doctype(Hinges::DocType::HTML5)),
       '<!DOCTYPE html>
<html>
  <h1>foo</h1>
  <h1>bar</h1>
  <h1>baz</h1>
</html>
', 'for loop with custom loop variable works';
}
