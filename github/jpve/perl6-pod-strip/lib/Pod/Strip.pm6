=NAME
Pod::Strip

=begin SYNOPSIS
    use Pod::Strip;

    my Str $code = slurp $?FILE
    say pod-strip($code);
=end SYNOPSIS

=begin EXPORTS
    sub pod-strip; # See below
=end EXPORTS

=DESCRIPTION

=head2 module Pod::Strip;

unit module Pod::Strip;

=head3 Subroutines

#| Replace Pod lines with empty lines.
sub _pod-strip(@in is rw, Str :$in-block? = '') {
    my @out;
    my $in-para = False;
    while @in.elems {
        my $line = @in.shift;
	
        if $in-para && $line ~~ /^\s*$/ {
	    # End of paragraph
            $in-para = False;
            @out.push: $line;
            next;
        }
        if $in-block && $line ~~ /^\s* '=end' \s* $in-block / {
	    # End of block
            @out.push: '';
            last;
        }
	
        if $line ~~ /^\s* '=begin' \s+ (<[\w\-]>+)/ && $0 -> $block-type {
	    # Start of block
            $in-para = False;
            @out.push: '', |_pod-strip(@in, :in-block($block-type.Str));
            next;
        }
        if $line ~~ /^\s* '='\w<[\w-]>* (\s|$)/ {
	    # Start of paragraph
            $in-para = True;
            @out.push: '';
            next;
        }

        @out.push: ($in-para || $in-block) ?? '' !! $line;
    }
    @out;
}

sub pod-strip(Str $code) is export {
    my @in = $code.lines;
    my @out = _pod-strip(@in);

    return @out.join("\n");
}

