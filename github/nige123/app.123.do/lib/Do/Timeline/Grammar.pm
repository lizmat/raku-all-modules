#!/usr/bin/env perl6

#use Grammar::Debugger; # uncomment this to turn on tracing
use Do::Timeline::Grammar::Actions;

grammar Do::Timeline::Grammar {

    # the timeline has one or more sections containing entries
    rule  TOP               { <ws> <timeline-section>+                                                                      }
    rule  timeline-section  { <heading> <entry>*                                                                            }
#   rule  timeline-section  { <heading> <entry>*  || <error('timeline section failed to parse')>                            }

    # each section has a heading with a date and number of days relative to now
    token heading           { ^^ [ <relative-day> | <day-of-week> ] \s+ '(' <date> ')' \s* [ <days-away> | <days-ago> ]?    }
    token relative-day      { 'Yesterday' | 'Earlier Today' | 'NOW' | 'Later Today' | 'Tomorrow'                            }
    token day-of-week       { 'Monday' | 'Tuesday' | 'Wednesday' | 'Thursday' | 'Friday' | 'Saturday' | 'Sunday'            }
    token date              { <day> '/' <month> '/' <year>                                                                  }
    token day               { \d\d?                                                                                         }
    token month             { \d\d?                                                                                         }
    token year              { \d\d\d\d                                                                                      }
    rule  days-away         { '[' <day-count> [ 'day' | 'days' ] 'away]'                                                    }  
    rule  days-ago          { '[' <day-count> [ 'day' | 'days' ] 'ago]'                                                     }  
    token day-count         { \d+                                                                                           }

    # each entry begins with an icon: !+- and optionally an offset to move it to and some entry text
    rule  entry             { <entry-icon> <move-to-offset>? <entry-id>? <entry-text>                                       }
    token entry-icon        { ^^ <[!+^-]>                                                                                   }
    token move-to-offset    { \d+                                                                                           }
    token entry-id          { '[' <id> ']'                                                                                  }
    token id                { \s*\d+\s*                                                                                     }
    token entry-text        { .*? <?before [ <entry-icon> | <heading> | $]>                                                 }   

    method error ($message) { 
        my $parsed-so-far = self.target.substr(0, self.pos);
        my @lines = $parsed-so-far.lines;
        note "123.do file doesn't look right: $message at line @lines.elems(), after '@lines[*-1]'. Please manually edit the file to fix.";
        exit;
    }

    method parse-timeline ($file) {
        my $m = self.parsefile($file, :actions(Do::Timeline::Grammar::Actions));
        unless $m {
            note "$file is not a valid 123.do file. Please check the format of the file: $file";
            exit;
        }   
        return $m.made;
    }
}
