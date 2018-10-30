#!/usr/bin/env perl6
use Test;
use lib './lib';
use URI::Encode;

plan 23;

# encode
is uri_encode("  "),    "%20%20",       'Encode "   "';
is uri_encode("|abcå"), "%7Cabc%C3%A5",    'Encode "|abcå"';
is uri_encode("-.~_"), "-.~_",    'Encode -.~_';
is uri_encode(":/?#\[\]@!\$\&'()*+,;="), ":/?#\[\]@!\$\&'()*+,;=",    'Encode :/?#\[\]@!$&\'()*+,;=';
is uri_encode("abc"),   "abc",          'Encode "abc"';
is uri_encode("<\">"),  "%3C%22%3E",    'Encode "<\"';
is uri_encode("Hello World!"), "Hello%20World!", 'Encode "Hello World!"';
is uri_encode("http://perltricks.com/"),  "http://perltricks.com/",
  'Encode "http://perltricks.com/"';
is uri_encode("https://perltricks.com/"), "https://perltricks.com/",
  'Encode "https://perltricks.com/"';
is uri_encode("https://www.example.com/🇩🇪"), "https://www.example.com/%F0%9F%87%A9%F0%9F%87%AA",
  'Encode "https://www.example.com/🇩🇪"';

is uri_encode_component("Hello World!"), "Hello%20World%21", 'Encode components "Hello World!"';
is uri_encode_component('#$&+,/:;=?@'), '%23%24%26%2B%2C%2F%3A%3B%3D%3F%40',
  'Encode components \'#$&+,/:;=?@\'';
is uri_encode_component("🇩🇪"), "%F0%9F%87%A9%F0%9F%87%AA", 'Encode components "🇩🇪"';

# decode
is uri_decode("%20%20"),        "  ",    'Decode to "   "';
is uri_decode("%7Cabc%C3%A5"),     "|abcå", 'Decode to "|abcå"';
is uri_decode("abc"),           "abc",   'Decode to "abc"';
is uri_decode("~%2A%27%28%29"), "~*'()", 'Decode to "~*\'()"';
is uri_decode("%3C%22%3E"),     "<\">",  'Decode to "<\"';
is uri_decode("http://perltricks.com/"),  "http://perltricks.com/",
  'Decode to "http://perltricks.com/"';
is uri_decode("https://perltricks.com/"), "https://perltricks.com/",
  'Decode tp "https://perltricks.com/"';
is uri_decode("https://www.example.com/%F0%9F%87%A9%F0%9F%87%AA"), "https://www.example.com/🇩🇪",
  'Decode "https://www.example.com/%F0%9F%87%A9%F0%9F%87%AA"';
is uri_decode_component('%23%24%26%2B%2C%2F%3A%3B%3D%3F%40'), '#$&+,/:;=?@',
  'Decode components to \'#$&+,/:;=?@\'';
is uri_decode_component("%F0%9F%87%A9%F0%9F%87%AA"), "🇩🇪", 'Decode components "🇩🇪"';

# vim: ft=perl6
