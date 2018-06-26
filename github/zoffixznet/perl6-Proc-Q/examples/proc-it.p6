use lib <lib>;
use Proc::Q;

# Run 26 procs; each receiving stuff on STDIN and putting stuff out to STDOUT,
# as well as sleeping for increasingly long periods of time. The timeout
# of 3 seconds will kill all the procs that sleep longer than that.

my @stuff = 'a'..'z';
my $proc-chan = proc-q
             @stuff.map({«perl6 -e "print '$_' ~ \$*IN.slurp; sleep $($++/5)"»}),
  tags    => @stuff.map('Letter ' ~ *),
  in      => @stuff.map(*.uc),
  timeout => 3;

react whenever $proc-chan {
    say "Got a result for {.tag}: STDOUT: {.out}"
        ~ (". Killed due to timeout" if .killed)
}

# OUTPUT:
# Got a result for Letter a: STDOUT: aA
# Got a result for Letter b: STDOUT: bB
# Got a result for Letter c: STDOUT: cC
# Got a result for Letter d: STDOUT: dD
# Got a result for Letter e: STDOUT: eE
# Got a result for Letter f: STDOUT: fF
# Got a result for Letter g: STDOUT: gG
# Got a result for Letter h: STDOUT: hH
# Got a result for Letter i: STDOUT: iI
# Got a result for Letter j: STDOUT: jJ
# Got a result for Letter k: STDOUT: kK
# Got a result for Letter l: STDOUT: lL
# Got a result for Letter m: STDOUT: mM
# Got a result for Letter n: STDOUT: nN
# Got a result for Letter o: STDOUT: oO. Killed due to timeout
# Got a result for Letter p: STDOUT: pP. Killed due to timeout
# Got a result for Letter s: STDOUT: sS. Killed due to timeout
# Got a result for Letter t: STDOUT: tT. Killed due to timeout
# Got a result for Letter v: STDOUT: vV. Killed due to timeout
# Got a result for Letter w: STDOUT: wW. Killed due to timeout
# Got a result for Letter q: STDOUT: qQ. Killed due to timeout
# Got a result for Letter r: STDOUT: rR. Killed due to timeout
# Got a result for Letter u: STDOUT: uU. Killed due to timeout
# Got a result for Letter x: STDOUT: xX. Killed due to timeout
# Got a result for Letter y: STDOUT: yY. Killed due to timeout
# Got a result for Letter z: STDOUT: zZ. Killed due to timeout
