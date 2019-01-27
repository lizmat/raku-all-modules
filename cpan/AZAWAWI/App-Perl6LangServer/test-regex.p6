use v6;


my $source-code = q:to/END/;
class ClassA::B {
# Some class FakeComment weird comment
  method A { }
}
END

# Remove line comments
$source-code = $source-code.lines.map({
  $_.subst(/ '#' (.+?) $ /, { '#' ~ (" " x $0.chars) })
}).join("\n");

say $source-code;


my $to = 0;
my $line-number = 0;
my @line-ranges;
for $source-code.lines -> $line { 
  my $length = $line.chars;
  my $from = $to;
  $to += $length;
  @line-ranges.push: {
    line-number => $line-number++,
    from        => $from,
    to          => $to
  };
}

sub to-line-number(Int $position) {
  for @line-ranges -> $line-range {
    if $position >= $line-range<from> && $position <= $line-range<to> {
      return $line-range<line-number>;
    }
  }
  return -1;
}

# Find all package declarations
my @package-declarations = $source-code ~~ m:global/
  # Declaration
  ('class'| 'grammar'| 'module'| 'package'| 'role')
  # Whitespace
  \s+
  # Identifier
  (\w+ ('::' \w+))
/;
for @package-declarations -> $decl {
  my %record = %(
    from        => $decl[0].from,
    to          => $decl[0].pos,
    line-number => to-line-number($decl[0].from) + 1,
    type        => ~$decl[0],
    name        => ~$decl[1],
  );
  say %record;
}

my @variable-declarations = $source-code ~~ m:global/
  # Declaration
  ('my'| 'state')
  # Whitespace
  \s+
  # Identifier
  (( '$' | '@' | '%') \w+)
/;
for @variable-declarations -> $decl {
  my %record = %(
    from        => $decl[0].from,
    to          => $decl[0].pos,
    line-number => to-line-number($decl[0].from) + 1,
    type        => ~$decl[0],
    name        => ~$decl[1],
  );
  say %record;
}

my @routine-declarations = $source-code ~~ m:global/
  # Declaration
  ('sub'| 'method')
  # Whitespace
  \s+
  # Identifier
  (\w+)
/;
for @routine-declarations -> $decl {
  my %record = %(
    from        => $decl[0].from,
    to          => $decl[0].pos,
    line-number => to-line-number($decl[0].from) + 1,
    type        => ~$decl[0],
    name        => ~$decl[1],
  );
  say %record;
}
