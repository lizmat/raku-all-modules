use v6.c;
use File::HomeDir;

#-------------------------------------------------------------------------------
unit class Config::DataLang::Refine:ver<0.3.4>:auth<github:MARTIMM>;

has Str $!config-name;
has Hash $.config;

subset StrMode of Int where 10 <= $_ <= 13;
constant C-URI-OPTS-T1          is export = 10;
constant C-URI-OPTS-T2          is export = 11;
constant C-UNIX-OPTS-T1         is export = 12;
constant C-UNIX-OPTS-T2         is export = 13;

#-------------------------------------------------------------------------------
submethod BUILD (
  Str :$config-name is copy,
  Bool :$merge = False,
  Array :$locations is copy = [],
  Str :$data-module = 'Config::TOML'
) {

  # Import proper routine and select read routine
  my Sub $read-from-text;
  my Str $extension;
  given $data-module {
    when 'Config::TOML' {
      require ::($data-module) <&from-toml>;
      $read-from-text = &from-toml;
      $extension = '.toml';
    }

    when 'JSON::Fast' {
      require ::($data-module) <&from-json>;
      $read-from-text = &from-json;
      $extension = '.json';
    }

    default {
      die "Module $data-module not supported (yet)";
    }
  }

  # Read and deserialize text from file
  my Str $config-content;

  # Read file only once
  if not $!config.defined {

    # Check name
    if $config-name.defined {

      # Check if name holds complete path, relative or absolute
      if $config-name ~~ m/<[/]>+/ {
        my Str $base-name = $config-name.IO.basename;
        my Str $p = $config-name.IO.resolve.Str;
        $p ~~ s/<[/]>? $base-name $//;
        $locations.push($p);
        $config-name = $base-name;
      }
    }

    # If user didn't define a name, derive it from the program name
    else {
      $config-name = $*PROGRAM.basename;
      my Str $ext = $*PROGRAM.extension;
      $config-name ~~ s/\.$ext// if $ext.defined;
      $config-name ~= $extension;
    }

    if $merge {

      $config-content = '';
      $!config = {};
      for |(map {[~] .IO.resolve.Str, '/', $config-name}, @$locations),
          File::HomeDir.my-home ~ "/.$config-name",
          ".$config-name", $config-name -> $cfg-name {

        if $cfg-name.IO ~~ :r {
          $config-content = slurp($cfg-name) ~ "\n";

#say "Merge $cfg-name";

          # Parse config file if exists
          $!config = self!merge-hash( $!config, $read-from-text($config-content));
        }
      }

      unless $!config.elems {
        die "Config files derived from $config-name not found or empty in current directory (plain or hidden) or in home directory";
      }
    }

    else {

      for $config-name, ".$config-name",
          File::HomeDir.my-home ~ "/.$config-name",
          |(map {[~] .IO.resolve.Str, '/', $config-name}, @$locations)
          -> $cfg-name {

#say "Search $cfg-name";

        if $cfg-name.IO ~~ :r {
          $config-content = slurp($cfg-name);
          last;
        }
      }

      unless ?$config-content {
        die "Config file $config-name not found in current directory (plain or hidden) or in home directory";
      }

      # Parse config file if exists
      $!config = $read-from-text($config-content);
    }
  }
}

#-------------------------------------------------------------------------------
method refine ( *@key-list, Bool :$filter = False --> Hash ) {

  my Hash $refined-list = {};
  my Hash $s = $!config;

  for @key-list -> $refine-key {

    last unless $s{$refine-key}:exists and $s{$refine-key}.defined;
    $s = $s{$refine-key};

    for $s.keys -> $k {
      next if $s{$k} ~~ Hash;
      $refined-list{$k} = $s{$k};

      # Looks like too much but it isn't. It must be able to remove
      # previously set entries.
      $refined-list{$k}:delete if $filter and $s{$k} ~~ Bool and !$s{$k};
    }
  }

  $refined-list;
}

