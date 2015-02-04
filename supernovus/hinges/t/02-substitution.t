use v6;
use Test;
use Hinges;

plan 2;

todo('Hinges::Stream.render not implemented yet', 2);
{
    my Hinges::MarkupTemplate $template .= new('<html>
  <h1>Hello, $name!</h1>
</html>
');
    my Hinges::Stream $stream = $template.generate( :name<world> );
    is $stream.render('html', :doctype(Hinges::DocType::HTML5)),
       '<!DOCTYPE html>
<html>
  <h1>Hello, world!</h1>
</html>
', 'simple variable substitution works';
}

{
    my Hinges::MarkupTemplate $template .= new('<html>
  <h1>Hello, ${ $name }</h1></html>
');
    my Hinges::Stream $stream = $template.generate( :name<world> );
    is $stream.render('html', :doctype(Hinges::DocType::HTML5)),       '<!DOCTYPE html>
<html>
  <h1>Hello, world!</h1>
</html>
', 'dollar block substitution works';
}
