unit class App::MoarVM::HeapAnalyzer::Model;

# We resolve the top-level data structures asynchronously.
has $!strings-promise;
has $!types-promise;
has $!static-frames-promise;

# Raw, unparsed, snapshot data.
has @!unparsed-snapshots;

# Promises that resolve to parsed snapshots.
has @!snapshot-promises;

# Holds and provides access to the types data set.
my class Types {
    has int @!repr-name-indexes;
    has int @!type-name-indexes;
    has @!strings;

    submethod BUILD(:@repr-name-indexes, int :@type-name-indexes, :@strings) {
        @!repr-name-indexes := @repr-name-indexes;
        @!type-name-indexes := @type-name-indexes;
        @!strings := @strings;
    }

    method repr-name(int $idx) {
        @!strings[@!repr-name-indexes[$idx]]
    }

    method type-name(int $idx) {
        @!strings[@!type-name-indexes[$idx]]
    }

    method all-with-type($name) {
        my int @found;
        with @!strings.first($name, :k) -> int $goal {
            my int $num-types = @!type-name-indexes.elems;
            loop (my int $i = 0; $i < $num-types; $i++) {
                @found.push($i) if @!type-name-indexes[$i] == $goal;
            }
        }
        @found
    }

    method all-with-repr($name) {
        my int @found;
        with @!strings.first($name, :k) -> int $goal {
            my int $num-types = @!repr-name-indexes.elems;
            loop (my int $i = 0; $i < $num-types; $i++) {
                @found.push($i) if @!repr-name-indexes[$i] == $goal;
            }
        }
        @found
    }
}

# Holds and provides access to the static frames data set.
my class StaticFrames {
    has int @!name-indexes;
    has int @!cuid-indexes;
    has int32 @!lines;
    has int @!file-indexes;
    has @!strings;

    submethod BUILD(:@name-indexes, :@cuid-indexes, :@lines, :@file-indexes, :@strings) {
        @!name-indexes := @name-indexes;
        @!cuid-indexes := @cuid-indexes;
        @!lines := @lines;
        @!file-indexes := @file-indexes;
        @!strings := @strings;
    }

    method summary(int $index) {
        my $name = @!strings[@!name-indexes[$index]] || '<anon>';
        my $line = @!lines[$index];
        my $path = @!strings[@!file-indexes[$index]];
        my $file = $path.split(/<[\\/]>/).tail;
        "$name ($file:$line)"
    }

    method all-with-name($name) {
        my int @found;
        with @!strings.first($name, :k) -> int $goal {
            my int $num-sf = @!name-indexes.elems;
            loop (my int $i = 0; $i < $num-sf; $i++) {
                @found.push($i) if @!name-indexes[$i] == $goal;
            }
        }
        @found
    }
}

# The various kinds of collectable.
my enum CollectableKind is export <<
    :Object(1) TypeObject STable Frame PermRoots InstanceRoots
    CStackRoots ThreadRoots Root InterGenerationalRoots CallStackRoots
>>;

my enum RefKind is export << :Unknown(0) Index String >>;

