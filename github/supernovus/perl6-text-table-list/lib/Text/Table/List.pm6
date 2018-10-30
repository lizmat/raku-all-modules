unit class Text::Table::List;

has @!lines;
has $!text;

has $.length = 80;

### Default drawing characters.
has $.top-left     = "╔";
has $.top-right    = "╗";
has $.top-char     = "═";
has $.left-char    = "║ ";
has $.right-char   = " ║";
has $.sep-left     = "╟";
has $.sep-right    = "╢";
has $.sep-char     = "─";
has $.bottom-left  = "╚";
has $.bottom-right = "╝";
has $.bottom-char  = "═";

method start {
  my $line = $.top-left;
  my $pad = $.length - $.top-left.chars - $.top-right.chars;
  $line ~= $.top-char x $pad;
  $line ~= $.top-right;
  @!lines.push: $line;
  return self;
}

method end {
  my $line = $.bottom-left;
  my $pad = $.length - $.bottom-left.chars - $.bottom-right.chars;
  $line ~= $.bottom-char x $pad;
  $line ~= $.bottom-right;
  @!lines.push: $line;
  return @!lines;
}

method Str {
  if $!text.defined { return $!text; }
  return $!text = self.end.join("\n");
}

method say {
  say self.Str;
}

method print {
  print self.Str;
}

method line {
  my $line = $.sep-left;
  my $pad = $.length - $.sep-left.chars - $.sep-right.chars;
  $line ~= $.sep-char x $pad;
  $line ~= $.sep-right;
  @!lines.push: $line;
}

method blank {
  my $line = $.left-char;
  my $pad = $.length - $.left-char.chars - $.right-char.chars;
  $line ~= ' ' x $pad;
  $line ~= $.right-char;
  @!lines.push: $line;
}

method label ($label) {
  my $line = $.left-char;
  my $pad = $.length - $.left-char.chars - $.right-char.chars;
  $line ~= sprintf('%-'~$pad~'s', $label);
  $line ~= $.right-char;
  @!lines.push: $line;
}

multi method field ($name, $value) {
  my $line = $.left-char;
  my $pad = $.length - $.left-char.chars - $.right-char.chars - $name.chars;
  $line ~= $name;
  $line ~= sprintf('%'~$pad~'s', $value);
  $line ~= $.right-char;
  @!lines.push: $line;
}

multi method field (*@fields) {
  for @fields -> $field {
    my ($name, $value) = $field.kv;
    self.field($name, $value);
  }
}

