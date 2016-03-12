unit class Inline::Scheme::Gambit;

use NativeCall;

sub native(Sub $sub) {
    my Str $path = %?RESOURCES<libraries/gambithelper>.Str;
    unless $path {
        die "unable to find gambithelper library";
    }
    trait_mod:<is>($sub, :native($path));
}

sub gambit_init()
    { ... }
    native(&gambit_init);

sub gambit_cleanup()
    { ... }
    native(&gambit_cleanup);

sub gambit_eval(Str)
    returns OpaquePointer { ... }
    native(&gambit_eval);

sub gambit_apply(OpaquePointer, OpaquePointer)
    returns OpaquePointer { ... }
    native(&gambit_apply);

sub gambit_null()
    returns OpaquePointer { ... }
    native(&gambit_null);

sub gambit_string_check(OpaquePointer) 
    returns bool { ... }
    native(&gambit_string_check);

sub gambit_rational_check(OpaquePointer) 
    returns bool { ... }
    native(&gambit_rational_check);

sub gambit_complex_check(OpaquePointer) 
    returns bool { ... }
    native(&gambit_complex_check);

sub gambit_exact_check(OpaquePointer) 
    returns bool { ... }
    native(&gambit_exact_check);

sub gambit_number_check(OpaquePointer) 
    returns bool { ... }
    native(&gambit_number_check);

sub gambit_boolean_check(OpaquePointer) 
    returns bool { ... }
    native(&gambit_boolean_check);

sub gambit_integer_check(OpaquePointer) 
    returns bool { ... }
    native(&gambit_integer_check);

sub gambit_list_check(OpaquePointer) 
    returns bool { ... }
    native(&gambit_list_check);

sub gambit_vector_check(OpaquePointer) 
    returns bool { ... }
    native(&gambit_vector_check);

sub gambit_table_check(OpaquePointer) 
    returns bool { ... }
    native(&gambit_table_check);

sub gambit_pair_check(OpaquePointer) 
    returns bool { ... }
    native(&gambit_pair_check);

sub gambit_exception_wrapper_check(OpaquePointer) 
    returns bool { ... }
    native(&gambit_exception_wrapper_check);

sub gambit_exception_wrapper_display(OpaquePointer) 
    returns Str { ... }
    native(&gambit_exception_wrapper_display);


sub gambit_cons(OpaquePointer, OpaquePointer) 
    returns OpaquePointer { ... }
    native(&gambit_cons);

sub gambit_car(OpaquePointer) 
    returns OpaquePointer { ... }
    native(&gambit_car);

sub gambit_cdr(OpaquePointer) 
    returns OpaquePointer { ... }
    native(&gambit_cdr);


sub gambit_integer_as_long(OpaquePointer)
    returns long { ... }
    native(&gambit_integer_as_long);

sub gambit_number_as_double(OpaquePointer)
    returns num64 { ... }
    native(&gambit_number_as_double);

sub gambit_string_as_string(OpaquePointer)
    returns Str { ... }
    native(&gambit_string_as_string);

sub gambit_boolean_as_bool(OpaquePointer)
    returns bool { ... }
    native(&gambit_boolean_as_bool);

sub gambit_vector_length(OpaquePointer)
    returns long { ... }
    native(&gambit_vector_length);

sub gambit_vector_ref(OpaquePointer, long)
    returns OpaquePointer { ... }
    native(&gambit_vector_ref);

sub gambit_make_table()
    returns OpaquePointer { ... }
    native(&gambit_make_table);

sub gambit_table_set(OpaquePointer, OpaquePointer, OpaquePointer)
    { ... }
    native(&gambit_table_set);

sub gambit_table_to_list(OpaquePointer)
    returns OpaquePointer { ... }
    native(&gambit_table_to_list);

sub gambit_list_to_vector(OpaquePointer)
    returns OpaquePointer { ... }
    native(&gambit_list_to_vector);

sub gambit_boolean_to_scheme(long)
    returns OpaquePointer { ... }
    native(&gambit_boolean_to_scheme);

sub gambit_integer_to_scheme(long)
    returns OpaquePointer { ... }
    native(&gambit_integer_to_scheme);

sub gambit_number_to_scheme(num64)
    returns OpaquePointer { ... }
    native(&gambit_number_to_scheme);

sub gambit_string_to_scheme(Str)
    returns OpaquePointer { ... }
    native(&gambit_string_to_scheme);


method gambit_pair_as_pair(OpaquePointer $gambit_pair) {
    my $key = self.gambit_to_p6(gambit_car($gambit_pair));
    my $val = self.gambit_to_p6(gambit_cdr($gambit_pair));
    return ($key => $val);
}

