unit class Audio::MIDI::Note:ver<1.001001>;
use Subset::Helper;
use Audio::PortMIDI;

my %midi-note  = build-midi-notes;
my subset ValidNote     of Str where subset-is { %midi-note{ $_ }:exists },
    'Valid notes are strings "C0" through "G#10"/"Ab10"';
my subset ValidVelocity of Int where subset-is 0 <= * <= 127,
    'Velocity value must be an Int 0 to 127, inclusive';

has Int                     $.instrument                   = 0;
has ValidVelocity           $.velocity               is rw = 80;
has Int                     $.tempo is rw where { $_ > 0 } = 40;
has Numeric                 $.value                        = ¼;
has Int                     $.channel                      = 0;
has Audio::PortMIDI::Stream $.stream is required;

method aplay (
     $notes                  is copy,
     $value                          = $!value,
    ValidVelocity :$velocity is copy = $!velocity,
    Int           :$instrument       = $!instrument,
    Bool          :$off              = False,
    Bool          :$on               = False,
    Bool          :$on-on            = False,
    Bool          :$rest-to-end      = False,
) {
    $notes = [ $notes ] unless $notes ~~ Array|List;
    die 'Invalid note' if $notes.grep: { $_ !~~ ValidNote };

    $velocity += $off ?? -15 !! $on ?? 20 !! $on-on ?? 40 !! 0;
    $velocity = 0   if $velocity < 0;
    $velocity = 126 if $velocity > 126;

    my &send-to-play = sub {
        $!stream.write: Audio::PortMIDI::Event.new:
            :$!channel, :event-type(ProgramChange),
            :data-one($instrument);

        $!stream.write: Audio::PortMIDI::Event.new:
            :$!channel, :event-type(NoteOn),
            :data-one(%midi-note{ $_ }), :data-two($velocity)
        for |$notes;

        sleep $value * (60 / $!tempo);

        $!stream.write: Audio::PortMIDI::Event.new:
            :$!channel, :event-type(NoteOff),
            :data-one(%midi-note{ $_ }), :data-two($velocity)
        for |$notes;
    };

    # Unless we're waiting for the note to complete, play it asynchronously
    $rest-to-end ?? send-to-play() !! start { send-to-play; }

    self;
}

method play (|c)                       { self.aplay: |c, :rest-to-end         }
method rest (Numeric $value = $.value) { sleep $value * (60 / $!tempo); self; }
method riff (&riff)                    { return self.&riff;                   }

multi method instrument ($instr) { $!instrument = $instr; self; }
multi method tempo      ($temp)  { $!tempo      = $temp;  self; }
multi method stream     ($str)   { $!stream     = $str;   self; }
multi method value      ($val)   { $!value      = $val;   self; }
multi method velocity   ($vel)   { $!velocity   = $vel;   self; }
multi method instrument          { return-rw $!instrument;      }
multi method tempo               { return-rw $!tempo;           }
multi method stream              { return-rw $!stream;          }
multi method value               { return-rw $!value;           }
multi method velocity            { return-rw $!velocity;        }

##################################

my sub build-midi-notes {
    my @notes   = <C C# Db D D# Eb E F F# Gb G G# Ab A A# Bb B>;
    my @pattern = <0 1  1  2 3  3  4 5 6  6  7 8  8  9 10 10 11>;
    my %midi-note; # build a map of all notes to MIDI note code
    BUILD-MIDI: for ^11 -> $octave {
        for @notes.keys {
            my $midi-note = $octave*12 + @pattern[$_];
            last BUILD-MIDI if $midi-note > 127;
            %midi-note{ @notes[$_] ~ $octave } = $midi-note;
        }
    }
    return %midi-note;
}

#     C	C#	D	D#	E	F	F#	G	G#	A	A#	B
# 0	0	1	2	3	4	5	6	7	8	9	10	11
# 1	12	13	14	15	16	17	18	19	20	21	22	23
# 2	24	25	26	27	28	29	30	31	32	33	34	35
# 3	36	37	38	39	40	41	42	43	44	45	46	47
# 4	48	49	50	51	52	53	54	55	56	57	58	59
# 5	60	61	62	63	64	65	66	67	68	69	70	71
# 6	72	73	74	75	76	77	78	79	80	81	82	83
# 7	84	85	86	87	88	89	90	91	92	93	94	95
# 8	96	97	98	99	100	101	102	103	104	105	106	107
# 9	108	109	110	111	112	113	114	115	116	117	118	119
# 10	120	121	122	123	124	125	126	127
