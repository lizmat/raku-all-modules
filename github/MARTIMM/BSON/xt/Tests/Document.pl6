#!/usr/bin/env perl6

use v6;
use Bench;


say "\nHash order...";
my Hash $h;
for 'a' ... 'z' -> $c {
  $h{$c} = rand * time;
}

for $h.kv -> $k, $v {
  say "$k => $v";
  last if $k eq 'h';
}



say "\nMap order ...";
my Map $m;
for 'a' ... 'z' -> $c {
  $m{$c} = rand * time;
}

say "\nAs hash ...";
for $m.kv -> $k, $v {
  say "$k => $v";
  last if $k eq 'h';
}

say "\nAs hash ...";
for @$m -> $e {
  say $e.key, ' => ', $e.value;
  last if $e.key eq 'h';
}


#===============================================================================
#
class Document1 does Associative {
  has Array $!keys .= new;
  has Array $!values .= new;

  #-----------------------------------------------------------------------------
  multi method AT-KEY ( Str $key --> Mu ) is rw {

    my $value;
    loop ( my $i = 0; $i < $!keys.elems; $i++ ) {
      if $!keys[$i] ~~ $key {
#say "AT-KEY: modify $key";
        $value := $!values[$i];
        last;
      }
    }

#say "AT-KEY: $i, {$!keys.elems} new key $key";
    if $i == $!keys.elems {
      $!keys[$i] = $key;
      $!values[$i] = '';
      $value := $!values[$i];
    }

#say "V: $value";
    $value;
  }

  #-----------------------------------------------------------------------------
  multi method EXISTS-KEY ( Str $key --> Bool ) {

say "EXISTS-KEY: $key";
    for $!keys -> $k {
      return True if $k ~~ $key;
    }

    return False;
  }

  #-----------------------------------------------------------------------------
  multi method DELETE-KEY ( Str $key --> Bool ) {

say "DELETE-KEY: $key";
    loop ( my $i = 0; $i < $!keys.elems; $i++ ) {
      if $!keys[$i] ~~ $key {
        $!keys.splice( $i, 1);
        $!values.splice( $i, 1);
        last;
      }
    }
  }

  #-----------------------------------------------------------------------------
  multi method kv ( --> List ) {

    ($!keys Z $!values).flat.list;
  }

  #-----------------------------------------------------------------------------
  multi method keys ( --> List ) {

    $!keys.list;
  }

#  multi method ASSIGN-KEY ( $key, $value --> )
}

#===============================================================================
# Solution with @ instead of Array
#
class Document2 does Associative {
  has @!keys;
  has @!values;

  #-----------------------------------------------------------------------------
  multi method AT-KEY ( Str $key --> Mu ) is rw {

    my $value;
    loop ( my $i = 0; $i < @!keys.elems; $i++ ) {
      if @!keys[$i] ~~ $key {
#say "AT-KEY: modify $key";
        $value := @!values[$i];
        last;
      }
    }

#say "AT-KEY: $i, {@!keys.elems} new key $key";
    if $i == @!keys.elems {
      @!keys[$i] = $key;
      @!values[$i] = '';
      $value := @!values[$i];
    }

#say "V: $value";
    $value;
  }

  #-----------------------------------------------------------------------------
  multi method EXISTS-KEY ( Str $key --> Bool ) {

say "EXISTS-KEY: $key";
    for @!keys -> $k {
      return True if $k ~~ $key;
    }

    return False;
  }

  #-----------------------------------------------------------------------------
  multi method DELETE-KEY ( Str $key --> Bool ) {

say "DELETE-KEY: $key";
    loop ( my $i = 0; $i < @!keys.elems; $i++ ) {
      if @!keys[$i] ~~ $key {
        @!keys.splice( $i, 1);
        @!values.splice( $i, 1);
        last;
      }
    }
  }

  #-----------------------------------------------------------------------------
  multi method kv ( --> List ) {

    (@!keys Z @!values).flat.list;
  }

  #-----------------------------------------------------------------------------
  multi method keys ( --> List ) {

    @!keys.list;
  }

#  multi method ASSIGN-KEY ( $key, $value --> )
}

#===============================================================================
# Solution with @ instead of Array
#
class Document3 does Associative {
  has @!keys;
  has Hash $!data;

