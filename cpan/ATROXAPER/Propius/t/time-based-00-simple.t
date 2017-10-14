#!/usr/bin/env perl6

use v6;
use Test;
use lib 'lib';
use Propius;

plan 23;

{
  my $loader-call;
  my $cache = eviction-based-cache(loader => { $loader-call = True; $:key ** 2 });

  is $cache.get(5), 25, 'base loader';
  ok $loader-call, 'loader called';

  $loader-call = False;
  is $cache.get(5), 25, 'get without load';
  nok $loader-call, 'loader is not called again';

  $cache.put(:key(6), :value(16));
  is $cache.get(6), 16, 'direct simple put';

  $cache.put(:key(7), loader => { $:key ** 3 });
  is $cache.get(7), 343, 'direct loader put';

  is $cache.hash(), %(5, 25, 6, 16, 7, 343), 'get copy of stored values';
}

{
  my ($r-key, $r-value, $r-cause, $removal-call);
  my $cache = eviction-based-cache(
    loader => { $:key ** 2 },
    removal-listener => {
      $removal-call = True;
      is $:key, $r-key, 'removal key is valid';
      is $:value, $r-value, 'removal value is valid';
      is $:cause, $r-cause, 'removal cause is valid';
    });

  ($r-key, $r-value, $r-cause) = 5, 25, Propius::RemoveCause::Replaced;
  is $cache.get($r-key), $r-value, 'initialize removal cache';
  $cache.put(key => $r-key, value => $r-value + 1);
  ok $removal-call, 'removal listener is called';


  ($r-value, $r-cause, $removal-call) = ($r-value + 1, Propius::RemoveCause::Explicit, False);
  $cache.invalidate($r-key);
  ok $removal-call, 'removal listener is called again';
  is $cache.get($r-key), $r-value - 1, 'load after removal';
}

{
  my class Id {
    has Str $.key;
    has Int $.value;
  }

  my $cache = eviction-based-cache(loader => { $:key.key ~ $:key.value ~ $:key.key });

  my Id $obj-key = Id.new: key => 'k', value => 4;
  is $cache.get($obj-key), 'k4k', 'loader by object key';
  is $cache.get(Id.new: key => 'k', value => 4), 'k4k', 'loader by similar object key';
  is $cache.elems, 2, 'keys was similar but not equals';
}

{
  my class Id {
    has Str $.key;
    has Int $.value;

    multi method WHICH() {
      ObjAt.new("Id|key=$.key|value=$.value");
    }
  }

  my $cache = eviction-based-cache(loader => { $:key.key ~ $:key.value ~ $:key.key });

  my Id $obj-key = Id.new: key => 'k', value => 4;
  is $cache.get($obj-key), 'k4k', 'loader by object key with WHICH';
  is $cache.get(Id.new: key => 'k', value => 4), 'k4k', 'loader by similar object key with WHICH';
  is $cache.elems, 1, 'keys was similar and with equal WHICH';
}

done-testing;