use Do::Timeline::UI::Colours;

class Do::Timeline::UI::Graph {

    has $.graph-height  = 8;  
    has $.bar-char      = '▉';
    has $.colour        = Do::Timeline::UI::Colours.new;

    method render ($screen, %timeline-entries) {

        my @days = get-day-range($screen.cursor.selected-day, $screen.columns);

        my $current-column = 0;

        for @days -> $day {
            
            my $highlight = so $screen.cursor.selected-day == $day;
            
            if %timeline-entries{$day}:exists {                                
                self.render-bar($screen, $current-column, %timeline-entries{$day});
            }
            else {
                # no bar - show a blank bar
                self.render-no-bar($screen, $current-column, $day, $highlight);
            }

            if $day == $screen.cursor.selected-day {
                $screen.current-grid.change-cell($current-column, $!graph-height + 1, %( char => $!day-arrow, color => 'red'));
            }

            $current-column++;
        }
    }

    submethod render-no-bar ($screen, $x, $day, $highlight) {

        my $today   = Date.today.daycount;
        my $max-y   = $!graph-height;
        
        for 1 .. $max-y - 1 -> $y {
            $grid.change-cell($x, $y, ' ');  
        }

        my $add-bold = ($highlight) ?? 'bold ' !! '';

        given $day {
            when $_ < $today {
                $grid.change-cell($x, $max-y, %(char => $!no-bar-char, color => $add-bold ~ $.colour.past));
            }
            when $today {
                $grid.change-cell($x, $max-y, %(char => $!no-bar-char, color => $add-bold ~ $.colour.now));
            }
            when $_ > $today {
                $grid.change-cell($x, $max-y, %(char => $!no-bar-char, color => $add-bold ~ $.colour.next));
            }
        } 
    }

    submethod render-bar ($screen, $x, @entries, $highlight) {

        my $y = $!graph-height;

        my $add-bold = ($highlight) ?? 'bold ' !! '';

        for @entries -> $entry {
            given $entry {
                when .is-pinned {
                    $screen.grid.change-cell($x, $y, %(char => $!bar-char, color => $add-bold ~ $.colour.pinned));
                }
                when .is-past {
                    $screen.grid.change-cell($x, $y, %(char => $!bar-char, color => $add-bold ~ $.colour.past));
                }
                when .is-now {
                    $screen.grid.change-cell($x, $y, %(char => $!bar-char, color => $add-bold ~ $.colour.now));
                }
                when .is-next {
                    $screen.grid.change-cell($x, $y, %(char => $!bar-char, color => $add-bold ~ $.colour.next));
                }
            }
            $y--;
            last if $y == 0;
        }
        
        for 1 .. $y -> $y-padding {
            $screen.grid.change-cell($x, $y-padding, ' ');
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

