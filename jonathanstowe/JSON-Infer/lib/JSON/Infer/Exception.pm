use v6;


=begin pod

=head1 NAME

JSON::Infer::Exception

=head1 DESCRIPTION

Generalised exception class

=head2 METHODS


=end pod

class JSON::Infer::Exception is Exception {
   has Str $.message is rw;
   has Str $.uri is rw;
   has Exception $.inner-exception is rw;
}
# vim: expandtab shiftwidth=4 ft=perl6
