#!/usr/bin/perl6

use v6;

unit module Coro::Simple;

# receives a simple block / pointy block
sub coro (&block) is export {
    # returns a closure as constructor that receives many arguments
    return sub (*@params) {
        # bind &block at @yields for further lookups and flat the arguments
        my @yields := gather block |@params;
        my $index   = 0; # array "pointer"
        # that will returns another closure as generator
        return sub ( ) {
            my $result;
            # increase 'index' "pointer" to next, after
            if defined @yields[ $index++ ] {
                $result = @yields[ $index - 1 ];
            }
            # otherwise, if the coroutine is dead
            else {
        	$index -= 1; # disallow other lookups
                $result = False; # I just don't like <null> :P
            }
            return $result; # returns some value or just a dead status <false>
        }
    }
}

# an alias for { take $value }.
sub yield ($value) is export { take $value }

# an alias for { take True }.
sub suspend( ) is export { take True }

# to check if generated value was "yielded" (instead just False)
sub ensure (&block, $value) is export {
    # is False?
    if ($value ~~ Bool) && (!$value) {
        return block; # so, executes the &block
    }
    return $value; # otherwise
}

# deprecated function
sub assert (&block, $value) is export {
    warn "[ Deprecated function ]\n" ~
        "This function will be removed in a future version. Please use 'ensure' instead.";
    return ensure &block, $value;
}

# receives a generator and returns a lazy array
sub from (&generator) is export {
    my $temp = generator; # obtains the first value
    # eval-by-need trick
    return gather {
        # request more a value until it becomes False
        while ($temp !~~ Bool) || (?$temp) {
            take $temp; # <yield>
            $temp = generator; # asks a new value
        }
    }; # you can bind it to an external array when calling the 'from' function
}

# end of module
