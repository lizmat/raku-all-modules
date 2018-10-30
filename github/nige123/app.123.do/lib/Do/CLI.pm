#!/usr/bin/env perl6

#---------------------------------------------------------------------------------------
#
# 123 - a timeline to help your work flow: do -> doing -> done
#
# Author:               Nigel Hamilton (nige@123.do)
# Copyright licence:    Artistic 2.0
#
#---------------------------------------------------------------------------------------

use Do;
use Terminal::ANSIColor;

unit module Do::CLI;

# mark all MAIN methods as exported
proto MAIN(|) is export {*}

sub USAGE is export {
    
    say q:to"USAGE";

    123 - a timeline to help your work flow: do, doing, done

        shell> 123 do    Add a task to do later today       
        shell> 123 doing Add a task for doing now
        shell> 123 done  Add a task done earlier today
        
        shell> 123 +1 Add a task to do tomorrow
        shell> 123 -1 Add a task completed yesterday 
        shell> 123 25/12/2020 Happy Christmas           # pin a task or event to a specific date
        
        shell> 123 now                                  # show what you're doing now
        shell> 123 yesterday                            # show tasks completed yesterday
        shell> 123 +1                                   # show tasks to do tomorrow
        shell> 123 25/12/2020                           # show a specific date

        shell> 123 done 777 888                         # move tasks with id 777 and 888 to done earlier today
        shell> 123 mv 777 -                             # same as above
        shell> 123 mv 777 -1                            # move task with id 777 to done yesterday
        shell> 123 doing 777                            # move task to doing Now - only one task at a time
        shell> 123 mv 777 +                             # move to later today
        shell> 123 mv 777 tomorrow                      # move to tomorrow

        shell> 123 rm 777 888                           # delete tasks with id 777 and 888

        shell> 123 find <search terms>                  # search for matching entries
        shell> 123 edit                                 # 'jmp' to your editor to make bulk changes
        shell> 123 edit 777                             # edit task with id 777

    USAGE

}


my $do-file-location = find-nearest-file();

my $do = Do.new(file => $do-file-location);

sub find-nearest-file {

    my $file-path = $*CWD.path;

    my $loop-counter;
    
    loop {
        my $do-file = $file-path.IO.add('123.do');
        return $do-file.path if $do-file.IO.e;
        $file-path = $file-path.IO.parent;
        last if $do-file.path eq '/123.do';
        $loop-counter++;
        last if $loop-counter > 20; # protect against infinite loop
    }
    
    # default to the user's home directory
    return $*HOME.path.IO.add('123.do');
    
}


# show a section of the timeline
multi sub MAIN ($arg1 where /<Do::Timeline::Grammar::entry>/) {

    my $m = Do::Timeline::Grammar.parse($arg1, :actions(Do::Timeline::Grammar::Actions), :rule('entry'));
    my $icon           = $m<entry-icon>.made;
    my $move-to-offset = $m<move-to-offset>.made // 0;

    say $do.render-day($icon, $move-to-offset);
}

# add to a section of the timeline
multi sub MAIN ($arg1 where /<Do::Timeline::Grammar::entry>/, *@entry) {

    my $m = Do::Timeline::Grammar.parse($arg1, :actions(Do::Timeline::Grammar::Actions), :rule('entry'));
    my $icon           = $m<entry-icon>.made;
    my $move-to-offset = $m<move-to-offset>.made // 0;

    $do.add($icon, $move-to-offset, join(' ', @entry));
    say $do.render-day($icon, $move-to-offset);
}

# move an entry on the timeline
multi sub MAIN ($entry-id, $arg2 where /<Do::Timeline::Grammar::entry>/)  {   

    my $m = Do::Timeline::Grammar.parse($arg2, :actions(Do::Timeline::Grammar::Actions), :rule('entry'));
    my $icon           = $m<entry-icon>.made;
    my $move-to-offset = $m<move-to-offset>.made // 0;

    $do.move($entry-id, $icon, $move-to-offset);
    say $do.render-day($icon, $move-to-offset);

}

