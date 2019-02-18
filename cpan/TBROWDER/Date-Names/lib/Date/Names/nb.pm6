unit module Date::Names::nb;

#**********
# Bokmål
# Norwegian
#**********

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
constant $mon = <
    januar      februar   mars      april
    mai         juni      juli      august
    september   oktober   november  desember
>;

constant $dow = <
     mandag  tirsdag onsdag torsdag
     fredag  lørdag  søndag
>;

#=== THREE-LETTER ABBREVIATIONS ======================================
# 3
constant $mon3 = <
>;

# 4
constant $dow3 = <
>;


#=== TWO-LETTER ABBREVIATIONS ========================================
# 5
constant $mon2  = <
>;

# 6
constant $dow2 = <
>;

#=== MIXED-LENGTH ABBREVIATIONS ======================================
# 7
constant $mona  = <
>;

# 8
constant $dowa  = <
>;
