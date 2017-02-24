use v6.c;

#-------------------------------------------------------------------------------
class X::Config::DataLang::Refine is Exception {
  has Str $.message;
}

#-------------------------------------------------------------------------------
class Config::DataLang::Refine:auth<https://github.com/MARTIMM> {

  has Array $!config-names = [];
  has Array $!locations = [];

  has Sub $!read-from-text;
  has Str $!extension;

  has Bool $!merge = False;
  has Str $!config-content = '';
  has Hash:D $.config is rw = {};

  has Str $!p-out;
  has Int $!p-lvl;

  has Bool $!trace = False;

  enum StrMode is export <
    C-URI-OPTS-T1 C-URI-OPTS-T2 C-UNIX-OPTS-T1 C-UNIX-OPTS-T2 C-UNIX-OPTS-T3
  >;

  #-----------------------------------------------------------------------------
  submethod BUILD (
    Str :$config-name = '', Bool :$!merge = False, Array :$!locations = [],
    Str :$data-module = 'Config::TOML', Hash :$other-config = {},
    Bool :$!trace = False
  ) {

    # When the caller provides a configuration as a base, set that as a
    # starting point and set merge to True
    $!merge = True if $other-config.elems;

    # Import proper routine and select read routine
    self!init-config-type(:$data-module);
    $!config = $other-config;

    # Read and deserialize text from file
    my Str $config-content;

    self!init-config(:$config-name);
  }

  #-----------------------------------------------------------------------------
  # Import module and select proper read routine and extension
  method !init-config-type ( Str :$data-module = 'Config::TOML' ) {

    given $data-module {
      when 'Config::TOML' {
        require ::($data-module) <&from-toml>;
        $!read-from-text = &from-toml;
        $!extension = '.toml';
      }

      when 'JSON::Fast' {
        require ::($data-module) <&from-json>;
        $!read-from-text = &from-json;
        $!extension = '.json';
      }

      default {
        die X::Config::DataLang::Refine.new(
          :message("Module $data-module not supported (yet)")
        );
      }
    }
  }

  #-----------------------------------------------------------------------------
  method !init-config ( Str :$config-name is copy ) {

    my Str $basename = (
      ?$config-name ?? $config-name !! $*PROGRAM.Str
    ).IO.basename;

    # Check if basename is seen before
    if $basename !~~ any(@$!config-names) {

      # Do we have a name
      if ? $config-name {

        # Check if name holds a path, relative or absolute
        if $config-name ~~ m/<[/]>+/ {

          # Separate basename from path and add path to locations
          my Str $p = $config-name.IO.abspath;
          $p ~~ s/ ('/'|\\) $basename $//;
#say "Path: $p";
#say "Base: $basename";
          $!locations.push($p);
          $config-name = $basename;
        }
      }

      # If user didn't define a name, derive it from the program name already
      # set in basename
      else {

        # Remove extension of program, if any, and add config extension
        $config-name = $basename;
        my Str $ext = $basename.IO.extension;
        $config-name ~~ s/\.$ext// if ?$ext;
        $config-name ~= $!extension;
      }

      $!config-names.push: $config-name;

#say "cfgn: $config-name";
      self!read-config($config-name);
    }
  }

  #-----------------------------------------------------------------------------
  method !read-config ( Str $config-name ) {

    note "\nSearch using name $config-name" if $!trace;

    $!config-content = '';

    # Get all locations and push the path when config is found and readable
    my Array $locs = [];
    my Str $cn = $config-name.IO.abspath;
#$cn ~~ s/^ \\ (<[CDE]> ':') /$0/;
#say "cn: $cn, ", $cn.IO ~~ :r;
    $locs.push: $cn if $cn.IO ~~ :r;

    $cn = ".$config-name".IO.abspath;
#$cn ~~ s/^ \\ (<[CDE]> ':') /$0/;
#say "cn: $cn, ", $cn.IO ~~ :r;
    $locs.push: $cn if $cn.IO ~~ :r;

    $cn = ($*HOME.Str ~ '/' ~ $config-name).IO.abspath;
#$cn ~~ s/^ \\ (<[CDE]> ':') /$0/;
#say "cn: $cn, ", $cn.IO ~~ :r;
    $locs.push: $cn if $cn.IO ~~ :r;

    for @$!locations -> $l {
#TODO perl6 bug on windows?, $l must now be mutable!
#$l ~~ s/^ \\ (<[CDE]> ':') /$0/;
#say "L: $l";
      if ? $l and $l.IO.r and $l.IO.d {
        my Str $cn = [~] $l.IO.abspath, '/', $config-name;
#$cn ~~ s/^ \\ (<[CDE]> ':') /$0/;
#say "C: $cn";
        $locs.push: $cn if $cn.IO ~~ :r;
      }
    }

    # merge all content
    if $!merge {

      # Start with the last entry from the locations
      for @$locs.reverse -> $cfg-name {

        if $!trace {
          my $p = $cfg-name;
          $p ~~ s/ $*CWD '/'? //;
          $p ~~ s/ $*HOME '/'? /~\//;
          note "Merge file $p";
        }

        $!config-content = slurp($cfg-name) ~ "\n";

        # Parse config file if exists
        $!config = self.merge-hash(
          $!config,
          $!read-from-text($!config-content)
        );
      }
    }

    # no merge, pick first config we find
    else {

      if ?$locs[0] {
        if $!trace {
          my $p = $locs[0];
          $p ~~ s/ $*CWD '/'? //;
          $p ~~ s/ $*HOME '/'? /~\//;
          note "Use only file $p";
        }

        $!config-content = slurp($locs[0]);
        $!config = $!read-from-text($!config-content);
      }
    }

    unless $!config.elems {
      die X::Config::DataLang::Refine.new(
        :message("Config files derived from $config-name not found or empty in current directory (plain or hidden) or in home directory")
      );
    }
  }

  #-----------------------------------------------------------------------------
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
        $refined-list{$k}:delete
          if $filter and ( $s{$k} ~~ Bool and !$s{$k} or not $s{$k}.defined );
      }
    }

    $refined-list;
  }

  #-----------------------------------------------------------------------------
  method refine-str (
    *@key-list,
    Str :$glue = ',',
    Bool :$filter is copy = False,
    StrMode :$str-mode = C-URI-OPTS-T1
    --> Array
  ) {

    # turn off filter when C-URI-OPTS-T3 is used but filter was turned on
    $filter = False if $str-mode == C-UNIX-OPTS-T3;

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

    elsif $str-mode ~~ any(C-UNIX-OPTS-T1|C-UNIX-OPTS-T2|C-UNIX-OPTS-T3) {

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
                if $str-mode == C-UNIX-OPTS-T1 {
                  $entry = "-$k";
                }

                elsif $str-mode == C-UNIX-OPTS-T2 {
                  $T2-entry ~= "$k";
                }

                elsif $str-mode == C-UNIX-OPTS-T3 {
                  $entry = "-$k";
                }
              }

              else {
                $entry = "--no$k";
                if $str-mode == C-UNIX-OPTS-T3 {
                  $entry = "--/$k";
                }
              }
            }

            else {
              if ?$v {
                $entry = "--$k";
              }

              else {
                $entry = "--no$k";
                if $str-mode == C-UNIX-OPTS-T3 {
                  $entry = "--/$k";
                }
              }
            }
          }

          # Check for backticks(`), in Unix these can hold other commands. The line
          # is checked for an even number of backticks. When there are spaces in
          # the line the user must add the quoting to the line if necessary.
          when m:g/ '`'/ and !((m:g/ '`'/).elems +& 0x01) {
            $entry = ($k.chars == 1 ?? "-$k" !! "--$k=" ) ~ "$v";
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

      $refined-list.push: $T2-entry
        if $str-mode == C-UNIX-OPTS-T2 and $T2-entry.chars > 1;
    }

    $refined-list;
  }

  #-----------------------------------------------------------------------------
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

  #-----------------------------------------------------------------------------
  multi method merge-hash ( Hash:D $h1, Hash:D $h2 --> Hash ) {

    my Hash $h3 = $h1;
    for $h2.kv -> $k, $v {

      if $v ~~ Hash {

        $h3{$k} = self.merge-hash( $h3{$k} // {}, $v);
      }

      else {

        $h3{$k} = $v;
      }
    }

    $h3 // {};
  }

  #-----------------------------------------------------------------------------
  multi method merge-hash ( Hash:D $h2 --> Hash ) {

    my Hash $h3 = $!config;
    for $h2.kv -> $k, $v {

      if $v ~~ Hash {

        $h3{$k} = self.merge-hash( $h3{$k} // {}, $v);
      }

      else {

        $h3{$k} = $v;
      }
    }

    $h3 // {};
  }

  #-----------------------------------------------------------------------------
  method perl ( Hash :$h --> Str ) {

    $!p-out = '';
    $!p-lvl = 0;

    self!dd($h // $!config);
    $!p-out;
  }

  #-----------------------------------------------------------------------------
  method !dd ( Hash $h ) {

    $!p-out ~= "\n";

    for $h.keys.sort -> $k {
      if $h{$k} ~~ Hash {
        $!p-out ~= (' ' x $!p-lvl) ~ "$k => \{";
        $!p-lvl += 2;
        self!dd($h{$k});
        $!p-lvl -= 2;
        $!p-out ~= (' ' x $!p-lvl) ~ "},\n";
      }

      else {
        $!p-out ~= (' ' x $!p-lvl) ~ "$k => $h{$k},\n";
      }
    }
  }
}
