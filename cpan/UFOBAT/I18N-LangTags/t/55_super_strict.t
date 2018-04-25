use v6.c;
use Test;
use I18N::LangTags;

my $in = q:to/END/;
 NIX => NIX
  sv => sv
  en => en
 hai => hai

          pt-br => pt-br pt
       pt-br fr => pt-br fr pt
    pt-br fr pt => pt-br fr pt
 pt-br fr pt de => pt-br fr pt de
 de pt-br fr pt => de pt-br fr pt
    de pt-br fr => de pt-br fr pt
   hai pt-br fr => hai pt-br fr  pt

# Now test multi-part complicateds:
   pt-br-janeiro fr => pt-br-janeiro fr pt-br pt
pt-br-janeiro de fr => pt-br-janeiro de fr pt-br pt
pt-br-janeiro de pt fr => pt-br-janeiro de pt fr pt-br

ja    pt-br-janeiro fr => ja pt-br-janeiro fr pt-br pt
ja pt-br-janeiro de fr => ja pt-br-janeiro de fr pt-br pt
ja pt-br-janeiro de pt fr => ja pt-br-janeiro de pt fr pt-br

pt-br-janeiro de pt-br fr => pt-br-janeiro de pt-br fr pt
 # an odd case, since we don't filter for uniqueness in this sub
END

for $in.lines.grep(*.so) -> $line {
    next unless $line ~~ m/ ^ \s* (.*?) \s* '=>' \s* (.*?) \s* $ /;
    my @in     = $/[0].Str.comb( /[<alnum>||'-']+/ );
    my @should = $/[1].Str.comb( /[<alnum>||'-']+/ );
    my @out    = implicate_supers_strictly(|@in);
    exit unless is-deeply @out, @should, "implicate_supers_strictly for {@in}";
}

done-testing;
