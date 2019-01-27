use v6.d.PREVIEW;
use Terminal::Print;
use Terminal::Print::DecodedInput;

# Display character stream, exiting the program when 'q' is pressed
#my $in-supply = decoded-input-supply;

class Tick { }

class Do::Timeline::UI::Cursor {

    has $.column            = 19;   # the column where the cursor appears
    has $.selected-day      = Date.today.daycount;  
    has $.starts-at-line    = 0;
    has $.ends-at-line      = 0;
    has $.icon              = '▉';
    has $.colour            = 'bold yellow';
    has $.past-colour       = 'bold blue';
    has $.now-colour        = 'bold yellow';
    has $.next-colour       = 'bold red';

    method move-down ($screen) {

        for $.starts-at-line .. $.ends-at-line -> $line {
            # clear existing cursor
            $screen.current-grid.print-cell($.column, $line, %(char => ' '));                    
        }
    
        # grab the next entry - if there is one
#        $cursor-line++ if $cursor-line < $max-lines;
 #       $screen.current-grid.print-cell($.column, $cursor-line, %(char => $!right-arrow, color => 'bold red'));                
    }

    # get actions - what actions are available?
    #
}

role Do::Timeline::UI {

    has $.graph-height      =  8;  
    has $.bar-char          = '▉';
    has $.day-arrow         = '▲';
    has $.right-arrow       = '🠊';
    has $.left-arrow        = '🠈';

    has $.no-bar-char       = '_';
    has $.pinned-colour     = 'green';
#    has $.pinned-colour     = 'darkgreen';
    has $.cursor-colour     = 'on_green';
    has $.past-colour       = 'blue';
    has $.now-colour        = 'yellow';
    has $.next-colour       = 'red';
    has $.highlight-colour  = 'magenta';

    method show-graph ($selected-day = Date.today.daycount, %timeline-entries = %.entries) {

        my $screen = Terminal::Print.new;

        # saves current screen state, blanks screen, and hides cursor
        $screen.initialize-screen;                      

        my $in-supply   = decoded-input-supply;
        my $timer       = Supply.interval(1).map: { Tick };
        my $supplies    = Supply.merge($in-supply, $timer);
        my $current-day = $selected-day;
        my $cursor-start-at-y = 11;
        my $cursor-line = $cursor-start-at-y;
        my $max-lines   = $screen.rows - 1;

        self.refresh-screen($screen, $current-day, $cursor-line, %timeline-entries);

        react {
            whenever $supplies -> $_ {
                when Tick {
                    # tock - time passes
                }
                when 'a' | 'A'  {
                    # add a new entry
                    self.edit();    # add to the start of the day
                    self.refresh-screen($screen, $current-day, $cursor-line, %timeline-entries);                    
                }
                when 'e' | 'E'  {
                    # launch your editor at current position
                    # get the first line of the current day
#                    my $day = self.render-day($selected-day);
#                    self.edit($day-heading, $cursor-line - $cursor-start-at-y); 
 #                   self.refresh-screen($screen, $current-day, $cursor-line, %timeline-entries);                    
                }
                when 'x' | 'X' | ' '  {
                    $screen.shutdown-screen;
                    run('reset');
                    exit;
                }
                # someone has pressed enter
                when $_.ord == 13 {
                    my $day-heading = self.render-day($current-day).lines[1];
                    self.edit($day-heading, $cursor-line - $cursor-start-at-y); 
                    self.refresh-screen($screen, $current-day, $cursor-line, %timeline-entries);                    
                }
                when 'CursorRight' {
                    $current-day++;
                    self.refresh-screen($screen, $current-day, $cursor-line, %timeline-entries);
                }
                when 'CursorDown' {
                    $cursor.move-down($screen);
                }
                when 'CursorUp' {
                    $screen.current-grid.print-cell(19, $cursor-line, %(char => ' '));                    
                    $cursor-line-- if $cursor-line > $cursor-start-at-y;
                    $screen.current-grid.print-cell(19, $cursor-line, %(char => $!right-arrow, color => 'bold red'));
                }
                when 'CursorLeft'  {
                    $current-day--;
                    self.refresh-screen($screen, $current-day, $cursor-line, %timeline-entries);
                }
            }
        }
    }

    method refresh-screen ($screen, $selected-day = Date.today.daycount, $cursor-line = 1, %timeline-entries = %.entries) {
        self.render-graph($screen, $selected-day, %timeline-entries);
        self.render-header($screen);
        self.render-entries($screen, $selected-day, $cursor-line);
        self.render-actions($screen);
        print $screen;
    }

    method render-header($screen) {        
        # show which 123.do file to provide some context - later would be good to choose from available
        $screen.current-grid.set-span-text(0, 0, self.file);
    }
 
    method render-actions($screen) {        
        my $y = $screen.rows - 1;
        $screen.current-grid.set-span-text(20, $y, '🠈 Previous       [A]dd        [E]dit      e[X]it        Next 🠊');  
    }
   
    method render-entries ($screen, $selected-day, $cursor-line = 1) {
        
        my $grid-width = $screen.columns - 20;
        
        my $y = $!graph-height + 2;
               
        my $day = self.render-day($selected-day);
        
        my @lines = $day.lines();
            
        for @lines -> $line {
            $screen.current-grid.set-span-text(20, $y, $line ~ ' ' x $grid-width - $line.chars);
            $y++;
        }    

        # fill the rest in with blank lines
        for $y .. $screen.rows -> $blank-y {
            $screen.current-grid.set-span-text(20, $blank-y, ' ' x $grid-width);
        }
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
                $screen.current-grid.change-cell($current-column, $!graph-height + 1, %( char => $!day-arrow, color => 'red'));
            }

            $current-column++;
        }
    }

    submethod set-no-bar ($grid, $x, $day, $highlight) {

        my $today   = Date.today.daycount;
        my $max-y   = $!graph-height;
        
        for 1 .. $max-y - 1 -> $y {
            $grid.change-cell($x, $y, ' ');  
        }

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
#                when $highlight {
#                   $grid.change-cell($x, $y, %(char => $!bar-char, color => $!highlight-colour));
#              }
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
        
        for 1 .. $y -> $y-padding {
            $grid.change-cell($x, $y-padding, ' ');
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