multi sub MAIN ('mv', $entry-id, $arg2 where /<Do::Timeline::Grammar::entry>/)  {   

    MAIN($entry-id, $arg2);
}

# show a specfic date in the timeline
multi sub MAIN ($date where /<Do::Timeline::Grammar::date>/)  {   

    my $m = Do::Timeline::Grammar.parse($date, :actions(Do::Timeline::Grammar::Actions), :rule('date'));
    say $do.render-day($m.made.daycount);

}

# add an entry and ^ pin it to a specfic date in the timeline
multi sub MAIN ($date where /<Do::Timeline::Grammar::date>/, *@entry) {   

    my $m = Do::Timeline::Grammar.parse($date, :actions(Do::Timeline::Grammar::Actions), :rule('date'));
    $do.add($m.made, join(' ', @entry));
    say $do.render-day($m.made.daycount);

}

# for those that don't like todo sigils
multi sub MAIN ('tomorrow', *@entry) { MAIN('+1', @entry) }
multi sub MAIN ('today',    *@entry) { MAIN('!',  @entry) }
multi sub MAIN ('now',      *@entry) { MAIN('!',  @entry) }
multi sub MAIN ('yesterday',*@entry) { MAIN('-1', @entry) }

# change the status of entries
multi sub MAIN ('do',    *@entry-ids where { $_.all ~~ UInt }) { $do.move($_, '+') for @entry-ids; MAIN('+'); }
multi sub MAIN ('doing', *@entry-ids where { $_.all ~~ UInt }) { $do.move($_, '!') for @entry-ids; MAIN('!'); }
multi sub MAIN ('done',  *@entry-ids where { $_.all ~~ UInt }) { $do.move($_, '-') for @entry-ids; MAIN('-'); }

# add new entries
multi sub MAIN ('do',    *@entry) { MAIN('+',  @entry) }
multi sub MAIN ('doing', *@entry) { MAIN('!',  @entry) }
multi sub MAIN ('done',  *@entry) { MAIN('-',  @entry) }

multi sub MAIN ('mv', UInt $entry-id, 'today')        { MAIN($entry-id, '!')  }
multi sub MAIN ('mv', UInt $entry-id, 'now')          { MAIN($entry-id, '!')  }
multi sub MAIN ('mv', UInt $entry-id, 'yesterday')    { MAIN($entry-id, '-1') }
multi sub MAIN ('mv', UInt $entry-id, 'tomorrow')     { MAIN($entry-id, '+1') }

# show a day
multi sub MAIN ('do')           { MAIN('+')     }
multi sub MAIN ('doing')        { MAIN('!')     }
multi sub MAIN ('done')         { MAIN('-')     }

multi sub MAIN ('tomorrow')     { MAIN('+1')    }
multi sub MAIN ('today')        { MAIN('!')     }
multi sub MAIN ('now')          { MAIN('!')     }
multi sub MAIN ('status')       { MAIN('!')     }   # for git muscle memory
multi sub MAIN ('yesterday')    { MAIN('-1')    }


# search for matching entries
multi sub MAIN ('find', *@search-terms) {

    my $search-terms = @search-terms.join(' ');
    if my %matching-timeline-entries = $do.find($search-terms) {
        my $timeline-section = $do.render(%matching-timeline-entries);
        say $timeline-section.subst($search-terms, color('inverse') ~ $search-terms ~ color('reset'), :g);
    }
    else {
        say "Nothing matched.";
    }

}


# change the 123.do file with your favourite $EDITOR
multi sub MAIN ('edit') { $do.edit; }

# look for a specific entry id - and drop the user off there
multi sub MAIN ('edit', UInt $entry-id) { $do.edit($entry-id); }

# remove one or more entries from the timeline
multi sub MAIN ('rm', *@entry-ids where { $_.all ~~ UInt }) {

    my $last-entry-day = 0;

    for @entry-ids -> $entry-id {
        if my $entry = $do.get-entry($entry-id) {
            $last-entry-day = $entry.daycount;
            $do.remove($entry-id);
        }
        else {
            say "No entry matching $entry-id";
        }
    } 

    # show the day the entry was previously on
    say $do.render-day($last-entry-day);

}

