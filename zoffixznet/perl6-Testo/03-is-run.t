use lib <lib>;
use Testo;

plan 1;

is-run $*EXECUTABLE, :in<hi!>, :args['-e', 'say $*IN.uc'],
    :out(/'HI!'/), :err(''), :0status, 'can say hi';
