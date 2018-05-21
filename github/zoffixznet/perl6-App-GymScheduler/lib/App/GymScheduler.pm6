unit class App::GymScheduler;
use Terminal::ANSIColor;
use Config::JSON '';

method run {
    init-config my $conf-file := ($*HOME//'.').IO.add: '.gym.p6.conf';
    my %conf  := jconf $conf-file, *;

    my $day   := Date.new(Instant.from-posix: %conf<seed>)
      .truncated-to('month').earlier: months => 1+%conf<show-months-before>;

    my $wdays := %conf<workout-days-per-month>;
    my @days  := ($day …^ Date.today.truncated-to('month')
      .later(months => 1+%conf<show-months-after>)
      .earlier: :day).map(*.&[does]: role {
          method day-of-week { callsame() andthen $_ == 7 ?? 0 !! $_ }
      }).List;

    my $start := Date.today.truncated-to('month').earlier:
      months => %conf<show-months-before>;
    my @modes = %conf<modes><>;
    with %conf<modes-desc> {
        say();
        $_ == @modes or die '`modes-desc` config key needs to have same number '
          ~ 'of elements as `modes` key';
        for .kv -> \idx, $v {
            print colored "██ $v ", @modes[idx];
        }
        say "\n";
    }
    my role WorkoutDay {
        method day {
            callsame() but role {
                method fmt(|) { colored callsame, 'inverse' }
            }
        }
    }
    srand %conf<seed>;
    for @days.categorize({.month ~ "|" ~ .year}).sort».value {
        .grep(*.day-of-week == none 0, 6).pick($wdays)».&[does]: WorkoutDay;
        next if $_ before $start;

        say colored "{.month}/{.year}", 'yellow bold' with .head;
        say colored "  S   M   T   W   T   F   S", 'bold';

        print "    " x .head.day-of-week;
        for .<> {
            my $s := .day.fmt: .Str eq ~Date.today ?? "*%2d*" !! " %2d ";
            $s := colored $s, (@modes.=rotate).head when WorkoutDay;
            $s.print;
            say() if .day-of-week == 6;
        }
        say "\n";
    }
}

sub init-config {
    $^conf-file.e and jconf $conf-file, 'seed' and return()
      or $conf-file.IO.spurt: '{}';
    jconf-write $conf-file, 'seed', time;
    jconf-write $conf-file, 'workout-days-per-month', 14;
    jconf-write $conf-file, 'modes', <yellow magenta>;
    jconf-write $conf-file, 'show-months-before', 1;
    jconf-write $conf-file, 'show-months-after',  1;
}
