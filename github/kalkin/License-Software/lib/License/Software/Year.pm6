subset MyDateish of Dateish where
{
    .year >= 0 or warn "Licensing year Dateish value must be *.year >= 0"
};

subset YearRange of Range where {
    .is-int and all(.int-bounds) >= 0 or
        warn "Licensing YearRange both endpoints must be Int values and have bounds 0.." ;
};

subset License::Software::Year where UInt | MyDateish | YearRange;

