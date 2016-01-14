#########################################
## Michael D. Hensley
## December 5, 2015
##
## Client program to check if domain IP address is out of date
## and update if it is.
##
##########################################################
use v6;
use WebService::GoogleDyDNS;

##########################################################
## Start up in batch mode.
multi sub MAIN ( ) {
  my $updater = WebService::GoogleDyDNS.new();
  my @data;
  my $dataFile = $*CWD ~ "/ipUpdater.data";

  ## Open data set form file;
  my $readFile = open $dataFile, :r;
  for $readFile.lines ->  $line {
    @data.push($line);
  }
  $readFile.close;

  ## Send data to be checked by updater obj.
  my @results = $updater.batchMode(@data);

  # write current data set to file...
  my $writeFile = open $dataFile, :w;
  for @data -> $line {
    say $writeFile.say($line);
  }
  $writeFile.close;
}
##########################################################
multi sub MAIN( :$domain, :$login, :$password ) {

  my $updater = WebService::GoogleDyDNS.new(domainName => $domain, login => $login , password => $password );
  $updater.checkPreviousIP();
  if $updater.outdated { say $updater.updateIP(); } else { say "No change. No action taken."; }
}
