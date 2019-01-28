#!perl

use strict;
use JSON qw{decode_json};

if ($ENV{BUILD_NOPATCHREVISION}){

  print "Build.NoPatchVersion is set, don't patch revision ... \n";

  open JSON, "package.json" or die "can't open package.jspon to read";
  my $js = join "", <JSON>;
  close JSON;
  
  my $main_version = decode_json($js)->{version};
  
  print "set version ...\n";
  print "main version (taken from package.json) - $main_version ...\n";
  
  system("npm run cordova-set-version -- -v $main_version")  == 0 
    or die "npm run cordova-set-version -- -v $main_version failed: $?";

} else {

  
  my $build_id = @ARGV[0];
  
  # see https://stackoverflow.com/questions/1188284/net-large-revision-numbers-in-assemblyversionattribute
  # why
  
  my $revision = $build_id - 35365 * (sprintf "%d",  $build_id / 35365);
  
  open JSON, "package.json" or die "can't open package.jspon to read";
  my $js = join "", <JSON>;
  close JSON;
  
  my $main_version = decode_json($js)->{version};
  
  print "set version ...\n";
  print "main version (taken from package.json) - $main_version ...\n";
  print "build_id - $build_id ...\n";
  print "revision version (calculated by build_id) - $revision ...\n";
  
  system("npm run cordova-set-version -- -v $main_version.$revision")  == 0 
    or die "npm run cordova-set-version -- -v $main_version.$revision failed: $?";
}

