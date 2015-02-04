use lib 'lib';
use Threads;
use Semaphore;

my @elements;
my $free-slots = Semaphore.new(value => 10); # 10 remaining slots
my $full-slots = Semaphore.new(value => 0);  # 10 slots taken

sub produce($id) {
    my $i = 0;
    loop {
        note "Producer $id waiting for an empty slot";
        $free-slots.wait; # acquire an empty slot
        note "Producer $id adding element $i";
        @elements.push: $i;
        $i++;
        note "Now present {+@elements} elements";
        $full-slots.post; # there is now one more full slot
    }
}

sub consume($id) {
    loop {
        note "Consumer $id waiting for a full slot";
        $full-slots.wait; # acquire a full slot
        my $a = @elements.shift;
        note "Consumer $id eating $a";
        $free-slots.post; # there is now one more free slot
    }
}

for 1..5 -> $i {
    async sub { produce($i)  }
}

for 5..10 -> $i {
    async sub { consume($i) }
}

sleep 5;
exit;
