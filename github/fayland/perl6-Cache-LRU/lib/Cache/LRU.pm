use v6;

class Cache::LRU {

    my class Entry {
        has $.value;
        has $!ref = 1;
        has Bool $.expired = False;
        method touch() { $!ref++ }
        method release() { $!expired = (--$!ref) == 0 }
        method expires() { $!expired = True; $!ref = 0; }

    }

    has Int $.size = 1024;
    has %!entries;
    has @!fifo;

    constant GC_FACTOR = 10;

    method set(Cache::LRU:D: $key, $value --> Mu) {
        if $key ~~ %!entries {
            my $old = %!entries{$key}:delete;
            $old.expires();
        }

        my $entry = Entry.new( :$value );
        %!entries{$key} = $entry;
        self!update_fifo( $key, $entry );
        # expire the oldest entry if full
        while %!entries.elems > $!size {
            my $exp_key = @!fifo.shift;
            next if $exp_key[1].expired;
            $exp_key[1].release();
            if %!entries{$exp_key[0]} && %!entries{$exp_key[0]}.expired {
                %!entries{$exp_key[0]}:delete;
            }
        }

        $value;
    }

    method !update_fifo( $key, $entry ) {
        # precondition: %!entries should contain given key
        @!fifo.push( ($key, $entry) );

        if @!fifo.elems >= $.size * GC_FACTOR {
            my %need = %!entries.keys X=> 1;
            @!fifo .= grep( { %need{$_.[0]}:delete } );
        }
    }

    method get($key) {
        return if $key !~~ %!entries;
        my $entry = %!entries{$key};
        $entry.touch();
        self!update_fifo( $key, $entry );
        $entry.value;
    }

    method remove($key) {
        return unless $key ~~ %!entries;
        my $entry = %!entries{$key}:delete;
        $entry.expires;
        $entry.value;
    }

    method clear {
        %!entries = ();
        @!fifo = ();
    }
}
