use Template::Protone;

my Template::Protone $renderer .=new;

role Hiker::Render {
  has Bool $!rendered = False;
  has Str  $.template is rw;
  has $.req is rw;
  has %.data;

  method render(:$file? = $.template, :$stash?) {
    if !$file:defined || $file.IO !~~ :f {
      $.close('404');
    }
    $renderer.parse(:template($file.IO.slurp), :name($file)) unless $renderer.cache{$file}:exists;
    $.close($renderer.render(:name($file), :data(%.data)));
    $!rendered = True;
  }
  method rendered { return $!rendered; } #ro
}
