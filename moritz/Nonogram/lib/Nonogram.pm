class Turtle {
    has @.rows;
    has $.x = 0;
    has $.y = 0;
    has $.dx = 0;
    has $.dy = 1;
    has %.seen;

    has $.finished = False;
    method step {
        $!x += $!dx;
        $!y += $!dy;
        $!finished = not ($!x ~~ 0..@.rows[0].end) && ($!y ~~ 0..@.rows.end);
    }
    method direction($d, $idx) {
        %!seen{$.current}++;
        given $d {
            when 'left'  { $!dx = -1; $!dy =  0; $!x = @.rows[0].end; $!y = $idx };
            when 'right' { $!dx = 1;  $!dy =  0; $!x = 0;            $!y = $idx };
            when 'up'    { $!dx = 0;  $!dy = -1; $!x = $idx; $!y = @.rows.end    };
            when 'down'  { $!dx = 0,  $!dy =  1; $!x = $idx; $!y = 0            };
            default { die "unknown direction '$d' (should be any <left right up down>)" };
        }
    }

    method current {
        $.finished ?? Any !! @!rows[$!y][$!x];
    }
}
class Nonogram {
    # UNKNOWN, SPACE and BOX need the following properties:
    # SPACE ~& $BOX eq $UNKNOWN
    my $UNKNOWN = '0';
    my $SPACE   = '1';
    my $BOX     = '2';

    has @.colspec;
    has @.rowspec;

    has @.field-rows;

    submethod BUILD(:@!colspec, :@!rowspec){
        @!field-rows =  @!rowspec.map: { [ $UNKNOWN xx @!colspec ] };
    }

    method max-colspec-elems {
        [max] @.colspec>>.elems;
    }

    method max-rowspec-elems {
        [max] @.rowspec>>.elems;
    }

    method Str {
        my $max-c = $.max-colspec-elems;
        my $max-r = $.max-rowspec-elems;

        my %print = (
            $SPACE   => ' ',
            $BOX     => '#',
            $UNKNOWN => '.',
        );

        my @result;
        sub sep-line {
            @result.push: '-' x $max-r;
            @result.push: '+';
            @result.push: '-' x @.colspec;
            @result.push: "+\n";
        }
        # header rows
        for ^$max-c -> $row-num {
            @result.push: ' ' x $max-r;
            @result.push: '|';
            for @.colspec -> $c {
                my $i = $row-num + $c.elems - $max-c;
                if $row-num == $max-c - 1 {
                    @result.push: $c[$i] // '0';
                } else {
                    @result.push: $i < 0 ?? ' ' !! $c[$i];
                }
            }
            @result.push: "|\n";
        }
        sep-line();

        # rows
        for @.rowspec.kv -> $row-num, $r {
            if $r {
                @result.push: ' ' x ($max-r - $r.elems);
                @result.push: $r.join;
            } else {
                @result.push: ' ' x ($max-r - 1);
                @result.push: '0';
            }
            @result.push: '|';
            @result.push: %print{@!field-rows[$row-num]}.join();
            @result.push: "|\n";
        }
        sep-line();

        @result.join;
    }

    method solve() {
        # trivial cases first
        $.solve-zero();
        $.solve-one();
        $.solve-shift();
        $.solve-gen();
    }

    method solve-zero() {
        for @.colspec.kv -> $idx, $col {
            if $col.elems == 0 {
                for @!field-rows {
                    .[$idx] = $SPACE;
                }
            }
        }
        for @.rowspec.kv -> $idx, $row {
            if $row.elems == 0 {
                @!field-rows.[$idx][*] = $SPACE xx *;
            }
        }
    }

    method solve-one() {
        for @.colspec.kv -> $idx, $col {
            next unless $col.elems == 1;
            my $c = $col[0];
            my $overlaps =  2 * $c - @!rowspec;
            if $overlaps > 0 {
                my $lower = @!rowspec - $c;
                my $upper = $lower + $overlaps - 1;
                @!field-rows[$_][$idx] = $BOX for $lower..$upper;
            }
        }
        for @.rowspec.kv -> $idx, $row {
            next unless $row.elems == 1;
            my $r = $row[0];
            my $overlaps = 2 * $r - @!colspec;
            if $overlaps > 0 {
                my $lower = @!colspec - $r;
                my $upper = $lower + $overlaps - 1;
                @!field-rows[$idx][$lower..$upper] = $BOX xx $overlaps;
            }
        }
    }

    method solve-shift {
        for <right down> -> $direction {
            my @spec = do given $direction {
                when 'right' { @!rowspec }
                when 'left'  { @!rowspec.reverse }
                when 'down'  { @!colspec }
                when 'up'    { @!colspec.reverse }
            }
            for @spec.kv -> $idx, @chunks is copy {
                next unless @chunks;
                my $expect_next = '';
                my $max =  $direction eq (any <left right>)
                            ?? @!colspec.elems
                            !! @!rowspec.elems;
                my $t = Turtle.new(
                    rows => @!field-rows,
                );
                $t.direction($direction, $idx);
                until $t.finished {
                    if $expect_next.chars {
                        @!field-rows[$t.y][$t.x] = $expect_next;
                        if $expect_next eq $BOX {
                            @chunks[0]--;
                            if @chunks[0] == 0 {
                                @chunks.shift;
                                $expect_next = $SPACE;
                            }
                        } else {
                            $expect_next = '';
                        }
                        $t.step;
                    } elsif $t.current eq $SPACE {
                        $expect_next = '';
                        $t.step;
                    } elsif $t.current eq $BOX {
                        $expect_next = $BOX;
                        @chunks[0]--;
                        $t.step;
                    } else {
                        if  ($t.seen{$BOX} // 0) == [+] @chunks {
                            $expect_next = $SPACE;
                        } elsif ($t.seen.{$SPACE} // 0) == $max - [+] @chunks {
                            $expect_next = $BOX;
                        } elsif @chunks[0] == 0 {
                            @chunks.shift;
                            $expect_next = $SPACE;
                        } else {
                            last;
                        }
                    }
                }
            }
        }
    }

    method solve-gen() {
        sub distribute($total, $cells) {
            return [$total] if $cells == 1;
            gather for 0..$total -> $c {
                take [$c, $_.flat] for distribute($total - $c, $cells - 1);
            }
        }
        for <h v> -> $direction {
            my $total =  $direction eq 'h'
                         ?? @.colspec.elems
                         !! @.rowspec.elems;
            my @specs := $direction eq 'h' ?? @!rowspec !! @!colspec;
            for @specs.kv -> $idx, @chunks {
                my @boxes = $BOX Xx @chunks;
                my $template = $direction eq 'h'
                               ?? @.field-rows[$idx].join
                               !! (.[$idx] for @.field-rows).join;
                next unless $template.index($UNKNOWN).defined;

                my $spaces-to-distribute = $total - ([+] @chunks) - @chunks + 1;
                my $str = $UNKNOWN x $total;
                for distribute($spaces-to-distribute, @chunks.elems + 1) -> $c {
                    my @a := $c;
                    @a[1..(@a-2)]>>++;
                    my $current = join '', (($SPACE Xx @a) Z @boxes),
                                            $SPACE x @a[*-1];
                    if ($current ~& $template) eq $template {
                        $str ~|= $current;
                    }
                }
                for $str.comb(/$SPACE|$BOX/, :match) -> $v {
                    if $direction eq 'h' {
                        @.field-rows[$idx][$v.from] = ~$v;
                    } else {
                        @.field-rows[$v.from][$idx] = ~$v;
                    }
                }
            }
        }
    }
}

# vim: ft=perl6
