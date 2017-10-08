use v6;
my $VERSION = "0.9";
unit module python::itertools;

=begin pod 

=head1 NAME
python::itertools

=head1 SYNOPSIS

A direct port of Python's itertools to perl6.

=head1 DESCRIPTION

It provides all the functionality that python's itertools does, including lazy evaluation.  In the future, I'd like to maximize the performance of these
functions.  Function signatures may be a little different.

I needed a itertools.combinations_with_replacement and couldn't find an easy builtin or library to do it.  So why not write the library myself? It turns out
perl6 has most of these functions built in already. Unfortunatley, I did not realize that until after writing it. Oops.

=head1 FUNCTIONS

=head2 accumulate(@iterable, $func=&[+])
Gathers accumulated sums, or accumulated results of other binary functions (specified via the optional $func argument). If $func is
supplied, it should be a function of two arguments.

=begin code
accumulate((1,2,3,4,5)) --> (1, 3, 6, 10, 15)
accumulate((1,2,3,4,5), &[*]) --> (1, 2, 6, 24, 120)
=end code

=head2 chain(*@iterables)
Merges all of *@iterables into a single list. 

=begin code
chain(("A","B","C"), ("D","E","F")) --> ("A", "B", "C", "D", "E", "F")
=end code

=head2 count($start is copy, $step=1)
Gathers values from $start, increasing by $step each time. Infinte list.

=begin code
count(10)[^5] --> (10, 11, 12, 13, 14)
count(10, 2)[^5], (10,12,14,16,18);
=end code

=head2 compress(@elements, @selectors)
Returns all members of @elements where the corresponding ?@selector is True.

=begin code
compress(['a','b','c','d'], [True,False,True,False]) -> ['a','c']
=end code

=head2 combinations_with_replacement(@iterable, $r)
Gathers all combinations of length $r from @iterable, allowing elements to repeat.

=begin code
combinations_with_replacement(('a','b','c'), 2) -> (('a','a'), ('a','b'), ('a','c'), ('b','a'), ('b','b'), ('b','c'), ('c','a'), ('c','b'), ('c','c'));
=end code

=head2 chain(@elements, @selectors)
Gathers all items of @elements where it's corresponding Bool in @selectors is True.

=begin code
compress(['a','b','c','d'], [1,1,0,1]) --> ['a','b','d'];
=end code

=head2 dropwhile(@elements, $predicate=Bool)
Shifts @elements until $predicate evaluates to False and gathers remaining elements

=begin code
dropwhile([1,4,6,4,1], {$_ < 5;}) --> [6,4,1];
=end code

=head2 takewhile(@elements, $predicate=Bool)
Gathers items from @elements until $predicate evaluates to False. 

=begin code
takewhile([1,4,6,4,1], {$_ < 5;}) --> [1,4];
=end code

=head2 product(**@iterables, :$repeat=1)
Duplicates each item in @iterables $repeat times and then creates the cartesian product of all items.

=begin code
product([0,1], :repeat(3)) -> ((0,0,0), (0,0,1), (0,1,0), (0,1,1), (1,0,0), (1,0,1), (1,1,0), (1,1,1));
product([0,1], [0,1]) -> ((0,0), (0,1), (1,0), (1,1));
product([0,1], [0,1], :repeat(2)) -> ((0, 0, 0, 0), (0, 0, 0, 1), (0, 0, 1, 0), (0, 0, 1, 1), (0, 1, 0, 0), (0, 1, 0, 1), (0, 1, 1, 0), (0, 1, 1, 1), (1, 0, 0, 0), (1, 0, 0, 1), (1, 0, 1, 0), (1, 0, 1, 1), (1, 1, 0, 0), (1, 1, 0, 1), (1, 1, 1, 0), (1, 1, 1, 1));
=end code

=head2 repeats($obj, Int $times=0)
Gathers $obj $times times or Infintely is $times is 0.

=begin code
repeats("3")[^5] -> [3,3,3,3,3];  
repeats("3",3) -> [3,3,3];  
=end code

