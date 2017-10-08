use v6;
use Test;
use Algorithm::Manacher;

{
    is Algorithm::Manacher.new(text => "").is-palindrome(), False;
    is Algorithm::Manacher.new(text => "あ").is-palindrome(), True;
    is Algorithm::Manacher.new(text => "ああ").is-palindrome(), True;
    is Algorithm::Manacher.new(text => "あいあ").is-palindrome(), True;
    is Algorithm::Manacher.new(text => "たけやぶやけた").is-palindrome(), True;
    is Algorithm::Manacher.new(text => "たけやぶやけた？").is-palindrome(), False;
    is Algorithm::Manacher.new(text => "...たけやぶやけた").is-palindrome(), False;
    is Algorithm::Manacher.new(text => "たけやぶはやけた").is-palindrome(), False;
}

done-testing;
