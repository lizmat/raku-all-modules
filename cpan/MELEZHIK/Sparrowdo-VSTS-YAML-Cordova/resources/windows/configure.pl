#!perl

use strict;
use File::Copy;
our $OS;

my $root_dir = @ARGV[0];
my $source_code_branch = @ARGV[1];

my $target;

if (_resolve_os() eq 'windows'){
  $target = "uwp";
} elsif(_resolve_os() eq 'darwin') {
  $target = "ios";
} else {
  die "unsupported platform: ".(_resolve_os());
}

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
    $i =~ /.*\.(cmd|ps1|pl)$/ or next;
    -f "$root_dir/src/env/$target/$source_code_branch/$i" or next;
    push @commands, $i;
  }

  closedir $dh;

  for my $c (sort { $a <=> $b } @commands){
    print "executing $root_dir/src/env/$target/$source_code_branch/$c ... \n";

    if ($c =~/\.cmd$/){
      system("$root_dir/src/env/$target/$source_code_branch/$c") == 0 or die "Batch command [$root_dir/src/env/$target/$source_code_branch/$c] failed: $!";
    } elsif ($c =~/\.ps1$/) {
      system("powershell -executionPolicy bypass  -file $root_dir/src/env/$target/$source_code_branch/$c") == 0 or die "Powershell command [$root_dir/src/env/$target/$source_code_branch/$c] failed: $!";
    } elsif ($c =~/\.pl$/) {
      system("perl $root_dir/src/env/$target/$source_code_branch/$c") == 0 or die "Perl command $root_dir/src/env/$target/$source_code_branch/$c failed: $!";
    } else {
      die "this type of commands is not supported: $c";
    }

  }

}


sub dump_os {

return $^O if $^O  =~ 'MSWin';

my $cmd = <<'HERE';
#! /usr/bin/env sh

# Find out the target OS
if [ -s /etc/os-release ]; then
  # freedesktop.org and systemd
  . /etc/os-release
  OS=$NAME
  VER=$VERSION_ID
elif lsb_release -h >/dev/null 2>&1; then
  # linuxbase.org
  OS=$(lsb_release -si)
  VER=$(lsb_release -sr)
elif [ -s /etc/lsb-release ]; then
  # For some versions of Debian/Ubuntu without lsb_release command
  . /etc/lsb-release
  OS=$DISTRIB_ID
  VER=$DISTRIB_RELEASE
elif [ -s /etc/debian_version ]; then
  # Older Debian/Ubuntu/etc.
  OS=Debian
  VER=$(cat /etc/debian_version)
elif [ -s /etc/SuSe-release ]; then
  # Older SuSE/etc.
  printf "TODO\n"
elif [ -s /etc/redhat-release ]; then
  # Older Red Hat, CentOS, etc.
  OS=$(cat /etc/redhat-release| head -n 1)
else
  RELEASE_INFO=$(cat /etc/*-release 2>/dev/null | head -n 1)

  if [ ! -z "$RELEASE_INFO" ]; then
    OS=$(printf -- "$RELEASE_INFO" | awk '{ print $1 }')
    VER=$(printf -- "$RELEASE_INFO" | awk '{ print $NF }')
  else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
    VER=$(uname -r)
  fi
fi

  echo "$OS$VER"

HERE

  `$cmd`

}

sub _resolve_os {


    if (!$OS){

       DONE: while (1) {
          my $data = dump_os();
          $data=~/alpine/i and $OS = 'alpine' and last DONE;
          $data=~/minoca/i and $OS = "minoca" and last DONE;
          $data=~/centos linux(\d+)/i and $OS = "centos$1" and last DONE;
          $data=~/Red Hat.*release\s+(\d)/i and $OS = "centos$1" and last DONE;
          $data=~/arch/i and $OS = 'archlinux' and last DONE;
          $data=~/funtoo/i and $OS = 'funtoo' and last DONE;
          $data=~/fedora/i and $OS = 'fedora' and last DONE;
          $data=~/amazon/i and $OS = 'amazon' and last DONE;
          $data=~/ubuntu/i and $OS = 'ubuntu' and last DONE;
          $data=~/debian/i and $OS = 'debian' and last DONE;
          $data=~/darwin/i and $OS = 'darwin' and last DONE;
          $data=~/MSWin/i and $OS = 'windows' and last DONE;
          warn "unknown os: $data";
          last DONE;
      }
  }
  return $OS;
}
