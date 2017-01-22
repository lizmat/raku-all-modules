use v6;
unit class Algorithm::AhoCorasick::Node;

has Set $.matched-string is rw;
has Algorithm::AhoCorasick::Node %.transitions is rw;
has Algorithm::AhoCorasick::Node $.failure is rw;
