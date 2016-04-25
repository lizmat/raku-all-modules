use v6.c;

=begin pod

=head1 NAME

Audio::PortMIDI - Perl6 MIDI access using the portmidi library

=head1 SYNOPSIS

=begin code

use Audio::PortMIDI;

my $pm = Audio::PortMIDI.new;

my $dev = $pm.default-output-device;

say $dev;


my $stream = $pm.open-output($dev, 32);

# Play 1/8th note middle C
my $note-on = Audio::PortMIDI::Event.new(event-type => NoteOn, channel => 1, data-one => 60, data-two => 127, timestamp => 0);
my $note-off = Audio::PortMIDI::Event.new(event-type => NoteOff, channel => 1, data-one => 60, data-two => 127, timestamp => 0);

$stream.write($note-on);
sleep .25;
$stream.write($note-off);

$stream.close;

$pm.terminate;

=end code

See also the examples directory in the distributtion for more complete examples.

=head1 DESCRIPTION

This allows you to get MIDI data into or out of your Perl 6 programs. It
provides the minimum abstraction to construct and unpack MIDI messages
and send and receive them via some interface available on your system,
be that ALSA on Linux, CoreMidi on Mac OS/X or whatever it is that
Windows uses.  Depending on the way that the portmidi library is built
there may be other interfaces available.

The MIDI specification itself doesn't particularly provide for the 
arrangement of the events themselves in time and this is assumed to
be the responsibility of the calling application.  

You almost certainly will want to familiarise yourself to some extent
with the L<MIDI protocol|http://www.midi.org> and especially the types
of messages that are sent as the interface of PortMIDI and hence this
module is fairly "close to the wire".

One thing that should be noted is that currently this uses the 
default time source provided by the PortMIDI library, which you can
access in your own programs, if synchronization to an alternative 
clock is required the native subroutines would support it, just not
available through the public interface at this time.

=head1 METHODS

The majority of the methods will throw an exception C<X::PortMIDI>
if a problem is encountered with the underlying library call.

=head2 method new

    method new() returns Audio::PortMIDI

This is the constructor of the class, it will call C<initialize> and
start the default time source.

=head2 method initialize

    method initialize()

This initializes the portmidi library and should be called before using
any of the other methods, however it is called by the constructor so in
practice it should not be necessary in most programs.

=head2 method terminate

    method terminate()

This allows the portmidi libray to free up any resources it may have
allocated and close any connections, this may not be necessary in
short running programs but it is good practice to do it anyway ( I
have noticed no ill-effects on Linux but your system may differ.)

=head2 method count-devices

    method count-devices() returns Int

This returns the number of MIDI devices available on your system. The
devices are numbered 0 .. count-devices - 1.  Typically each physical
(or virtual device) will be counted as two devices if it provides both
input and output and may provide a different number of input and output
devices. If there is some problem enumerating the devices then an
exception will be thrown.

=head2 method device-info

    method device-info(Int $device-id) returns DeviceInfo

This returns a L<Audio::PortMIDI::DeviceInfo|#Audio::PortMIDI::DeviceInfo> 
object describing the device specified as the integer device ID, which
should be between 0 and count-devices - 1.  If the number is out of range
or there is some other problem getting the device information an exception
will be thrown.

=head2 method devices

    method devices()

This returns the list of all the devices on the system as 
L<Audio::PortMIDI::DeviceInfo|#Audio::PortMIDI::DeviceInfo> objects. which is
really just a shortcut combining the above two methods.  If there is a problem
getting the list then an exception will be thrown.

=head2 method default-input-device

    method default-input-device() returns DeviceInfo

This returns L<Audio::PortMIDI::DeviceInfo|#Audio::PortMIDI::DeviceInfo>
representing the default device that can be used for input on your system
(if one is configured,) it may be be more or less useful depending on
the configuration of your MIDI system, for instance on Linux with ALSA
a default "MIDI Thru" device will always be created irrespective of the
presence of any other MIDI devices and this will usually be returned as
the default (for both input and output.)

=head2 method default-output-device

    method default-outpur-device() returns DeviceInfo

This returns L<Audio::PortMIDI::DeviceInfo|#Audio::PortMIDI::DeviceInfo>
representing the default device that can be used for output on your system
(if one is configured,) it may be be more or less useful depending on
the configuration of your MIDI system, for instance on Linux with ALSA
a default "MIDI Thru" device will always be created irrespective of the
presence of any other MIDI devices and this will usually be returned as
the default (for both input and output.)


