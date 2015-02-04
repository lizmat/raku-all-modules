
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
        chdir($.gitdir);
        my $optstr = join " ", map -> $k,$v { $v eqv Bool::True ??  "-$k" !! "--$k='$v'" }, %named.kv;
        @positionals.push(".") if $subcommand eq 'clone' && +@positionals == 1;
        my $git-cmd = "$.git-executable $subcommand $optstr @positionals[] 2>/dev/null";
        my $p = open $git-cmd, :p or die;
        my @out = $p.slurp-rest;
        chdir($old-dir);
        return @out;
    }

    method version() {
        return self.run('version');
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

