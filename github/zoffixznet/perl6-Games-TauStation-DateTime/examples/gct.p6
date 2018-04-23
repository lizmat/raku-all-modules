
# 198.15/03:973 GCT = 2018-04-23T00:57:13.361615Z
my $d := DateTime.new: "2018-04-23T00:57:13.361615Z";

say $d.earlier(:seconds(
    198*100*24*60*60
    + 15*24*60*60
    + 3*24*60*60/100
    + 973*24*60*60/100000
))

=finish

use lib <lib ../lib>;

use Games::TauStation::DateTime;

# Show time in GCT or Old Earth time:
say GCT.new('193.99/59:586 GCT');    # OUTPUT: «193.99/59:586 GCT␤»
say GCT.new('193.99/59:586 GCT').OE; # OUTPUT: «2017-03-03T16:00:32.229148Z␤»

# Show duration from now:
say GCT.new('D12/43:044 GCT');    # OUTPUT: «198.27/19:285 GCT␤»
say GCT.new('D12/43:044 GCT').OE; # OUTPUT: «2018-05-05T06:20:12.543815Z␤»

# Adjust date using GCT or Old Earth time units:
say GCT.new('193.99/59:586 GCT').later(:30segments).earlier(:2hours);
# OUTPUT: «193.99/81:253 GCT␤»

# We inherit from DateTime class:
say GCT.new('2018-04-03T12:20:43Z');    # OUTPUT: «197.95/44:321 GCT␤»
say GCT.new('193.99/59:586 GCT').posix; # OUTPUT: «1488556832␤»

# Coerce to normal DateTime
say GCT.new('D12/43:044 GCT').DateTime;       # OUTPUT: «2018-05-05T06:29:14.494109Z␤»
say GCT.new('D12/43:044 GCT').DateTime.^name; # OUTPUT: «DateTime␤»
