use lib <lib>;
use Testo;

plan 5;

is 1, 1;

group 'group of tests' => 4 => {
    is 2, 2;
    is 3, 3;
    is 4, 4;
    is 5, 5;
}

group 'group of tests with manual plan' => {
    plan 4;
    is 2, 2;
    is 3, 3;
    is 4, 4;
    is 5, 5;
}

group 'group of tests' => 4 => {
    is 2, 2;
    is 3, 3;
    is 4, 4;
    group 'group of tests' => 4 => {
        is 2, 2;
        is 3, 3;
        is 4, 4;
        group 'group of tests' => {
            plan 4;
            is 2, 2;
            is 3, 3;
            is 4, 4;
            group 'group of tests' => 4 => {
                is 2, 2;
                is 3, 3;
                is 4, 4;
                is 5, 5;
            }
        }
    }
}

group 'group of tests' => {
    plan 4;
    is 2, 2;
    is 3, 3;
    is 4, 4;
    group 'group of tests' => 4 => {
        is 2, 2;
        is 3, 3;
        is 4, 4;
        group 'group of tests' => {
            plan 4;
            is 2, 2;
            is 3, 3;
            is 4, 4;
            group 'group of tests' => 4 => {
                is 2, 2;
                is 3, 3;
                is 4, 4;
                is 5, 5;
            }
        }
    }
}
