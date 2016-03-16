use v6.c;

=begin pod

=head1 

Audio::Silan - Audio silence detection using silan

=head1 SYNOPSIS

=begin code

use Audio::Silan;

my $silan = Audio::Silan.new;

my $promise = $silan.find-boundaries($some-audio-file);

await $promise.then(-> $i { say "Start : { $i.start } End: { $i.end }" });

=end code

=head1 DESCRIPTION

This module provides a mechanism to use L<Silan|https://github.com/x42/silan>
to detect the silence at the beginning and end of an audio file (which are
sometimes described as cue in and cue out points.)

It allows the setting of the silence threshold and "hold off" (that is the
minimum length of silence required before it is considered the end of the
audio.)  For certain material these values may need adjustment in order to
provide accurate output.

Because the detection may take some time for larger files, this takes
place asynchronously: the method C<find-boundaries> returns a L<Promise>
which will be kept with the result of the detection (or broken if the
detection failed.)

=head1 METHODS

=head2 method new

    method new(Str :$silan-path, Numeric :$hold-off, Numeric :$threshold)

The constructor for L<Audio::Silan>.  C<$silan-path> if provided must be
the fully qualified path to the C<silan> executable, otherwise it will be
looked for in the C<$PATH> environment.  C<$hold-off> is the minimum time
in seconds before silence is detected, it really only applies to the end of
the file (this can be increased to stop spurious detection,) the default is
0.5.  C<$threshold> is a floating point RMS signal threshold at which silence
is detected, the default is 0.001 (which is about -60dB) this can be decreased
to prevent spurious detection in quite passages.

=head2 method find-boundaries

    method find-boundaries(Str $file) returns Promise

This uses C<silan> to detect the cue points in the audio file supplied as
C<$file>, returning a L<Promise>.  

If there is a problem with the detection or the file cannot be read or the
silan cannot be executed then the C<Promise> will be broken with an exception.

If the detection is successful the Promise will be kept with an object
of the type C<Audio::Silan::Info> which has the following members:

=head3 duration

The total length of the audio file in seconds

=head3 sample-rate

The sample rate of the audio, this can be used to convert the bounds to
samples rather than seconds if they are to be used for processing.

=head3 start

The floating point number of seconds into the audio data that the content
was detected to begin.

=head3 end

The floating point number of seconds (from the start of the file,) where the
audio is detected to end.

=end pod

class Audio::Silan:ver<0.0.3>:auth<github:jonathanstowe> {
    use File::Which;
    use JSON::Fast;

    class X::NoSilan is Exception {
        has Str $.message = "No silan executable found";
    }

    class X::NoFile is Exception {
        has Str $.filename is required;
        method message() {
            return "File '{ $.filename }' does not exist";
        }
    }

    class Info {
        has Rat $.duration;
        has Int $.sample-rate;
        has Rat $.start;
        has Rat $.end;
    }

    has Str $.silan-path;
    has Numeric $.threshold is rw;
    has Numeric $.hold-off   is rw;

    method silan-path() { 
        if not $!silan-path.defined {
            my $sp = which('silan');
            if not $sp.defined {
                X::NoSilan.new.throw;
            }
            else {
                $!silan-path = $sp;
            }
        }

        if not $!silan-path.IO.x {
            X::NoSilan.new.throw;
        }

        $!silan-path;
    }

    method find-boundaries(Str $file) returns Promise {
        start {
            if not $file.IO.r {
                X::NoFile.new(filename => $file).throw;
            }
            else {
                my @args = self.build-args($file);
                my $proc = run(@args, :out, :err);

                if $proc.exitcode == 0 {
                    my $out = $proc.out.slurp-rest;

                    my $data = from-json($out);
                    my $duration = $data{"file duration"};
                    my $sample-rate = $data{"sample rate"};
                    my ( $start, $end ) = $data<sound>[0].list;

                    Info.new(:$duration, :$sample-rate, :$start, :$end);
                }
            }
        }
    }

    method build-args(Str $file ) {
        my @args = (self.silan-path, '-b', '--format', 'json');

        if $!threshold.defined {
            @args.append('--threshold', $!threshold.Str);
        }
        if $!hold-off.defined {
            @args.append('--holdoff', $!hold-off.Str);
        }
        @args.append($file);
        @args;
    }

}
# vim: expandtab shiftwidth=4 ft=perl6
