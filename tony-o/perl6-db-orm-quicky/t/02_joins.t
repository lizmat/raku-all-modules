#!/usr/bin/env perl6

use Test;
use DB::ORM::Quicky;


my $orm = DB::ORM::Quicky.new(debug => False);

my $optout = 0;

try {
  $orm.connect(
    driver  => 'SQLite', 
    options => %( 
      database => './sqlite.sqlite3',
    )
  );
  $optout = 1;
};

if $optout == 0 { 
  plan 1;
  ok 1==1,'Able to \'use\'';
  exit;
}

my $j = time;
my @expected = |qw<DBORMID joined uid username password>, 'full name'; 
my %expectedv = 
  joined => $j,
  password => 'tony',
  username => 'tony-o',
  'full name' => 'whatever',
;

plan @expected.elems + %expectedv.keys.elems + 1;

$orm.search('nickl', { }).delete;
$orm.search('profile', { }).delete;

my $newrow = $orm.create('nickl');


$newrow.set('username' => 'tony-o');
$newrow.set('password' => 'tony');
$newrow.set('joined' => $j);
$newrow.save;

##TODO: TEST JOINS
my $profile = $orm.create('profile');
$profile.set('uid' => $newrow.id);
$profile.set('full name' => 'whatever');
$profile.save;

my $prof = $orm.search('nickl', {
  '-join' => {
    '-table' => 'profile',
    '-type'  => 'inner',
    '-on' => {
      'uid' => 'DBORMID',
    },
  }
});

my @got = $prof.first.fields;
for @expected {
  ok @got.grep(* eq $_), "got field '$_' from join";
}

$profile = $orm.create('profile');
$profile.set('uid' => $newrow.id + 50);
$profile.set('full name' => 'whatever');
$profile.save;


$prof = $orm.search('nickl', {
  '-join' => {
    '-table' => 'profile',
    '-type'  => 'inner',
    '-on' => {
      '-and' => {
        'uid' => 'DBORMID',
      },
    },
  },
  '"profile"."full name"' => ('-like' => '%what%'),
});

my @elems = $prof.all;
ok @elems.elems == 1, 'should only get one result';
for %expectedv.keys {
  ok @elems[0].get($_) eq %expectedv{$_}, "result for column '$_' should be: '{%expectedv{$_}}' got: '{@elems[0].get($_)}'";
}

$orm.search('profile', { }).delete;

$orm.search('nickl', { }).delete;

# vim:syntax=perl6
