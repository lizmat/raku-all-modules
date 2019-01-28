use File::Find;
use File::Spec;

my $dir = shift or die "usage: AssemblyInfoPatchVersion.pl dir revision";
my $r = shift or die "usage: AssemblyInfoPatchVersion.pl dir revision";

find( { wanted => \&wanted ,  follow => 1 }, $dir );


sub wanted {

  my $f = File::Spec->rel2abs($_);


  # AssemblyFileVersion("2.5.0.0")

  if ($f=~/\.cs$/){

    open(my $fh, "<", $f) || die "Can't open UTF-8 encoded $f to read: $!";

    my $c = join "", <$fh>;
    close $fh;

    if ($c=~s/(AssemblyFileVersion.*\d+\.\d+\.\d+\.)(\d+)/$1$r/){
      print "patch  ", $f , " rev: $r ...\n";
      open($fh, ">", $f) || die "Can't open UTF-8 encoded $f to write: $!";
      print $fh $c;
      close $fh;
    }

  }
}
