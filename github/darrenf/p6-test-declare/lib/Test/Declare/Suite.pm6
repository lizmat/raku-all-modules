use v6.c;

use Test::Declare;

role Test::Declare::Suite {
    has $!errstr = q|must declare '%s' either in call or as a method|;

    method class { die sprintf($!errstr, 'class') }
    method method { die sprintf($!errstr, 'method') }
    method tests { … }
    method construct returns Capture { \() }

    method run-me {
        my @tests = self.tests;
        @tests.map:{
            for <class method construct> -> $attr {
                if $_{'call'}{$attr}:!exists { $_{'call'}{$attr} = self."$attr"(); }
            }
        };
        declare(@tests);
    }
}

=begin pod

=head1 NAME

Test::Declare::Suite

=head1 SYNOPSIS

    use Test::Declare::Suite;
    use Module::Under::Test;

    class MyTest does Test::Declare::Suite {
        method class { Module::Under::Test }
        method method { 'some-method' }
        method construct { \(some => 'value') }

        method tests {
            ${
                name => 'test 1',
                args => \(3),
                expected => {
                    return-value => …,
                },
            },
            …
        }
    }

    MyTest.new.run-me;

Test::Declare::Suite is a helper role which enables bundling of
multiple tests that operate on the same callable, to reduce repetition.

When consuming the role, you must implement methods called C<class>,
C<method> and C<construct> (if appropriate) to use as defaults. Also
implement C<method tests() returns Array {...}> for the slimmed down test
scenarios, now varying only on arguments and expectations.

Individual test hashes can still provide any element of the C<call>
hash to override the default.

Each class's tests should be executed by calling C<ClassName.new.run-me>.

=end pod
