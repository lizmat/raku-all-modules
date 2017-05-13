#!/usr/bin/env perl6

use v6;
use Concurrent::BoundedChannel;
use Test;

class X::TestException is Exception
{
  method message
  {
    "This is a test exception.";
  }
}

plan 39;

my $bc=BoundedChannel.new(limit=>5);
$bc.send(1);
is($bc.receive,1);

my $p=start {$bc.receive};
$bc.send(2);
is($p.result,2);

$bc.offer(3);
is($bc.receive,3);

$bc.offer(4);
is($bc.poll,4);

is($bc.poll,Nil);

$p=start {$bc.receive};
await Promise.in(1);
is($p.status,Planned);
is($bc.offer(5),5);
is($p.result,5);

#tests with full channel
for ^5 {$bc.send($_)};

is($bc.offer(6),Nil);

$p=start {$bc.send(6)};
await Promise.in(1);
is($p.status,Planned);

is($bc.poll,0);

await $p;
is($p.status,Kept);

{
  my @z;
  for ^5 {@z.append($bc.receive)};
  is(@z,(1,2,3,4,6));
}

#zero length channel tests
$bc=BoundedChannel.new(limit=>0);

is($bc.poll,Nil);

is($bc.offer(5),Nil);

$p=start {$bc.send(0)};
await Promise.in(1);
is($p.status,Planned);
is($bc.receive,0);
await $p;
is($p.status,Kept);

$p=start {$bc.receive};
await Promise.in(1);
is($p.status,Planned);
$bc.send(1);
await $p;
is($p.result,1);

$p=start {$bc.send(0)};
await Promise.in(1);
is($p.status,Planned);
is($bc.poll,0);
is($bc.poll,Nil);
await $p;
is($p.status,Kept);

$p=start {$bc.receive};
await Promise.in(1);
is($p.status,Planned);
is($bc.offer(2),2);
is($bc.offer(3),Nil);
await $p;
is($p.result,2);

$p=start {my @z; for ^10 {@z.append($bc.receive)}; @z};
for ^10 {$bc.send($_)};
is($p.result,(0,1,2,3,4,5,6,7,8,9));

$p=start {for ^10 {$bc.send($_)}};
{
  my @z;
  for ^10 {@z.append($bc.receive)};
  is(@z,(0,1,2,3,4,5,6,7,8,9));
}

my @pp=start {$bc.receive} xx 10;
for ^10 {$bc.send($_)};
await @pp;
is(@pp.map({$_.result}).sort,(0,1,2,3,4,5,6,7,8,9));

@pp.splice(0);
{
  my $c=Channel.new;
  for ^10 {$c.send($_)};
  @pp=start {for ^10 {$bc.send($c.receive)}} xx 10;
  my @z;
  for ^10 {@z.append($bc.receive)};
  is(@z.sort,(0,1,2,3,4,5,6,7,8,9));
}

$bc=BoundedChannel.new(limit=>5);
$bc.send(1);
$bc.send(2);
$bc.send(3);
$bc.close;
throws-like({$bc.send(4)},X::Channel::SendOnClosed);
$bc.receive;
$bc.receive;
$bc.receive;
throws-like({$bc.receive},X::Channel::ReceiveOnClosed);

$bc=BoundedChannel.new(limit=>5);
for ^5 {$bc.send($_)};
$p = start {$bc.send(6)};
await Promise.in(1);
$bc.close;
throws-like({$bc.send(5)},X::Channel::SendOnClosed);
throws-like({$p.result},X::Channel::SendOnClosed);

$bc=BoundedChannel.new(limit=>5);
for ^5 {$bc.send($_)};
$bc.fail(X::TestException.new);
for ^5 {$bc.receive};
throws-like({$bc.receive},X::TestException);

$bc=BoundedChannel.new(limit=>5);
$bc.send(1);
$bc.send(2);
$bc.send(3);
$bc.fail(X::TestException.new);
throws-like({$bc.send(4)},X::Channel::SendOnClosed);
for ^3 {$bc.receive};
throws-like({$bc.receive},X::TestException);
