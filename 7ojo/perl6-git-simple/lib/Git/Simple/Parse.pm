use v6;

class Git::Simple::Parse {

    method status(Str :$out!) returns Hash {
        my %res;
        if $out && $out.Str.lines[0] ~~ / ^\#**2 \s
            $<local> = [ \S+? ]  # local branch
            [
                \.**3
                $<remote> = [ \S+ ] # remote branch
                \s? [ \[ahead \s
                $<ahead> = \d+      # ahead nr of commits
                [ \,\s ]?
                [ behind \s
                $<behind> = \d+     # behind nr of commits
                ]?
                \]
                ]?                  # ahead+behind is optional
            ]?
            $$ /
        {
            %res = $/.hash;
        }
        %res;
    }

}
