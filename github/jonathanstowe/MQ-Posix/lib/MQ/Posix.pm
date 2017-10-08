use v6.c;

=begin pod

=head1 NAME

MQ::Posix - Perl 6 interface for POSIX message queues

=head1 SYNOPSIS

=begin code

use MQ::Posix;

my $queue = MQ::Posix.new(name => 'test-queue', :create, :r );

react {
    whenever $queue.Supply -> $buf {
        say $buf.decode;
    }
    whenever signal(SIGINT) {
        $queue.close;
        $queue.unlink;
        done;
    }
}
=end code

And in some separate process:

=begin code

use MQ::Posix;

my $queue = MQ::Posix.new(name => 'test-queue', :create, :w );

await $queue.send("some test message", priority => 10);

$queue.close;

=end code

=head1 DESCRIPTION

POSIX message queues offer a mechanism for processes to reliably exchange
data in the form of messages

The messages are presented as a priority ordered queue with higher priority
messages being delivered first and messages of equal priority being delivered
in age order.

The mechanism is simple, having no provision for message metadata and so forth
and whilst reliable, unread messages do not persist beyond the lifetime of the
running kernel.

=head1 METHODS

=head2 method new

    method new(Str :$name!, Bool :$r, Bool :$w, Bool :$create, Bool :$exclusive, Int :$max-messages, Int :$message-size, Int :$mode = 0o660)

The constructor of the class, C<$name> is the name of the queue and is required,
there may be different constraints on the name in different implementations but
in both B<Linux> and B<FreeBSD> it must conform to the requirements of a
filename.  On or both of C<r> or C<w> must be provided to indicate whether
the queue should be readable, writable or both.  If C<create> is supplied
the queue will be created if necessary, otherwise if the queue doesn't
exist an exception will be thrown.  If C<exclusive> is supplied along with
C<create> an exception will be thrown if the queue already exists. C<$mode>
will be used as the mode of the queue if the queue is to be created, after
the application of the user file creation mask in effect.

C<$max-messages> and C<$message-size> will be used to set the queues attributes
if it is created if provided, otherwise the system defaults will be used.
The system defaults may differ from system to system. If the user is not
privileged and the values are higher than the configured limits then an
exception may be thrown when the queue is created - how to determine the
limits may differ from system to system, on Linux they can be obtained
and set through a C<sysctl> interface (or via C</proc/sys/fs/mqueue/> )

The queue itself may not be created immediately but rather when it first
needs to be used, so any exception may not be thrown at the time the
constructor is called.

=head2 method attributes

    method attributes(--> MQ::Posix::Attr)

This returns an object describing the queue's attributes, they can't
be changed after the queue is created.  The object has the attributes
C<message-size> which is the allowed maximum size of a message,
C<max-messages> is the maximum number of messages allowed in the queue
simulataneously and C<current-messages> the number of messages in
the queue.

=head2 method send

    multi method send(Str $msg, Int $priority = 0 --> Promise)
    multi method send(Buf $msg, Int $priority = 0 --> Promise)
    multi method send(CArray $msg, Int $length, Int $priority = 0 --> Promise)

If the queue is opened for writing this will send the supplied message
with the specified priority, returning a Promise that will be kept
when the message is placed on the queue (as it may block if there are
C<max-messages> alreadt on the queue.) The Promise will be broken with
an exception if the queue is not opened for writing or if the message is
longer than C<message-size>.

=head2 method receive

    method receive(--> Promise )

This returns a Promise that will be kept with the highest priority
message from the queue as a L<Buf> (you are free to decode or
marshal this as you wish as there is no mechanism to convey the
encoding.)  it will be broken with an exception if the queue wasn't
opened for reading. The message will never exceed C<message-size> bytes.

=head2 method Supply

    method Supply(--> Supply)

This provides a Supply onto which are emitted the messages as a L<Buf>
as they arrive on the queue.  An exception will be thrown if the queue
isn't opened for reading. The first time this is called a new thread
will be started to feed the supply which will run until the queue is
closed.

In places which expect a Supply such as a C<whenever> this need not
be explicitly called and the object can be coerced instead,

=head2 method close

    method close( --> Bool)

This closes the queue handle that will have been opened if the queue
was written to or read, after this has been called an exception
will be thrown if attempting to read or write. If C<Supply> was
called the thread it started will finish.

=head2 method unlink

    method unlink( --> Bool)

