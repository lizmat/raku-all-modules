use v6;

constant $VERSION = '0.01';

# XXX can I make this parameterized?
#| A priority queue implementation. Z<Implemented as a binary heap>
class PriorityQueue:auth<github:hoelzro>:ver<0.1.0> {
    has @!elements; # XXX should be @!elements{1..*}
    has &!cmp;

    #| Constructor.  You can specify a custom comparator via
    #| C<:cmp>; it should be a code object that returns True
    #| if its first argument should appear before its second
    #| when shifting items off of the queue.  If you provide
    #| a unary function, C<&cmp($a) before &cmp($b)> will be
    #| used.
    submethod BUILD(:&!cmp = &[before]) {
        # pad the array so that our starting index is
        # 1; makes our calculations a bit easier
        @!elements.push: Any;

        if &!cmp.count == 1 {
            my $cmp = &!cmp;
            &!cmp = -> $a, $b {
                $cmp($a) before $cmp($b)
            };
        }
    }

    #| Adds an element to the queue.
    method push($element) {
        @!elements.push: $element;

        my int $index = @!elements.end;

        while $index > 1 {
            my int $parent-index = $index div 2;
            my $parent           = @!elements[$parent-index];

            last unless &!cmp($element, $parent);

            @!elements[$index]        = $parent;
            @!elements[$parent-index] = $element;

            $index = $parent-index;
        }
    }

    #| Removes the next element from the queue.
    method shift {
        return unless @!elements > 1;
        return @!elements.pop if @!elements == 2;

        my $result    = @!elements[1];
        @!elements[1] = @!elements.pop;

        my int $index   = 1;
        my int $end     = @!elements.end;
        my int $halfway = $end div 2;

        while $index <= $halfway {
            my $left-index  = $index * 2;
            my $right-index = $left-index + 1;

            my $swap-index = [$index, $left-index, $right-index].grep(* <= $end).min: {
                &!cmp(@!elements[$^a], @!elements[$^b]) ?? Order::Less !! Order::More
            };
            last if $index == $swap-index;

            @!elements[$index, $swap-index] = @!elements[$swap-index, $index];

            $index = $swap-index;
        }
        $result
    }
}

=begin NAME
PriorityQueue
=end NAME

=begin VERSION
A<$VERSION>
=end VERSION

=begin SYNOPSIS
    use PriorityQueue;

    my $p = PriorityQueue.new;

    for 1 .. 100 {
        $p.push: 100.rand.floor;
    }

    # should return in increasing order
    while $p.shift -> $e {
        say $e;
    }

    # if you want a max heap, or just a different ordering:
    $p = PriorityQueue.new(:cmp(&infix:«>=»));
=end SYNOPSIS

=begin DESCRIPTION
This class implements a priority queue data structure.
=end DESCRIPTION

=begin AUTHOR
Rob Hoelz <rob AT-SIGN hoelz.ro>
=end AUTHOR
