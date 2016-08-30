unit class Acme::Sudoku:ver<v0.0.1>:auth<github:pierre-vigier>;
use Terminal::ANSIColor;

grammar SudokuGrid {
    token TOP {
        \s*                 #maybe some spaces before
        <line> ** 9 % \n
        \s*                 #maybe some spaces after
    }
    token line { <cell> ** 9 % \s? }
    token cell { <[ 0 .. 9 . ]> }
}

class Cell {
    has $.initial is required;
    has $.solved is rw = Int;
    has $.candidates is rw = ();
    has $.current-candidate is rw = Int;

    method is-empty( Bool $only-final = True ) {
        return $.value($only-final) eq "."
    }

    method Str(Cell:D: --> Str) {
        if $.solved.defined {
            return colored(~$.solved,'red');
        }
        if $.current-candidate.defined {
            return colored(~$.current-candidate,'green');
        }
        return colored(~$.initial,'blue');
    }

    method gist(Cell:D: --> Str) {
        return $.value(False);
    }

    method value(Cell:D: Bool $only-final = True --> Str) {
        if $only-final {
            return ~($.solved//$.initial);
        }
        return ~($.solved//$.current-candidate//$.initial);
    }
}

has @.cells;

method new( Str $grid ) {
    my @c;
    my $match = Acme::Sudoku::SudokuGrid.parse( $grid );
    fail "Grid format is incorrect"
        unless ?$match;

    for $match<line>.kv -> $row, $line {
        for $line.<cell>.kv -> $col, $cell {
            @c[$row][$col] = Acme::Sudoku::Cell.new( initial => ~$cell );
        }
    }

    self.bless( cells => @c );
}

method export(Acme::Sudoku:D: --> Str) {
    my $str;
    for ^9 -> $r {
        for ^9 -> $c {
            $str ~= " " if ?$c;
            $str ~= @!cells[$r][$c];
        }
        $str ~= "\n";
    }
    return $str;
}

method gist(Acme::Sudoku:D: --> Str) {
    my $str = '┌' ~ join( '┬', ('─' x 7) xx 3 ) ~ '┐' ~ "\n";
    for ^9 -> $r {
        $str ~= "│ ";
        for ^9 -> $c {
            $str ~= @!cells[$r][$c]~" ";
            if $c == 2 | 5 {
                $str ~= '│ ';
            }
        }
        $str ~= "│\n";
        $str ~= '├'  ~ join( '┼', ('─' x 7) xx 3 ) ~ '┤' ~ "\n"
            if $r == 2 | 5;
    }
    $str ~= '└' ~ join( '┴', ('─' x 7) xx 3 ) ~ '┘' ~ "\n";
    return $str;
}

method is-valid(Acme::Sudoku:D: --> Bool) {
    for ^9 -> $i {
        return False if @!cells[$i;*].grep(!*.is-empty).map( *.value ).repeated;
        return False if @!cells[*;$i].grep(!*.is-empty).map( *.value ).repeated;
    }
    #check square
    for (0,3,6) X (0,3,6) -> ($r, $c) {
        return False if @!cells[$r..$r+2;$c..$c+2].grep(!*.is-empty).map( *.value ).repeated;
    }
    return True;
}

method solve(Acme::Sudoku:D: Bool :$interactive = False --> Nil) {
    say $interactive;
    #initialize easy solution with naive method, to prepare backtracking and reduce combinations
    say "First part of the solution";
    while my $cnt = self.one-pass-candidates() {
        say "\e[2J" ~ self.gist if $interactive;
        #note "Pass #{$++} : case solved : $cnt";
    }
    #self.one-pass-candidates();

    say "Second part of the solution";
    self.iterate-with-backtracking( 0, :$interactive );
    say ''; #new line
}

method iterate-with-backtracking(Acme::Sudoku:D: Int $position, Bool :$interactive = False --> Bool) {
    return True if $position == 81;

    say "\e[2J" ~ self.gist if $interactive;
    #print '.';
    my $r = $position div 9;
    my $c = $position % 9;

    if !@!cells[$r;$c].is-empty {
        return self.iterate-with-backtracking( $position + 1, :$interactive );
    }

    for @!cells[$r;$c].candidates.unique -> $value {
        @!cells[$r;$c].current-candidate = Int;
        if self.missing-on-row( $value, $r, False, $position == 0)
            and self.missing-on-column( $value, $c, False , $position == 0)
            and self.missing-on-square( $value, ($r div 3)*3+($c div 3), False, $position == 0 )
        {
            @!cells[$r;$c].current-candidate = $value;
            return True if self.iterate-with-backtracking( $position + 1, :$interactive );
        }
    }
    @!cells[$r;$c].current-candidate = Int;
    return False;
}

method missing-on-row(Acme::Sudoku:D: Int $value, Int $row, Bool $only-final = True, Bool $debug = False --> Bool) {
    for @!cells[$row;*] -> $c {
        return False if !$c.is-empty($only-final) and $c.value($only-final) == $value;
    }
    return True;
}
method missing-on-column(Acme::Sudoku:D: Int $value, Int $column, Bool $only-final = True, Bool $debug = False --> Bool) {
    for @!cells[*;$column] -> $c {
        return False if !$c.is-empty($only-final) and $c.value($only-final) == $value;
    }
    return True;
}
method missing-on-square(Acme::Sudoku:D: Int $value, Int $square, Bool $only-final = True, Bool $debug = False --> Bool) {
    my $r = ($square div 3) * 3;
    my $c = ($square % 3) * 3;
    for @!cells[ $r..$r+2;$c..$c+2] -> $c {
        return False if !$c.is-empty($only-final) and $c.value($only-final) == $value;
    }
    return True;
}

method one-pass-candidates(Acme::Sudoku:D: --> Int ) {
    my $case-solved = 0;
    my %missing-per-row;
    my %missing-per-column;
    my %missing-per-square;
    for ^9 -> $i {
        %missing-per-row{$i} = (1..9) (-) @!cells[$i;*].grep(!*.is-empty).map( +*.value );
        %missing-per-column{$i} = (1..9) (-) @!cells[*;$i].grep(!*.is-empty).map( +*.value );

        my $r = ($i div 3) * 3;
        my $c = ($i % 3) * 3;
        %missing-per-square{$i} = (1..9) (-) @!cells[ $r..$r+2;$c..$c+2].grep(!*.is-empty).map( +*.value );
    }

    for ^9 X ^9 -> ($r, $c) {
        next unless @!cells[$r;$c].is-empty;

        my $intersect = %missing-per-row{$r} (&) %missing-per-column{$c} (&) %missing-per-square{($r div 3)*3+($c div 3)};
        @!cells[$r;$c].candidates = $intersect.keys.list.sort;

        if @!cells[$r;$c].candidates.elems == 1 {
            @!cells[$r;$c].solved = @!cells[$r;$c].candidates.first;
            $case-solved++;
        }
    }
    return $case-solved;
}

method ACCEPTS(Acme::Sudoku:D: $b --> Bool ) {
    for ^9 X ^9 -> ($r, $c) {
        return False if @!cells[$r;$c].value(False) != $b.cells[$r;$c].value(False);
    }
    return True;
}

=begin pod
=head1 NAME

Acme::Sudoku

=head1 SYNOPSIS

Simple sudoku solver, keeping the Sudoku namespace clean, as it will use really naive algorithm

=head1 DESCRIPTION

This module provides a naive sudoku solver

    use Acme::Sudoku;

    my $game = Acme::Sudoku.new( q:to/END/ );
    . . . . . 8 . . .
    7 . . . . . 9 . 5
    . 1 4 . 3 5 8 . .
    . 2 . . 1 6 . 3 .
    . 5 . . . 9 6 . 1
    8 . . . . . . . 4
    3 . 9 2 . . 1 . .
    . . 6 1 . 7 . . 2
    1 . . 5 . . . 7 .
    END

    $game.solve;
    say $game;

The only algorithm implemented now is for each case, looking for missing value in row/column/square.
If we can reduce the missing set to 1 element, case is filled. That algorithm does not enusre
the finding of a solution, and works only for extremly easy sudoku grid.
=end pod

