use v6.d.PREVIEW;
use Terminal::Print;
use Terminal::Print::DecodedInput;

class Tick { }

role Do::Timeline::UI {

    has $.graph-height      =  8;  
    has $.bar-char          = '▉';
    has $.day-arrow         = '▲';
    has $.right-arrow       = '🠊';
    has $.left-arrow        = '🠈';
    has $.max-entry-width   = 120;
    has $.no-bar-char       = '_';
    has $.pinned-colour     = 'green';
    has $.past-colour       = 'blue';
    has $.now-colour        = 'yellow';
    has $.next-colour       = 'red';

    method show-graph ($selected-day = Date.today.daycount, %timeline-entries = %.entries) {

        my $screen = Terminal::Print.new;

        # saves current screen state, blanks screen, and hides cursor
        $screen.initialize-screen;                      

        my $input   = decoded-input-supply;
        #my $timer       = Supply.interval(1).map: { Tick };
        #my $supplies    = Supply.merge($in-supply, $timer);
        my $current-day = $selected-day;

        self.refresh-screen($screen, $current-day, %timeline-entries);

        react {
            whenever $input -> $_ {
                when Tick {
                    # tock - time passes
                }
                when 'x' | 'X' {
                    $screen.shutdown-screen;
                    done;
                }
                when $_.ord == 13 {
                    self.edit-day($current-day, %timeline-entries);
                    self.refresh-screen($screen, $current-day, %timeline-entries);
                }
                when 'e' | 'E' | ' ' {
                    self.edit-day($current-day, %timeline-entries);
                    self.refresh-screen($screen, $current-day, %timeline-entries);
                }
                when 'PageUp' {
                    # back one week
                    $current-day -= 7;
                    self.refresh-screen($screen, $current-day, %timeline-entries);                    
                }
                when 'PageDown' {
                    $current-day += 7;
                    self.refresh-screen($screen, $current-day, %timeline-entries);                    
                }
                when 'CursorRight' | 'CursorDown' {
                    $current-day++;
                    self.refresh-screen($screen, $current-day, %timeline-entries);
                }
                when 'CursorLeft' | 'CursorUp' {
                    $current-day--;
                    self.refresh-screen($screen, $current-day, %timeline-entries);
                }
            }
        }
    }

    method edit-day ($current-day, %timeline-entries) {

        unless %timeline-entries{$current-day}:exists {
            self.log("current day $current-day does not exists");
            # no entries on this day
            %timeline-entries{$current-day} = [];
            # re-render the file
            self.save;
        } 

        # jmp to the matching day
        my $day-heading = self.render-day($current-day).lines[1];            
        self.edit-matching-line($day-heading, 1);
       
    }

    method refresh-screen ($screen, $selected-day = Date.today.daycount, %timeline-entries = %.entries) {
        $screen.current-grid.clear();
        self.render-graph($screen, $selected-day, %timeline-entries);
        self.render-header($screen);
        self.render-entries($screen, $selected-day);
        self.render-actions($screen);
        print $screen;
    }

    method render-header($screen) {        
        # show which 123.do file to provide some context - later would be good to choose from available
        $screen.current-grid.set-span-text(0, 0, self.file);
    }
 
    method render-actions($screen) {        
        my $y = $screen.rows - 1;
        my $actions =  '🠈 Previous       [E]dit      e[X]it        Next 🠊';
        my $start-at-x = ($screen.columns - $actions.chars) div 2;
        $screen.current-grid.set-span-text($start-at-x, $y, $actions);  
    }
   
    method render-entries ($screen, $selected-day) {
        
        my $y = $!graph-height + 2;
        my $x = self.entry-left-margin($screen);               

        my @entry-lines = self.render-day-with-padding($selected-day, $!max-entry-width).lines;
        
        for @entry-lines -> $line {
            $screen.current-grid.set-span-text($x, $y, $line);
            $y++;
        }    

    }    

    method log ($message) {
        "/tmp/log".IO.spurt($message ~ "\n", :append);
    }

    submethod entry-left-margin ($screen) {

        # max 80 chars
        my $grid-width = $screen.columns < $!max-entry-width
                       ?? $screen.columns 
                       !! $!max-entry-width;
        
        return 1 unless $screen.columns > $grid-width;
        return ($screen.columns - $grid-width) div 2; 

    }

    method render-graph ($screen, $selected-day = Date.today.daycount, %timeline-entries = %.entries) {

        my @days = get-day-range($selected-day, $screen.columns);

        my $current-column = 0;

        for @days -> $day {
            
            my $highlight = so $selected-day == $day;
            
            if %timeline-entries{$day}:exists {
                self.set-bar($screen.current-grid, $current-column, %timeline-entries{$day}, $highlight);
            }
            else {
                # no bar - show a blank bar
                self.set-no-bar($screen.current-grid, $current-column, $day, $highlight);
            }

            if $day == $selected-day {
                $screen.current-grid.change-cell($current-column, $!graph-height + 1, %( char => $!day-arrow, color => 'bold yellow'));
            }

            $current-column++;
        }
    }

    submethod set-no-bar ($grid, $x, $day, $highlight) {

        my $today   = Date.today.daycount;
        my $max-y   = $!graph-height;
        
        my $add-bold = ($highlight) ?? 'bold ' !! '';

        given $day {
            when $_ < $today {
                $grid.change-cell($x, $max-y, %(char => $!no-bar-char, color => $add-bold ~ $!past-colour));
            }
            when $today {
                $grid.change-cell($x, $max-y, %(char => $!no-bar-char, color => $add-bold ~ $!now-colour));
            }
            when $_ > $today {
                $grid.change-cell($x, $max-y, %(char => $!no-bar-char, color => $add-bold ~ $!next-colour));
            }
        } 
    }

    submethod set-bar ($grid, $x, @entries, $highlight) {

        my $y = $!graph-height;

        my $add-bold = ($highlight) ?? 'bold ' !! '';

        for @entries -> $entry {
            given $entry {
                when .is-pinned {
                    $grid.change-cell($x, $y, %(char => $!bar-char, color => $add-bold ~ $!pinned-colour));
                }
                when .is-past {
                    $grid.change-cell($x, $y, %(char => $!bar-char, color => $add-bold ~ $!past-colour));
                }
                when .is-now {
                    $grid.change-cell($x, $y, %(char => $!bar-char, color => $add-bold ~ $!now-colour));
                }
                when .is-next {
                    $grid.change-cell($x, $y, %(char => $!bar-char, color => $add-bold ~ $!next-colour));
                }
            }
            $y--;
            last if $y == 0;
        }
        
    }

    sub get-day-range ($selected-day, $column-count) {
    
        # centre point of the graph, rounds down
        my $half-way = $column-count div 2;
        my $from-day = $selected-day - $half-way;

        # add an extra day to allow for rounding down
        my $to-day   = $column-count %% 2 
                     ?? $selected-day + $half-way
                     !! $selected-day + $half-way + 1;

        return $from-day .. $to-day;

    }   
}

