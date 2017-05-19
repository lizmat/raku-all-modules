use lib <lib>;
use Testo;

plan 2;
is 1, 1;
group 'group of tests' => 4 => {
    is 2, 2;
    is 3, 3;
    is 4, 4;
    is 5, 5;
}
