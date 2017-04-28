
use Git::Log::Parser;

my sub find-git {
    my $gitdir = qx/which git/;
    $gitdir.=chomp;
    die "No git executable found" unless $gitdir;
    return $gitdir;
}

class Git::Wrapper {
    has $.gitdir = !!! 'gitdir required';
    has $.git-executable = find-git;              # which git

    method run($subcommand, *@positionals, *%named) {
        my $old-dir = $*CWD;
        my @optstr = map -> $k,$v {
            $v eqv Bool::True
                ?? do { $k.chars > 1 ?? "--$k" !! "-$k" }
                !! "--$k=$v"
        }, %named.kv;
        @positionals.unshift(|@optstr) if ?@optstr;
        my $p = run :out, :err, :cwd($.gitdir), $.git-executable, $subcommand, |@positionals;
        my @out = $p.out.slurp-rest;
        return @out;
    }

    method is-repo() {
        (self.run('status').join.chomp eq "")
            ?? False
            !! True
    }

    method version() {
        return self.run('version').Str.chomp;
    }

    method log(*@p, *%n) {
        %n<date> = "iso8601";
        my @output = self.run('log', |@p, |%n);
        my $log-parser = Git::Log::Parser.parse(@output.join, :actions(Git::Log::Actions.new));
        return $log-parser.made.list;
    }

    method clone(*@p, *%n) {
        return self.run('clone', |@p, |%n);
    }

    for <init branch checkout add pull rebase reset push fetch commit show status diff grep merge mv rm tag> -> $method {
        Git::Wrapper.HOW.add_method(Git::Wrapper, $method, anon method (*@p, *%n) {
            return self.run($method, |@p, |%n);
        });
    }

}
