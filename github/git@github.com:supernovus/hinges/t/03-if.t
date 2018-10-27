use v6;
use Test;
use Hinges;

plan 2;

todo('Hinges::Stream.render not implemented yet', 2);
{
    my Hinges::MarkupTemplate $template .= new('<html>
  <h1 pe:if="$flag">Hello, world!</h1>
</html>
');
    is $template.generate( :flag(True) ).render('html',
                           :doctype(Hinges::DocType::HTML5)),
       '<!DOCTYPE html>
<html>
  <h1>Hello, world!</h1>
</html>
', 'true if statement works';
    is $template.generate( :flag(False) ).render('html',
                           :doctype(Hinges::DocType::HTML5)),
       '<!DOCTYPE html>
<html>
</html>
', 'false if statement works';
}