method gambit_vector_as_array(OpaquePointer $gambit_vec) {
    my $array = [];
    my $len = gambit_vector_length($gambit_vec);
    for 0..^$len {
        my $item = gambit_vector_ref($gambit_vec, $_);
        $array[$_] = self.gambit_to_p6($item);
    }
    return $array;
}

method gambit_rational_as_rat(OpaquePointer $gambit_val) {
    my $denom = self.call("denominator", $gambit_val);
    my $num = self.call("numerator", $gambit_val);
    return Rat.new($num, $denom);
}

method gambit_number_as_complex(OpaquePointer $gambit_val) {
    my $re = self.call("real-part", $gambit_val);
    my $im = self.call("imag-part", $gambit_val);
    return Complex.new($re, $im);
}

method gambit_list_as_array(OpaquePointer $gambit_lst) {
    return self.gambit_vector_as_array(gambit_list_to_vector($gambit_lst));
}

method gambit_table_as_hash(OpaquePointer $table) {
    my %hash;
    my $assoc_lst = self.gambit_list_as_array(gambit_table_to_list($table));
    %hash = $assoc_lst;
    return %hash;
}

method gambit_to_p6(OpaquePointer $value) {

    if gambit_boolean_check($value) {
        return gambit_boolean_as_bool($value).Bool;
    }
    elsif (gambit_number_check($value)) {
        if (gambit_rational_check($value)) {
            if gambit_exact_check($value) {
                if gambit_integer_check($value) {
                    return gambit_integer_as_long($value);
                } else {
                    return self.gambit_rational_as_rat($value);
                }
            } else {
                return gambit_number_as_double($value);
            }
        } else {
            return self.gambit_number_as_complex($value);
        }
    }
    elsif (gambit_string_check($value)) {
        return gambit_string_as_string($value);
    }
    elsif (gambit_list_check($value)) {
        return self.gambit_list_as_array($value);
    }
    elsif (gambit_vector_check($value)) {
        return self.gambit_vector_as_array($value);
    }
    elsif (gambit_pair_check($value)) {
        return self.gambit_pair_as_pair($value);
    }
    elsif (gambit_table_check($value)) {
        return self.gambit_table_as_hash($value);
    }
    else {
        return $value;
    }
}

multi method p6_to_gambit(Bool:D $value) returns OpaquePointer {
    gambit_boolean_to_scheme($value);
}

multi method p6_to_gambit(Int:D $value) returns OpaquePointer {
    gambit_integer_to_scheme($value);
}

multi method p6_to_gambit(Rat:D $value) returns OpaquePointer {
    gambit_apply(self.p6_to_gambit("/"),
            self.p6_to_gambit([$value.numerator, $value.denominator]));
}

multi method p6_to_gambit(Num:D $value) returns OpaquePointer {
    gambit_number_to_scheme($value);
}

multi method p6_to_gambit(Complex:D $value) returns OpaquePointer {
    gambit_apply(self.p6_to_gambit("make-rectangular"),
            self.p6_to_gambit([$value.re, $value.im]));
}

multi method p6_to_gambit(Stringy:D $value) returns OpaquePointer {
    gambit_string_to_scheme($value);
}

multi method p6_to_gambit(Positional:D $value) returns OpaquePointer {
    my $lst = gambit_null();
    for @$value.reverse -> $item {
        my $gambit_item = self.p6_to_gambit($item);
        $lst = gambit_cons($gambit_item, $lst);
    }
    return $lst;
}

multi method p6_to_gambit(Associative:D $value) returns OpaquePointer {
    my $table = gambit_make_table();
    for %$value -> $item {
        gambit_table_set($table,
            self.p6_to_gambit($item.key), self.p6_to_gambit($item.value));
    }
    return $table;
}

multi method p6_to_gambit(OpaquePointer:D $value) returns OpaquePointer {
    return $value;
}

multi method p6_to_gambit(Any:U $value) returns OpaquePointer {
    return gambit_null();
}

multi method handle_exception(OpaquePointer:D $res) {
    if (gambit_exception_wrapper_check($res)) {
        die gambit_exception_wrapper_display($res);
    }
}

multi method handle_exception(Any:U $res) {
    ;
}

method run(Str:D $code, **@args) {
    my $res = gambit_eval($code);
    self.handle_exception($res);
    return self.gambit_to_p6($res);
}

multi method call(Str:D $funcname, **@args) {
    my $func = self.p6_to_gambit($funcname);
    return self.call($func, |@args);
}

multi method call(OpaquePointer:D $gambit_func, **@args) {
    my $gambit_args = self.p6_to_gambit(@args);
    my $res = gambit_apply($gambit_func, $gambit_args);
    self.handle_exception($res);
    return self.gambit_to_p6($res);
}


my $initialized = False;

method BUILD {
    unless ($initialized) {
        gambit_init();
        $initialized = True;
    }
}

method END {
    if ($initialized) {
        gambit_cleanup();
    }
}

