# Audio::PortAudio

Access to audio input and output devices

## Synopsis

```perl6

use Audio::PortAudio;

my $pa = Audio::PortAudio.new;

# get the default stream with no inputs, 2 output channels
# for audio encoded as 32 bit floats at 44100 samplerate;
my $stream = $pa.open-default-stream(0,2,Audio::PortAudio::Float32,44100);

$stream.start;

loop {
	# get some audio data in a carray from somewhere
	$stream.write($carray, $frame-count);
}


```

See also [the examples directory](examples)

## Description

This module provides a mechanism to get audio into and out of your
program via a sound card or some other sub-system supported by the
[portaudio](http://www.portaudio.com/), this may include "ALSA", "JACK"
or "OSS" on Linux, "CoreAudio" on Mac and "ASIO" on Windows, (of course
the actual support depends on how the library was built on your system.)

You will need to have the portaudio library installed on your system
to use this, it may be available as a package or come pre-installed,
but the details will be specific to your platform.

The interface is somewhat simplified in comparison to the underlying
library and in particular only "blocking" IO is supported at the current
time (though this does not preclude the use of the callback API in the
future, it's just an interface that is natural to a Perl 6 developer
doesn't suggest itself at the moment.)

It is important to note that the constraints of real-time audio data
handling mean that you have to be careful that you allow for consistent
and timely handing of the data to or from the device for proper results,
you may find that for some applications you will need to avoid the use
of any concurrency whatsoever for instance (the streaming example is
such a case where the time budget was such that any unexpected garbage
collection or other processor stealing activity didn't leave the process
enough time spare to recover and the stream eventually became unusable.)

Also it should be noted that some types of source API ("JACK" in
particular,) require that you use a fixed buffer size that is consistent
with that configured for the host service, unfortunately portaudio doesn't
appear to provide a way of discovering this so you may need to either
check with the source configuration or experiment to find a correct and
working value for buffer sizes.  The symptoms of this may include choppy,
"syncopated" or "phased" output.

This is based on the original work of
[Peschwa](https://github.com/peschwa/Audio-PortAudio) which I forked and
then just completely hijacked when I realised it could be potentially
be made useful :) So most of the credit probably goes to him.

## Installation

This module depends on having the portaudio library installed, your
operating system may offer this is as a package that you can install
with whatever tools the system uses (it may be installed already as it
is quite a common dependency for audio applications,) or you may be able
to obtain and install the source from http://www.portaudio.com/download.html.
If you take the latter route you want to make sure that you install at
least one driver for it to be useful.

If you have [panda](https://github.com/tadzik/panda) installed you can
install this module directly:

    panda install Audio::PortAudio

Or if you have a copy of this source then you can do so from within the
distribution directory:

    panda install .

I haven't tested with other installers such as [zef](https://github.com/ugexe/zef)
but I have no reason to believe that it shouldn't work just as well.

## Support

This probably falls into the 'experimental' category, it is definitely usable
but I will not be surprised if you have difficulty using it because of the
performance constraints alluded to above.  

It is also quite difficult to do automated tests beyond basic sanity checks, as
it would have to be able to "hear" the output or the result of input which may
be beyond our control so the examples stand in as a proxy for proper unit tests.

Anyway if you're still reading and you do have a problem then please provide as
much detail as possible, including the details and configuration of your sound
card and/or host API if possible (e.g. "jack" configuration,)

I'd also be delighted to hear if you don't have problems and have made something
really cool with this, or have patches to improve the interface (in the latter
case a working example that demonstrates that it is usable would be nice,) or
any other suggestions via https://github.com/jonathanstowe/Audio-PortAudio/issues

I'd be particularly interested in a Perl-ish way of expressing the portaudio
callback API, the native subs support it, it just isn't exposed through the
class API here.

## License

Please see the LICENCE file in the distribution.

(C) Peschwa        2015
(C) Jonathan Stowe 2016


