use v6;

unit module Package::Updates;

sub get-updates() is export {
  my %ret;

  if '/etc/apt'.IO.e      { %ret = apt() }
  if '/etc/pacman.d'.IO.e { %ret = pacman() }
  if '/etc/yum'.IO.e      { %ret = yum() }
  if $*KERNEL eq "win32"  { %ret = win32() }

  return %ret;
}

sub apt() {
  my @out-update = (run 'apt-get', 'update', :out).out.lines;
  my @out-upgrade = (run 'apt-get', '--just-print', 'upgrade', :out).out.lines;

  return gather for @out-upgrade {
    next unless $_;

    if $_ ~~ m:g:s/Inst\s(.*?)\s\[(.*?)\]\s\((.*?)\)/ {

      take $/[0][0].Str => {
        'current' => $/[0][1].Str,
        'new'     => $/[0][2].Str
      };
    }
  }
}

sub pacman() {
  my @out-update = (run 'pacman', '-Sy', :out).out.lines;
  my @out-upgrade = (run 'pacman', '-Qu', :out).out.lines;

  return gather for @out-upgrade {
    next unless $_;

    if $_ ~~ m:g:s/^(.*?)\s(.*?)\s\-\>\s(.*?)$/ {

      take $/[0][0].Str => {
        'current' => $/[0][1].Str,
        'new' => $/[0][2].Str
      };
    }
  }
}

sub yum() {
  my @out-update = (run 'yum', '-q', 'check-update', :out).out.lines;

  return gather for @out-update {
    next unless $_;
    next if !$_.words[0] || !$_.words[1];
    my $packet = $_.words[0];
    my $newver = $_.words[1];

    my $out-current = (run 'yum', 'list', $packet, :out).out.slurp-rest;

    if $out-current ~~ m:s/$packet\s+(.*?)\s+/ {
      take $packet => {
        'current' => $/[0].Str,
        'new' => $newver
      };
    }
  }    
}

sub win32(){
  my @out-powershell = (shell "powershell ./get-updates.ps1", :out).out.lines;

  return gather for @out-powershell {
    next unless $_;
    take $_ => {
      'current' => "-",
      'new' => "-"
    };
  }
}
