use v6.c;
unit class Xmav::JSON::Actions;

my %esc-map = %('\\"/bfnrt'.comb Z=> "\\\"/\b\f\n\r\t".comb);

method TOP($/) { make $<json-value>.made }

method json-value:sym<object>($/) { make $<json-object>.made }
method json-value:sym<array>($/)  { make $<json-array>.made }
method json-value:sym<string>($/) { make $<json-string>.made }
method json-value:sym<number>($/) { make $<json-number>.made }
method json-value:sym<true>($/)   { make True }
method json-value:sym<false>($/)  { make False }
method json-value:sym<null>($/)   { make Nil }

method json-number($/) { make +~$/ }
method json-string($/) { make $/.caps».value».made .join }
method json-array($/)  { make Array.new($/.caps».value».made) }
method json-object($/) { make Hash.new($/.caps».value».made) }

method object-pair($/) { make $<json-string>.made => $<json-value>.made }

method string-char:sym<regular>($/) { make $<regular-char>.made }
method regular-char($/)             { make ~$/ }
method string-char:sym<escape>($/)  { make $<escape-char>.made }
method escape-char:sym<single>($/)  { make $<backslash-char>.made }
method escape-char:sym<unicode>($/) { make $<unicode-char>.made }
method unicode-char($/)             { make utf16.new(:16(~$/.substr(2))) }
method backslash-char($/)           { make %esc-map{~$/.substr(1)} }
