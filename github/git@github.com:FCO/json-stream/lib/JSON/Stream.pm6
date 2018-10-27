=begin pod

=head1 JSON::Stream

A JSON stream parser

	react whenever json-stream "a-big-json-file.json".IO.Supply, [["\$", "employees", *],] -> (:$key, :$value) {
	   say "[$key => $value.perl()]"
	}

=head2 Warning

It doesn't validate the json. If the json isn't valid, it may have unusual behavior.

=end pod

use JSON::Fast;
use JSON::Stream::Type;
use JSON::Stream::Parse;

constant @stop-words = '{', '}', '[', ']', '"', ':', ',';

sub json-stream(Supply $supply, @subscribed) is export {
    my Parser $state .= new: :@subscribed;
    supply {
        my @rest;
        whenever $supply -> $chunk {
            my @chunks = $chunk.comb: /'[' | ']' | '{' | '}' | <!after \\> '"' | ':' | ',' | [<-[[\]{}":,]> | <after \\> '"']+/;
            @chunks .= grep: * !~~ /^\s+$/;
            if @rest and @chunks.head ~~ @stop-words.none {
                @rest.tail ~= @chunks.shift;
            }
            my @new-chunks = |@rest, |@chunks;
            @rest = ();
            @rest.unshift: @new-chunks.pop while @new-chunks and @new-chunks.tail ~~ @stop-words.none;
            $state.parse: $_ for @new-chunks;
			LAST $state.parse: $_ for @rest;
        }
    }
}
