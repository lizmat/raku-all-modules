use Web::Template;

class Web::Template::Mojo does Web::Template
{
  use Template::Mojo;

  has $!engine = Template::Mojo;
  has @!paths  = './views';

  method render ($template-name, *%named, *@positional)
  {
    my $template-file;
    my $template;
    for @!paths -> $path
    {
      $template-file = IO::Spec.catfile($path, $template-name);
      unless $template-file.IO ~~ :f {
        $template-file = IO::Spec.catfile($path, $template-name ~ ".tm");
      }
      if $template-file.IO ~~ :f
      {
        $template = slurp($template-file);
        last;
      }
    }

    $template orelse die "No template file for '$template-name' was found.";

    ## Template::Mojo uses positional paramemters.
    $!engine.new($template).render(%named.kv, |@positional);
  }

  method set-path (*@paths)
  {
    @!paths = @paths;
  }

}
