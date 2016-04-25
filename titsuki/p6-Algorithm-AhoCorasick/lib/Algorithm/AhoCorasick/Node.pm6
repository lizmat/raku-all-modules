use v6;
unit class Algorithm::AhoCorasick::Node;

has Set $.matched-string is rw;
has %.transitions is rw;
has $.failure is rw;
