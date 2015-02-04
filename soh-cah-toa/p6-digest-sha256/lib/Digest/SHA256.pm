# Copyright (C) 2011, Kevin Polulak <kpolulak@gmail.com>.

module Digest::SHA256:<soh-cah-toa 0.1>;

=begin Pod

=head1 NAME

Digest::SHA256 - Perl 6 interface to the SHA256 algorithm

=head1 SYNOPSIS

    use v6;
    use Digest::SHA256;

    my $hex = sha256_hex("foobar");
    say $hex;

=head1 DESCRIPTION

The C<Digest::SHA256> module provides a procedural interface to the 256-bit
Secure Hash Algorithm. The algorithm takes a message of arbitrary length as
input and produces a 256-bit message digest as output.

Note that while the Perl 5 C<SHA256> module provides an object-oriented
interface, C<Digest::SHA256> has a procedural interface. This is subject to
change in future versions.

=head1 SUBROUTINES

The following functions are exported by default.

=over 4

=item B<sha256_hex(Str $msg)>, B<sha256_hex(@msg)>

Takes either a scalar of type C<Str> or a list and concatenates all elements.
Calculates the SHA256 digest and returns it in hexadecimal form.

=item B<sha256_sum(Str $msg)>, B<sha256_sum(@msg)>

Returns an Int Array with the resulting SHA256 sum.

=item B<sha256_print(Str $msg)>, B<sha256_sum(@msg)>

Prints the hexadecimal representation of the SHA256 digest og the given string.

=back

=head1 AUTHOR

C<Digest::SHA256> was written by Kevin Polulak (a.k.a. soh_cah_toa).

The SHA256 hash algorithm was designed by the National Security Agency (NSA)
and published by the National Institute of Standards and Technology (NIST).

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011, Kevin Polulak <kpolulak@gmail.com>.

This program is distributed under the terms of the Artistic License 2.0.

For further information, please see LICENSE or visit 
<http://www.perlfoundation.org/attachment/legal/artistic-2_0.txt>.

=end Pod

=cut

pir::load_bytecode('Digest/sha256.pir');

my $PD := Q:PIR { %r = new ['Digest';'SHA256'] };

multi sub sha256_sum(Str $msg) is export {
	my $FIA := $PD.sha_sum($msg);
	my int $elems = pir::set__IP($FIA);
	my Int @list;
	loop (my Int $i = 0; $i < $elems; $i++) {
		my Int $item := nqp::p6box_i(nqp::atpos($FIA, $i));
		@list.push($item);
	}
	return @list;
}

multi sub sha256_sum(@msg) is export {
	return sha256_sum(@msg.join);
}

multi sub sha256_hex(Str $msg) is export {
	sha256_sum($msg);
	return nqp::p6box_s($PD.sha_hex());
}

multi sub sha256_hex(@msg)     is export {
	return sha256_hex(@msg.join);
}

multi sub sha256_print($sum) is export {
	sha256_sum($sum);
	return nqp::p6box_s($PD.sha_print());
}

multi sub sha256_print(@sum)   is export {
	return sha256_print(@sum.join);
}

# vim: ft=perl6