This will remove the queue and it will no longer be able to be opened
by another process, any process that currently has it opened will still
be able to use it, and the queue will be removed when the last opener
closes it. An exception will be thrown if the queue was already removed
or if the effective user doesn't have permission.

=end pod

use NativeCall;
use NativeHelpers::Array;

class MQ::Posix {

    my constant __syscall_slong_t  = int64;
    my constant mqd_t              = int32;

    my constant LIB = [ 'rt', v1 ];

    constant ReadOnly   = 0;
    constant WriteOnly  = 1;
    constant ReadWrite  = 2;

    constant Create     = 64;
    constant Exclusive  = 128;

    class X::MQ is Exception {
        has Str $.message;
    }

    class X::MQ::System is X::MQ {
        has Int $.errno is required;

        has Str $!message;

        method message( --> Str) {
            $!message //= self!strerror ~ " ({ $!errno })";
        }

        sub strerror_r(int32, CArray $buf is rw, size_t $buflen --> CArray) is native { * }

        method !strerror(--> Str) {
            my $array = CArray[uint8].new((0) xx 256);
            my $out = strerror_r($!errno, $array, 256);
            my $buff = copy-carray-to-buf($out, 256);
            $buff.decode;

        }
    }

    class X::MQ::Open is X::MQ::System {
    }

    class Attr is repr('CStruct') {
        has __syscall_slong_t           $.flags;
        has __syscall_slong_t           $.max-messages;
        has __syscall_slong_t           $.message-size;
        has __syscall_slong_t           $.current-messages;
        has __syscall_slong_t           $!__pad_1;
        has __syscall_slong_t           $!__pad_2;
        has __syscall_slong_t           $!__pad_3;
        has __syscall_slong_t           $!__pad_4;
    }

    has Str $.name is required;
    has Int  $!open-flags;

    has Int $.max-messages;
    has Int $.message-size;

    has Int $.mode;

    has Attr $.attributes;


    has Int $!queue-descriptor;

    has Promise $!open-promise;

    my $errno := cglobal(Str, 'errno', int32);

    sub mq_open(Str $name, int32 $oflag, int32 $mode, Attr $attr) is native(LIB) returns mqd_t  { * }


    method queue-descriptor(--> mqd_t) {
        my Attr $attr;

        if ( $!open-flags & Create ) && ( $!message-size || $!max-messages ) {
            $attr = Attr.new(message-size => $!message-size || 8192, max-messages => $!max-messages || 10);
        }
        $!queue-descriptor //= do {

            my $fd = mq_open($!name, $!open-flags, $!mode, $attr);
            if $fd < 0 {
                X::MQ::Open.new(:$errno).throw;
            }
            $!open-promise = Promise.new;
            $fd;
        }
    }

    method r(--> Bool) {
        ?($!open-flags +& ( ReadOnly | ReadWrite));
    }

    method w(--> Bool) {
        ?($!open-flags +& ( WriteOnly | ReadWrite));
    }

# == /usr/include/mqueue.h ==

#-From /usr/include/mqueue.h:40
#/* Establish connection between a process and a message queue NAME and
#   return message queue descriptor or (mqd_t) -1 on error.  OFLAG determines
#   the type of access used.  If O_CREAT is on OFLAG, the third argument is
#   taken as a `mode_t', the mode of the created message queue, and the fourth
#   argument is taken as `struct Attr *', pointer to message queue
#   attributes.  If the fourth argument is NULL, default attributes are
#   used.  */
#extern mqd_t mq_open (const char *__name, int __oflag, ...)


    submethod BUILD(Str :$!name!, Bool :$r, Bool :$w, Bool :$create, Bool :$exclusive, Int :$!max-messages, Int :$!message-size, Int :$!mode = 0o660) {
        if !$!name.starts-with('/') {
            $!name = '/' ~ $!name;
        }
        $!open-flags = do if $r && $w {
            ReadWrite;
        }
        elsif $w {
            WriteOnly;
        }
        else {
            ReadOnly;
        }

        if $create {
            $!open-flags +|= Create;
            if $exclusive {
                $!open-flags +|= Exclusive;
            }
        }

    }

#-From /usr/include/mqueue.h:45
#/* Removes the association between message queue descriptor MQDES and its
#   message queue.  */
#extern int mq_close (mqd_t __mqdes) __THROW;

    class X::MQ::Close is X::MQ::System {
    }

    sub mq_close(mqd_t $mqdes ) is native(LIB) returns int32 { * }

    method close( --> Bool) {
        my Bool $rc = True;
        if $!queue-descriptor.defined {
            if mq_close($!queue-descriptor) < 0 {
                X::MQ::Close.new(:$errno).throw;
            }
            $!open-promise.keep: True;
        }
        $rc;
    }

