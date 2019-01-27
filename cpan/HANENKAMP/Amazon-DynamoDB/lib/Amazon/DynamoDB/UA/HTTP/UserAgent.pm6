use v6;

use Amazon::DynamoDB::UA;
use HTTP::Request::Common;
use HTTP::UserAgent;

# EXPERIMENTAL API! I am not documenting this officially yet, but I want the
# ability to let a custom UA be used instead. It must implement this interface
# to work.
class Amazon::DynamoDB::UA::HTTP::UserAgent does Amazon::DynamoDB::UA {
    has $.ua is rw;

    only method new(HTTP::UserAgent $ua? is copy) {
        quietly $ua //= HTTP::UserAgent.new(
            :useragent("perl6-$?PACKAGE.^name()/$?PACKAGE.^ver()"),
        );
        self.bless(:$ua);
    }

    method request(:$method, :$uri, :%headers, :$content --> Promise) {

        start {
            my $req = POST($uri, |%headers, :$content);
            my $res = $!ua.request($req, :bin);

            my $raw = Promise.new;
            $raw.keep($res.content);

            my $dec = Promise.new;
            $dec.keep($res.decoded-content);

            %(
                Status         => $res.code,
                Header         => % = $res.header.hash.map({
                    .key.lc => .value.join(', ')
                }),
                RawContent     => $raw,
                DecodedContent => $dec,
            );
        }
    }
}
