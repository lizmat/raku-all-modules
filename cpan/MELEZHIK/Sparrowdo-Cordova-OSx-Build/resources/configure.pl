#!perl

use strict;

use File::Copy;

my $root_dir = $ENV{BUILD_SOURCESDIRECTORY};
my $source_code_branch = $ENV{BUILD_SOURCEBRANCHNAME};

my $target = 'ios';

print "target: $target\n\n";

print "update configuration for env: $source_code_branch (data)\n=================================\n";

if ( $source_code_branch && -d "$root_dir/src/env/$target/$source_code_branch/" && -d "src/assets/jsons/" ) {
  copy_data($source_code_branch);
} elsif ( ! $source_code_branch ) {
  print "source branch is not set, is Build.SourceBranchName empty? .... nothing to do\n";
} elsif ( ! -d "$root_dir/src/assets/jsons/" ) {
  print "src/assets/jsons/ does not exit, hope it's ok ... nothing to do\n";
} elsif (-d "$root_dir/src/env/$target/default") {
  print "fallback to default source branch\n";
  copy_data("default");
} else {
  print "fallback to default source branch but it is not found .... nothing to do\n";
}

print "\n\nupdate configuration for env: $source_code_branch (cmd)\n=================================\n";

if ( $source_code_branch && -d "$root_dir/src/env/$target/$source_code_branch/" ) {
  execute_commands($source_code_branch);
} elsif ( ! $source_code_branch ) {
  print "source branch is not set, is Build.SourceBranchName empty? .... nothing to do\n";
} elsif (-d "$root_dir/src/env/$target/default") {
  print "fallback to default source branch\n";
  execute_commands("default");
} else {
  print "fallback to default source branch but it is not found .... nothing to do\n";
}

if ( $source_code_branch && -d "$root_dir/src/env/any/" ) {
  execute_commands("any");
}

sub copy_data {

  my $source_code_branch = shift;

  opendir(my $dh, "$root_dir/src/env/$target/$source_code_branch/" ) || die "Can't open directory $root_dir/src/env/$target/$source_code_branch/ to read: $!";
  while ( my $i = readdir $dh) {
    $i =~ /.*\.json/ or next;
    -f "$root_dir/src/env/$target/$source_code_branch/$i" or next;
    print "copy $root_dir/src/env/$target/$source_code_branch/$i ==> $root_dir/src/assets/jsons/$i ... \n";
    copy("$root_dir/src/env/$target/$source_code_branch/$i","$root_dir/src/assets/jsons/$i") or die "Copy failed: $!";
  }
  closedir $dh;

}


sub execute_commands {

  my $source_code_branch = shift;

  my @commands;

  opendir(my $dh, "$root_dir/src/env/$target/$source_code_branch/" ) || die "Can't open directory $root_dir/src/env/$target/$source_code_branch/ to read: $!";

  while ( my $i = readdir $dh) {
    $i =~ /.*\.(sh|pl)$/ or next;
    -f "$root_dir/src/env/$target/$source_code_branch/$i" or next;
    push @commands, $i;
  }

  closedir $dh;

  for my $c (sort { $a <=> $b } @commands){
    print "executing $root_dir/src/env/$target/$source_code_branch/$c ... \n";

    if ($c =~/\.sh$/){
      system("bash $root_dir/src/env/$target/$source_code_branch/$c") == 0 or die "Bash command [$root_dir/src/env/$target/$source_code_branch/$c] failed: $!";
    } elsif ($c =~/\.pl$/) {
      system("perl $root_dir/src/env/$target/$source_code_branch/$c") == 0 or die "Perl command $root_dir/src/env/$target/$source_code_branch/$c failed: $!";
    } else {
      die "this type of commands is not supported: $c";
    }

  }

}


