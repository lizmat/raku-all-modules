#!/usr/bin/env perl6
use v6;
use lib 'lib';
use Test;
use Time::Crontab::Set;

plan 5;

sub run-test-for(Time::Crontab::Set::Type $type, Int $min, Int $max) {
    subtest {
        plan 15;
        diag $type;
        my $set = Time::Crontab::Set.new(type => $type);
        nok($set.will-ever-execute(), "a new set for $type, with initial values, will-never-execute()");
        nok($set.all-enabled(), "a new set for $type, with initial values, will not have all-enabled()");
        my $list;
        $list{$_} = False for ($min..$max);
        is-deeply($set.hash, $list, 'everything is false');
        $set.enable(5);
        ok($set.contains(5), 'element 5 is enabled');
        ok($set.will-ever-execute(), "but it will execute after 5 is enabled");

        my Int $distance = 0;
        my $next = $set.next(3, $distance);
        is($next, 5, "next to 3 is 5");
        is($distance, 2, "which is 2 steps ahead");

        $next = $set.next(6, $distance);
        is($next, 5, "next to 6 is 5");

        my $expected-distance = ($max - $min - (6-5)) + 1; # 6 := start, 5 := expected
        is($distance, $expected-distance, "which is $expected-distance ahead");

        $list{5} = True;
        is-deeply($set.hash, $list, '5th element of the list is true');
        
        dies-ok(sub {$set.enable($min-1) }, "enabling element smaller than possible fails");
        dies-ok(sub {$set.enable($max+1) }, "enabling element higher than possible fails");
        lives-ok(sub {$set.enable($min) }, "enabling minimal element");
        lives-ok(sub {$set.enable($max) }, "enabling maximal element");

        $set.enable-any();
        ok($set.all-enabled(), "we will have all-enabled() after enabling all");
    }
}

run-test-for(Time::Crontab::Set::Type::minute, 0, 59);
run-test-for(Time::Crontab::Set::Type::hour, 0, 23);
run-test-for(Time::Crontab::Set::Type::dom, 1, 31);
run-test-for(Time::Crontab::Set::Type::month, 1, 12);
run-test-for(Time::Crontab::Set::Type::dow, 0, 6);

