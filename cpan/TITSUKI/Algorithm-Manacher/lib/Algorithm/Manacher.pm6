use v6;
unit class Algorithm::Manacher:ver<0.0.1>;

has $!text;
has %!m;

submethod BUILD(Str:D :$!text) {
    my @text-array = $!text.split("", :skip-empty);
    @text-array.unshift('30'.chr);
    @text-array.push('31'.chr);

    %!m{0.5} = 0;
    %!m{$!text.chars + 0.5} = 0;

    my Int $left = 2;
    my Rat $center-radius = 0.5;
    my Rat $center = 1.0;
    while ($center <= $!text.chars) {
	my Int $mirror = (2.0 * $center - $left).Int;
	while (@text-array[$left] eq @text-array[$mirror]) {
	    $left++;
	    $mirror--;
	    $center-radius += 1.0;
	}
	%!m{$center} = $center-radius;
	my Rat $d = 0.5;
	while ($d <= $center-radius) {
	    next if (not %!m{$center - $d}:exists);
	    last if (%!m{$center - $d} == $center-radius - $d);
	    my $right-radius = min($center-radius - $d, %!m{$center - $d});
	    %!m{$center + $d} = $right-radius;
	    $d += 0.5;
	}
	if ($d > $center-radius) {
	    $left++;
	    $center-radius = 0.5;
	} else {
	    $center-radius -= $d;
	}
	$center += $d;
    }
}

method find-all-palindrome() {
    my %result;
    loop (my $center = 0.5; $center <= $!text.chars; $center += 0.5) {
	my $radius = %!m{$center};
	my $key = $!text.substr($center - $radius - 0.5, $radius * 2.0);
	next if ($key eq "");
	%result.push($key => $center - $radius - 0.5);
    }
    return %result;
}

method is-palindrome() {
    my %result = self.find-longest-palindrome();
    return (%result.elems == 1 and (%result.keys[0].chars == $!text.chars) and $!text.chars > 0);
}

method find-longest-palindrome() {
    my $max-radius = 0;
    my %result;
    loop (my $center = 0.5; $center <= $!text.chars; $center += 0.5) {
	my $radius = %!m{$center};
	if ($max-radius <= $radius) {
	    if ($max-radius < $radius) {
		%result = ();
	    }
	    my $key = $!text.substr($center - $radius - 0.5, $radius * 2.0);
	    next if ($key eq "");
	    %result.push($key => $center - $radius - 0.5);
	    $max-radius = $radius;
	}
    }
    return %result;
}

=begin pod

=head1 NAME

Algorithm::Manacher - a perl6 implementation of the extended Manacher's Algorithm for solving longest palindromic substring(i.e. palindrome) problem

=head1 SYNOPSIS

  use Algorithm::Manacher;

  # "たけやぶやけた" is one of the most famous palindromes in Japan.
  # It means "The bamboo grove was destroyed by a fire." in English.
  my $manacher = Algorithm::Manacher.new(text => "たけやぶやけた");
  $manacher.is-palindrome(); # True
  $manacher.find-longest-palindrome(); # {"たけやぶやけた" => [0]};
  $manacher.find-all-palindrome(); # {"た" => [0, 6], "け" => [1, 5], "や" => [2, 4], "たけやぶやけた" => [0]}
  
=head1 DESCRIPTION

Algorithm::Manacher is a perl6 implementation of the extended Manacher's Algorithm for solving longest palindromic substring problem. A palindrome is a sequence which can be read same from left to right and right to left. In the original Manacher's paper [0], his algorithm has some limitations(e.g. couldn't handle a text of even length). Therefore this module employs the extended Manacher's Algorithm in [1], it enables to handle a text of both even and odd length, and compute all palindromes in a given text.

=head2 CONSTRUCTOR

       my $manacher = Algorithm::Manacher.new(text => $text);

=head2 METHODS

=head3 find-all-palindrome

       Algorithm::Manacher.new(text => "たけやぶやけた").find-all-palindrome(); # {"た" => [0, 6], "け" => [1, 5], "や" => [2, 4], "たけやぶやけた" => [0]}

Finds all palindromes in a text and returns a hash containing key/value pairs, where key is a palindromic substring and value is an array of its starting positions. If there are multiple palindromes that share the same point of symmetry, it remains the longest one.

=head3 is-palindrome

       Algorithm::Manacher.new(text => "たけやぶやけた").is-palindrome(); # True
       Algorithm::Manacher.new(text => "たけやぶやけたわ").is-palindrome(); # False
       Algorithm::Manacher.new(text => "Perl6").is-palindrome(); # False

Returns whether a given text is a palindrome or not.
       
=head3 find-longest-palindrome

       Algorithm::Manacher.new(text => "たけやぶやけた").find-longest-palindrome(); # {"たけやぶやけた" => [0]};
       Algorithm::Manacher.new(text => "たけやぶやけた。、だんしがしんだ").find-longest-palindrome(), {"たけやぶやけた" => [0], "だんしがしんだ" => [9]};

Returns the longest palindrome. If there are many candidates, it returns all of them.

=head1 AUTHOR

titsuki <titsuki@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 titsuki

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

This algorithm is from

=item [0] Manacher, Glenn. "A New Linear-Time``On-Line''Algorithm for Finding the Smallest Initial Palindrome of a String." Journal of the ACM (JACM) 22.3 (1975): 346-351.

=item [1] Tomohiro, I., et al. "Counting and verifying maximal palindromes." String Processing and Information Retrieval. Springer Berlin Heidelberg, 2010.

=end pod
