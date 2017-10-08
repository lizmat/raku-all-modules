# -*- mode: perl6; -*-
use v6;

use Test;

sub find-source-url() {
    try my @lines = qx{git remote -v 2> /dev/null};

    return '' unless @lines;

    my $url = gather for @lines -> $line {
        my ($, $url) = $line.split( /\s+/ );

        if  $url {
            take $url;

            last;
        }
    }

    return '' unless $url;

    $url .= Str;

    $url ~~ s/^https?/git/;

    if $url ~~ m/'git@' $<host>=[.+] ':' $<repo>=[<-[:]>+] $/ {
        $url = "git://$<host>/$<repo>";
    } elsif $url ~~ m/'ssh://git@' $<rest>=[.+] / {
        $url = "git://$<rest>";
    }
    $url;
}

sub guess-user-and-repository() {
    my $source-url = find-source-url;

    return if $source-url eq '';

    if $source-url ~~ m{ ( 'git' | 'http' 's'? ) '://'
                         [<-[/]>+] '/'
                         $<user>=[<-[/]>+] '/'
                         $<repo>=[.+?] [\.git]?
                         $}
    {
        return $/<user>, $/<repo>;
    }

    return ;
}

plan 4;

unless '.git'.IO.e {
    skip-rest( "We can't find source from git repository, Not found .git/" );

    exit;
}

my $url = find-source-url;

ok $url;
is 'git://github.com/noqisofon/p6-miroku.git', $url;

my @user-and-repo = guess-user-and-repository;

is 'noqisofon', @user-and-repo[0],   'user is "noqisofon"?';
is 'p6-miroku', @user-and-repo[1],   'repository is "p6-miroku"?';

done-testing;
