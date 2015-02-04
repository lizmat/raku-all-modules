#!/usr/bin/env perl6
use v6;

#BEGIN { @*INC.unshift: './lib'; }

use HTTP::Status;
use Test;

plan 4;

is get_http_status_msg(200), 'OK',        'Known code 1';
is get_http_status_msg(404), 'Not Found', 'Known code 2';
is get_http_status_msg(289), 'Unknown',   'Unknown code 1';
is get_http_status_msg(607), 'Unknown',   'Unknown code 2';

