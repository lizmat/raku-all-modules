my @constants;
my @functions;
my @classes;

my @comments;
my @declarations;

my $comment;
my $id = 0;

for 'lib/Native/LibC.pm6'.IO.lines {
    next unless $_;
    $comment = /^ \s* '#|' \s+ (.+) / ?? ~$0 !! Nil;

    given $_ {
        when /^ \s* [our|multi] \s+ sub \s+ / { @functions.push($id) }
        when /^ \s* constant \s+ / { @constants.push($id) }
        when /^ \s* class \s+ / { next if / '...' /; @classes.push($id) }
        when /^ \s* method \s+ / { @classes.push($id) }
        default { next }
    }

    @comments[$id] = $comment;
    @declarations[$id] = $_ ~ do given .chomp.substr(*-1) {
        when '(' { ' * );' }
        when '{' { ' * }' }
        default { '' }
    }

    ++$id;
}

multi dump(@list) {
    say "{ @declarations[$_] }\n{ @comments[$_] // '' }" for @list;
}

multi dump {
    say "\n## Constants\n";
    dump @constants;

    say "\n## Functions\n";
    dump @functions;

    say "\n## Classes\n";
    dump @classes;
}

for $*IN.lines {
    if / __API__  / { dump }
    else { .say }
}
