use nqp;

sub EXPORT {
    $*W.do_pragma(Match.new, 'MONKEY', 1, []);
    Map.new: '&b' => &b
}

my &colored = sub {
    return sub (Str $s, $) { $s } if Nil === try require Terminal::ANSIColor;
    ::('Terminal::ANSIColor::EXPORT::DEFAULT::&colored')
}();

sub b (int $full-n, &old, &new, &bare = { $ = $ }, :$silent) {
    my int $n = floor ½ × $full-n;
    my int $i;
    my Instant $now;
    my %times;

    $i = -1; $now = now;
    nqp::until(nqp::islt_i($n, $i = nqp::add_i($i, 1)), bare, :nohandler);
    %times<bare> = now - $now;

    $i = -1; $now = now;
    nqp::until(nqp::islt_i($n, $i = nqp::add_i($i, 1)), old, :nohandler);
    %times<old> = now - $now;

    $i = -1; $now = now;
    nqp::until(nqp::islt_i($n, $i = nqp::add_i($i, 1)), new, :nohandler);
    %times<new> = now - $now;

    $i = -1; $now = now;
    nqp::until(nqp::islt_i($n, $i = nqp::add_i($i, 1)), bare, :nohandler);
    %times<bare> += now - $now;

    $i = -1; $now = now;
    nqp::until(nqp::islt_i($n, $i = nqp::add_i($i, 1)), new, :nohandler);
    %times<new> += now - $now;

    $i = -1; $now = now;
    nqp::until(nqp::islt_i($n, $i = nqp::add_i($i, 1)), old, :nohandler);
    %times<old> += now - $now;

    with %times {
      .<bare> max= 0;
      .<new> -= .<bare>;
      .<old> -= .<bare>;
      .<new> max= 0;
      .<old> max= 0;
    }

    unless $silent {
        say "Bare: %times<bare>s";
        say "Old:  %times<old>s";
        say "New:  %times<new>s";

        sub dif {
            my $d = [/] @_;
            $d >= 2 ?? sprintf('%.2fx', $d)
                    !! ($d = Int(100*($d-1)))
                        ?? sprintf('%d%%', $d)
                        !! 'slightly (<1%)'
        }
        say (.<old>/.<new> > 1)
            ?? colored("NEW version is {dif .<old new>} faster", 'green')
            !! colored("OLD version is {dif .<new old>} faster", 'red'  )
        with %times
    }

    %times;
}
