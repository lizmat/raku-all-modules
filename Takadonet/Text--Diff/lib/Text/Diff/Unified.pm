class Text::Diff::Unified {
## Hunks are made of ops.  An op is the starting index for each
## sequence and the opcode:
our $A = 0;    # Array index before match/discard
our $B = 1;
our $OPCODE = 2; # "-", " ", "+"
our $FLAG = 3; # What to display if not OPCODE "!"

    
method file_header(@a,@b, %options ) {
    return self.header(FILENAME_PREFIX_A => "---", FILENAME_PREFIX_B => "+++",|%options);
}                                                                                                 

method hunk_header(@a,@b,%options,*@_) {                                                            

    return "@@ -" ~
         self.range( @_, $A, "unified" ) ~
         " +" ~
         self.range( @_, $B, "unified" ) ~
         " @@\n";
}                                                                                                 

#NB i changed the order of %options and @_ 
method hunk(@a,@b,%options,*@diffs) {
    my %prefixes = ( "+" => "+", " " => " ", "-" => "-");

    my @result = map { self.op_to_line( @a,@b, $_,Any, %prefixes ) }, @diffs;
    
    return @result.join('');
}

method hunk_footer(*@args) {
    return '';
}

method file_footer(*@args) {
    return '';
}


method header(:FILENAME_PREFIX_A($p1),:FILENAME_A($fn1),:MTIME_A($t1),
         :FILENAME_PREFIX_B($p2),
         :FILENAME_B($fn2),
         :MTIME_B($t2)
) {

    ## remember to change Text::Diff::Table if this logic is tweaked.
    return "" unless defined $fn1 && defined $fn2;
    
    return $p1 ~ " " ~ $fn1 ~ "\n" ~ $p2 ~ " " ~ $fn2 ~ "\n";
    
#    return join( "",
#                 $p1, " ", $fn1, defined $t1 ?? "\t" ~ DateTime.now.local $t1 !! '', "\n",
#                 $p2, " ", $fn2, defined $t2 ?? "\t" ~ DateTime.now.local $t2 !! '', "\n");
}

## _range encapsulates the building of, well, ranges.  Turns out there are
## a few nuances.
method range(@ops,$a_or_b,$format) {
    my $start = @ops[0][$a_or_b];
    my $after = @ops[*-1][$a_or_b];

    ## The sequence indexes in the lines are from *before* the OPCODE is
    ## executed, so we bump the last index up unless the OP indicates
    ## it didn't change.
    ++$after
        unless @ops[*-1][$OPCODE] eq ( $a_or_b == $A ?? "+" !! "-" );

    ## convert from 0..n index to 1..(n+1) line number.  The unless modifier
    ## handles diffs with no context, where only one file is affected.  In this
    ## case $start == $after indicates an empty range, and the $start must
    ## not be incremented.
    my $empty_range = $start == $after;
    ++$start unless $empty_range;

     return
         $start == $after
             ?? $format eq "unified" && $empty_range
                 ?? "$start,0"
                 !! $start
             !! $format eq "unified"
                 ?? "$start," ~ ($after-$start+1)
                 !! "$start,$after";
}

method op_to_line(@a,@b,@op,$a_or_b is copy ,%op_prefixes) {

    my $opcode = @op[$OPCODE];
    return () unless defined %op_prefixes{$opcode};

    my $op_sym = defined @op[$FLAG] ?? @op[$FLAG] !! $opcode;
    $op_sym = %op_prefixes{$op_sym};
    return () unless defined $op_sym;

    $a_or_b = @op[$OPCODE] ne "+" ?? 0 !! 1 unless defined $a_or_b;

    return ($op_sym, $a_or_b ?? @b[ @op[$a_or_b] ] !! @a[ @op[$a_or_b] ]);
}




}

