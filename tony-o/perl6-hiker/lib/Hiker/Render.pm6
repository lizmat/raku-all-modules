use Template::Mustache;

my Template::Mustache $renderer .=new;

role Hiker::Render {
  has Bool $!rendered = False;
  has Str  $.template is rw;
  has $.req is rw;
  has %.data;

  method render(:$file? = $.template) {
    if !$file.defined || $file.IO !~~ :f {
      $.close('404');
    }
    $.close($renderer.render($file.IO.slurp, %.data));
    $!rendered = True;
  }
  method rendered { return $!rendered; } #ro
}
