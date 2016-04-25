use Web::Template;

class Web::Template::TAL does Web::Template
{
  use Flower::TAL;
  
  has $!engine = Flower::TAL.new;

  method render ($template, *%named, *@positional)
  { ## Flower::TAL uses named parameters only.
    $!engine.process($template, |%named);
  }

  method set-path (*@paths)
  {
    for @paths -> $path
    {
      $!engine.provider.add-path($path);
    }
  }

}
