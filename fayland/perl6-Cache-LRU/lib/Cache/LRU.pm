use v6;

class Cache::LRU {
    has Int $.size is rw = 1024;
    has %._entries;
    has @._fifo;

    sub GC_FACTOR { 10 }

    method set($key, $value is copy) {
        if %._entries{$key}:exists {
            %._entries{$key}:delete;
        }

        %._entries{$key} = $value;
        self._update_fifo($key, $value);

        # expire the oldest entry if full
        while %._entries.elems > $.size {
            my @exp_key = @._fifo.shift;
            %._entries{@exp_key[0]}:delete
                unless %._entries{@exp_key[0]};
        }

        $value;
    }

    method _update_fifo($key, $value is copy) {
        # precondition: %._entries should contain given key
        @._fifo.push( ($key, $value) );

        if @._fifo.elems >= $.size * GC_FACTOR() {
            my @new_fifo;
            my %need;
            for %._entries.keys => my $i {
                %need{$i} = 1;
            }
            while (%need.elems) {
                my $fifo_entry = @._fifo.pop();
                @new_fifo.unshift($fifo_entry)
                    if %need{$fifo_entry.()[0]}:delete;
            }
            @._fifo = @new_fifo;
        }
    }

    method get($key) {
        my $value = %._entries{$key};
        return unless $value.defined;

        self._update_fifo($key, $value);
        $value;
    }

    method remove($key) {
        my $value = %._entries{$key}:delete;
        return unless $value.defined;
        $value;
    }

    method clear {
        %._entries = ();
        @._fifo = ();
    }
}