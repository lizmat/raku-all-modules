use v6;
use Test;
use Algorithm::ZobristHashing;

{
    my $zobrist = Algorithm::ZobristHashing.new();
    is $zobrist.encode(["a","b","c"]), $zobrist.encode(["a","b","c"]), "Given a nested array(depth 1), it should keep consistancy";
}

{
    my $zobrist = Algorithm::ZobristHashing.new();
    is $zobrist.encode([["a"],["b"],["c"]]), $zobrist.encode([["a"],["b"],["c"]]), "Given a nested array(depth 2), it should keep consistancy";
}

{
    my $zobrist = Algorithm::ZobristHashing.new();
    is $zobrist.encode("abc"), $zobrist.encode("abc"), "Given a word, it should keep consistancy";
}

{
    my $zobrist = Algorithm::ZobristHashing.new();
    is $zobrist.encode("abc"), $zobrist.encode([[["a"],["b"],["c"]]]), "It should flatten a nested array";
}

{
    my $zobrist = Algorithm::ZobristHashing.new();
    isnt $zobrist.encode("abc"), $zobrist.encode(["abc"]), "Given the word \"abc\" and the word array [\"abc\"], it should return different hash values";
}

{
    my $zobrist = Algorithm::ZobristHashing.new();
    is $zobrist.encode(""), Int, "Given the empty word, it should return Int";
}

{
    my $zobrist = Algorithm::ZobristHashing.new();
    is $zobrist.encode([]), Int, "Given the empty array, it should return Int";
}

{
    my $zobrist = Algorithm::ZobristHashing.new();
    my $expected = $zobrist.encode(["abc"]);
    is $zobrist.get(0,"abc"), $expected, "It should get h(0,\"abc\") correctly";
}


done-testing;
