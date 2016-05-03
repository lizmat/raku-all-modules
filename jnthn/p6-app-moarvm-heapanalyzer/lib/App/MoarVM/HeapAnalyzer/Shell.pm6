use App::MoarVM::HeapAnalyzer::Model;

unit class App::MoarVM::HeapAnalyzer::Shell;

has $.model;

method interactive(IO::Path $file) {
    whine("No such file '$file'") unless $file.e;

    print "Considering the snapshot...";
    $*OUT.flush;
    try {
        $!model = App::MoarVM::HeapAnalyzer::Model.new(:$file);
        CATCH {
            say "oops!\n";
            whine(.message);
        }
    }
    say "looks reasonable!\n";

    my $current-snapshot;
    given $!model.num-snapshots {
        when 0 {
            whine "This file contains no heap snapshots.";
        }
        when 1 {
            say "This file contains 1 heap snapshot. I've selected it for you.";
            $current-snapshot = 0;
            $!model.prepare-snapshot($current-snapshot);
        }
        default {
            say "This file contains $_ heap snapshots. To select one to look\n"
              ~ "at, type something like `snapshot {^$_ .pick}`.";
        }
    }
    say "Type `help` for available commands, or `exit` to exit.\n";
    
    loop {
        sub with-current-snapshot(&code) {
            without $current-snapshot {
                die "Please select a snapshot to use this instruction (`snapshot <n>`)";
            }
            if $!model.prepare-snapshot($current-snapshot) == SnapshotStatus::Preparing {
                say "Wait a moment, while I finish loading the snapshot...\n";
            }
            code($!model.get-snapshot($current-snapshot))
        }

        my constant %kind-map = hash
            objects => CollectableKind::Object,
            stables => CollectableKind::STable,
            frames  => CollectableKind::Frame;

        given prompt "> " {
            when /^ \s* snapshot \s+ (\d+) \s* $/ {
                $current-snapshot = $0.Int;
                if $!model.prepare-snapshot($current-snapshot) == SnapshotStatus::Preparing {
                    say "Loading that snapshot. Carry on..."
                }
                else {
                    say "Snapshot loaded and ready."
                }
            }
            when 'summary' {
                with-current-snapshot -> $s {
                    say qq:to/SUMMARY/;
                        Total heap size:              &size($s.total-size)

                        Total objects:                &mag($s.num-objects)
                        Total type objects:           &mag($s.num-type-objects)
                        Total STables (type tables):  &mag($s.num-stables)
                        Total frames:                 &mag($s.num-frames)
                        Total references:             &mag($s.num-references)
                    SUMMARY
                }
            }
            when /^ top \s+ [(\d+)\s+]?
                    (< objects stables frames >)
                    [\s+ 'by' \s+ (< size count >)]? \s* 
                    $/ {
                my $n = $0 ?? $0.Int !! 15;
                my $what = ~$1;
                my $by = $2 ?? ~$2 !! 'size';
                with-current-snapshot -> $s {
                    say table
                        $s."top-by-$by"($n, %kind-map{$what}),
                        $by eq 'count'
                            ?? [ Name => Any, Count => &mag ]
                            !! [ Name => Any, 'Total Bytes' => &size ]
                }
            }
            when /^ find \s+ [(\d+)\s+]? (< objects stables frames >) \s+
                    (< type repr name >) \s* '=' \s* \" ~ \" (<-["]>+) \s*
                    $ / {
                my $n = $0 ?? $0.Int !! 15;
                my ($what, $cond, $value) = ~$1, ~$2, ~$3;
                with-current-snapshot -> $s {
                    say table
                        $s.find($n, %kind-map{$what}, $cond, $value),
                        [ 'Object Id' => Any, 'Description' => Any ];
                }
            }
            when /^ count \s+ (< objects stables frames >) \s+
                    (< type repr name >) \s* '=' \s* \" ~ \" (<-["]>+) \s*
                    $ / {
                my ($what, $cond, $value) = ~$0, ~$1, ~$2;
                with-current-snapshot -> $s {
                    say +$s.find(0xFFFFFFFF, %kind-map{$what}, $cond, $value);
                }
            }
            when /^ path \s+ (\d+) \s* $/ {
                my $idx = $0.Int;
                with-current-snapshot -> $s {
                    my @path = $s.path($idx);
                    my @pieces = @path.shift();
                    for @path -> $route, $target {
                        @pieces.push("    --[ $route ]-->");
                        @pieces.push($target)
                    }
                    say @pieces.join("\n") ~ "\n";
                }
            }
            when 'help' {
                say help();
            }
            when 'exit' {
                exit 0;
            }
            default {
                say "Sorry, I don't understand.";
            }
        }
        CATCH {
            default {
                say "Oops: " ~ .message;
            }
        }
    }
}

sub size($n) {
    mag($n) ~ ' bytes'
}

sub mag($n) {
    $n.Str.flip.comb(3).join(',').flip
}

sub table(@data, @columns) {
    my @formatters = @columns>>.value;
    my @formatted-data = @data.map(-> @row {
        list @row.pairs.map({
            @formatters[.key] ~~ Callable
                ?? @formatters[.key](.value)
                !! .value
        })
    });

    my @names = @columns>>.key;
    my @col-widths = ^@columns
        .map({ (flat $@names, @formatted-data)>>.[$_]>>.chars.max });

    my @pieces;
    for ^@columns -> $i {
        push @pieces, @names[$i];
        push @pieces, ' ' x 2 + @col-widths[$i] - @names[$i].chars;
    }
    push @pieces, "\n";
    for ^@columns -> $i {
        push @pieces, '=' x @col-widths[$i];
        push @pieces, "  ";
    }
    push @pieces, "\n";
    for @formatted-data -> @row {
        for ^@columns -> $i {
            push @pieces, @row[$i];
            push @pieces, ' ' x 2 + @col-widths[$i] - @row[$i].chars;
        }
        push @pieces, "\n";
    }
    @pieces.join("")
}

sub help() {
    q:to/HELP/
    General:
        snapshot <n>
            Work with snapshot <n>
        exit
            Exit this application
    
    On the currently selected snapshot:
        summary
            Basic summary information
        top [<n>]? <what> [by size | by count]?
            Where <what> is objects, stables, or frames. By default, <n> is 15
            and they are ordered by their total memory size.
        find [<n>]? <what> [type="..." | repr="..." | name="..."]
            Where <what> is objects, stables, or frames. By default, <n> is 15.
            Finds objects matching the given type or REPR, or frames by name.
        path <objectid>
            Shortest path from the root to <objectid> (find these with `find`)
    HELP
}

sub whine ($msg) {
    note $msg;
    exit 1;
}
