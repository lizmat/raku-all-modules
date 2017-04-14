use v6.c;

=head1 Log::Any::Definitions
=head2 %Log::Any::Definitions::SEVERITIES
=para These are the default severities known by Log::Any.

package Log::Any::Definitions {
	our constant %SEVERITIES = Hash.new: <trace debug info notice warning error critical alert emergency> Z=> 1 .. +Inf;
}