=head2 method open-input

    multi method open-input(DeviceInfo:D $dev, Int $buffer-size) returns Stream {
    multi method open-input(Int $device-id, Int $buffer-size) returns Stream {

This opens the specified device (which can
be provided as either an integer device ID or a
L<Audio::PortMIDI::DeviceInfo|#Audio::PortMIDI::DeviceInfo> object,)
for input returning a L<Audio::PortMIDI::Stream|#Audio::PortMIDI::Stream>
object.  If the device is not available for input then an exception will
be thrown.

The buffer size argument indicates the number of messages that should be
buffered and should be tailored to suit your application, if the number
of messages received without a read exceeds the size of the buffer then
an exception may be thrown at the time of the next read, so you may want
a higher value if you are expecting a high number of messages between
each opportunity to read, this may of course slightly increase overall
application latency.  If you have a large number of messages (clocks,
control changes, and so forth) that you are not interested in then you
may set a filter on the Stream to reduce the number that are buffered
for your application.

=head2 method open-output

    multi method open-output(DeviceInfo:D $dev, Int $buffer-size, Int $latency = 0 ) returns Stream {
    multi method open-output(Int $device-id, Int $buffer-size, Int $latency = 0) returns Stream {

This opens the specified device (which can
be provided as either an integer device ID or a
L<Audio::PortMIDI::DeviceInfo|#Audio::PortMIDI::DeviceInfo> object,) for
output returning a L<Audio::PortMIDI::Stream|#Audio::PortMIDI::Stream>
object.  If the device is not available for output then an exception
will be thrown.

The buffer size argument is the maximum number of messages that can be
buffered before being sent out by the device, If you exceed the buffer
size then an exception will be thrown at the next attempt to write to the
device, however the rate for a standard MIDI (serial) device is just a
little less than a thousand messages a second so unless you are sending
many notes at once with high frequency then you are unlikely to need a
very large buffer.

The latency argument is a delay in milliseconds that is applied to
determine when the output of the message will actually occur.  If it
is set to 0 (the default,) then the timestamp on a message is basically
ignored and the message is sent immediately, if it is greater than 0 then
the message will be delayed until the timestamp on the message + latency
is equal to the application time reference.  The portmidi time reference
can be obtained from the L<Audio::PortMIDI::Time|#Audio::PortMIDI::Time>
class method C<time> and the timestamps should be constructed with
reference to that value if this feature is to be used.

=head1 Audio::PortMIDI::DeviceInfo

This class represents a device that is returned by C<device-info> and can be opened for input
or output.

=head2 device-id

This is the integer device id of the device that may be passed to
C<open-input> or C<open-output>

=head2 name

This is the name of the device, it may be duplicated if the physical
device provides both input and output.

=head2 interface

This is the name if the host interface, such as "ALSA".

=head2 input

This is a Bool indicating whether this is an input device (i.e. whether
it is valid to pass to C<open-input>.)

=head2 output

This is a Bool indicating whether this is an output device (i.e. whether
it is valid to pass to C<open-output>.)

=head2 opened

This is a Bool indicating whether you have the device opened or not.

=head1 Audio::PortMIDI::Time

This provides access to the reference timer that is used by default
by portmidi and provides timestamp values that (with the C<latency>
setting of C<open-output>) can provide finer control over when the
messages are sent.  The timer itself is started when the first instance if
C<Audio::PortMIDI> is created in your application. All of the methods can
be treated as "class methods" as there is only a single timer maintained
by the C<portmidi> library.

=head2 method start

    method start()

This starts the timer, though it will always be started for you when you
create an L<Audio::PortMIDI> object, this may be useful if you want to
use it in some other way.

=head2 method started

    method started() returns Bool

This returns a Bool indicating whether the timer is running.

=head2 method time

    method time() returns Int

This returns the monotonously increasing time reference value of the
timer in milliseconds.  It is only meaningful relative to other values
obtained from the timer (i.e. it isn't the actual wallclock time,)
these values can be used to create event timestamps with some offset
for accurate timing of the despatch of the messages if a C<latency>
value was provided to C<open-output>.

=head1 Audio::PortMIDI::Stream

Objects of this type are returned by C<open-input> and C<open-output>
through which messages are read or written to the device. You will never
construct one of these objects yourself.

=head2 method has-host-error

    method has-host-error() returns Bool

This returns a Bool to indicate whether the host interface API has an
error on the stream.

=head2 method set-filter

    method set-filter(Int $filter)

This allows the setting of a filter on the stream that will exclude the
specified types of messages from the input. It only makes sense for
streams opened for input.  The filter is the bitwise OR of values of
the enumeration C<Audio::PortMIDI::Format> :

=item Active

=item Sysex

=item Clock

=item Play

=item Tick

=item Fd

=item Undefined

=item Reset

=item Realtime

=item Note

=item ChannelAftertouch

=item PolyAftertouch

=item Aftertouch

=item Program

=item Control

=item Pitchbend

=item Mtc

=item SongPosition

=item SongSelect

=item Tune

=item Systemcommon


This can be used to reduce the number of messages that will be buffered
for your stream to those that you are actually interested in (especially
if you have a busy MIDI bus.)

=head2 method set-channel-mask

    method set-channel-mask(*@channels)

This can be used to restrict the messages that you will receive to those
on one or more specified channels (by default you will get messages for
all channels,)  you can supply up to 16 channel numbers in the range
0 .. 15 (that is the commonly referred channel number - 1).  It is an
error to supply more than sixteen or values outside that range.

=head2 method abort

    method abort()

This closes the stream immediately, discarding any unsent or unread
messages.  After this is called reading or writing the stream will give
rise to an exception.

=head2 method close

    method close()

This closes the stream after all of the pending messages have been sent
and will not accept any new messages to the buffer to read. It will give
rise to an exception if a write is attempted after this is called.


=head2 method synchronize

    method synchronize()

This would typically be used if the timer was started B<after> the stream
was opened, however this situation is unlikely to arise with this module
as the timer is always started.

=head2 method poll

    method poll() returns Bool

This returns (for streams opened for input,) a Bool indicating whether
there are messages to be read.  It does not block. It may be preferable to
continuously calling C<read> as it just checks whether there is anything
in the input buffer rather than trying to obtain a message or messages.

=head2 method read

    method read(Int $length)

For a stream opened for input this will attempt to obtain at most
C<$length> messages from the buffer and will return an array of
L<Audio::PortMIDI::Event|#Audio::PortMIDI::Event> objects which will
contain at most C<$length> objects.  If the buffer size that you
specified to C<open-input> has been overflowed since the last C<read>
then an exception will be thrown.  If the stream is closed then an
exception will be thrown. If the stream was not opened for input then
an exception will be thrown.

=head2 method write

    multi method write(Event @events)
    multi method write(Event $event)

For a stream that is opened for output, this will queue one or more
L<Audio::PortMIDI::Event|#Audio::PortMIDI::Event> objects to be delivered
to the device.  The single candidate uses a native function that can
discard the timestamp if it is not going to be used, and may be quicker,
but the multiple candidate will typically endeavour to ensure that all
the messages are despatched at the same time (or at the time appropriate
for the timestamp and latency provided to C<open-output>,) so will be
better if "polyphonic" output is required for instance.

If the messages would overflow the buffer provided to C<open-output>
then an exception will be thrown.  If the stream was not opened for
output an exception will be thrown.

=head1 Audio::PortMIDI::Event

Objects of this type represent MIDI messages and are returned from
C<read> and passed to C<write> on a stream, they provide a very thin
abstraction over the MIDI message itself as well as the C<timestamp>
that may be used by C<portmidi> for the timing of the delivery of
the message but is not part of the MIDI specification. 

An actual MIDI message on the wire comprises three bytes: a C<status>
byte that encodes the command and, for channel messages, the channel
number and two data bytes of which one or both may be ignored for
certain commands. (the values of the data bytes are actually 7 bits
the high bit should be left unset, i.e. they are values 0 .. 127.)
Whilst some sugar is provided for some message types you really
should familiarise yourself with the MIDI specification if you 
want to get the most out of this.

A good summary of the structure of MIDI messages can be found in
L<https://www.midi.org/specifications/item/table-1-summary-of-midi-message>


=head2 method new

    method new(Int :$event, Int :$!timestamp, Int :$!channel, Type :$!event-type, Int :$!data-one, Int :$!data-two, Int :$!status)

This is the constructor for objects of this class. Except for C<event>
the named arguments relate to the attributes of this class described
below.  

C<event> is used when the object is being constructed from the value
returned by C<portmidi> in C<read> (it is the timestamp and the 
entire MIDI message packed into a 64 bit Int,) you will almost certainly
not need to use this in your own code.

If creating an object of this type you should provide C<timestamp> 
(it can be 0 if you are not using the timing facilities described
above, but if set to greater than 0 should never decrease.)

C<status> comprises the C<channel> and C<event-type> and it doesn't
make sense to provide all three to the constructor.  Typically you
should use C<channel> and C<event-type> for "channel messages" 
(e.g. "note on", "note off", "program change", "control change") and
C<status> for "system messages" such as MIDI clock where the specific
message type is specified by the entire status byte.

=head2 timestamp

This is the timestamp of the message that will be used for scheduling the
despatch of the message if a latency value was passed to C<open-output>,
it can be set to 0 or should be an increasing value in milliseconds.
The C<time> method of L<Audio::PortMIDI::Time|#Audio::PortMIDI::Time>
provides values that can be used (possibly with an offset.)

=head2 channel

This is the Int channel number to be used for channel messages, it
should be a value between 0 .. 15 (most documentation uses 1 .. 16
so you may need to subtract 1 from a value for the device if you have
one.) It doesn't make sense as a channel number if it is a system message
(it will actually be part of the "command".) Setting this (along with
C<event-type>,) does not make sense if C<status> is being set.

=head2 event-type

This is a value of the enum C<Audio::PortMIDI::Event::Type> (which is
exported so it does not need to be fully qualified,):

=head3 NoteOff

This should be sent after a C<NoteOn> with the same C<data-one> and
C<data-two> as the original note, to turn the note off, this may not
be necessary for instance with percussive instruments or those with
a short envelope, however some instruments may get confused if they
don't receive one so it's better to send it in all cases.

=head3 NoteOn

This starts a "note". C<data-one> should be the "note number" in 
the range 0 .. 127 and C<data-two> the "velocity" (again 0 .. 127.)
Unless the target instrument is percussive or has a similar short
envelope it should be followed by a NoteOff with the same data
after a period that represents the length of the note to be sounded.

=head3 PolyphonicPressure

This represents a continued downward pressure on a keyboard after
the note has been struck and before it has been released, it should
have the "note number" in C<data-one> (as above) and the "amount"
of pressure in C<data-two> (again 0 .. 127,) for most synthesizers
it doesn't make sense unless it follows a NoteOn for the same
note number and precedes the NoteOff - you can of course send as
many as you like between the NoteOn and NoteOff as you want.
Some documentation may refer to this as "after touch", the precise
effect is entirely dependent on the device.

=head3 ControlChange

This sends a "control change" (often referred to as CC,) on the
specified channel with the control number (in the range 0 .. 127)
in C<data-one> and the value in C<data-two>.  The documentation
for your synthesizer should list those it understands, though
some controls are reserved for special purposes.  You are generally
free to interpret them how you wish on reading messages.

=head3 ProgramChange

This requests that the "program" or "patch" is changed on the
specified channel, the new program number is supplied in 
C<data-one>, C<data-two> should be ignored by most devices
but ideally should be 0. The documentation of the device
may describe the programs but often they can be user defined.
Some synthesizers may allow multiple "banks" of programs
which can be specified by a control change, but you will 
need to refer to the specific documentation about this.

=head3 ChannelPressure

This is similar to Polyphonic Pressure but applies to all
active notes rather than just one "key". The C<data-one>
contains the amount of "Pressure" and C<data-two> should
ideally be 0 though it should be ignored by a device.
As with PolyphonicPressure the precise effect on the sound
is dependent on the actual device.

=head3 PitchBend

"pitch bend" will typically alter the pitch of all the
active notes (though a device could conceivably interpret
it differently) the amount of "bend" is specified as a
14 bit value with the 7 most significant bits in C<data-one>
and the 7 least significant in C<data-two>.  You can
consider this as being 0 .. 127 of "coarse" modulation 
in C<data-one> and 0 .. 127 of "fine" control in C<data-two>
if it is easier.

=head3 SystemMessage

This (for a read message,) indicates that the message is
a "system" message and that, rather than being a separate
command and channel, the whole status byte should be
considered to be the "command".  For a message that is
to be sent you probably wouldn't set this but supply
the appropriate C<status>.

=head2 status

This is the entire status byte, if this has the highest
four bits set (i.e. it has the value of 240 or greater) then
the message is a "system message", and the C<event-type> and
C<channel> are probably not meaningful themselves (the 
C<event-type> is C<SystemMessage> and the lower four bits
indicate the actual message type.)  If you set this then you
do not need to set the C<event-type> and C<channel> and vice
versa.

The most common values used are those related to the MIDI
realtime clock that may control the tempo and playback of
the receiving device or may be received to control the
tempo in your application:

=head3 Clock

If a clock is being provided to or from a device events of
this type are sent 24 times per quarter note (or every
0.020833 seconds at 120 beats per minute.) This sort of
frequency should be doable in a Perl program though various
scheduling delays may mean it will be difficult to maintain
accuracy at higher tempos without using the C<portmidi> timer.

The received clocks may be used for other than just setting
the tempo on a receiving system, for instance synchronising the
rate of an LFO or other modulation source.

Some devices may commence playing on receipt of the first few
clocks rather than needing a C<Start> message.

Some devices that emit a clock may alter the frequency of the
clocks temporarily to affect some time based decoration (such
as a fill or roll from a drum machine.)

=head3 Start

If this is received the current sequence will start playing
and it is assumed that will be followed by a series of C<Clock>
messages indicating the tempo of playback. Playback is expected
to start at the beginning.

=head3 Continue

If this is received and the sequence is stopped then playback
will restart at the position where it was last stopped. Like
Start it is assumed that this will be followed by a steady flow
of C<Clock> messages.

=head3 Stop

This will stop any running sequence on any attached device,
typically the stream of C<Clock> messages will stop as well.


=end pod


use NativeCall;

class Audio::PortMIDI {

    constant LIB = ('portmidi',v0);

    enum Error (
        NoError             => 0,
        NoData              => 0,
        GotData             => 1,
        HostError           => -10000,
        InvalidDeviceId     => -9999,
        InsufficientMemory  => -9998,
        BufferTooSmall      => -9997,
        BufferOverflow      => -9996,
        BadPtr              => -9995,
        BadData             => -9994,
        InternalError       => -9993,
        BufferMaxSize       => -9992
    );

    sub Pm_GetErrorText(int32 $errnum) is native(LIB) returns Str { * }

    method error-text(Int $code) returns Str {
        Pm_GetErrorText($code);
    }

    class X::PortMIDI is Exception {
        has Int $.code is required;
        has Str $.what is required;
        has Str $.message;

        method message() returns Str {
            if !$!message.defined {
                my $text = Pm_GetErrorText($!code);
                $!message = "{$!what} : $text";
            }
            $!message;
        }

    }

    my class DeviceInfoX is repr('CStruct') {
        has int32                         $.struct-version;
        has Str                           $.interface;
        has Str                           $.name;
        has int32                         $.input;
        has int32                         $.output;
        has int32                         $.opened;
    }

    class DeviceInfo {
        has DeviceInfoX $.device-info handles <interface name> is required;
        has Int $.device-id is required;

        method input() returns Bool {
            Bool($!device-info.input);
        }
        method output() returns Bool {
            Bool($!device-info.output);
        }
        method opened() returns Bool {
            Bool($!device-info.opened);
        }

        method gist() {
            sprintf "%3i :  %-25s  %10s  %2s   %3s   %4s", self.device-id, 
                                                        self.name, 
                                                        self.interface,
                                                        ( self.input ?? 'In' !! '--' ),
                                                        ( self.output ?? 'Out' !! '---' ), 
                                                        (self.opened ?? 'Open' !! '----');
        }


    }

    # For some reason the nativecall can't deal with the pattern
    # we have here so we will cheat and pretend we're dealing with
    # a uint64 and unpack the parts ourself.

    class EventX is repr('CStruct') {
        has int32   $.message;
        has int32   $.timestamp;
    }

    use Util::Bitfield;

    class Event {
        enum Type is export (
            NoteOff             => 0b1000,
            NoteOn              => 0b1001,
            PolyphonicPressure  => 0b1010,
            ControlChange       => 0b1011,
            ProgramChange       => 0b1100,
            ChannelPressure     => 0b1101,
            PitchBend           => 0b1110,
            SystemMessage       => 0b1111,
        );
        enum RealTime is export (
            Clock       =>  0b11111000,
            Start       =>  0b11111010,
            Continue    =>  0b11111011,
            Stop        =>  0b11111100
        );

        has Int     $.message;
        has Int     $.timestamp;
        has Int     $.status;
        has Int     $.channel;
        has Type    $.event-type;
        has Int     $.data-one;
        has Int     $.data-two;

        submethod BUILD(Int :$event, Int :$!timestamp, Int :$!channel, Type :$!event-type, Int :$!data-one, Int :$!data-two, Int :$!status) {
            if $event.defined {
                $!timestamp = extract-bits($event,32,0,64);
                $!message   = extract-bits($event,32,32,64);
            }
        }

        method message() returns Int {
            if !$!message.defined {
               my $mess = 0;
               if self.status.defined {
                   $mess = insert-bits(self.status, $mess, 8, 16, 24 );
               }
               if self.data-one.defined {
                   $mess = insert-bits(self.data-one, $mess,8, 8, 24 );
               }
               if self.data-two.defined {
                   $mess = insert-bits(self.data-two, $mess,8, 0, 24);
               }
               $!message = $mess;
            }
            $!message;
        }

        method status() returns Int {
            if !$!status.defined {
                if $!message.defined {
                    $!status = extract-bits($!message,8,16,24);
                }
                elsif $!channel.defined && $!event-type.defined {
                    my $status = insert-bits($!event-type,0,4,0,8);
                    $!status = insert-bits($!channel, $status,4,4,8);
                }
            }
            $!status;
        }

        method channel() returns Int {
            if !$!channel.defined {
                if self.status.defined {
                    $!channel = extract-bits(self.status,4,4,8);
                }
            }
            $!channel;
        }
        method event-type() returns Int {
            if !$!event-type.defined  {
                if self.status.defined {
                    $!event-type = Type(extract-bits(self.status,4,0,8));
                }
            }
            $!event-type;
        }

        method data-one() returns Int {
            if !$!data-one.defined && $!message.defined {
                $!data-one = extract-bits($!message,8,8,24);
            }
            $!data-one;
        }
        method data-two() returns Int {
            if !$!data-two.defined  && $!message.defined {
                $!data-two = extract-bits($!message,8,0,24);
            }
            $!data-two;
        }

        method gist() returns Str {
            "Channel : { self.channel } Event: { self.event-type } D1 : { self.data-one } D2 : { self.data-two }";
        }

        method Int() returns Int {
            my $int = insert-bits(self.message // 0, 0, 32, 32, 64);
            insert-bits(self.timestamp // 0, $int, 32, 0, 64);
        }
    }

    enum Filter (
        Active => (1 +< 0x0E),
        Sysex => (1 +< 0x00),
        Clock => (1 +< 0x08),
        Play => ((1 +< 0x0A) +| (1 +< 0x0C) +| (1 +< 0x0B)),
        Tick => (1 +< 0x09),
        Fd => (1 +< 0x0D),
        Undefined => (1 +< 0x0D),
        Reset => (1 +< 0x0F),
        Realtime => ((1 +< 0x0E) +| (1 +< 0x00) +| (1 +< 0x08) +| (1 +< 0x0A) +| (1 +< 0x0C) +| (1 +< 0x0B) +| (1 +< 0x09) +| (1 +< 0x0D) +| (1 +< 0x0F)),
        Note => ((1 +< 0x19) +| (1 +< 0x18)),
        ChannelAftertouch => (1 +< 0x1D),
        PolyAftertouch => (1 +< 0x1A),
        Aftertouch => ((1 +< 0x1D) +| (1 +< 0x1A) ),
        Program => (1 +< 0x1C),
        Control => (1 +< 0x1B),
        Pitchbend => (1 +< 0x1E),
        Mtc => (1 +< 0x01),
        SongPosition => (1 +< 0x02),
        SongSelect => (1 +< 0x03),
        Tune => (1 +< 0x06),
        Systemcommon => ((1 +< 0x01) +| (1 +< 0x02) +| (1 +< 0x03) +| (1 +< 0x06)),
    );

    class Stream is repr('CPointer')  {

        sub Pm_HasHostError(Stream $stream) is native(LIB) returns int32 { * }

        method has-host-error() returns Bool {
            my $rc = Pm_HasHostError(self);
            Bool($rc);
        }

        sub Pm_SetFilter(Stream $stream , int32 $filters) is native(LIB) returns int32 { * }

        method set-filter(Int $filter) {
            my $rc = Pm_SetFilter(self, $filter);
            if $rc < 0 {
                X::PortMIDI.new(code => $rc, what => 'setting filter').throw;
            }
            True;
        }

        sub Pm_SetChannelMask(Stream $stream, int32 $mask ) is native(LIB) returns int32 { * }

        method set-channel-mask(*@channels where { @channels.elems <= 16 && all(@channels) ~~ ( 0 ..15 ) }) {
            my int $mask = @channels.map(1 +< *).reduce(&[+|]);
            my $rc = Pm_SetChannelMask(self, $mask);
            if $rc < 0 {
                X::PortMIDI.new(code => $rc, what => 'setting channel mask').throw;
            }
            True;
        }

        sub Pm_Abort(Stream $stream) is native(LIB) returns int32 { * }

        method abort() {
            my $rc = Pm_Abort(self);
            if $rc < 0 {
                X::PortMIDI.new(code => $rc, what => "aborting stream").throw;
            }
        }

        sub Pm_Close(Stream $stream) is native(LIB) returns int32 { * }

        method close() {
            my $rc = Pm_Close(self);
            if $rc < 0 {
                X::PortMIDI.new(code => $rc, what => "closing stream").throw;
            }
        }
    
        sub Pm_Synchronize(Stream $stream ) is native(LIB) returns int32 { * }

        method synchronize() {
            my $rc = Pm_Synchronize(self);
            if $rc < 0 {
                X::PortMIDI.new(code => $rc, what => "synchronizing stream").throw;
            }
        }


        sub Pm_Poll(Stream $stream ) is native(LIB) returns int32 { * }

        method poll() returns Bool {
            my $rc = Pm_Poll(self);
            if $rc < 0 {
                X::PortMIDI.new(code => $rc, what => "polling stream").throw;
            }
            Bool($rc);
        }

        sub Pm_Read(Stream $stream, CArray $buffer, int32 $length) is native(LIB) returns int32 { * }


        proto method read(|c) { * }

        multi method read(Int $length) {
            my CArray[int64] $buff = CArray[int64].new;
            $buff[$length - 1] = 0;
            my $rc = Pm_Read(self, $buff, $length);
            if $rc < 0 {
                X::PortMIDI.new(code => $rc, what => "reading stream").throw;
            }

            my @buff;

            for ^$rc -> $i {
                @buff.append: Event.new(event => $buff[$i]);
            }

            @buff;
        }

        sub Pm_Write(Stream $stream, CArray[int64] $buffer, int32  $length ) is native(LIB) returns int32 { * }

        proto method write(|c) { * }

        multi method write(Event @events) {
            my $buffer = CArray[int64].new;
            my $length = @events.elems;
            for @events -> $event {
                $buffer[$++] = $event.Int;
            }
            my $rc = Pm_Write(self, $buffer, $length);
            if $rc < 0 {
                X::PortMIDI.new(code => $rc, what => "writing stream").throw;
            }
        }

        sub Pm_WriteShort(Stream $stream, int32 $when, int32 $msg) is native(LIB) returns int32 { * }

        multi method write(Event $event) {
            my $rc = Pm_WriteShort(self, $event.timestamp // 0, $event.message);
            if $rc < 0 {
                X::PortMIDI.new(code => $rc, what => "writing stream").throw;
            }
        }

        sub Pm_WriteSysEx(Stream $stream, int32 $when, Pointer[uint8] $msg) is native(LIB) returns int32 { * }
    }

    class Time {

        sub Pt_Started() returns int32 is native(LIB) { * }

        method started() returns Bool {
            my $rc = Pt_Started();
            Bool($rc);
        }
        sub Pt_Start(int32 $resolution, &ccb (int32 $timestamp, Pointer $userdata), Pointer $u) returns int32 is native(LIB) { * }

        method start() {
            Pt_Start(1, Code, Pointer);
        }

        sub Pt_Time() returns int32 is native(LIB) { * }

        method time() returns Int {
            Pt_Time();
        }
    }


    multi submethod BUILD() {
        self.initialize();
        Time.start();
    }

    sub Pm_Initialize() is native(LIB) returns int32 { * }

    method initialize() {
        my $rc = Pm_Initialize();
        if $rc < 0 {
            X::PortMIDI.new(code => $rc, what => 'initialising portmidi').throw;
        }
    }

    sub Pm_Terminate() is native(LIB) returns int32  { * }

    method terminate() {
        my $rc = Pm_Terminate();
        if $rc < 0 {
            X::PortMIDI.new(code => $rc, what => 'terminating portmidi').throw;
        }
    }

    sub Pm_GetHostErrorText(Str $msg is rw, uint32 $len ) is native(LIB)  { * }

    sub Pm_CountDevices() is native(LIB) returns int32 { * }

    method count-devices() returns Int {
        my $rc = Pm_CountDevices();
        if $rc < 0 {
            X::PortMIDI.new(code => $rc, what => 'count-devices').throw;
        }
        $rc;
    }

    sub Pm_GetDeviceInfo(int32 $id) is native(LIB) returns DeviceInfoX { * }

    method device-info(Int $device-id) returns DeviceInfo {
        DeviceInfo.new(device-info => Pm_GetDeviceInfo($device-id), :$device-id);
    }

    method devices() {
        gather {
            for ^(self.count-devices()) -> $id {
                take self.device-info($id);
            }
        }
    }

    sub Pm_GetDefaultInputDeviceID() is native(LIB) returns int32 { * }

    method default-input-device() returns DeviceInfo {
        my $rc = Pm_GetDefaultInputDeviceID();
        if $rc < 0 {
            X::PortMIDI.new(code => $rc, what => "default-input-device").throw;
        }
        self.device-info($rc);
    }

    sub Pm_GetDefaultOutputDeviceID() is native(LIB) returns int32 { * }

    method default-output-device() returns DeviceInfo {
        my $rc = Pm_GetDefaultOutputDeviceID();
        if $rc < 0 {
            X::PortMIDI.new(code => $rc, what => "default-output-device").throw;
        }
        self.device-info($rc);
    }

    sub Pm_OpenInput(CArray[Stream] $stream, int32 $inputDevice, Pointer $inputDriverInfo, int32 $bufferSize ,&time_proc (Pointer --> int32), Pointer $time_info) is native(LIB) returns int32 { * }

    proto method open-input(|c) { * }

    multi method open-input(DeviceInfo:D $dev, Int $buffer-size) returns Stream {
        if $dev.input {
            samewith $dev.device-id, $buffer-size;
        }
        else {
            X::PortMIDI.new(code => -9999, message => "not an input device", what => "opening input stream").throw;
        }
    }

    multi method open-input(Int $device-id, Int $buffer-size) returns Stream {
        my $stream = CArray[Stream].new(Stream.new);
        my $rc = Pm_OpenInput($stream, $device-id, Pointer, $buffer-size, Code, Pointer);
        if $rc < 0 {
            X::PortMIDI.new(code => $rc, what => "opening input stream").throw;
        }
        $stream[0];
    }

    sub Pm_OpenOutput(CArray[Stream] $stream, int32 $outputDevice, Pointer $outputDriverInfo, int32 $bufferSize ,&time_proc (Pointer --> int32), Pointer $time_info, int32 $latency) is native(LIB) returns int32 { * }

    
    proto method open-output(|c) { * }


    multi method open-output(DeviceInfo:D $dev, Int $buffer-size, Int $latency = 0 ) returns Stream {
        if $dev.output {
            samewith $dev.device-id, $buffer-size, $latency;
        }
        else {
            X::PortMIDI.new(code => -9999, message => "not an output device", what => "opening output stream").throw;
        }
    }

    multi method open-output(Int $device-id, Int $buffer-size, Int $latency = 0) returns Stream {
        my $stream = CArray[Stream].new(Stream.new);
        my $rc = Pm_OpenOutput($stream, $device-id, Pointer, $buffer-size, Code, Pointer, $latency);
        if $rc < 0 {
            X::PortMIDI.new(code => $rc, what => "opening output stream").throw;
        }
        $stream[0];
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
