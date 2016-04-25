use Music::Helpers;

multi MAIN(:$mode = 'major', Int :$root = 48) {
    my $mode-obj = Mode.new(:$mode, :root(NoteName($root % 12)));

    my $pm = Audio::PortMIDI.new;
    my $s  = $pm.open-output(3, 32);
    my $in = $pm.open-input($pm.default-input-device.device-id, 32);

    sub flip-flop { $ .= not }

    sub nth(Int $in) { (++$) % $in }

    my $code = supply {
        whenever supply { emit $in.poll while True } {
            emit $in.read(1);
        }
    }

    my @intervals = Interval.pick(5);

    react {
        my $next-chord;
        my $chord = $mode-obj.chords.pick;
        my $melnote = $chord.notes.pick + 12;
        my $third = $mode-obj.notes.grep({ $_.is-interval($melnote, one(M3, m3)) && $_.octave == $melnote.octave })[0];
        my $sw = 0;
        my Audio::PortMIDI::Event @outevs;
        whenever $code -> $ev {
            if $ev {
                given $ev[0].data-two {
                    my $redo = False;
                    when * +& 1 {
                        if $sw++ %% 4 {
                            @intervals = Interval.pick(6);
                        }
                        proceed if rand < .1;
                        $next-chord = $mode-obj.next-chord($chord, :@intervals).invert((-3, -2, -1, 0, 1, 2, 3).pick);
                        if rand < .7 {
                            my $variant = $next-chord.changes-into.pick.^shortname;
                            $next-chord = $next-chord."$variant"();
                        }
                        $next-chord .= invert(-1) while any($next-chord.notes>>.octave) > 4;
                        $next-chord .= invert( 1) while any($next-chord.notes>>.octave) < 4;
                        # proceed if rand < .2;
                        if $chord {
                            for $chord.OffEvents {
                                @outevs.push: $_
                            }
                        }
                        say $next-chord.Str;
                        $chord = $next-chord;
                        for $chord.OnEvents {
                            @outevs.push: $_
                        }
                        proceed;
                    }
                    when 1 < * {
                        if rand < .4 || $redo {
                            $redo = False;
                            @outevs.push: $melnote.OffEvent if $melnote;
                            $melnote = $chord.notes.pick + (12);
                            if rand < .3 && $melnote {
                                $melnote = $mode-obj.notes.grep({ 
                                    $_.is-interval($melnote, any(@intervals.pick(3)) ) 
                                &&  $_.octave == $melnote.octave + (-1,0,1).pick;
                                }).pick;
                                $redo = True;
                            }
                            @outevs.push: $melnote.?OnEvent // Empty;
                        } 
                        elsif rand < .2 {
                            @outevs.push: $third.OffEvent if $third;
                            $third = $mode-obj.notes.grep({
                                $_.is-interval($melnote, one(M3, m3)) 
                            &&  $_.octave == $melnote.octave + (-1,0,1).pick;
                            }).pick if $melnote;
                            @outevs.push: $melnote.?OnEvent // Empty;
                            @outevs.push: $third.?OnEvent // Empty;
                            $redo = True;
                        }
                        proceed;
                    }
                }
                $s.write(@outevs);
                @outevs = [];
            }
        }
    }
}
