use v6.c;

our $p_name    is export(:FIELDS);
our @p_aliases is export(:FIELDS);
our $p_proto   is export(:FIELDS);

class Net::protoent:ver<0.0.1>:auth<cpan:ELIZABETH> {
    has Str $.name;
    has     @.aliases;
    has Int $.proto;
}

sub populate(@fields) {
    if @fields {
        Net::protoent.new(
          name    => ($p_name    = @fields[0]),
          aliases => (@p_aliases = @fields[1]),
          proto   => ($p_proto   = @fields[2]),
        )
    }
    else {
          $p_name    = Str;
          @p_aliases = ();
          $p_proto   = Int;
          Nil
    }
}

my sub getprotobyname(Str() $name) is export(:DEFAULT:FIELDS) {
    use P5getprotobyname; populate(getprotobyname($name))
}

my sub getprotobynumber(Int:D $proto) is export(:DEFAULT:FIELDS) {
    use P5getprotobyname; populate(getprotobynumber($proto))
}

my sub getprotoent() is export(:DEFAULT:FIELDS) {
    use P5getprotobyname; populate(getprotoent)
}

my proto sub getproto(|) is export(:DEFAULT:FIELDS) {*}
my multi sub getproto(Int:D $proto) is export(:DEFAULT:FIELDS) {
    getprotobynumber($proto)
}
my multi sub getproto(Str:D $nam) is export(:DEFAULT:FIELDS) {
    getprotobyname($nam)
}

my constant &setprotoent is export(:DEFAULT:FIELDS) = do {
    use P5getprotobyname; &setprotoent
}
my constant &endprotoent is export(:DEFAULT:FIELDS) = do {
    use P5getprotobyname; &endprotoent
}

=begin pod

=head1 NAME

Net::protoent - Port of Perl 5's Net::protoent

=head1 SYNOPSIS

    use Net::protoent;
    my $p = getprotobyname('tcp') || die "no proto";
    printf "proto for %s is %d, aliases are %s\n",
       $p.name, $p.proto, "$p.aliases()";
     
    use Net::protoent qw(:FIELDS);
    getprotobyname('tcp')         || die "no proto";
    print "proto for $p_name is $p_proto, aliases are @p_aliases\n";

=head1 DESCRIPTION

This module's exports C<getprotobyname>, C<getprotobynumber>, and
C<getprotoent> functions that return C<Netr::protoent> objects. This object
has methods that return the similarly named structure field name from the
C's protoent structure from netdb.h, stripped of their leading "p_" parts,
namely name, aliases, and proto.

You may also import all the structure fields directly into your namespace as
regular variables using the :FIELDS import tag.  Access these fields as
variables named with a preceding p_ in front their method names. Thus,
$proto_obj.name corresponds to $p_name if you import the fields.

The C<getproto> function is a simple front-end that forwards a numeric
argument to C<getprotobynumber> and the rest to C<getprotobyname>.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Net-protoent . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: ft=perl6 expandtab sw=4
