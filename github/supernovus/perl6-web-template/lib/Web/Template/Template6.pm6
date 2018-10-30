use Web::Template;

class Web::Template::Template6 does Web::Template
{
  use Template6;
  
  has $!engine = Template6.new;

  method render ($template, *%named, *@positional)
  { ## Template6 uses named parameters only.
    $!engine.process($template, |%named);
  }

  method set-path (*@paths)
  {
    for @paths -> $path
    {
      $!engine.add-path($path);
    }
  }

}

