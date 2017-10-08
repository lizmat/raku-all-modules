use v6;
use Git::Simple::Parse;

class Git::Simple {

    has Str $.cwd = '.';

    method branch-info returns Hash {
        my $proc = run <git -C>, $.cwd, <status --porcelain -b>, :out, :err;
        return Hash.new if $proc.err.slurp-rest.lines;
        my %info = Git::Simple::Parse.new.status(out => $proc.out.slurp-rest);
        if (%info.elems == 0) { # detached branch
            $proc = run <git -C>, $.cwd, <describe --tags --always>, :out, :err;
            if ($proc.err.slurp-rest.lines) {
                %info<local> = 'Big Bang'; # initial repository
            } else {
                %info<local> = $proc.out.slurp-rest.lines[0]; # right?
            }
        }
        %info;
    }

}
