#!/usr/bin/env perl6;
use v6;
use lib 'lib';
use Test;
use Time::Crontab;

plan 4;

subtest {
    plan 7;

    my $crontab     = "* * * * *";
    my $tc          = Time::Crontab.new(:$crontab);

    my $next;
    my $comp;
    my $date;
    
    $date = DateTime.new(2016, 3, 28, 15, 57, 35.3622677326202);
    $next = $tc.next-datetime($date);
    $comp = DateTime.new(2016, 3, 28, 15, 58, 0);
    is($next, $comp, "next datetime is the next whole minute - partial step");

    $date = $next;
    $next = $tc.next-datetime($next);
    $comp = DateTime.new(2016, 3, 28, 15, 59, 0);
    is($next, $comp, "next datetime is the next whole minute - 1 minute step {$next}");

    $date = $next;
    $next = $tc.next-datetime($next);
    $comp = DateTime.new(2016, 3, 28, 16, 0, 0);
    is($next, $comp, "datetime is the next hour - hour wrap step for crontab '$crontab' - next to $date is $comp");

    $date = DateTime.new(2016, 3, 28, 23, 59, 0);
    $next = $tc.next-datetime($date);
    $comp = DateTime.new(2016, 3, 29, 0, 0, 0);
    is($next, $comp, "datetime is the next day - day wrap step for crontab '$crontab' - next to $date is $comp");

    $date = DateTime.new(2016, 3, 31, 23, 59, 0);
    $next = $tc.next-datetime($date);
    $comp = DateTime.new(2016, 4, 1, 0, 0, 0);
    is($next, $comp, "datetime is the next month - month wrap step for a 31dayish month for crontab '$crontab' - next to $date is $comp");

    $date = DateTime.new(2016, 4, 30, 23, 59, 0);
    $next = $tc.next-datetime($date);
    $comp = DateTime.new(2016, 5, 1, 0, 0, 0);
    is($next, $comp, "datetime is the next month - month wrap step for a 30dayish month for crontab '$crontab' - next to $date is $comp");

    $date = DateTime.new(2016, 12, 31, 23, 59, 0);
    $next = $tc.next-datetime($date);
    $comp = DateTime.new(2017, 1, 1, 0, 0, 0);
    is($next, $comp, "datetime is the next year - year wrap step");
}, "Simple Tests";

## test with crontab so that dow is not any
subtest {
    plan 8;

    # at 10 o'clock on every 10th or 31th of any month as well as every Tuesday
    my $crontab = "0 10 10,31 * 2"; 
    my $tc = Time::Crontab.new(:$crontab);

    # a date where the next is the 10th
    my $date = DateTime.new(2016, 3, 9, 14, 11, 0);
    my $next = $tc.next-datetime($date);
    my $comp = DateTime.new(2016, 3, 10, 10, 0, 0);
    is($next, $comp, "for crontab '$crontab' - next to $date is $comp");
    
    # a date where the next is the Tuesday
    $date = DateTime.new(2016, 3, 12, 14, 11, 0);
    $next = $tc.next-datetime($date);
    $comp = DateTime.new(2016, 3, 15, 10, 0, 0);
    is($next, $comp, "for crontab '$crontab' - next to $date is $comp");
    
    # a date where the next is the 31th - now it's after 10:00am
    $date = DateTime.new(2016, 3, 30, 14, 11, 0);
    $next = $tc.next-datetime($date);
    $comp = DateTime.new(2016, 3, 31, 10, 0, 0);
    is($next, $comp, "for crontab '$crontab' - next to $date is $comp");

    # a date where the next is the 31th - now its before 10:00am
    $date = DateTime.new(2016, 3, 30, 8, 11, 0);
    $next = $tc.next-datetime($date);
    $comp = DateTime.new(2016, 3, 31, 10, 0, 0);
    is($next, $comp, "for crontab '$crontab' - next to $date is $comp");
    
    # a date where the next cant be the 31th, because like April there is no 31th of the month.
    $date = DateTime.new(2016, 4, 29, 14, 11, 0);
    $next = $tc.next-datetime($date);
    $comp = DateTime.new(2016, 5, 3, 10, 0, 0,);
    is($next, $comp, "for crontab '$crontab' - next to $date is $comp");

    # a year wrap around! now it is 16oclock on 31dec.
    $date = DateTime.new(2016, 12, 31, 16, 0, 0);
    $next = $tc.next-datetime($date);
    $comp = DateTime.new(2017,  1,  3, 10, 0, 0);
    is($next, $comp, "for crontab '$crontab' - next to $date is $comp");


    ## test that sat and sunday are not executed
    $crontab = "0 22 * * 1-5"; # at 10pm each working day
    $tc = Time::Crontab.new(:$crontab);

    # it's Monday so next is Tue
    $date = DateTime.new(2016, 3, 28, 14, 11, 0);
    $next = $tc.next-datetime($date);
    $comp = DateTime.new(2016, 3, 28, 22, 0, 0);
    is($next, $comp, "for crontab '$crontab' - next to $date is $comp");
    
    # it's Fr so next is Monday
    $date = DateTime.new(2016, 3, 25, 23, 11, 0);
    $next = $tc.next-datetime($date);
    $comp = DateTime.new(2016, 3, 28, 22, 0, 0);
    is($next, $comp, "for crontab '$crontab' - next to $date is $comp");

    # testcase for dow := any == *, in this case only dom counts.
    #
}, "Tests with DOW and DOM both not set to any";

subtest {
    plan 3;

    my $crontab = '0 15 10,20 * *';
    my $tc = Time::Crontab.new(:$crontab);
    my $date = DateTime.new(2016, 3, 11, 13, 10, 10);
    my $next = $tc.next-datetime($date);
    my $comp = DateTime.new(2016, 3, 20, 15, 0, 0);
    is($next, $comp, "for crontab '$crontab' -  next to $date is $comp");

    # at 10 o'clock on every 10th or 31th of any month
    $crontab = "0 10 10,31 * *"; 
    $tc = Time::Crontab.new(:$crontab);
    $date = DateTime.new(2016, 4, 29, 14, 11, 0);
    $next = $tc.next-datetime($date);
    $comp = DateTime.new(2016, 5, 10, 10, 0, 0, );
    is($next, $comp, "for crontab '$crontab' - next to $date is $comp");

    # a test for double month wrap around - should execute every 31th a month at 10 o'clock its the 31 march, so we need to skip April
    $crontab = "0 10 31 * *";
    $tc = Time::Crontab.new(:$crontab);
    $date = DateTime.new(2016, 3, 31, 11, 0, 0);
    $next = $tc.next-datetime($date);
    $comp = DateTime.new(2016, 5, 31, 10, 0, 0);
    is($next, $comp, "for crontab '$crontab' - next to $date is $comp");
}, "DOW is set to any";

subtest {
    plan 2;

    # the dow way - no month wrap around
    my $crontab = '0 15 * * 3';
    my $tc = Time::Crontab.new(:$crontab);
    my $date = DateTime.new(2016, 3, 11, 13, 10, 10);
    my $next = $tc.next-datetime($date);
    my $comp = DateTime.new(2016, 3, 16, 15, 0, 0);
    is($next, $comp, "for crontab '$crontab' - next to $date is $comp");

    # the dow way - no month wrap around
    $tc = Time::Crontab.new(:$crontab);
    $date = DateTime.new(2016, 4, 29, 14, 11, 0);
    $next = $tc.next-datetime($date);
    $comp = DateTime.new(2016, 5, 4, 15, 0, 0, );
    is($next, $comp, "for crontab '$crontab' - next to $date is $comp");
}, "DOM is set to any";
