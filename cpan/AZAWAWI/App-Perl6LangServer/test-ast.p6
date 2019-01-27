use v6;

my $source-code = q:to/END/;
class ClassA {

  method A { }
  sub B { }
  sub foo {
    my $var = 1;
    say "Hello, World!";
  }
}
class ClassB {
  
  class ClassC {
    
  };

  method A1 { }
  sub B1 { }
  sub foo1 {  }
}
END

"foofoo.p6".IO.spurt($source-code);
LEAVE "foofoo.p6".IO.unlink;

# say $source-code.chars;

my $output = qq:x{perl6 --target=parse foofoo.p6};
"ast-tree.txt".IO.spurt: $output;

my @array;
my (Int $indent, $rule, $value);
for $output.lines -> $line {
  if $line ~~ /^ (\s*) '- ' (\w+) ': ' (.+) $/ {

    if $rule.defined {
      # say "$indent: $rule => $value";
      @array.push( {
          indent => +$indent,
          rule   => $rule,
          value  => $value,
      });
    }

    $indent = (~$/[0]).chars;
    $rule   = ~$/[1];
    $value  = ~$/[2];
  } else {
    $value ~= $line;
  }
}


my @results;
my @packages;
my Int $package-indent = -1;
my Int $last-package-indent = -1;
my Str $type;
for @array -> $item {
  say $item.perl;
  # if $item<rule> eq 'statementlist' {
  #   #my $length = $item<value>.chars; 
  #   #say $length;
  # }
  if $item<rule> eq 'package_declarator' {
    if $item<value> ~~ /('class' | 'grammar') \s+/ {
      $type = ~$/[0];
      $last-package-indent = $package-indent;
      $package-indent = $item<indent>;
      # if (@packages.elems > 0) && ($last-package-indent >= $package-indent) {
      #   # my $zz = @packages.pop;
      #   # say "popped $zz";
      # }
    }
  }
  if $item<rule> eq 'routine_declarator' {
    # say "Found routine";
    if $item<value> ~~ /('sub' | 'method') \s+/ {
      $type = ~$/[0];
    }
  }
  if $item<rule> eq 'variable' {
    # say "Found variable {$item<value>}";
  }
  if $item<rule> eq 'name' {
    if $type.defined {
      my $name = $item<value>;
      # say $item<indent> ~" vs " ~ $package-indent;
      # if $item<indent> <= $package-indent {
      #   #my $zz = @packages.pop;
      #   die "popped";
      # }

      if $type eq any('class', 'grammar') {
        say "Found new package '$name'";
        @packages.push($name);
      }
      @results.push( {
        'type'    => $type,
        'name'    => $item<value>,
        'packages' => @packages.join('|'),
      });
      $type = Nil;
    }
  }
}

say "|" ~ "----|" x 20;

for @results -> $result {
  say $result;
}
