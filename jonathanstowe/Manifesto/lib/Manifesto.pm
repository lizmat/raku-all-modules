use v6.c;

=begin pod

=head1 NAME

Manifesto - Make a supply of the results of Promises

=head1 SYNOPSIS

Yet another version of the "sleep sort"

=begin code

use Manifesto;

my $manifesto = Manifesto.new;

for (^10).pick(*).map( -> $i { Promise.in($i + 0.5).then({ $i })}) -> $p {
    $manifesto.add-promise($p);
}

my $channel = Channel.new;

react {
    whenever $manifesto -> $v {
        $channel.send: $v;
    }
    whenever $manifesto.empty {
        $channel.close;
        done;
    }
}

say $channel.list;

=end code

=head1 DESCRIPTION

This manages a collection of Promise objects and provides a Supply
of the result of the kept Promises.

This is useful to aggregate a number of Promises to a single stream
of results, which may then be used in, a C<react> or C<supply> block
or othewise tapped.

=head1 METHODS

=head2 method new

    method new() returns Manifesto

The constructor takes no arguments.

=head2 method Supply

    method Supply() returns Supply

This returns the Supply on which will be emited the results of the
kept managed Promises, (it is named C<Supply> so the Manifesto object
can be 'coerced' into a Supply in for instance a C<whenever>.

=head2 method add-promise

    method add-promise(Promise $promise) returns Bool

This adds a Promise to be managed by this object, it will return True if
the Promise was successfully added, it will not be added if it is not in
state C<Planned>.


=head2 method empty

    method empty() returns Supply

This returns a Supply which will emit an event (with the value of True,)
whenever the list of C<Planned> Promises is exhausted.

=head2 method exception

    method exception() returns Supply

This returns a Supply onto which the exceptions from broken Promises are
emitted.

=head2 method promises

    method promises() returns Array[Promise]

This is a list of the Promises that are yet to be kept, when they are kept
(or broken,) then they will be removed.

=end pod

class Manifesto {
    has Supplier $!supplier;
    has Promise  %!promises;

    has Supplier $!empty;
    has Supplier $!exception;



    submethod BUILD() {
        $!supplier  = Supplier.new;
        $!empty     = Supplier.new;
        $!exception = Supplier.new;
    }

    method Supply() returns Supply {
        $!supplier.Supply;
    }

    method add-promise(Promise() $promise) returns Bool {
        my Bool $rc;
        my $which = $promise.WHICH;
        if  $promise.status ~~ Planned {
            $promise.then(sub ($p ) {
                CATCH {
                    default {
                        $!exception.emit: $_;
                    }
                }
                $!supplier.emit: $p.result;
                $p;
            }).then( {
                %!promises{$which}:delete;
                if %!promises.values.elems == 0 {
                    $!empty.emit: True;
                }
            });
            %!promises{$which} = $promise;
            $rc = True;
        }
        $rc;
    }

    method empty() {
        $!empty.Supply;
    }

    method exception() {
        $!exception.Supply;
    }

    method promises() {
        %!promises.values;
    }
}
# vim: expandtab shiftwidth=4 ft=perl6
