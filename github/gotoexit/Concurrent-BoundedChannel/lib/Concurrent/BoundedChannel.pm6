unit module Concurrent::BoundedChannel;

class X::Concurrent::BoundedChannel::LimitOutOfBounds is Exception
{
  has $!limit;

  submethod BUILD(Int :$limit is required)
  {
    $!limit=$limit;
  }

  method message
  {
    "Got limit $!limit, but limit can't be negative.";
  }
}

class BoundedChannel is Channel is export
{
  has $!limit;
  has $!bclock;
  has $!sendwait;
  has $!sendwaiters;
  has $!receivewait;
  has $!receivewaiters;
  has $!count;
  has $!closed;

  submethod BUILD (Int :$limit is required)
  {
    die X::Concurrent::BoundedChannel::LimitOutOfBounds.new(limit=>$limit) if $limit < 0;
    $!limit=$limit;
    $!bclock=Lock.new;
    $!sendwait=$!bclock.condition;
    $!sendwaiters=0;
    $!receivewait=$!bclock.condition;
    $!receivewaiters=0;
    $!count=0;
    $!closed=False;
  }

  method send(Channel:D: \item)
  {
    my $z;
    my $p;
    $!bclock.lock;

    while $!count >= $!limit && ! $!closed
    {
      last if $!limit==0 && $!receivewaiters>0;
      $!sendwaiters++;
      $!sendwait.wait;
      $!sendwaiters--;
    }

    $!receivewait.signal;

    $!count++;
    try
    {
      $z:=callsame;
      CATCH
      {
        $!bclock.unlock;
        .throw;
      }
    }
    $!bclock.unlock;
    return $z;
  }

  method offer(Channel:D: \item)
  {
    $!bclock.lock;
    if ( $!count >= $!limit && $!limit != 0 ) || ( $!limit==0 && $!receivewaiters==0 )
    {
      $!bclock.unlock;
      return Nil;
    }

    $!receivewait.signal;

    self.Channel::send(item);
    $!count++;
    $!bclock.unlock;
    return item;
  }

  method receive(Channel:D:)
  {
    my $x;
    $!bclock.lock;

    $!sendwait.signal;

    while $!count == 0 && ! $!closed
    {
      $!receivewaiters++;
      $!receivewait.wait;
      $!receivewaiters--;
    }
    try
    {
      $x:=callsame;
      CATCH
      {
        $!bclock.unlock;
        .throw;
      }
    }
    $!count--;
    $!bclock.unlock;
    return $x;
  }

  method poll(Channel:D:)
  {
    my $x;
    $!bclock.lock;
    $!sendwait.signal;
    if $!limit==0 && $!sendwaiters>0
    {
      $!receivewaiters++;
      $!receivewait.wait;
      $!receivewaiters--;
    }
    try
    {
      $x:=callsame;
      CATCH
      {
        $!bclock.unlock;
        .throw;
      }
    }
    $!count-- with $x;


    $!bclock.unlock;
    return $x;
  }

  method close(Channel:D:)
  {
    $!bclock.lock;
    $!closed=True;
    $!receivewait.signal_all;
    $!sendwait.signal_all;
    my $x:=callsame;
    $!bclock.unlock;
    return $x;
  }

  method fail(Channel:D: $error)
  {
    $!bclock.lock;
    $!closed=True;
    $!receivewait.signal_all;
    $!sendwait.signal_all;
    my $x:=callsame;
    $!bclock.unlock;
    return $x;
  }
}
