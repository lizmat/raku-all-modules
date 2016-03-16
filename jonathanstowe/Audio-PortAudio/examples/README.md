# Examples for Audio::PortAudio

This directory has some examples of ways you might use
Audio::PortAudio.

They may be useful in their own right but shouldn't be
considered "production ready".

Also some of the examples are somewhat constrained by the performance
requirements for real-time audio, the stream and record examples are
operating fairly close to what is possible at the current time (on
my machine anyway,) but hopefully this will improve over time.

If you come up with something particularly cute I'd love to hear about them.


They have depencies on some or all of:

*	[Audio::Sndfile](https://github.com/jonathanstowe/Audio-Sndfile)
*	[Audio::Encode::LameMP3](https://github.com/jonathanstowe/Audio-Encode-LameMP3)
*	[Audio::Libshout](https://github.com/jonathanstowe/Audio-Libshout)

You may just want to install them now.

# [enum-devices](enum-devices)

This outputs a list of the portaudio devices available to your system, it may be
useful for determining sources for the other programs

# [play-sine](play-sine)

This outputs a constant sine-wave to the default device.  It may be useful for
testing that your sound setup works with this module.

# [play-wav](play-wav)

This will play a specified WAV audio file to either the default or a specified
output device.

# [record-wav](record-wav)

This will record input from the default or a specified input device to a WAV
file.

# [stream-source](stream-source)

This will encode and stream MP3 audio from the specified source to an icecast
server.

