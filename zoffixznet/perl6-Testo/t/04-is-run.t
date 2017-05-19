use lib <lib>;
use Testo;

plan 1;

is-run $*EXECUTABLE, :in<hi!>, :args['-e', 'say $*IN.get.uc'],
    :out(/'HI!'/), :err(''), :42exitcode, 'can say hi';
