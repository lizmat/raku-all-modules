#!/usr/bin/env perl6

unit module Propius;

use OO::Monitors;
use TimeUnit;
use Propius::Linked;

#|[Role of time provider.
#
#That provider will use to retrieve current time in seconds.
#You can use custom implementation for testing of time-based
#caches for example.]
role Ticker {
  #|Getter of current time in seconds.
  method now( --> Int:D) { ... };
}

#|[Default implementation of Ticker.
#
#Uses current system time.]
my class DateTimeTicker does Ticker {
  #|Getter of current time as system time in seconds.
  method now() {
    return DateTime.now.posix;
  }
}

#|[Exception witch will be thrown in case provider loader
#return not defined value.]
class X::Propius::LoadingFail {
  has $.key;
  method message() {
    "Specified loader return type object instead of object for key $!key";
  }
}

#|Amount of reads we can do without cleanup.
my constant READS_MAX = 20;

#|[Reason of removing some element from a cache.
#
#Expired - in case a value expired;
#Explicit - in case user removed value himself;
#Replaced - in case user overwrite value himself;
#Size - in case when max capacity is reached.]
enum RemoveCause <Expired Explicit Replaced Size>;

#|Name of user action with data in a cache.
my enum ActionType <Access Write>;

#|[Internal representation of value in cache.
#
#Contains key-value pair, times of last actions and links
#to linked chain for each actions type.]
my class ValueStore {
  has $.key;
  has $.value is rw;
  has Propius::Linked::Node %.nodes{ActionType};
  has Int %.last-action-at{ActionType};

  #|[Constructor.
  #
  #:$key! - key of stored value;
  #:$value! - stored value;
  #:@types! - list of ActionType. Times of last actions and linked chains
  #will be computed only for that actions.]
  multi method new(:$key!, :$value!, :@types!) {
    my $blessed = self.new(:$key, :$value);
    for @types -> $type {
      $blessed.nodes{$type} = Propius::Linked::Node.new: value => $blessed;
    }
    $blessed;
  }

  #|[Move chain link to its head.
  #
  #@types - list of ActionType for witch have to move;
  #%chains - Hash of ActionType -> Linked::Chain - chains for each ActionType;
  #$now - current time in seconds to save.]
  method move-to-head-for(@types, Propius::Linked::Chain %chains, Int $now) {
    for %!nodes.keys.grep: * ~~ any(@types) {
      %chains{$_}.move-to-head(%!nodes{$_});
      %!last-action-at{$_} = $now;
    }
  }

  #|Remove that value from all chains.
  method remove-nodes() {
    .remove() for %!nodes.values;
  }

  #|[Return time of last action with the value.
  #
  #$type - ActionType for retrieving time.]
  method last-at(ActionType $type) {
    %!last-action-at{$type};
  }
}

