use v6;
use Test;
use Algorithm::Manacher;

{
    is Algorithm::Manacher.new(text => "").find-longest-palindrome(), {};
    is Algorithm::Manacher.new(text => "あ").find-longest-palindrome(), {"あ" => [0]};
    is Algorithm::Manacher.new(text => "ああ").find-longest-palindrome(), {"ああ" => [0]};
    is Algorithm::Manacher.new(text => "あいあ").find-longest-palindrome(), {"あいあ" => [0]};
    is Algorithm::Manacher.new(text => "たけやぶやけた").find-longest-palindrome(), {"たけやぶやけた" => 0};
    is Algorithm::Manacher.new(text => "たけやぶやけた。わたしまけましたわ").find-longest-palindrome(), {"わたしまけましたわ" => [8]};
    is Algorithm::Manacher.new(text => "たけやぶやけた。、たけやぶやけた").find-longest-palindrome(), {"たけやぶやけた" => [0, 9]};
    is Algorithm::Manacher.new(text => "たけやぶやけた。、だんしがしんだ").find-longest-palindrome(), {"たけやぶやけた" => [0], "だんしがしんだ" => [9]};
    is Algorithm::Manacher.new(text => "ああたけやぶやけた。、たけやぶやけた").find-longest-palindrome(), {"たけやぶやけた" => [2, 11]};
}

done-testing;
