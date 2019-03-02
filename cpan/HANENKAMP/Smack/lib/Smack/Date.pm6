use v6;

unit module Smack::Date;

use DateTime::Format;

# TODO Move into HTTP::Date or similar. Also make sure it's correct.
sub time2str(DateTime:D $d) returns Str:D is export {
    strftime("%a, %d %b %Y %H:%M:%S GMT", $d.utc);
}
