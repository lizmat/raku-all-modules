use v6;

use Amazon::DynamoDB::UA;
use Cro::HTTP::Client;

# EXPERIMENTAL API! I am not documenting this officially yet, but I want the
# ability to let a custom UA be used instead. It must implement this interface
# to work.
class Amazon::DynamoDB::UA::Cro does Amazon::DynamoDB::UA {
    has $.client is rw;

    only method new(Cro::HTTP::Client $client? is copy) {
        $client //= Cro::HTTP::Client.new;
        self.bless(:$client);
    }

    method request(:$method, :$uri, :%headers, :$content --> Promise) {
        start {
            my $result;

            try {
                $result = await $!client.request($method, $uri, :%headers, body => $content);

                CATCH {
                    when X::Cro::HTTP::Error::Client {
                        $result = .response;
                    }
                }
            }

            given $result {
                my $raw = .body-blob;
                my $txt = $raw.then({ .result.decode('UTF-8') });

                %(
                    Status         => .status,
                    Header         => % = .headers.map({
                        .name.lc => .value
                    }),
                    RawContent     => $raw,
                    DecodedContent => $txt,
                );
            }
        }
    }
}
