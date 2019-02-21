unit module Date::Names::es;

#********
# <name of your language in its native script>
# Spanish
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
    enero       febrero  marzo      abril
    mayo        junio    julio      agosto
    septiembre  octubre  noviembre  diciembre
>;

# 2
our $dow = <
     lunes    martes  miércoles  jueves
     viernes  sábado  domingo
>;

#=== THREE-LETTER ABBREVIATIONS ======================================
# 3
our $mon3 = <
     ene   feb   mar   abr
     may   jun   jul   ago
     sep   oct   nov   dic
>;

# 4
our $dow3 = <
     lun  mar  mié  jue
     vie  sáb  dom
>;

#=== TWO-LETTER ABBREVIATIONS ========================================
# 5
our $mon2 = <
     en   fb   mr   ab
     my   jn   jl   ag
     sp   oc   nv   dc
>;

# 6
our $dow2 = <
     lu  ma  mi  ju
     vi  sá  do
>;

#=== MIXED-LENGTH ABBREVIATIONS ======================================
# 7
our $mona = <
     en.     febr.   mzo.    abr.
     my.     jun.    jul.    ag.
     sept.   oct.    nov.    dic.
>;

# 8
our $dowa = <
     lun.   mart.   miér.  juev.
     vier.  sáb.    dom.
>;
