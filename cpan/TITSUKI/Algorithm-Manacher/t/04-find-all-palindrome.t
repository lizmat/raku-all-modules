use v6;
use Test;
use Algorithm::Manacher;

{
    is Algorithm::Manacher.new(text => "").find-all-palindrome(), {};
    is Algorithm::Manacher.new(text => "あ").find-all-palindrome(), {"あ" => [0]};
    is Algorithm::Manacher.new(text => "ああ").find-all-palindrome(), {"あ" => [0, 1], "ああ" => [0]};
    is Algorithm::Manacher.new(text => "あいあ").find-all-palindrome(), {"あいあ" => [0], "あ" => [0, 2]}; # "い" is the center of both "い" and "あいあ". then it returns "あいあ" as a final result.
    is Algorithm::Manacher.new(text => "たけやぶやけた").find-all-palindrome(), {"た" => [0, 6], "け" => [1, 5], "や" => [2, 4], "たけやぶやけた" => [0]};
}

done-testing;
