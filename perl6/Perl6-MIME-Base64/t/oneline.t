use v6;

use Test;

use MIME::Base64;

plan 2;

my MIME::Base64 $mime .= new;

is $mime.encode-str("x" x 64), "eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4\neHh4eHh4eA==";
is $mime.encode-str("x" x 64, :oneline), "eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eA==";
