use v6;
use Test;

use Term::Choose;


my @unsigned_int = <default pad>;

my @inval_u_int = 'hello', -1, ( 2, 4, 6 ), 3.4;
for @unsigned_int -> $key {
    for @inval_u_int -> $value {
        my $p = Pair.new($key, $value);
        dies-ok { my $n = Term::Choose.new( |$p ) }, "invalid value $value for option $key dies ok";
    }
}

my @val_u_int = 0, 2, 17, 1000;
for @unsigned_int -> $key {
    for @val_u_int -> $value {
        my $p = Pair.new($key, $value);
        lives-ok { my $n = Term::Choose.new( |$p ) }, "valid value $value for option $key lives ok";
    }
}



my @positive_int = <keep ll max-height>;

my @inval_p_int = 0, |@inval_u_int;
for @positive_int -> $key {
    for @inval_p_int -> $value {
        my $p = Pair.new($key, $value);
        dies-ok { my $n = Term::Choose.new( |$p ) }, "invalid value $value for option $key dies ok";
    }
}

my @val_p_int = 1, 2, 17, 1000;
for @positive_int -> $key {
    for @val_p_int -> $value {
        my $p = Pair.new($key, $value);
        lives-ok { my $n = Term::Choose.new( |$p ) }, "invalid value $value for option $key lives ok";
    }
}



my @ge_2_int = <max-width>;

my @inval_ge_2 = 1, |@inval_p_int;
for @ge_2_int -> $key {
    for @inval_ge_2 -> $value {
        my $p = Pair.new($key, $value);
        dies-ok { my $n = Term::Choose.new( |$p ) }, "invalid value $value for option $key dies ok";
    }
}

my @val_ge_2 = 2, 17, 1000;
for @ge_2_int -> $key {
    for @val_ge_2 -> $value {
        my $p = Pair.new($key, $value);
        lives-ok { my $n = Term::Choose.new( |$p ) }, "invalid value $value for option $key lives ok";
    }
}




my @int_0_2 = <justify layout>;

my @inval_int_0_2 = 3, |@inval_u_int;
for @int_0_2 -> $key {
    for @inval_int_0_2 -> $value {
        my $p = Pair.new($key, $value);
        dies-ok { my $n = Term::Choose.new( |$p ) }, "invalid value $value for option $key dies ok";
    }
}

my @val_int_0_2 = 0, 1, 2;
for @int_0_2 -> $key {
    for @val_int_0_2 -> $value {
        my $p = Pair.new($key, $value);
        lives-ok { my $n = Term::Choose.new( |$p ) }, "invalid value $value for option $key lives ok";
    }
}




my @int_0_1 = <beep index mouse order page>;

my @inval_int_0_1 = 2, 3, |@inval_u_int;
for @int_0_1 -> $key {
    for @inval_int_0_1 -> $value {
        my $p = Pair.new($key, $value);
        dies-ok { my $n = Term::Choose.new( |$p ) }, "invalid value $value for option $key dies ok";
    }
}

my @val_int_0_1 = 0, 1;
for @int_0_1 -> $key {
    for @val_int_0_1 -> $value {
        my $p = Pair.new($key, $value);
        lives-ok { my $n = Term::Choose.new( |$p ) }, "invalid value $value for option $key lives ok";
    }
}



my @string = <prompt empty undef>;

my @inval_str = 2, 3, -3, 6.6, [];
for @string -> $key {
    for @inval_str -> $value {
        my $p = Pair.new($key, $value);
        dies-ok { my $n = Term::Choose.new( |$p ) }, "invalid value $value for option $key dies ok";
    }
}

my @val_str = <prompt Hello €@>;
for @string -> $key {
    for @val_str -> $value {
        my $p = Pair.new($key, $value);
        lives-ok { my $n = Term::Choose.new( |$p ) }, "invalid value $value for option $key lives ok";
    }
}




my @list = <lf mark no-spacebar>;

my @inval_list = 2, 3, -3, 6.6, 'hello';
for @list -> $key {
    for @inval_list -> $value {
        my $p = Pair.new($key, $value);
        dies-ok { my $n = Term::Choose.new( |$p ) }, "invalid value $value for option $key dies ok";
    }
}

my @temp = 7 .. 11;
my @val_list = ( 1, 2, 3 ), [ 4, 5, 6 ], @temp;
for @list -> $key {
    for @val_list -> $value {
        my $p = Pair.new($key, $value);
        lives-ok { my $n = Term::Choose.new( |$p ) }, "invalid value $value for option $key lives ok";
    }
}






done-testing();
