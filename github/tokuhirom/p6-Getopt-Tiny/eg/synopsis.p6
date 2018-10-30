use v6;

use Getopt::Tiny;

my $env = {
    host => '127.0.0.1',
    port => 5000,
};

get-options(
    $env, <
        e=s
        I=s@
        p|port=i
        h|host=s
    >
);

$env.perl.say;
@*ARGS.perl.say;

=begin pod

=head1 NAME

crustup

=head1 SYNOPSIS

    crustup -e EVAL
    crustup app.psgi

        -Ilib
        -p --port
        -h --host

=end pod