# Holds data about a snapshot and provides various query operations on it.
my class Snapshot {
    has int8 @!col-kinds;
    has int @!col-desc-indexes;
    has int16 @!col-size;
    has int @!col-unmanaged-size;
    has int @!col-refs-start;
    has int32 @!col-num-refs;

    has @!strings;
    has $!types;
    has $!static-frames;

    has $.num-objects;
    has $.num-type-objects;
    has $.num-stables;
    has $.num-frames;
    has $.total-size;

    has int8 @!ref-kinds;
    has int @!ref-indexes;
    has int @!ref-tos;

    has @!bfs-distances;
    has @!bfs-preds;
    has @!bfs-pred-refs;

    submethod BUILD(
        :@col-kinds, :@col-desc-indexes, :@col-size, :@col-unmanaged-size,
        :@col-refs-start, :@col-num-refs, :@strings, :$!types, :$!static-frames,
        :$!num-objects, :$!num-type-objects, :$!num-stables, :$!num-frames,
        :$!total-size, :@ref-kinds, :@ref-indexes, :@ref-tos
    ) {
        @!col-kinds := @col-kinds;
        @!col-desc-indexes := @col-desc-indexes;
        @!col-size := @col-size;
        @!col-unmanaged-size := @col-unmanaged-size;
        @!col-refs-start := @col-refs-start;
        @!col-num-refs := @col-num-refs;
        @!strings := @strings;
        @!ref-kinds := @ref-kinds;
        @!ref-indexes := @ref-indexes;
        @!ref-tos := @ref-tos;
    }

    method num-references() {
        @!ref-kinds.elems
    }

    method top-by-count(int $n, int $kind) {
        my %top;
        my int $num-cols = @!col-kinds.elems;
        loop (my int $i = 0; $i < $num-cols; $i++) {
            if @!col-kinds[$i] == $kind {
                %top{@!col-desc-indexes[$i]}++;
            }
        }
        self!munge-top-results(%top, $n, $kind)
    }

    method top-by-size(int $n, int $kind) {
        my %top;
        my int $num-cols = @!col-kinds.elems;
        loop (my int $i = 0; $i < $num-cols; $i++) {
            if @!col-kinds[$i] == $kind {
                %top{@!col-desc-indexes[$i]} += @!col-size[$i] + @!col-unmanaged-size[$i];
            }
        }
        self!munge-top-results(%top, $n, $kind)
    }
    
    method !munge-top-results(%top, int $n, int $kind) {
        my @raw-results = %top.sort(-*.value).head($n);
        if $kind == CollectableKind::Frame {
            @raw-results.map({
                [$!static-frames.summary(.key.Int), .value]
            })
        }
        else {
            @raw-results.map({
                [$!types.type-name(.key.Int), .value]
            })
        }
    }

    method find(int $n, int $kind, $cond, $value) {
        my int8 @matching;
        given $cond {
            when 'type' {
                @matching[$_] = 1 for $!types.all-with-type($value);
            }
            when 'repr' {
                @matching[$_] = 1 for $!types.all-with-repr($value);
            }
            when 'name' {
                @matching[$_] = 1 for $!static-frames.all-with-name($value);
            }
            default {
                die "Sorry, don't understand search condition $cond";
            }
        }

        my @results;
        my int $num-cols = @!col-kinds.elems;
        loop (my int $i = 0; $i < $num-cols; $i++) {
            if @!col-kinds[$i] == $kind && @matching[@!col-desc-indexes[$i]] {
                @results.push: [
                    $i,
                    $kind == CollectableKind::Frame
                        ?? $!static-frames.summary(@!col-desc-indexes[$i])
                        !! $!types.type-name(@!col-desc-indexes[$i])
                ];
                last if @results == $n;
            }
        }
        @results
    }

    method describe-col($cur-col) {
        unless $cur-col ~~ ^@!col-kinds.elems {
            die "No such collectable index $cur-col";
        }
        given @!col-kinds[$cur-col] {
            when Object {
                $!types.type-name(@!col-desc-indexes[$cur-col]) ~ ' (Object)'
            }
            when TypeObject {
                $!types.type-name(@!col-desc-indexes[$cur-col]) ~ ' (Type Object)'
            }
            when STable {
                $!types.type-name(@!col-desc-indexes[$cur-col]) ~ ' (STable)'
            }
            when Frame {
                $!static-frames.summary(@!col-desc-indexes[$cur-col]) ~ ' (Frame)'
            }
            when PermRoots { 'Permanent roots' }
            when InstanceRoots { 'VM Instance Roots' }
            when CStackRoots { 'C Stack Roots' }
            when ThreadRoots { 'Thread Roots' }
            when Root { 'Root' }
            when InterGenerationalRoots { 'Inter-generational Roots' }
            when CallStackRoots { 'Call Stack Roots' }
            default { '???' }
        }
    }

    method path($idx) {
        unless $idx ~~ ^@!col-kinds.elems {
            die "No such collectable index $idx";
        }
        self!ensure-bfs();

        my @path;
        my int $cur-col = $idx;
        until $cur-col == -1 {
            @path.unshift: self.describe-col($cur-col) ~ " ($cur-col)";

            my int $pred-ref = @!bfs-pred-refs[$cur-col];
            if $pred-ref >= 0 {
                @path.unshift: do given @!ref-kinds[$pred-ref] {
                    when String {
                        @!strings[@!ref-indexes[$pred-ref]]
                    }
                    when Index {
                        "Index @!ref-indexes[$pred-ref]"
                    }
                    default { 'Unknown' }
                }
            }

            $cur-col = @!bfs-preds[$cur-col];
        }

        @path
    }

    method details($idx) {
        unless $idx ~~ ^@!col-kinds.elems {
            die "No such collectable index $idx";
        }
        my @parts;

        @parts.push: self.describe-col($idx);

        my int $num-refs = @!col-num-refs[$idx];
        my int $refs-start = @!col-refs-start[$idx];
        loop (my int $i = 0; $i < $num-refs; $i++) {
            my int $ref-idx = $refs-start + $i;
            my int $to = @!ref-tos[$ref-idx];

            @parts.push: do given @!ref-kinds[$ref-idx] {
                when String {
                    @!strings[@!ref-indexes[$ref-idx]]
                }
                when Index {
                    "Index @!ref-indexes[$ref-idx]"
                }
                default { 'Unknown' }
            }
            @parts.push: self.describe-col($to) ~ " ($to)";
        }
        @parts;
    }

    method !ensure-bfs() {
        return if @!bfs-distances;

        my int32 @distances;
        my int @pred;
        my int @pred-ref;
        my int8 @color; # 0 = white, 1 = grey, 2 = black

        @color[0] = 1;
        @distances[0] = 0;
        @pred[0] = -1;
        @pred-ref[0] = -1;

        my int @queue;
        @queue.push(0);
        while @queue {
            my int $cur-col = @queue.shift;
            my int $num-refs = @!col-num-refs[$cur-col];
            my int $refs-start = @!col-refs-start[$cur-col];
            loop (my int $i = 0; $i < $num-refs; $i++) {
                my int $ref-idx = $refs-start + $i;
                my int $to = @!ref-tos[$ref-idx];
                if @color[$to] == 0 {
                    @color[$to] = 1;
                    @distances[$to] = @distances[$cur-col] + 1;
                    @pred[$to] = $cur-col;
                    @pred-ref[$to] = $ref-idx;
                    @queue.push($to);
                }
            }
            @color[$cur-col] = 2;
        }

        @!bfs-distances := @distances;
        @!bfs-preds := @pred;
        @!bfs-pred-refs := @pred-ref;
    }
}

