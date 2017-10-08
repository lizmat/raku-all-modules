use v6;
unit class Algorithm::TernarySearchTree::Node;

has Str $.split-char;
has Algorithm::TernarySearchTree::Node $.lokid is rw;
has Algorithm::TernarySearchTree::Node $.eqkid is rw;
has Algorithm::TernarySearchTree::Node $.hikid is rw;

submethod BUILD(:$!split-char) { }
