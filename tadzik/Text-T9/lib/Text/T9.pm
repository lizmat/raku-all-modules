#= Guess words basing on a T9 key sequence
unit module Text::T9;

=begin pod
=head1 SYNOPSIS

    my @words = <this is a simple kiss test lips here how>;
    .say for t9_find_words(5477, @words);

    my %additional-keys = ź => 9, ń => 6;
    @words.push: 'jaźń';
    t9_find_words(5296, @words, %additional-keys);

=end pod

my %default-keys;
%default-keys{$_} = 2 for <a b c>;
%default-keys{$_} = 3 for <d e f>;
%default-keys{$_} = 4 for <g h i>;
%default-keys{$_} = 5 for <j k l>;
%default-keys{$_} = 6 for <m n o>;
%default-keys{$_} = 7 for <p q r s>;
%default-keys{$_} = 8 for <t u v>;
%default-keys{$_} = 9 for <w x y z>;

#= get a list of words from @words matching $input
sub t9_find_words(Int $input as Str, @words, %optkeys?) is export {
    my %keys = %default-keys, %optkeys;
    gather for @words -> $candidate {
        next unless $input.chars == $candidate.chars;
        if $candidate.comb.map({%keys{$_}}).join eq $input {
            take $candidate;
        }
    }
}