submethod BUILD(IO::Path :$file = die "Must construct model with a file") {
    # Pull data from the file.
    my %top-level;
    my @snapshots;
    my $cur-snapshot-hash;
    for $file.lines.kv -> $lineno, $_ {
        # Empty or comment
        when /^ \s* ['#' .*]? $/ {
            next;
        }

        # Data item
        when /^ (\w+) ':' \s*/ {
            my $key = ~$0;
            my $value = .substr($/.chars);
            with $cur-snapshot-hash {
                .{$key} = $value;
            }
            else {
                %top-level{$key} = $value;
            }
        }
        
        # Snapshot heading
        when /^ snapshot \s+ \d+ \s* $/ {
            push @snapshots, $cur-snapshot-hash := {};
        }
        
        # Confused
        default {
            die "Confused by heap snapshot line {$lineno + 1}";
        }
    }

    # Sanity check.
    sub want-key(%hash, $key, $where = "in the snapshot file header") {
        unless %hash{$key}:exists {
            die "Seems there's a missing $key entry $where"
        }
    }
    want-key(%top-level, 'strings');
    want-key(%top-level, 'types');
    want-key(%top-level, 'static_frames');
    for @snapshots.kv -> $idx, %snapshot {
        want-key(%snapshot, 'collectables', "in snapshot $idx");
        want-key(%snapshot, 'references', "in snapshot $idx");
    }

    # Set off background parsing of the headers, and stash unparsed snapshots.
    $!strings-promise = start from-json(%top-level<strings>).list;
    $!types-promise = start self!parse-types(%top-level<types>);
    $!static-frames-promise = start self!parse-static-frames(%top-level<static_frames>);
    @!unparsed-snapshots = @snapshots;
}

