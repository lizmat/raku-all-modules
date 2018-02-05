unit class CoreHackers::Q;
use CoreHackers::Q::Parser;

method run (@args, :$opt) {
    @args.splice: 1, 0, ['--target=' ~ ($opt ?? 'optimize' !! 'ast')];
    my $source = (run @args, :out).out.slurp: :close;
    say CoreHackers::Q::Parser.new.view: ~@args.map({
        /\s/ ?? "'$_'" !! $_
    }), $source;
}

method zero-run(@args) { run @args }
