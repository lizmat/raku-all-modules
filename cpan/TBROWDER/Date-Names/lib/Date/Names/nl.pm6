unit module Date::Names::nl;

#********
# <name of your language in its native script>
# Dutch
#********

# IMPORTANT:
#
# All valid month and weekday name and abbreviation arrays must have
# either twelve (12) or seven (7) elements, respectively.  Arrays
# without month or day values MUST be completely empty as are the ones
# shown below.

# Note the standard eight arrays should exist in the file (see Table 2
# in the README for the correct names). They may be empty, but there
# should be eight (8) total arrays.

# To be an acceptable language for Date::Names, there must be defined completely
# at least one of the standard abbreviation sets for both months and weekdays
# in order to provide a default abbreviation set for the user in the
# event another abbreviation set is desired but not available.

#=== FULL NAMES ======================================================
# 1
our $mon = <
    januari    februari  maart     april
    mei        juni      juli      augustus
    september  oktober   november  december
>;

# 2
our $dow = <
    maandag  dinsdag   woensdag  donderdag
    vrijdag  zaterdag  zondag
>;

#=== THREE-LETTER ABBREVIATIONS ======================================
# 3
our $mon3 = <
    jan  feb  maa  apr
    mei  jun  jul  aug
    sep  okt  nov  dec
>;

# 4
our $dow3 = <
    maa  din  woe  don
    vri  zat  zon
>;

#=== TWO-LETTER ABBREVIATIONS ========================================
# 5
our $mon2  = <
>;

# 6
our $dow2 = <
    ma  di  wo  do
    vr  za  zo
>;


#=== MIXED-LENGTH ABBREVIATIONS ======================================
# 7
our $mona  = <
>;

# 8
our $dowa  = <
>;
