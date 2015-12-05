#########################################
## Michael D. Hensley
## December 3, 2015
##
## Simple web service used to update an IP address on domains.google.com
## if the current one has changed. Obtains current IP address using the
## WebService::HazIP module, then compares the results with the IP address
## that was set the last time the service was ran. It there was a change,
## the updateIP() method is then called to update the IP address
## using the HTTP::UserAgent module.
##
##########################################################
use v6;

class WebService::GoogleDyDNS {
  use WebService::HazIP;
  use HTTP::UserAgent;

  has $.currentHostPublicIP is rw;
  has $.login is rw;
  has $.password is rw;
  has $.domainName is rw;
  has Bool $.outdated is rw;

  has $lastIPFile = $*CWD ~ "/{self.domainName}" ~ ".lastIP";

  ##########################################################
  method checkPreviousIP() {
    my $fh;
    my $previousIP;

    ## Get current Host public IP address.
    my $currentIPObj = WebService::HazIP.new;
    self.currentHostPublicIP = $currentIPObj.returnIP();

    ## Check if there is already a domain file.
    if $lastIPFile.IO ~~ :e {
      ## Open file and read lines into data array.
      $fh = open($lastIPFile, :r);
      my @dataFile = $fh.IO.lines;
      if @dataFile[1] eq self.currentHostPublicIP { self.outdated = False; } else { self.outdated = True; }
      $fh.close;
    } else {
      ## File does not exist, make new one
      open( $lastIPFile, :w).close;
      self.outdated = True;
    }

    #if $data ~~ / ^^([\d ** 1..3] ** 4 % '.')$$ / { return $data; }
  }
  ##########################################################
  method updateIP() {
    # Make HTTP::UserAgent Object and set the useragent to Chrome/41.0 then set the time out
    # and then set the authorization's login and pasword.
    my $webAgent = HTTP::UserAgent.new(useragent => "Chrome/41.0");
    $webAgent.auth(self.login, self.password);
    $webAgent.timeout = 10;

    # Craft URL and make a GET response.  The get method will reachout to the URL provided on internet.
    my $response = $webAgent.get("https://domains.google.com/nic/update?hostname={self.domainName}&myip={self.currentHostPublicIP}");
    # Handle the results of the get method.
    if $response.is-success {
      return $response.content;
      if $response.content ~~ / good / {
        my $fh = open(self.lastIPFile, :w);
        $fh.say( self.currentHostPublicIP );
        $fh.close;
      }
    } else {
      return $response.status-line;
    }
  }

}
##########################################################





##########################################################
multi sub MAIN( :$domain, :$login, :$password ) {

  my $updater = WebService::GoogleDyDNS.new(domainName => $domain, login => $login , password => $password );
  $updater.checkPreviousIP();
  if $updater.outdated { say $updater.updateIP(); } else { say "No change. No action taken."; }
}
