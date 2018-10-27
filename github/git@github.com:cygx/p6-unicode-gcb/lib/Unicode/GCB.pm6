# Copyright 2016 cygx <cygx@cpan.org>
# Distributed under the Boost Software License, Version 1.0

use nqp;

my class GCB is export {
    my constant CODE = nqp::unipropcode('gcb');

    sub prop(\name) { nqp::unipvalcode(CODE, name) }
    sub getprop(\cp) { nqp::getuniprop_int(cp, CODE) }

    my enum _ (
        Other               => prop('Other'),
        Control             => prop('Control'),
        CR                  => prop('CR'),
        LF                  => prop('LF'),
        L                   => prop('L'),
        V                   => prop('V'),
        T                   => prop('T'),
        LV                  => prop('LV'),
        LVT                 => prop('LVT'),
        Prepend             => prop('Prepend'),
        Extend              => prop('Extend'),
        SpacingMark         => prop('SpacingMark'),
        ZWJ                 => prop('ZWJ'),
        Glue_After_Zwj      => prop('Glue_After_Zwj'),
        E_Base              => prop('E_Base'),
        E_Base_GAZ          => prop('E_Base_GAZ'),
        E_Modifier          => prop('E_Modifier'),
        Regional_Indicator  => prop('Regional_Indicator'),
    );

    my constant COUNT = +_::;

    sub idx(\a, \b) { a * COUNT + b }

    my constant ALWAYS = (for ^COUNT -> \a {
        slip (for ^COUNT -> \b {
            given \(a, b) {
                when :($ where CR,
                       $ where LF) { False }

                when :($ where Control|CR|LF,
                       $) { True }

                when :($,
                       $ where Control|CR|LF) { True }

                when :($ where L,
                       $ where L|V|LV|LVT) { False }

                when :($ where LV|V,
                       $ where V|T) { False }

                when :($ where LVT|T,
                       $ where T) { False }

                when :($,
                       $ where Extend|ZWJ) { False }

                when :($,
                       $ where SpacingMark) { False }

                when :($ where Prepend,
                       $) { False }

                when :($ where E_Base|E_Base_GAZ|Extend,
                       $ where E_Modifier) { False }

                when :($ where ZWJ,
                       $ where Glue_After_Zwj|E_Base_GAZ) { False }

                when :($ where Regional_Indicator,
                       $ where Regional_Indicator) { False }

                default { True }
            }
        });
    });

    my constant MAYBE = do given [ALWAYS] {
        .[idx Extend, E_Modifier] = True;
        .[idx Regional_Indicator, Regional_Indicator] = True;
        list |$_;
    }

    method always(uint32 \a, uint32 \b) { ALWAYS[idx getprop(a), getprop(b)] }
    method maybe(uint32 \a, uint32 \b) { MAYBE[idx getprop(a), getprop(b)] }

    proto method clusters(|) {*}
    multi method clusters(Uni \uni where uni.elems < 2) { uni }
    multi method clusters(Uni \uni) {
        my $emoji = False;
        my $regio = False;
        my int $i = 0;
        my int $j = 0;
        gather {
            while ($j = $j + 1) < uni.elems {
                my \pa = getprop(uni[$j-1]);
                my \pb = getprop(uni[$j]);
                if ALWAYS[idx pa, pb]
                        || (!$emoji && pa == Extend && pb == E_Modifier)
                        || ( $regio && pa == pb == Regional_Indicator) {
                    take Uni.new(uni[$i..^$j]);
                    $i = $j;
                    $emoji = False;
                    $regio = False;
                }
                else {
                    $emoji = True if pa == E_Base|E_Base_GAZ;
                    $regio = True if pa == pb == Regional_Indicator;
                }
            }
            take Uni.new(uni[$i..^$j]);
        }
    }
}
