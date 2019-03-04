use v6;

unit module Cofra::IOC;

my role Factory[&factory] {
    method compose(Mu $package) {
        callsame;

        my $attribute = self;
        if $attribute.has_accessor {

            my $name = self.name.substr(2);
            $package.^method_table.{$name}.wrap(
                method () {
                    # TODO It would be nice if we had a guarantee that this
                    # just ran once per object. As far as I know, though,
                    # there's no means for creating weak references or
                    # something like Java's WeakHashRef, which feels
                    # necessary to do that in a way that won't leak memory.
                    without $attribute.get_value(self) {
                        $attribute.set_value(
                            self,
                            self.&factory(
                                :$attribute,
                                :$name,
                            )
                        );
                    }

                    callsame;
                }
            );
        }

    }
}

# This is basically a poor person's IOC helper. It's not good but it will serve
# my purposes as an MVP solution in the short term.
multi trait_mod:<is> (Attribute $a, :$factory!) is export {
    $a does Factory[$factory];
}

=begin pod

=head1 NAME

Cofra::IOC - the inversion of control part

=head1 SYNOPSIS

    unit class MyApp::Bodge;

    use Cofra::IOC;
    use DB-Connector-Thingy;

    has Str $.database is required;

    has DB-Connector-Thingy $.dbh is factory(method () {
        DB-Connector-Thingy.new(:$.database);
    });

=head1 DESCRIPTION

This class module is clearly fake news. It provides a facility for aiding the use of inversion of control through lazy initialization. However, it does nto really provide IOC.

Someday, this may do that. Today, it is definitely faking.

=end pod
