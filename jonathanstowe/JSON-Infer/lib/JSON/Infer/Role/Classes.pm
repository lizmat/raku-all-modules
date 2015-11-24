
use v6;

=begin pod

=head1 NAME

JSON::Infer::Role::Classes

=head1 DESCRIPTION

=head2 METHODS


=head3 classes

=head3 add-classes

This takes and object of this role and adds it's classes to my classes.

=end pod

role JSON::Infer::Role::Classes {


    has @.classes is rw;

    method  add-classes(Mu:D $object) {

        if $object.does($?ROLE) {
            for $object.classes -> $class {
                if !?@!classes.grep({$class.name eq $_.name}) {
                    @!classes.push($class);
                }
            }
        }

        if  $object ~~ ::('JSON::Infer::Class') {
            @!classes.push($object);
        }
    }
}
# vim: expandtab shiftwidth=4 ft=perl6
