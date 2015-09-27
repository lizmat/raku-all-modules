use LibraryMake;

my $destdir = 'lib/Raw/Socket/';
my %vars = get-vars($destdir);
%vars{'LIBS'} ~= $*DISTRO.is-win ?? " -lws2_32" !! "";
process-makefile('.', %vars);
