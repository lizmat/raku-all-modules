# Examples for Audio::PortMIDI

This directory contains a number of programs that demonstrate
ways that you might usue this library. Some of them may even
be useful in their own right or as a starting point for your
own programs. Please feel free to use them however you see
fit.

## [show-devices](show-devices)

This simply shows the MIDI devices on your system, it may be
useful in conjunction with the other programs which may 
accept a device id as an argument.

## [dump-stream](dump-stream)

This outputs the details of the MIDI messages received on a
specified input device, it may be useful for debugging your
programs or for checking you are getting the input that you
expect from some other device.

## [wonky-clock](wonky-clock)

This outputs a MIDI clock that approximates to the supplied
BPM on the specified device, it's probably not very accurate
at all due to the timer resolution but could probably be
improved with a bit of care.

## [mode-play](mode-play)

This plays notes from the specificied mode starting at a given
root to a supplied device. Depending on the instrument you
use and the mode selected it can vary between acid house and
east coast jazz which may or may not be of interest but is
more of a demonstration of how you can calculate and vary
timings and generate MIDI note messages.

## [amen](amen)

This plays the (in)famous "Amen Break" on what is assumed to
be a "General MIDI" drumkit on the specified channel (which
defaults to that specified for drums by the GM spec,) and
device. It demonstrates the sending of a set of MIDI events
to PortMIDI at once for "simultaneous" play (it's not really
simultaneous because MIDI is a serial protocol.)
