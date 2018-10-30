#!/usr/bin/env perl6

#---------------------------------------------------------------------------------------
#
# 123 - a timeline to help your work flow: do -> doing -> done
#
# Author:               Nigel Hamilton (nige@123.do)
# Copyright licence:    Artistic 2.0
#
#---------------------------------------------------------------------------------------

use Do::Editor;
use Do::Timeline::Entry;
use Do::Timeline::Grammar;
use Do::Timeline::Viewport;

class Do::Timeline does Do::Timeline::Viewport {

    has $.file;
    has %.entries;

    multi method add ($icon, $move-to-offset, $entry-text) {
        my $entry = Do::Timeline::Entry.new(
                       id       => self.new-entry-id, 
                       icon     => $icon, 
                       text     => $entry-text,
                       daycount => get-daycount($icon, $move-to-offset)
                    );
        self.add($entry);
    }

    multi method add (Date $date, $entry-text) {
        my $move-to-offset = Date.today.daycount - $date.daycount;
        if $move-to-offset > 0 {
            # the - icon will pin it to the past
            self.add('-', $move-to-offset, $entry-text);
        }
        else {
            # the ^ icon will pin it to the future
            self.add('^', $move-to-offset * -1, $entry-text);
        }
    }

    multi method add (Do::Timeline::Entry $entry) {
        given $entry.icon {
            when '-' { 
                %!entries{$entry.daycount}.push($entry);
            }
            when '!' {
                %!entries{$entry.daycount}.unshift($entry);
                # only one now entry at a time 
                # push any other Now entries to Later Today 
                self.limit-now-entries;
            }
            when '+' {
                # add it to the start of the Next section
                # may cause other entries to move forward
                %!entries{$entry.daycount}.unshift($entry);
                self.limit-next-entries;
            }
            when '^' {
                # pin it to the given day
                %!entries{$entry.daycount}.unshift($entry);
            }
        }
        self.save;
    }

    submethod open-editor-at-line ($line-number = 1) {
        # time may have passed since the last edit
        # refresh the timeline view relative to NOW
        self.load;
        self.save;

        Do::Editor.new.open($!file, $line-number);

        # reload the 123.do file and save any changes
        self.load;
        self.save;
    }

    multi method edit (UInt $entry-id) {
        # where is entry-id in the file?
        my $entry-at-line = $.file.IO.slurp.match(/^ .*? '[' $entry-id ']'/).lines.elems // 1;    
        self.open-editor-at-line($entry-at-line);
    }
    
    multi method edit {
        # which line is NOW on in the 123.do file?
        my $now-at-line = $.file.IO.slurp.match(/^.*?^^NOW/).lines.elems // 0;
        self.open-editor-at-line(1 + $now-at-line);
    }

    submethod estimate-tasks-per-day {
        my %past-entries = self.entries.values.map(*.Slip).grep(*.is-past).classify(*.daycount);

        # default to 6 tasks per day
        return 6 unless %past-entries;

        my @past-day-entry-counts = %past-entries.values.map(*.elems);

        # average daily velocity previously in the past    
        return @past-day-entry-counts.sum div @past-day-entry-counts.elems; 
    }

    method find ($search-terms) {
        return %() unless my @found-entries = self.entries.values.map(*.Slip).grep(*.text.match($search-terms));
        return @found-entries.classify({$_.daycount});
    }
    
    sub get-daycount ($icon, $move-to-offset) {
        my $today = Date.today.daycount;
        given $icon {
            when '-' { return $today - $move-to-offset }
            when '!' { return $today                   }
            when '+' { return $today + $move-to-offset }
            when '^' { return $today + $move-to-offset }
        }
    }

    method get-entry ($entry-id) {
        # look for a matching entry
        return self.entries.values.map(*.Slip).grep(*.id == $entry-id).first;
    }

    submethod init {
        self.add('-', 0, 'past entries start with a -');
        self.add('!', 0, 'now entry starts with a ! Only one at a time');
        self.add('+', 0, 'next entries start with a + ');
    }

    submethod limit-now-entries {
        my ($first-entry, @extra-now-entries) = |%!entries{Date.today.daycount}.grep(*.is-now);
        
        # move to later today
        self.move($_.id, '+', 0) for @extra-now-entries;
    }

    submethod get-next-entries {
        my $today = Date.today.daycount;
        my @next-entries;
        
        for self.entries.keys.grep(* >= $today).sort -> $day {
            for self.entries{$day}.list -> $entry {
                push(@next-entries, $entry) if $entry.is-next;
            }
        }
        return @next-entries;
    }

    submethod limit-next-entries {

        # apply a daily velocity to next entries - based on the estimated tasks per day
        return unless my @next-entries = self.get-next-entries;

        my $current-daycount        = Date.today.daycount;
        my $tasks-per-day           = self.estimate-tasks-per-day;
        my $current-day-spaces-left = $tasks-per-day;

        for @next-entries -> $next-entry {
            if $current-day-spaces-left {
                $next-entry.set-daycount($current-daycount);
            }
            else {
                # this day is filled up - move onto the next one
                $current-daycount++;
                $next-entry.set-daycount($current-daycount);
                $current-day-spaces-left = $tasks-per-day;
            }  

            $current-day-spaces-left--;

            LAST {
                # reassign the entries to their proper days
                %!entries = self.entries.values.map(*.Slip).classify(*.daycount);
            }
        }
    }

    method load {
        self.init unless $.file.IO.e;

        %!entries = Do::Timeline::Grammar.parse-timeline($.file);     
        
        # assign new ids to any entries that don't have them
        self.entries.values.map(*.Slip).grep({ not $_.id }).map({ $_.id = self.new-entry-id });

        # make sure there is only one entry in NOW
        self.limit-now-entries;

        # push entries onto the next day if greater than average daily velocity
        self.limit-next-entries;
    }
    
    method move ($entry-id, $icon, $move-to-offset = 0) {
        return unless my $entry = self.get-entry($entry-id);

        # remove the existing entry 
        self.remove($entry-id);

        # add a new entry based on the old entry
        self.add(
            Do::Timeline::Entry.new( 
                id       => $entry-id,
                icon     => $icon,
                text     => $entry.text,
                daycount => get-daycount($icon, $move-to-offset)
            )
        );
        self.save;
    }

    submethod new-entry-id {
        return 1 unless self.entries;
        return 1 + self.entries.values.map(*.Slip).map(*.id).max;
    }

    method remove ($entry-id) {
        return unless my $entry = self.get-entry($entry-id);
        if my @remaining-entries = |%!entries{$entry.daycount}.grep(*.id != $entry-id) {
            %!entries{$entry.daycount} = @remaining-entries;
        }   
        else {
            %!entries{$entry.daycount}:delete;
        }
        self.save;
    }

    method save { 
        self.file.IO.spurt(self.render); 
    }
}