#|[Cache with loader and eviction by time.
#
#The cache can use object keys. If you want that you have to
#control .WITCH method if keys.]
my monitor EvictionBasedCache {
  has &!loader;
  has &!removal-listener;
  has Any %!expire-after-sec{ActionType};
  has Ticker $ticker;
  has $!size;

  has ValueStore %!store{Any};
  has Propius::Linked::Chain %!chains{ActionType};

  has $!reads-wo-clean;

  submethod BUILD(
      :&!loader! where .signature ~~ :(:$key),
      :&!removal-listener where .signature ~~ :(:$key, :$value, :$cause) = {},
      :%!expire-after-sec = :{(Access) => Inf, (Write)  => Inf},
      Ticker :$!ticker = DateTimeTicker.new,
      :$!size = Inf) {
    %!chains{Access} = Propius::Linked::Chain.new;
    if %!expire-after-sec{Write} !=== Inf {
      %!chains{Write} = Propius::Linked::Chain.new;
    }
    $!reads-wo-clean = 0;
  }

  #|[Retrieve value by key.
  #
  #If there is no value for specified key then loader with be
  #used to produce the new value]
  method get(Any:D $key) {
    my $value = self!retrieve($key);
    with $value {
      return $value.value;
    } else {
      self.put(:$key, :&!loader);
      return %!store{$key}.value;
    }
  }

  #|[Retrieve value by key only if it exists.
  #
  #If there is no value for specified key then Any will be returned.]
  method get-if-exists(Any:D $key) {
    with self!retrieve($key) { .value }
    else { Any }
  }

  #|[Store a value in cache.
  #
  #It will rewrite any cached value for specified key. In that case
  #removal-listener will be called with old value cause Replaced.
  #
  #In case of cache already reached max capacity value which has not
  #been used for a longest time will be removed. In that case
  #removal-listener will be called with old value cause Size.]
  multi method put(Any:D :$key, Any:D :$value) {
    $.clean-up();
    my $previous = %!store{$key};
    my $move;
    with $previous {
      self!publish($key, $previous.value, Replaced);
      $previous.value = $value;
      $move = $previous;
    } else {
      my $wrap = self!wrap-value($key, $value);
      %!store{$key} = $wrap;
      $move = $wrap;
    }
    $move.move-to-head-for(ActionType::.values, %!chains, $!ticker.now);
  }

  #|[Store a value in cache with specified loader.
  #
  #It will rewrite any cached value for specified key. In that case
  #removal-listener will be called with old value cause Replaced.
  #
  #In case of cache already reached max capacity value which has not
  #been used for a longest time will be removed. In that case
  #removal-listener will be called with old value cause Size.]
  multi method put(Any:D :$key, :&loader! where .signature ~~ :(:$key)) {
    self.put(:$key, value => self!load($key, &loader))
  }

  #|[Mark value for specified key as invalidate.
  #
  #The value will be removed and removal-listener will be called with
  #old value cause Explicit.]
  method invalidate(Any:D $key) {
    self!remove($key, Explicit);
  }

  #|[Mark values for specified keys as invalidate.
  #
  #The values will be removed and removal-listener will be called for
  #each with old values cause Explicit.]
  multi method invalidateAll(List:D @keys) {
    self.invalidate($_) for @keys;
  }

  #|[Mark all values in cache as invalidate.
  #
  #The values will be removed and removal-listener will be called for
  #each with old values cause Explicit.]
  multi method invalidateAll() {
    self.invalidateAll(%!store.keys);
  }

  #|Return amount of values already stored in the cache.
  method elems() {
    %!store.elems;
  }

  #|[Return keys and values stored in cache as Hash.
  #
  #This is a copy of values. Any modification of returned cache
  #will no have an effect on values in the store.]
  method hash() {
    my %copy{Any};
    for %!store.kv -> $key, $value {
      %copy{$key} = $value.value;
    }
    return %copy;
  }

  #|[Clean evicted values from cache.
  #
  #This method may be invoked directly by user.
  #The method invoked on each write operation and ones for several read operation
  #if there was no write operation recently.
  #
  #It means that evicted values will be removed on just in time of its eviction.
  #This is done for the purpose of optimisation - is it not requires special thread
  #for checking an eviction. If it is issue for you then you can call it method yourself
  #by some scheduled Promise for example.]
  method clean-up() {
    $!reads-wo-clean = 0;
    while $.elems >= $!size {
      self!remove(%!chains{Access}.last().value.key, Size);
    }
    my $now = $!ticker.now;
    for %!chains.kv -> $type, $chain {
      my $life-time = %!expire-after-sec{$type};
      next if $life-time === Inf;

      my $wrap = $chain.last.value;
      while $wrap.DEFINITE && $wrap.last-at($type) + $life-time <= $now {
        self!remove($wrap.key, Expired);
        $wrap = $chain.last.value;
      }
    }
  }

  #|Retrieve value from cache if it exists.
  method !retrieve($key) {
    my $value = %!store{$key};
    with $value {
      ++$!reads-wo-clean;
      $.clean-up if $!reads-wo-clean >= READS_MAX;

      $value.move-to-head-for((Access,), %!chains, $!ticker.now);
      return $value;
    } else {
      return Any;
    }
  }

  #|Wrap key and value into internal representation of value (ValueStore).
  method !wrap-value($key, $value) {
    ValueStore.new: :$key, :$value, types => %!chains.keys;
  }

  #|Compute the new value by specified loader.
  method !load($key, &loader) {
    my $value = self!invoke-with-args((:$key), &loader);
    fail X::Propius::LoadingFail.new(:$key) without $value;
    $value;
  }

  #|Call removal-listener about removed value.
  method !publish($key, $value, RemoveCause $cause) {
    self!invoke-with-args(%(:$key, :$value, :$cause), &!removal-listener)
  }

  #|Invoke specified sub with specified named arguments.
  method !invoke-with-args(%args, &sub) {
    my $wanted = &sub.signature.params.map( *.name.substr(1) ).Set;
    my %actual = %args.grep( {$wanted{$_.key}} ).hash;
    &sub(|%actual);
  }

  #|Completely remove value from cache and publish an event.
  method !remove($key, $cause) {
    my $previous = %!store{$key};
    with $previous {
      %!store{$key}:delete;
      $previous.remove-nodes();
      self!publish($key, $previous.value, $cause);
    }
  }
}

#|[Create eviction based cache.
#
#:&loader! - sub with signature like (:$key).
#   The sub will be used for producing the new values.
#:&removal-listener - sub with signature like (:$key, :$value, :$cause)
#   The sub will be called in case when value removed from the cache.
#   $cause is element of enum RemoveCause.
#:$expire-after-write - how long the cache have to store value after its last re/write
#:$expire-after-access - how long the cache have to store value after its last access (read or write)
#:$time-unit - object of TimeUnit, indicate time unit of expire-after-write/access value.
#   seconds by default.
#:$ticker - object of Ticker, witch is used for retrieve 'current' time.
#   Can be specified for overriding standard behaviour (current system time), for example for testing.
#:$size - max capacity of the cache.]
sub eviction-based-cache (
    :&loader! where .signature ~~ :(:$key),
    :&removal-listener where .signature ~~ :(:$key, :$value, :$cause) = sub {},
    :$expire-after-write = Inf,
    :$expire-after-access = Inf,
    :$time-unit = seconds,
    Ticker :$ticker = DateTimeTicker.new,
    :$size = Inf
) is export {
  EvictionBasedCache.new: :&loader, :&removal-listener, :$ticker, :$size,
    expire-after-sec => :{
      (Access) => seconds.from($expire-after-access, $time-unit),
      (Write)  => seconds.from($expire-after-write, $time-unit)};
}