grammar g{
    token alpha {<[2]>};
    token alpha1 {<[2]>};      # same as alpha but without internal car class conflict
    token beta { <[q]> };
    token delta {<+alpha +beta>};
    token delta1 {<+alpha>};
    token delta2 {<+alpha1 +beta>}
}
say so "2" ~~ /<g::delta1>/;   # OK
say so "2" ~~ /<g::delta2>/;   # OK
say so "2" ~~ /<g::delta>/;    # think wrong - should be true
say so "a" ~~ /<g::delta>/;    # true probably wrong but maybe understandable
