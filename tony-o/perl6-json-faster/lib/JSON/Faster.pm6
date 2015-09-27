unit module JSON::Faster;

sub to-json($obj, Bool :$pretty? = True, Int :$level? = 0, Int :$spacing? = 2) is export {
  CATCH { default { .say; } }
  return "{$obj}"     if $obj ~~ Int || $obj ~~ Rat;
  return "\"{$obj.subst(/'"'/, '\\"', :g)}\"" if $obj ~~ Str;

  my str  $out = '';
  my int  $lvl = $level;
  my Bool $arr = $obj ~~ Array;
  my $spacer   = sub {
    $out ~= "\n" ~ (' ' x $lvl*$spacing) if $pretty;
  };

  $out ~= $arr ?? '[' !! '{';
  $lvl++;
  $spacer();
  if $arr {
    for @($obj) -> $i {
      $out ~= to-json($i, :level($level+1), :$spacing, :$pretty) ~ ',';
      $spacer();
    }
  } else {
    for $obj.keys -> $key {
      $out ~= "\"{$key.subst(/'"'/, '\\"', :g)}\": " ~ to-json($obj{$key}, :level($level+1), :$spacing, :$pretty) ~ ',';
      $spacer();
    }
  }
  $out .=subst(/',' \s* $/, '');
  $lvl--;
  $spacer();
  $out ~= $arr ?? ']' !! '}';
  return $out;
}

sub sshift ($t is rw) { 
  wws($t);
  my $r = $t.substr(0,1);
  $t.=substr(1);
  $r;
}
sub wws ($t is rw) {
  $t.trim-leading; 
}

sub from-json(Str $t is rw, :$depth = -1) is export(:from-json) {
  my int $state = 0;
#  my str $t     = $text;
  my int $index = 0;
  my str $buff;
  my str ($key, $val);
  my $ret;
  
  wws($t);
  $buff = sshift($t);
  $ret  = $buff eq '{' ??
            %() !!
            $buff eq '[' ??
              @() !!
              die 'JSON must start with \'[\' or \'{\'';

  my int ($instr, $nest, $typ);
  my str $mat;

  while $t.chars {
    given $state {
      when 0 {
        $key = sshift($t);
        $typ = $key ~~ /^ ['.' | \d] $/ ?? 0 !! 1;
        die 'Unquoted JSON keys are not supported' if
          $ret ~~ Hash &&
          $typ == 0;
        $index = 10000;
        given $typ {
          when 0 {
            $index = $t.match(/[ ',' | ']' ]/).from;
            $key  ~= $t.substr(0, $index);
            $ret.push($key ~~ /^ \d+ $/ ?? $key.Int !! $key.Rat);
            $t.=substr($index+1);
            wws($t);
          }
          when 1 {
            if $ret ~~ Hash && ($key eq '{' || $key eq '[') {

              ($nest,$instr) = 0,0;
              $mat  = $val eq '[' ?? ']' !! '}';
              $index = 0;
              $t = $val ~ $t;
              while $index++ < $t.chars {
                if $t.substr($index, 1) eq '"' {
                  if $index > 0 && $t.substr($index-1,1) ne '\\' && $instr == 1 {
                    $instr = 0;
                  } else { 
                    $instr = 1;
                  }
                }
                last    if $t.substr($index, 1) eq $mat && !$instr && $nest == 0;
                $nest++ if $t.substr($index, 1) eq any('{','[') && $instr == 0;
              }
              $ret.push(from-json($t.substr(0, $index+1)));
              $t.=substr($index+1);
              wws($t);
              sshift($t);

            } elsif $key eq '"' {
              $index = $t.match(/<!after '\\'> '"'/).from;
              $key = $t.substr(0, $index).subst(/'\\"'/, '"', :g);
              $t.=substr($index+1);
              wws($t);
              if $ret ~~ Hash {
                die 'Key not followed up with a colon' if sshift($t) ne ':';
                $state++;
              } else {
                $ret.push($key);
                sshift($t);
              }
            }
          }
        };
      };
      when 1 {
        $val = sshift($t);
        $typ = $val ~~ /^ ['.' | \d] $/ ?? 0 !! 1;
        given $typ {
          when 0 {
            $index = $t.match(/[ ',' | '}' ]/).from;
            $val  ~= $t.substr(0, $index).trim;
            $ret{$key} = $val ~~ /^ \d+ $/ ?? $val.Int !! $val.Rat;
            $t.=substr($index+1);
            wws($t);
          }
          when 1 {
            if $val eq '{' || $val eq '[' {
              ($nest,$instr) = 0,0;
              $mat  = $val eq '[' ?? ']' !! '}';
              $index = 0;
              $t = $val ~ $t;
              my @indexes = $t.match(/[ '"' | '{' | '[' | "$mat" ]/, :g).map({.from});
              for @indexes -> $ii {
                $index = $ii;
                if $t.substr($ii, 1) eq '"' {
                  if $ii > 0 && $t.substr($ii-1,1) ne '\\' && $instr == 1 {
                    $instr = 0;
                  } else { 
                    $instr = 1;
                  }
                }
                last    if $t.substr($ii, 1) eq $mat && !$instr && $nest == 0;
                $nest++ if $t.substr($ii, 1) eq any('{','[') && $instr == 0;
              }
              $ret{$key} = from-json($t.substr(0, $index+1), :depth($depth-1)) if $depth-1 > 0;
              $ret{$key} = $t.substr(0, $index+1) if $depth-1 <= 0;
              $t.=substr($index+1);
              wws($t);
              sshift($t);
            } elsif $val eq '"' {
              $index = $t.match(/<!after '\\'> '"'/).from;
              $val = $t.substr(0, $index).subst(/'\\"'/, '"', :g);
              $t.=substr($index+1);
              wws($t);
              sshift($t);
              $ret{$key} = $val;
            } else {
              die 'Values must be a number or start with ", {, or [';
            }
          }
        };
        $state = 0;
      };
    };
  }
  return $ret;
}
