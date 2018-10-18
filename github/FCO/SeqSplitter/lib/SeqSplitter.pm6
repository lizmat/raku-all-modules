use v6.c;
unit class ChainableSeq:ver<0.0.1> does Sequence;

=begin pod

=head1 NAME

ChainableSeq - blah blah blah

=head1 SYNOPSIS

  use ChainableSeq;

=head1 DESCRIPTION

ChainableSeq is ...

=head1 AUTHOR

Fernando Correa de Oliveira <fernandocorrea@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Fernando Correa de Oliveira

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

has Sequence    $.parent;
has Iterator:D  $.iterator is required;

class PrependedItemIterator does Iterator {
    has Mu          $.item;
    has Iterator:D  $.iter is required;
    has Bool        $!has-item = True;
    method pull-one {
        do if $!has-item {
            $!has-item = False;
            $!item
        } else {
            $!iter.pull-one
        }
    }
}

sub prepend-item(Iterator:D $iter, Mu \i) {
    #say "prepend-item: ", $iter, ", ", i.Str;
    PrependedItemIterator.new: :item(i), :$iter
}

role SplitedIterator does Iterator {
    multi method from-iterator(SplitedIterator $iter)   { $iter }
    multi method from-iterator(Iterator $iter)          { prepend-item($iter, IterationEnd) but SplitedIterator }
}

class ConditionalIterator does SplitedIterator {
    has Sequence            $.orig-seq  is required;
    has                     $.condition;
    has Bool                $.on;
    has SplitedIterator     $!original;
    has SplitedIterator     $!handling;
    has SplitedIterator     $!unhandled;


    method pull-one {
        my $item := IterationEnd;
        if not $!original.defined and not $!handling.defined and $!unhandled.defined {
            $item := $!unhandled.pull-one;
            #note "unhandled {$item.Str}";
        }
        #note "post unhandled";
        with $!orig-seq {
            #note "orig-seq";
            $!original = ::?CLASS.from-iterator: $!orig-seq.iterator;
            $!orig-seq = Nil
        }
        #note "post orig-seq";
        with $!original {
            $item := .pull-one;
            #note "original {$item.Str}";
            if $item =:= IterationEnd {
                $!handling = $!original;
                $!original = Nil
            }
        }
        #note "post original";
        with $!handling {
            my Bool $has-last-value = False;
            my $last-value;
            if $!on {
                $item := .pull-one;
                #note "     ---> on : {$item.Str}";
                if $item !=:= IterationEnd and $item !~~ $!condition {
                    $last-value     = $item;
                    $has-last-value = True;
                    $item := IterationEnd
                }
            } else {
                repeat {
                    $item := .pull-one;
                    #note "     ---> off: {$item.Str}";
                    last if $item =:= IterationEnd;
                    if $item !~~ $!condition {
                        $last-value     = $item;
                        $has-last-value = True;
                        last
                    }
                } while $item !=:= IterationEnd;
                $item := IterationEnd;
            }
            if $has-last-value {
                #note "has-last-value";
                $!unhandled     = prepend-item($!handling, $last-value) but SplitedIterator;
                $!handling      = Nil;
                $has-last-value = False;
            }
            #note "handling {$item.Str}";
        }
        #note "post handling";
        #note "item: ", $item.Str;
        $item
    }
}

method new(Sequence:D $orig-seq, $condition = True, Bool :$on = True, Sequence :$parent) {
    ::?CLASS.bless: :$parent, iterator => ConditionalIterator.new(:$orig-seq, :$condition, :$on)
}

method pull-while($condition) {
    ::?CLASS.new: (self.?parent // self), $condition, :on
}

method pull-until($condition) {
    ::?CLASS.new: (self.?parent // self), * !~~ $condition, :on
}

method skip-while($condition) {
    my $parent = ::?CLASS.new: (self.?parent // self), $condition, :!on;
    my \seq = $parent.pull-while: True;
    seq.^attributes.first('$!parent').set_value: seq, $parent;
    seq
}

method skip-until($condition) {
    my $parent = ::?CLASS.new: (self.?parent // self), * !~~ $condition, :!on;
    my \seq = $parent.pull-while: True;
    seq.^attributes.first('$!parent').set_value: seq, $parent;
    seq
}

proto method skip($?) {*}
multi method skip(Whatever)         { self.skip-while: True }
multi method skip(UInt() $n = 1)    { self.skip-until: { $++ == $n } }

proto method pull($?) {*}
multi method pull(Whatever) { self.pull-while: True }
multi method pull(UInt() $n = 1) { self.pull-until: { $++ == $n } }

use MONKEY-TYPING;
augment class Seq {
    method pull-while($condition) { ChainableSeq.new(self, :!on, False).pull-while: $condition }
    method pull-until($condition) { ChainableSeq.new(self, :!on, False).pull-until: $condition }
    method skip-while($condition) { ChainableSeq.new(self, :!on, False).skip-while: $condition }
    method skip-until($condition) { ChainableSeq.new(self, :!on, False).skip-until: $condition }
    method pull($n = 1)           { ChainableSeq.new(self, :!on, False).pull: $n }
}
augment class Any {
    method pull-while($condition) { self.Seq.pull-while: $condition }
    method pull-until($condition) { self.Seq.pull-until: $condition }
    method skip-while($condition) { self.Seq.skip-while: $condition }
    method skip-until($condition) { self.Seq.skip-until: $condition }
    method pull($n = 1)           { self.Seq.pull: $n }
}
(Range)>>.^compose;
