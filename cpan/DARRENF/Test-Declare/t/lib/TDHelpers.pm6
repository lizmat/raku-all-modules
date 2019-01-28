use v6.c;

class T::Mutation {
    method increment-all(Array $arr) {
        $arr.map: *++;
        return;
    }
}

class T::Math {
    has Int $.num;

    method multiply(Int $a) returns Int {
        return $!num * $a; 
    }

    method as-word returns Str {
        my %words = 
            1 => 'one',
            2 => 'two',
            3 => 'three',
        ;
        return %words{$!num};
    }

    method speak {
        say self.as-word();
    }

    method add(Cool :$adder) returns Cool {
        return $!num+$adder;
    }

    method stern {
        note self.as-word();
    }
}

class T::Complex {
    method generate-complex(Int $i) returns T::Math {
        return T::Math.new(num => $i);
    }
}


class T::NoConstruct {
    has Int $.num is rw;

    method blurt() {
        if $!num {
            say 'GOT NUM: ' ~ $!num;
        }
        else {
            say 'NO NUM';
        }
    }
}
