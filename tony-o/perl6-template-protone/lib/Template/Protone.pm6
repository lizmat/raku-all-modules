unit class Template::Protone;

has Str $.open  = '<%';
has Str $.close = '%>';
has Bool $.trim = True;

has %.cache;

method parse(:$template is copy, :$name?) {
  if $template.IO ~~ :f {
    $template = $template.IO.slurp;
  }
  
  my (Int $from, Int $to, Str $code);

  $code = '';
  while ($from = $template.index($.open)) {
    $code ~= 'print \'' ~ $template.substr(0, $from).subst('\'', '\\\'') ~ '\';' if ! $.trim || $template.substr(0, $from).trim.chars > 0;
    $to = $template.index($.close, $from + $.open.chars);
    $code ~= "\n" ~ $template.substr($from + $.open.chars, $to - $from - $.close.chars - $.open.chars + 1);
    $template .=substr($to + $.close.chars);
  }

  my $sub = EVAL " sub (\$data?) \{ $code \}";

  %.cache{$name} = $sub if defined $name;
  return $sub;
}

multi method render(Str :$template, :$data? = Nil) {
  return callsame unless defined $template;
  return $.render($.parse(:$template), :$data);
}

multi method render(Str :$name, :$data? = Nil) {
  return $.render(%.cache{$name}, :$data);
}

multi method render(Callable $c, :$data? = Nil) {
  my $stdout = $*OUT;
  my $output = '';
  $*OUT = class {
    method print(*@args) { 
      $output ~= @args.join('') if @args.elems; 
    }
    method flush() { }
  };
  $c($data);
  $*OUT = $stdout;
  return $output;
}