#-------------------------------------------------------------------------------
method refine-str (
  *@key-list,
  Str :$glue = ',',
  Bool :$filter = False,
  StrMode :$str-mode = C-URI-OPTS-T1
  --> Array
) {

  my Str $entry;
  my Array $refined-list = [];
  my Hash $o = self.refine( @key-list, :$filter) // {};

  if $str-mode ~~ any(C-URI-OPTS-T1|C-URI-OPTS-T2) {
    for $o.kv -> $k is copy, $v is copy {
      $k = self!encode-uri-t2($k) if $str-mode == C-URI-OPTS-T2;

      given $v {
        # should not happen
        when Hash {
          next;
        }

        when Array {
          $v = $v.join($glue);
          $v = self!encode-uri-t2($v) if $str-mode == C-URI-OPTS-T2;
          $entry = "$k=$v";
        }

        when /\s/ {
          $v = "'$v'" if $str-mode == C-URI-OPTS-T1;
          $v = self!encode-uri-t2($v) if $str-mode == C-URI-OPTS-T2;
          $entry = "$k=$v";
        }

        default {
          $v = self!encode-uri-t2($v) if $str-mode == C-URI-OPTS-T2;
          $entry = "$k=$v";
        }
      }

      $refined-list.push: $entry;
    }
  }

  elsif $str-mode == C-UNIX-OPTS-T1 {

    for $o.kv -> $k, $v {

      given $v {
        # should not happen
        when Hash {
          next;
        }

        when Array {
          $entry = ($k.chars == 1 ?? "-$k" !! "--$k=" ) ~ $v.join($glue);
        }

        when Bool {
          if $k.chars == 1 {
            if ?$v {
              $entry = "-$k";
            }

            else {
              $entry = "--no$k";
            }
          }

          else {
            if ?$v {
              $entry = "--$k";
            }

            else {
              $entry = "--no$k";
            }
          }
        }

        when /\s/ {
          $entry = ($k.chars == 1 ?? "-$k" !! "--$k=" ) ~ "'$v'";
        }

        default {
          $entry = ($k.chars == 1 ?? "-$k" !! "--$k=" ) ~ $v;
        }
      }

      $refined-list.push: $entry;
    }
  }

  elsif $str-mode == C-UNIX-OPTS-T2 {
    my Str $T2-entry = '-';

    for $o.kv -> $k, $v {

      $entry = '';

      given $v {
        # should not happen
        when Hash {
          next;
        }

        when Array {
          $entry = ($k.chars == 1 ?? "-$k" !! "--$k=" ) ~ $v.join($glue);
        }

        when Bool {
          if $k.chars == 1 {
            if ?$v {
              $T2-entry ~= "$k";
            }

            else {
              $entry = "--no$k";
            }
          }

          else {
            if ?$v {
              $entry = "--$k";
            }

            else {
              $entry = "--no$k";
            }
          }
        }

        when /\s/ {
          $entry = ($k.chars == 1 ?? "-$k" !! "--$k=" ) ~ "'$v'";
        }

        default {
          $entry = ($k.chars == 1 ?? "-$k" !! "--$k=" ) ~ $v;
        }
      }

      $refined-list.push: $entry if ?$entry;
    }

    $refined-list.push: $T2-entry if $T2-entry.chars > 1;
  }

  $refined-list;
}

#-------------------------------------------------------------------------------
method !encode-uri-t2 ( Str $entry --> Str ) {

  my Str $new-entry = '';
  for ($entry ~~ /(.)+/).flat -> $c is copy { 
    $c = $c.Str;
    my int $c-ord = $c.ord;

    if 0x19 < $c-ord < 0x30
       or 0x39 < $c-ord < 0x41
       or 0x5a < $c-ord < 0x61
       or 0x7a < $c-ord < 0x80
       or $c.ord ~~ any(0x81|0x8f|0x9D) {
      $new-entry ~= $c.ord.fmt('%%%02X');
    }

    elsif $c-ord == 0x80 {
      $new-entry ~= '%E2%82%AC';
    }

    elsif $c-ord == 0x82 {
      $new-entry ~= '%E2%80%9A';
    }

    elsif $c-ord == 0x83 {
      $new-entry ~= '%C6%92';
    }

    elsif $c-ord == 0x84 {
      $new-entry ~= '%E2%80%9E';
    }

    elsif $c-ord == 0x85 {
      $new-entry ~= '%E2%80%A6';
    }

    elsif $c-ord == 0x86 {
      $new-entry ~= '%E2%80%A0';
    }

    else {
      $new-entry ~= $c;
    }
  }

  $new-entry;
}

#-------------------------------------------------------------------------------
method !merge-hash ( Hash $h1, Hash $h2 --> Hash ) {

  my Hash $h3 = $h1;
  for $h2.kv -> $k, $v {

    if $v ~~ Hash {

      $h3{$k} = self!merge-hash( $h3{$k} // {}, $v);
    }

    else {

      $h3{$k} = $v;
    }
  }

  $h3 // {};
}

