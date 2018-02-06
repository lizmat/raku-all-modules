#!/usr/bin/env perl6

use Do::Timeline::Entry;

class Do::Timeline::Grammar::Actions {

    method day($/)              { make $/.UInt      };
    method month($/)            { make $/.UInt      };
    method year($/)             { make $/.UInt      };
    method id($/)               { make $/.UInt      };
    method entry-text($/)       { make $/.Str.trim  };
    method entry-icon($/)       { make $/.Str       };
    method title($/)            { make $/.Str       };
    method move-to-offset($/)   { make $/.UInt      };
    method day-count($/)        { make $/.UInt      };

    method date($/) {
        make Date.new(
            day     => $<day>.made,
            month   => $<month>.made,
            year    => $<year>.made,
        );
    }

    sub get-daycount ($entry-icon, $heading, $move-to-offset?) {
        my $today = Date.today.daycount;
        given $entry-icon {
            when '-' {
                return $today - $move-to-offset if $move-to-offset;         # the user wants to move the entry into the past
                return $today if $heading<days-away>;                       # a past entry in the future - move to earlier today
                return $heading<date>.made.daycount;                        # keep in current section
            }
            when '^' {
                return $heading<date>.made.daycount;                        # entry is pinned to this date keep in current section
            }
            when '!' { 
                return $today;   # ! only do one thing at a time
            }
            when '+' {
                return $today + $move-to-offset if $move-to-offset;         # the user wants to move the entry into the future
                return $today if $heading<days-ago>;                        # next entry in the past - move to later today
                return $today + ($heading<days-away><day-count>.made // 0); # move future entry relative to NOW
            }
        }
    }

    method timeline-section ($/) {

        my $days-ago  = Date.today.daycount - $<heading><date>.made.daycount;
        my $days-away = $<heading><days-away>.made // Nil;
        
        my @timeline-entries;

        for $<entry> -> $entry {          
            @timeline-entries.push: Do::Timeline::Entry.new(
                icon        => $entry<entry-icon>.made,
                id          => $entry<entry-id><id>.made // Nil,
                text        => $entry<entry-text>.made,
                daycount    => get-daycount($entry<entry-icon>.made, $<heading>, $entry<move-to-offset>.made)
            );
        }

        make @timeline-entries;
    } 

    method TOP ($/) {
        my %timeline = $<timeline-section>.map(*.made.Slip).classify(*.daycount);
        # note %timeline.perl;
        make %timeline;
    }
}

