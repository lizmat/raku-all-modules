use SAT;

class SAT::Solver::Dummy does SAT::Solver {
    multi method solve (Supply $lines, $witness is rw, *% () --> Promise) {
        my $p = Promise.new;
        my $answer = $lines.map({ ~$/ if /:s the answer is <( \d+ )>/ }).first.wait;
        $witness = $answer / 2;
        # Magic: return a Bool to match the role's signature but
        # make it stringify to something that proves the above
        # code executed and obtained the correct $answer.
        # The `is` test will stringify it.
        $p.keep(True but $answer);
        $p
    }

    multi method solve (:$show-yourself where *.so, |c) {
        self
    }
}

class SAT::Counter::Dummy does SAT::Counter {
    multi method count (Supply $lines, *% () --> Promise) {
        my $p = Promise.new;
        my $answer = $lines.map({ ~$/ if /:s the answer is <( \d+ )>/ }).first.wait;
        $p.keep(+$answer but $answer);
        $p
    }

    multi method count (:$show-yourself where *.so, |c) {
        self
    }
}

class SAT::Enumerator::Dummy does SAT::Enumerator {
    multi method enumerate (Supply $lines, *% () --> Supply) {
        my $answer = $lines.map({ ~$/ if /:s the answer is <( \d+ )>/ }).first.wait;
        supply { emit $answer }
    }

    multi method enumerate (:$show-yourself where *.so, |c) {
        self
    }
}