method !parse-types($types-str) {
    my int @repr-name-indexes;
    my int @type-name-indexes;
    for $types-str.split(';') {
        my @pieces := .split(',').List;
        @repr-name-indexes.push(@pieces[0].Int);
        @type-name-indexes.push(@pieces[1].Int);
    }
    Types.new(
        :@repr-name-indexes, :@type-name-indexes,
        strings => await $!strings-promise
    )
}

method !parse-static-frames($sf-str) {
    my int @name-indexes;
    my int @cuid-indexes;
    my int32 @lines;
    my int @file-indexes;
    for $sf-str.split(';') {
        my @pieces := .split(',').List;
        @name-indexes.push(@pieces[0].Int);
        @cuid-indexes.push(@pieces[1].Int);
        @lines.push(@pieces[2].Int);
        @file-indexes.push(@pieces[3].Int);
    }
    StaticFrames.new(
        :@name-indexes, :@cuid-indexes, :@lines, :@file-indexes,
        strings => await $!strings-promise
    )
}

method num-snapshots() {
    @!unparsed-snapshots.elems
}

enum SnapshotStatus is export <Preparing Ready>;

method prepare-snapshot($index) {
    with @!snapshot-promises[$index] -> $prom {
        given $prom.status {
            when Kept { Ready }
            when Broken { die $prom.cause }
            default { Preparing }
        }
    }
    else {
        with @!unparsed-snapshots[$index] {
            @!snapshot-promises[$index] = start self!parse-snapshot($_);
            Preparing
        }
        else {
            die "No such snapshot $index"
        }
    }
}

method get-snapshot($index) {
    await @!snapshot-promises[$index] //= start self!parse-snapshot(
        @!unparsed-snapshots[$index]
    )
}

method !parse-snapshot(%snapshot) {
    my $col-data = start {
        my int8 @col-kinds;
        my int @col-desc-indexes;
        my int16 @col-size;
        my int @col-unmanaged-size;
        my int @col-refs-start;
        my int32 @col-num-refs;
        my int $num-objects;
        my int $num-type-objects;
        my int $num-stables;
        my int $num-frames;
        my int $total-size;
        for %snapshot<collectables>.split(';') {
            my @pieces := .split(',').List;
            
            my int $kind = @pieces[0].Int;
            @col-kinds.push($kind);
            if    $kind == 1 { $num-objects++ }
            elsif $kind == 2 { $num-type-objects++ }
            elsif $kind == 3 { $num-stables++ }
            elsif $kind == 4 { $num-frames++ }

            @col-desc-indexes.push(@pieces[1].Int);

            my int $size = @pieces[2].Int;
            @col-size.push($size);
            my int $unmanaged-size = @pieces[3].Int;
            @col-unmanaged-size.push($unmanaged-size);
            $total-size += $size + $unmanaged-size;

            @col-refs-start.push(@pieces[4].Int);
            @col-num-refs.push(@pieces[5].Int);
        }
        hash(
            :@col-kinds, :@col-desc-indexes, :@col-size, :@col-unmanaged-size,
            :@col-refs-start, :@col-num-refs, :$num-objects, :$num-type-objects,
            :$num-stables, :$num-frames, :$total-size
        )
    }

    my $ref-data = start {
        my int8 @ref-kinds;
        my int @ref-indexes;
        my int @ref-tos;
        for %snapshot<references>.split(';') {
            my @pieces := .split(',').List;
            @ref-kinds.push(@pieces[0].Int);
            @ref-indexes.push(@pieces[1].Int);
            @ref-tos.push(@pieces[2].Int);
        }
        hash(:@ref-kinds, :@ref-indexes, :@ref-tos)
    }

    Snapshot.new(
        |(await $col-data),
        |(await $ref-data),
        strings => await($!strings-promise),
        types => await($!types-promise),
        static-frames => await($!static-frames-promise)
    )
}
