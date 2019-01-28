use v6;
unit package Email::Address;

use Email::Address::Parser;

role Format {
    method format(--> Str) { ... }
}

module FormatHelpers {
    my sub is-atext($c) { ?Email::Address::RFC5322-Parser.parse($c, :rule<atext>) }

    my sub char-needs-escape($c) {
        $c eq '"' | Q'\' | '\0' | '\t' | '\n' | '\r'
    }

    our proto maybe-escape(|) is export(:maybe-escape) { * }
    multi maybe-escape("", :$quote-dot) { '""' }
    multi maybe-escape($data, :$quote-dot is copy = False) {
        # leading or trailing dot is always quoted
        $quote-dot++ if $data.starts-with('.') || $data.ends-with('.');

        # is quoting needed otherwise?
        my $chars = $data.comb.cache;
        if so $chars.first({ !is-atext($_) && ($quote-dot || $_ ne '.') }) {
            # quote and escape
            if so $chars.first({ char-needs-escape($_) }) {
                qq["{[~] $chars.map({
                    char-needs-escape($_) ?? "\\$_" !! $_
                })}"];
            }

            # only quote
            else {
                qq["$data"];
            }
        }

        # no quote or escape
        else {
            $data;
        }
    }

    our sub has-mime-word($str) is export(:has-mime-word) { $str.contains("=?") }
}

=begin pod

=head1 NAME

Email::Address::Format - helpers for formatting email addresses

=head1 DESCRIPTION

This is some helpers related to formatting email addresses. However, there's really not much hear of interest for outside the library.

=head1 DECLARATIONS

This is the list of classes, roles, and what-not that are provided by this that might be useful outside of the development of C<Email::Address> itself.

=head2 Email::Address::Format

The mailbox, group, and addr-spec classes all implement this role by providing a format method, which returns the clean formatted version of the object. When possible, this will be output according to the latest RFC 5322 spec, but it will fallback to RFC 2822 and RFC 822 compatible email addresses when required.

=head3 method format

    method format(--> Str)

This method is required for all format objects, including mailbox addresses, group addresses, and addr-specs.

=end pod
