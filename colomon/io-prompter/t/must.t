#! /Users/damian/bin/rakudo*
use v6;

use Testing;
use IO::Prompter;

my $result;

$result = prompt "Enter line 1",
               :must{ 'have a 2' => /2/ },
               in=>IN('Line 1','Line 2');
OK have => $result,
   want => 'Line 2',
   desc => 'First line retrieved';

$result = prompt "Enter line 2",
               :number,
               :must{ 'be in [1..10]' => 1..10,
                      'be even' => { $_ %% 2 }
                    },
               in=>IN(42,7,6);
OK have => $result,
   want => '6',
   desc => 'Second line retrieved';