#-From /usr/include/mqueue.h:48
#/* Query status and attributes of message queue MQDES.  */
#extern int mq_getattr (mqd_t __mqdes, struct Attr *__mqstat)

    class X::MQ::Attributes is X::MQ::System {
    }

    sub mq_getattr(mqd_t $mqdes, Attr $mqstat is rw) is native(LIB) returns int32  { * }

    method attributes(--> Attr) {
        $!attributes //= do {
            my $attrs = Attr.new;
            if mq_getattr(self.queue-descriptor, $attrs) < 0 {
                X::MQ::Attributes.new(:$errno).throw;
            }
            $attrs;
        }
    }


#-From /usr/include/mqueue.h:59
#/* Remove message queue named NAME.  */
#extern int mq_unlink (const char *__name) __THROW __nonnull ((1));

    class X::MQ::Unlink is X::MQ::System {
    }

    sub mq_unlink(Str $name ) is native(LIB) returns int32 { * }

    method unlink(--> Bool) {
        if mq_unlink($!name) < 0 {
            X::MQ::Unlink.new(:$errno).throw;
        }
        True;
    }

#`(
#-From /usr/include/mqueue.h:63
#/* Register notification issued upon message arrival to an empty
#   message queue MQDES.  */
#extern int mq_notify (mqd_t __mqdes, const struct sigevent *__notification)
sub mq_notify(mqd_t                         $__mqdes # Typedef<mqd_t>->|int|
             ,sigevent                      $__notification # const sigevent*
              ) is native(LIB) returns int32 is export { * }
)

#-From /usr/include/mqueue.h:68
#/* Receive the oldest from highest priority messages in message queue
#   MQDES.  */
#extern ssize_t mq_receive (mqd_t __mqdes, char *__msg_ptr, size_t __msg_len,

    class X::MQ::Receive is X::MQ::System {
    }

    sub mq_receive(mqd_t $mqdes, CArray[uint8] $msg_ptr is rw, size_t $msg_len, Pointer[uint32] $msg_prio) is native(LIB) returns ssize_t { * }

    method receive(--> Promise ) {
        start {
            my Int $msg-size = $.attributes.message-size;
            my CArray $buf = CArray[uint8].new((8) xx $msg-size);
            my $rc = mq_receive($.queue-descriptor, $buf, $msg-size, Pointer[uint32]);

            if $rc < 0 {
                X::MQ::Receive.new(:$errno).throw;
            }
            else {
                copy-carray-to-buf($buf, $rc);
            }
        }
    }

#-From /usr/include/mqueue.h:72
#/* Add message pointed by MSG_PTR to message queue MQDES.  */
#extern int mq_send (mqd_t __mqdes, const char *__msg_ptr, size_t __msg_len,

    class X::MQ::Send is X::MQ::System {
    }

    sub mq_send(mqd_t $mqdes, CArray[uint8] $msg_ptr, size_t  $msg_len, uint32 $msg_prio ) is native(LIB) returns int32  { * }

    proto method send(|c) { * }

    multi method send(Str $msg, Int $priority = 0 --> Promise) {
        self.send(Buf.new($msg.encode.list), $priority);
    }

    multi method send(Buf $msg, Int $priority = 0 --> Promise) {
        my CArray $carray = copy-buf-to-carray($msg);
        self.send($carray, $msg.elems, $priority);
    }

    multi method send(CArray $msg, Int $length, Int $priority = 0 --> Promise) {
        start {
            if mq_send(self.queue-descriptor, $msg, $length, $priority ) < 0 {
                X::MQ::Send.new(:$errno).throw;
            }
            else {
                True;
            }
        }
    }

    has Supplier $!supplier;
    has Supply   $.Supply;

    has Promise  $!supply-promise;


    method Supply(--> Supply) {
        $!Supply //= do {
            if !$!open-promise.defined {
                sink self.queue-descriptor;
            }
            $!supplier = Supplier.new;
            $!supply-promise = start {
                while $!open-promise.status ~~ Planned {
                    $!supplier.emit: await self.receive;
                }
                $!supplier.done;
            }
            $!supplier.Supply;
        }
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
