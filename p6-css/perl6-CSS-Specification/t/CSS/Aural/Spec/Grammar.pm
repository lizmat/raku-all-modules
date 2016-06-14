use v6;
#  -- DO NOT EDIT --
# generated by: t/build.t 

grammar CSS::Aural::Spec::Grammar {

    #| azimuth: <angle> | [[ left-side | far-left | left | center-left | center | center-right | right | far-right | right-side ] || behind ] | leftwards | rightwards
    rule decl:sym<azimuth> {:i (azimuth) ':' <val( rx{ <expr=.expr-azimuth> }, &?ROUTINE.WHY)> }
    rule expr-azimuth {:i :my @*SEEN; [ <angle> | [ [ [ [ left\-side | far\-left | left | center\-left | center | center\-right | right | far\-right | right\-side ] & <keyw> ] <!seen(0)> | behind & <keyw> <!seen(1)> ]+ ] | [ leftwards | rightwards ] & <keyw> ] }

    #| cue-after: <uri> | none
    rule decl:sym<cue-after> {:i (cue\-after) ':' <val( rx{ <expr=.expr-cue-after> }, &?ROUTINE.WHY)> }
    rule expr-cue-after {:i [ <uri> | none & <keyw> ] }

    #| cue-before: <uri> | none
    rule decl:sym<cue-before> {:i (cue\-before) ':' <val( rx{ <expr=.expr-cue-before> }, &?ROUTINE.WHY)> }
    rule expr-cue-before {:i [ <uri> | none & <keyw> ] }

    #| cue: [ 'cue-before' || 'cue-after' ]
    rule decl:sym<cue> {:i (cue) ':' <val( rx{ <expr=.expr-cue> }, &?ROUTINE.WHY)> }
    rule expr-cue {:i :my @*SEEN; [ [ <expr-cue-before> <!seen(0)> | <expr-cue-after> <!seen(1)> ]+ ] }

    #| elevation: <angle> | below | level | above | higher | lower
    rule decl:sym<elevation> {:i (elevation) ':' <val( rx{ <expr=.expr-elevation> }, &?ROUTINE.WHY)> }
    rule expr-elevation {:i [ <angle> | [ below | level | above | higher | lower ] & <keyw> ] }

    #| pause: [ [<time> | <percentage>]{1,2} ]
    rule decl:sym<pause> {:i (pause) ':' <val( rx{ <expr=.expr-pause> }, &?ROUTINE.WHY)> }
    rule expr-pause {:i [ [ [ <time> | <percentage> ] ]**1..2 ] }

    #| pause-after: <time> | <percentage>
    rule decl:sym<pause-after> {:i (pause\-after) ':' <val( rx{ <expr=.expr-pause-after> }, &?ROUTINE.WHY)> }
    rule expr-pause-after {:i [ <time> | <percentage> ] }

    #| pause-before: <time> | <percentage>
    rule decl:sym<pause-before> {:i (pause\-before) ':' <val( rx{ <expr=.expr-pause-before> }, &?ROUTINE.WHY)> }
    rule expr-pause-before {:i [ <time> | <percentage> ] }

    #| pitch-range: <number>
    rule decl:sym<pitch-range> {:i (pitch\-range) ':' <val( rx{ <expr=.expr-pitch-range> }, &?ROUTINE.WHY)> }
    rule expr-pitch-range {:i <number> }

    #| pitch: <frequency> | x-low | low | medium | high | x-high
    rule decl:sym<pitch> {:i (pitch) ':' <val( rx{ <expr=.expr-pitch> }, &?ROUTINE.WHY)> }
    rule expr-pitch {:i [ <frequency> | [ x\-low | low | medium | high | x\-high ] & <keyw> ] }

    #| play-during: <uri> [ mix || repeat ]? | auto | none
    rule decl:sym<play-during> {:i (play\-during) ':' <val( rx{ <expr=.expr-play-during> }, &?ROUTINE.WHY)> }
    rule expr-play-during {:i :my @*SEEN; [ <uri> [ [ mix & <keyw> <!seen(0)> | repeat & <keyw> <!seen(1)> ]+ ]? | [ auto | none ] & <keyw> ] }

    #| richness: <number>
    rule decl:sym<richness> {:i (richness) ':' <val( rx{ <expr=.expr-richness> }, &?ROUTINE.WHY)> }
    rule expr-richness {:i <number> }

    #| speak: normal | none | spell-out
    rule decl:sym<speak> {:i (speak) ':' <val( rx{ <expr=.expr-speak> }, &?ROUTINE.WHY)> }
    rule expr-speak {:i [ normal | none | spell\-out ] & <keyw> }

    #| speak-header: once | always
    rule decl:sym<speak-header> {:i (speak\-header) ':' <val( rx{ <expr=.expr-speak-header> }, &?ROUTINE.WHY)> }
    rule expr-speak-header {:i [ once | always ] & <keyw> }

    #| speak-numeral: digits | continuous
    rule decl:sym<speak-numeral> {:i (speak\-numeral) ':' <val( rx{ <expr=.expr-speak-numeral> }, &?ROUTINE.WHY)> }
    rule expr-speak-numeral {:i [ digits | continuous ] & <keyw> }

    #| speak-punctuation: code | none
    rule decl:sym<speak-punctuation> {:i (speak\-punctuation) ':' <val( rx{ <expr=.expr-speak-punctuation> }, &?ROUTINE.WHY)> }
    rule expr-speak-punctuation {:i [ code | none ] & <keyw> }

    #| speech-rate: <number> | x-slow | slow | medium | fast | x-fast | faster | slower
    rule decl:sym<speech-rate> {:i (speech\-rate) ':' <val( rx{ <expr=.expr-speech-rate> }, &?ROUTINE.WHY)> }
    rule expr-speech-rate {:i [ <number> | [ x\-slow | slow | medium | fast | x\-fast | faster | slower ] & <keyw> ] }

    #| stress: <number>
    rule decl:sym<stress> {:i (stress) ':' <val( rx{ <expr=.expr-stress> }, &?ROUTINE.WHY)> }
    rule expr-stress {:i <number> }

    #| voice-family: [<specific-voice> | <generic-voice> ]#
    rule decl:sym<voice-family> {:i (voice\-family) ':' <val( rx{ <expr=.expr-voice-family> }, &?ROUTINE.WHY)> }
    rule expr-voice-family {:i [ [ <specific-voice> | <generic-voice> ] ] +% <op(',')> }

    #| volume: <number> | <percentage> | silent | x-soft | soft | medium | loud | x-loud
    rule decl:sym<volume> {:i (volume) ':' <val( rx{ <expr=.expr-volume> }, &?ROUTINE.WHY)> }
    rule expr-volume {:i [ <number> | <percentage> | [ silent | x\-soft | soft | medium | loud | x\-loud ] & <keyw> ] }

    #| border-color: [ <color> | transparent ]{1,4}
    rule decl:sym<border-color> {:i (border\-color) ':' <val( rx{ <expr=.expr-border-color>**1..4 }, &?ROUTINE.WHY)> }
    rule expr-border-color {:i [ [ <color> | transparent & <keyw> ] ] }

    #| border-top-color: <color> | transparent
    rule decl:sym<border-top-color> {:i (border\-top\-color) ':' <val( rx{ <expr=.expr-border-top-color> }, &?ROUTINE.WHY)> }
    rule expr-border-top-color {:i [ <color> | transparent & <keyw> ] }

    #| border-right-color: <color> | transparent
    rule decl:sym<border-right-color> {:i (border\-right\-color) ':' <val( rx{ <expr=.expr-border-right-color> }, &?ROUTINE.WHY)> }
    rule expr-border-right-color {:i [ <color> | transparent & <keyw> ] }

    #| border-bottom-color: <color> | transparent
    rule decl:sym<border-bottom-color> {:i (border\-bottom\-color) ':' <val( rx{ <expr=.expr-border-bottom-color> }, &?ROUTINE.WHY)> }
    rule expr-border-bottom-color {:i [ <color> | transparent & <keyw> ] }

    #| border-left-color: <color> | transparent
    rule decl:sym<border-left-color> {:i (border\-left\-color) ':' <val( rx{ <expr=.expr-border-left-color> }, &?ROUTINE.WHY)> }
    rule expr-border-left-color {:i [ <color> | transparent & <keyw> ] }
}