  #-----------------------------------------------------------------------------
  multi method AT-KEY ( Str $key --> Mu ) is rw {

    my $value;
    if ! ($!data{$key}:exists) {
      $!data{$key} = '';
      @!keys.push($key);
    }

    $value := $!data{$key};
  }

  #-----------------------------------------------------------------------------
  multi method EXISTS-KEY ( Str $key --> Bool ) {

#say "EXISTS-KEY: $key";
    return $!data{$key}:exists;
  }

  #-----------------------------------------------------------------------------
  multi method ASSIGN-KEY (::?CLASS:D: $key, $new) {

#say "ASSIGN-KEY: $key => $new";
    @!keys.push($key) unless $!data{$key}:exists;
    $!data{$key} = $new;
  }

  #-----------------------------------------------------------------------------
  multi method DELETE-KEY ( Str $key --> Bool ) {

say "DELETE-KEY: $key";
    my $value;
    if $!data{$key}:exists {
      loop ( my $i = 0; $i < @!keys.elems; $i++ ) {
        if @!keys[$i] ~~ $key {
          @!keys.splice( $i, 1);
          $value = $!data{$key}:delete;
          last;
        }
      }
    }

    $value;
  }

  #-----------------------------------------------------------------------------
  multi method kv ( --> List ) {

    my @l;
    for @!keys -> $k {
      @l.push( $k, $!data{$k});
    }

    @l;
  }

  #-----------------------------------------------------------------------------
  multi method keys ( --> List ) {

    @!keys.list;
  }

#  multi method ASSIGN-KEY ( $key, $value --> )
}

#===============================================================================

say "\nDocument1 order...";
my Document1 $d1 .= new;
for 'a' ... 'z' -> $c {
  $d1{$c} = rand * time;
}

for $d1.kv -> $k, $v {
  say "$k => $v";
  last if $k eq 'h';
}


say "\nDocument2 order...";
my Document2 $d2 .= new;
for 'a' ... 'z' -> $c {
  $d2{$c} = rand * time;
}

for $d2.kv -> $k, $v {
  say "$k => $v";
  last if $k eq 'h';
}


say "\nDocument3 order...";
my Document3 $d3 .= new;
for 'a' ... 'z' -> $c {
  $d3{$c} = rand * time;
}

for $d3.kv -> $k, $v {
  say "$k => $v";
  last if $k eq 'h';
}



#===============================================================================
# Bench marking
#
my $b = Bench.new;
$b.timethese(
  200, {
    document1_200x2x26 => sub {
      my Document1 $d .= new;
      for 'aa' ... 'bz' -> $c {
        $d{$c} = 1;
      }
    },

    document2_200x2x26 => sub {
      my Document2 $d .= new;
      for 'aa' ... 'bz' -> $c {
        $d{$c} = 1;
      }
    },

    document3_200x2x26 => sub {
      my Document3 $d .= new;
      for 'aa' ... 'bz' -> $c {
        $d{$c} = 1;
      }
    },

    hash_200x2x26 => sub {
      my Hash $d .= new;
      for 'aa' ... 'bz' -> $c {
        $d{$c} = 1;
      }
    },
  }
);
















=finish

multi method postcircumfix:<{ }>(
  Document $container: **@keys,
  :$k, :$v, :$kv, :$p, :$exists, :$delete
) {

  say "pci: $container, **@keys, $k, $v";

#  @!p.push: $k => $v;
}



  has Int $idx = 0;
  method pull-one ( --> Mu ) {
    $idx < @!p.elems ?? @!p[$idx++] !! IterationEnd;
  }

  method push-exactly ( Document:D $target, Int $count --> Mu ) {
    if @!p.elems - $idx > $count {
      for ^$count {
        if $idx < @!p.elems {
          $target.push: @!p[$idx++];
        }
      }

      $count;
    }

    else {
      IterationEnd;
    }
  }

  method push-at-least ( Document:D $target, Int $count --> Mu ) {
    if @!p.elems - $idx > $count {
      for ^$count {
        if $idx < @!p.elems {
          $target.push: @!p[$idx++];
        }
      }

      $count;
    }

    else {
      IterationEnd;
    }
  }

  method iterator ( ) {

  }