=head2 starmap($function, @iterable)
Gathers items where each item in @iterable is computed with $function. Used instead of map when argument parameters are already grouped in tuples from a single iterable (the data has been “pre-zipped"

=begin code
repeats("3")[^5] -> [3,3,3,3,3];  
repeats("3",3) -> [3,3,3];  
=end code

=head2 tee(@iterable, $n)
Gathers $n independent @iterable;

=begin code
repeats("3")[^5] -> [3,3,3,3,3];  
repeats("3",3) -> [3,3,3];  
=end code

=head2 zip_longest(@elements, :$fillvalue=Nil)
zips elements from each of @iterables. If the iterables are of uneven length, fillvalue replaces the missing values.
Iteration continues until the longest iterable is exhausted. 

=begin code
zip_longest((1,2,3,4),(1,2), (-1,-2,-3), :fillvalue("0")) -> ((1,1,-1), (2,2,-2), (3,"0",-3), (4, "0","0"));
=end code
=end pod

sub accumulate(@iterable, $func=&[+]) is export {
    gather {
        my $accumulator = @iterable.first;
        take $accumulator;
        for @iterable[1..*-1] {
            $accumulator = $func($accumulator, $_);
            take $accumulator;
        }
    }
}

sub chain(*@iterables) is export { @iterables }

sub count($start is copy, $step=1) is export { $start, *+$step ... *; }

sub combinations_with_replacement(@iterable, $r) is export { 
    gather { cwr(@iterable, [], $r); }
}

sub cwr(@iterable, @state, $r) {
    my $place = @state.elems;
    @state.push(Nil);
    for @iterable {
        @state[$place] = $_;
        if $r > 1 {
            cwr(@iterable, @state, $r-1);
            @state.pop;
        } else {
            take @state.List;
        }
    }
}

sub compress(@elements, @selectors)  is export {
    gather {
        for zip(@elements, @selectors) -> ($element, $selector) {
            take $element if (?$selector);
        }
    }
}

sub cycle(@elements) is export {
    die "elements must be a list" unless @elements;
    gather {
        while True {
            take $_ for @elements; 
        }
    }
}

sub dropwhile(@elements, $predicate=Bool) is export {
    gather {
        my $index = 0;
        ++$index while $index < @elements.elems and $predicate(@elements[$index]);
        take $_ for @elements[$index..*-1];
    }
}

sub takewhile(@elements, $predicate=Bool) is export {
    gather {
        for @elements {
            last unless $predicate($_);
            take $_;
        }
    }
}

sub groupby(@elements is copy, $key={ $_ }) is export {
    gather {
        my @rest = @elements.Array;
        while ?@rest {
            my $head = $key(@rest.first);
            take (@rest ==> grep { $head eq $key($_)}).List;
            @rest = (@rest ==> grep { $head ne $key($_)});
        }
    }
}


sub product(**@iterables, :$repeat=1) is export {
    die unless $repeat > 0;
    if $repeat > 1 { 
        my @repeated = ();
        @iterables = (@iterables ==> map -> @it {@it xx $repeat} );  
        for @iterables -> @it {
            for @it -> @r { @repeated.push(@r); }
        }
        @iterables = @repeated;
    } 
    gather {
         take $_ for ([X] @iterables);
    }
}

#TODO:for future enhancements of product()
# sub prod(Int $repeat, **@iterables) {
# }

sub repeats($obj, Int $times=0) is export {
    die "times-repeated in repeats must be > -1." unless $times >= 0;
    gather {
        if $times == 0 {
            take $obj while True; 
        } else {
            take $obj for 1..$times;  
        }
    }
}

sub starmap($function, @iterable) is export { @iterable.map({.$function}) }

sub tee(@iterable is copy, Int $n) is export {
    gather { 
        take @iterable for 1..$n;
    }
}

sub zip_longest(**@iterables, :$fillvalue = Nil) is export {
    my $longest = (@iterables ==> map -> @it { @it.elems } ==> max);
    my $index = 0;
    gather {
        while $index < $longest {
            my @result = ();    
            for @iterables -> @it {
                if $index < @it.elems {
                    @result.push(@it[$index]);
                } else {
                    @result.push($fillvalue);
                }
            }
            take @result;
            ++$index;
        }
    }
}

