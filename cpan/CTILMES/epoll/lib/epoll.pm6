use NativeCall;

enum (
    EPOLL_CTL_ADD => 1,
    EPOLL_CTL_DEL => 2,
    EPOLL_CTL_MOD => 3
);

enum EPOLL_EVENTS (
    EPOLLIN      => 0x001,
    EPOLLPRI     => 0x002,
    EPOLLOUT     => 0x004,
    EPOLLRDNORM  => 0x040,
    EPOLLRDBAND  => 0x080,
    EPOLLWRNORM  => 0x100,
    EPOLLWRBAND  => 0x200,
    EPOLLMSG     => 0x400,
    EPOLLERR     => 0x008,
    EPOLLHUP     => 0x010,
    EPOLLRDHUP   => 0x2000,
    EPOLLWAKEUP  => 0x20000000,
    EPOLLONESHOT => 0x40000000,
    EPOLLET      => 0x80000000
);

class epoll-event is repr('CStruct')
{
    has uint32 $.events;
    has int32  $.fd;
    has int32  $!pad;

    method in  { so $!events +& EPOLLIN }
    method out { so $!events +& EPOLLOUT }
}

sub sys_close(int32 --> int32) is native is symbol('close') {}

sub calloc(size_t, size_t --> Pointer) is native {}

sub free(Pointer) is native {}

sub epoll_create1(int32 --> int32) is native {}

sub epoll_ctl(int32, int32, int32, epoll-event --> int32) is native {}

sub epoll_wait(int32, Pointer, int32, int32 --> int32) is native {}

class epoll
{
    has $.maxevents = 1;
    has $!epfd;
    has Pointer $!events;

    submethod TWEAK
    {
        $!epfd = epoll_create1(0);
        die "Failure creating epoll" if $!epfd == -1;
        $!events = calloc($!maxevents, nativesizeof(epoll-event));
        die "Out of memory" unless $!events;
    }

    submethod DESTROY
    {
        sys_close($!epfd) if $!epfd >= 0;
        $!epfd = -1;
        free($_) with $!events;
        $!events = Pointer;
    }

    method add(int32 $fd, Bool :$in = False,
                          Bool :$out = False,
                          Bool :$priority = False,
                          Bool :$edge-triggered = False,
                          Bool :$one-shot = False,
                          Bool :$mod = False)
    {
        my int32 $events = EPOLLIN      * $in
                        +| EPOLLPRI     * $priority
                        +| EPOLLOUT     * $out
                        +| EPOLLET      * $edge-triggered
                        +| EPOLLONESHOT * $one-shot;

        my $event = epoll-event.new(:$events, :$fd);

        if epoll_ctl($!epfd, ($mod ?? EPOLL_CTL_MOD !! EPOLL_CTL_ADD),
                     $fd, $event) == -1
        {
            die 'Failed epoll_ctl()';
        }

        self
    }

    method remove(int32 $fd)
    {
        if epoll_ctl($!epfd, EPOLL_CTL_DEL, $fd, epoll-event) == -1
        {
            die 'Failed in epoll_ctl()';
        }
    }

    method wait(int32 :$timeout = -1)
    {
        my $count = epoll_wait($!epfd, $!events, $!maxevents, $timeout);

        die 'Failed in epoll_wait()' if $count < 0;

        do for ^$count -> $i
        {
            nativecast(epoll-event,
                       Pointer.new(+$!events + $i*nativesizeof(epoll-event)))
        }
    }
}

=begin pod

=head1 NAME

epoll - I/O event notification facility

=head1 SYNOPSIS

  use epoll;

  my $epoll = epoll.new(maxevents => 1); # 1 is default

  $epoll.add($file-descriptor, :in, :out, :priority, :edge-triggered);

  # timeout in milliseconds, default -1 = block forever
  for $epoll.wait(:2000timeout)
  {
      say "{.fd} is ready for reading" if .in;
      say "{.fd} is ready for writing" if .out;
  }

  # Or use chained calls:

  for epoll.new.add(0, :in).wait
  {
      say "ready to read on {.fd}" if .in;
  }

=head1 DESCRIPTION

Simple low level interface around the Linux C<epoll(7)> I/O event
notification facility.  It can monitor multiple file descriptors to
see if I/O is possible on any of them.  Mainly useful for interfacing
with other NativeCall modules, since Perl itself has a rich I/O
system.  If you really want to use this with Perl C<IO::Handle>s, you
can use C<native-descriptor()> to get a suitable descriptor.

=head2 class B<epoll>

=item method B<new>(:$maxevents = 1)

Create a new epoll object.  Maxevents is the maximum number of events
that can be returned from a single call to wait.

=item method B<add>(int32 $file-descriptor, ...event flags...)

    Flags:

=table
      :in             | EPOLLIN       | ready for read
      :out            | EPOLLOUT      | ready for write
      :priority       | EPOLLPRI      | urgent data available for read
      :edge-triggered | EPOLLET       | Edge Triggered
      :one-shot       | EPOLLONESHOT  | Disables after 1 event
      :mod            | EPOLL_CTL_MOD | Modify an existing file descriptor

:mod is equivalent to EPOLL_CTL_MOD to change the events for a file
descriptor already added.  It will also re-enable a file descriptor
disabled by :one-shot mode.

For convenience, always returns the object itself, so you can chain
calls.

=item method B<remove>(int32 $file-descriptor)

Remove a file descriptor previously added.

=item method B<wait>(int32 :$timeout = -1)

Wait for 1 or more events to occur on the add()ed file descriptors.
You can specify an optional timeout in milliseconds.

Returns a List of up up to $maxevents B<epoll-event>s.

=head2 class B<epoll-event>

=item method int32 B<fd>()

The file descriptor for the event.

=item method uint32 B<events>()

A bitmask of the events that occurred.  You can check them like this:

if $event.events +& EPOLLIN {...}

or use the much easier:

=item method Bool B<in>()

Ready to read

=item method Bool B<out>()

Ready to write

=head2 EXCEPTIONS

Throws Ad-hoc exceptions for any errors.

(Should save errno, and make real Exceptions -- patches welcome!)

=head2 NOTE

epoll is a Linux specific mechanism, and is typically not available on
other architectures.

=head1 LICENSE

Copyright © 2017 United States Government as represented by the
Administrator of the National Aeronautics and Space Administration.
No copyright is claimed in the United States under Title 17,
U.S.Code. All Other Rights Reserved.

=end pod
