use v6;
unit class Test::Base;

use Test::Base::Actions;
use Test::Base::Grammar;

multi sub blocks() is export {
    blocks(CALLER::UNIT::<$=finish>);
}

multi sub blocks(Str $src) is export {
    my $got = Test::Base::Grammar.parse($src, :actions(Test::Base::Actions));
    if $got {
        my @blocks = $got.made;
        my ($only, ) = grep { $_<ONLY>:exists }, @blocks;
        if $only {
            $*ERR.say: "I found ONLY: maybe you're debugging?";
            return ($only);
        } else {
            return @blocks;
        }
    } else {
        die "cannot parse Test::Base data.";
    }
}

=begin pod

=head1 NAME

Test::Base - Data driven development for Perl6

=head1 SYNOPSIS

=begin code

    use v6;
    use Test;

    use Test::Base;

    for blocks($=finish) {
        is EVAL($_<input>), .expected;
    }

    done-testing;

    =finish

    === simple
    --- input: 3+2
    --- expected: 5

    === more
    --- input: 4+2
    --- expected: 6

=end code

=head1 DESCRIPTION

Test::Base is a port of ingy's perl5 Test::Base for Perl6.

=head1 FUNCTIONS

=item C<blocks(Str $src)>

Parse C<$src> as a data source and returns test data.

=head1 AUTHOR

Tokuhiro Matsuno <tokuhirom@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2015 Tokuhiro Matsuno

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
