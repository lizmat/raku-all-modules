#!/usr/bin/env perl6

# render parts of the timeline for display and storage
role Do::Timeline::Viewport {

    method render (%timeline-entries = %.entries) {
        my @days = %timeline-entries.keys.sort;
        return [~] @days.map({self.render-day(+$_)});
    }

    multi method render-day ('-', $past-offset) { self.render-day(Date.today.daycount - $past-offset) }
    multi method render-day ('!', $now-offset)  { self.render-day(Date.today.daycount)                }
    multi method render-day ('+', $next-offset) { self.render-day(Date.today.daycount + $next-offset) }
        
    multi method render-day (Int $daycount) {

        my $day-entries = %.entries{$daycount};
        my $date = Date.new-from-daycount($daycount);
        my $today-offset = $daycount - Date.today.daycount;
        
        given $today-offset {
            when -1 { 
                return render-day-section('Yesterday', $daycount, $day-entries);
            }
            when 0 {
                return join("\n",
                    render-day-section('Earlier Today', $daycount, $day-entries.grep({ $_.is-past or $_.is-pinned })),
                    render-day-section('NOW',           $daycount, $day-entries.grep(*.is-now)),
                    render-day-section('Later Today',   $daycount, $day-entries.grep(*.is-next))
               );
            }
            when 1 {
                return render-day-section('Tomorrow', $daycount, $day-entries);
            }
            default {
                my $dayname = <Monday Tuesday Wednesday Thursday Friday Saturday Sunday>[$date.day-of-week - 1];
                return render-day-section($dayname, $daycount, $day-entries);
            }
        }
    }

    sub render-day-section ($title, $daycount, $day-entries) {

        my $date            = Date.new-from-daycount($daycount);
        my $display-date    = join('/', $date.day, $date.month, $date.year);
        my $relative-day    = render-relative-day($daycount);

        my $heading         = $relative-day
                            ?? "\n" ~ $title ~ ' (' ~ $display-date ~ ')' ~ ' [' ~ $relative-day ~ ']' ~ "\n"
                            !! "\n" ~ $title ~ ' (' ~ $display-date ~ ')' ~ "\n";

        return $heading unless $day-entries;
        return $heading ~ [~] $day-entries.map(*.render);

    }

    sub render-relative-day ($daycount) {
        my $today-offset = $daycount - Date.today.daycount;
        given $today-offset {
            when 0      { return '';                        }
            when 1      { return '1 day away';              } 
            when -1     { return '1 day ago';               } 
            when $_ > 1 { return $_ ~  ' days away';        }
            when $_ < 1 { return ($_ * -1) ~ ' days ago';   }
        }
    }
}


