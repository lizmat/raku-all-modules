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
use JSON::Stream::State;
use JSON::Stream::Parse;

#constant @stop-words = '{', '}', '[', ']', '"', ':', ',';

sub json-stream(Supply $supply, @subscribed) is export {
    my $s1 = supply {
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
            .emit for @new-chunks;
			LAST .emit for @rest;
        }
    }
    my $s2 = supply {
        my State $state .= new: :@subscribed;
        whenever $s1 -> $chunk {
			#dd $state.cache;
            $state = parse $state, $chunk;
        }
    }
    supply {
        whenever $s2 -> (:$key, :$value) {
			#say $value;
			emit $key => from-json $value
        }
    }
}
