#!/usr/bin/env perl6

use lib 't/lib';
use Pluggable; 
use Test;

plan 9;

class Power does Pluggable {
  has %.testcases = 
    'Power::Plugins::Teaser::Helpers' => True,
    'Power::Plugins::Teaser'          => True,
    'Power::DontMatch'                => False,
  ;

  method test() {
    my @plugins = @( $.plugins );
    my ($test, $count);
    $count = 0;
    for %.testcases.keys -> $k {
      $test = False;
      for @plugins -> $p {
        $test = True, last if $p eq $k;
      }
      $count++ if True ~~ %.testcases{$k};
      is %.testcases{$k}, $test, "Test: $k";
    }
  }
};

class Checker2::T does Pluggable {
  has %.testcase1 = 
    'Power::Plugins::Teaser::Helpers' => True,
    'Power::Plugins::Teaser'          => True,
    'Power::DontMatch'                => False,
  ;
  has %.testcase2 = 
    'Checker2::T::PluginDir::Plugin1'    => False,
    'Checker2::T::PluginDir::Plugin3'    => False,
    'Checker2::T::PluginDir::Plugin2::Plugin2::Plugin2::DEEP' => True,
  ;

  method test() {
    my @plugins = @( $.plugins(:module('Power'), :plugin('Plugins')) );
    my ($test, $count);
    $count = 0;
    for %.testcase1.keys -> $k {
      $test = False;
      for @plugins -> $p {
        $test = True, last if $p eq $k;
      }
      $count++ if True ~~ %.testcase1{$k};
      is %.testcase1{$k}, $test, "Test: $k";
    }

    @plugins = @( $.plugins(:pattern(/ [ '.pm' | '.pm6' ] $ /), :plugin('PluginDir')) );
    $count = 0;
    for %.testcase2.keys -> $k {
      $test = False;
      for @plugins -> $p {
        $test = True, last if $p eq $k;
      }
      $count++ if True ~~ %.testcase2{$k};
      is %.testcase2{$k}, $test, "Test: $k";
    }
    
  }
};

Power.new.test;
Checker2::T.new.test;
