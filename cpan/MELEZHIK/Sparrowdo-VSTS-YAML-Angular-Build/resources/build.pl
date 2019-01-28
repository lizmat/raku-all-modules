#!perl

use strict;
use File::Copy;

my $root_dir = @ARGV[0];
my $source_code_branch = @ARGV[1];

print "update configuration for env: $source_code_branch (data)\n=================================\n";

if ( $source_code_branch && -d "src/env/$source_code_branch/" && -d "src/assets/jsons/" ) {
  copy_data($source_code_branch);
} elsif ( ! $source_code_branch ) {
  print "source branch is not set, is Build.SourceBranchName empty? .... nothing to do\n";
} elsif ( ! -d "src/assets/jsons/" ) {
  print "src/assets/jsons/ does not exit, hope it's ok ... nothing to do\n";
} elsif (-d "src/env/default") {
  print "fallback to default source branch\n";
  copy_data("default");
} else {
  print "fallback to default source branch but it is not found .... nothing to do\n";
}

print "\n\nupdate configuration for env: $source_code_branch (cmd)\n=================================\n";

if ( $source_code_branch && -d "src/env/$source_code_branch/" ) {
  execute_commands($source_code_branch);
} elsif ( ! $source_code_branch ) {
  print "source branch is not set, is Build.SourceBranchName empty? .... nothing to do\n";
} elsif (-d "src/env/default") {
  print "fallback to default source branch\n";
  execute_commands("default");
} else {
  print "fallback to default source branch but it is not found .... nothing to do\n";
}

sub copy_data {

  my $source_code_branch = shift;

  opendir(my $dh, "src/env/$source_code_branch/" ) || die "Can't open directory src/env/$source_code_branch/ to read: $!";
  while ( my $i = readdir $dh) {
    $i =~ /.*\.json/ or next;
    -f "src/env/$source_code_branch/$i" or next;
    print "copy src/env/$source_code_branch/$i ==> src/assets/jsons/$i ... \n";
    copy("src/env/$source_code_branch/$i","src/assets/jsons/$i") or die "Copy failed: $!";
  }
  closedir $dh;

}


sub execute_commands {

  my $source_code_branch = shift;

  my @commands;

  opendir(my $dh, "src/env/$source_code_branch/" ) || die "Can't open directory src/env/$source_code_branch/ to read: $!";

  while ( my $i = readdir $dh) {
    $i =~ /.*\.(cmd|ps1|pl)$/ or next;
    -f "src/env/$source_code_branch/$i" or next;
    push @commands, $i;
  }

  closedir $dh;

  for my $c (sort { $a <=> $b } @commands){
    print "executing $root_dir/src/env/$source_code_branch/$c ... \n";

    if ($c =~/\.cmd$/){
      system("$root_dir/src/env/$source_code_branch/$c") == 0 or die "Batch command [$root_dir/src/env/$source_code_branch/$c] failed: $!";
    } elsif ($c =~/\.ps1$/) {
      system("powershell -executionPolicy bypass  -file $root_dir/src/env/$source_code_branch/$c") == 0 or die "Powershell command [$root_dir/src/env/$source_code_branch/$c] failed: $!";
    } elsif ($c =~/\.pl$/) {
      system("perl $root_dir/src/env/$source_code_branch/$c") == 0 or die "Perl command $root_dir/src/env/$source_code_branch/$c failed: $!";
    } else {
      die "this type of commands is not supported: $c";
    }

  }

}

