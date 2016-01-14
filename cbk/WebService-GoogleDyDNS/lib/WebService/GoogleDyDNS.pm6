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
class WebService::GoogleDyDNS {
  use WebService::HazIP;
  use HTTP::UserAgent;

  has $.currentHostPublicIP is rw;
  has %.login is rw;
  has %.password is rw;
  has %.domainName is rw;
  has %.lastIP is rw;
  has Bool $.outdated is rw;

  has $lastIPFile = $*CWD ~ "/{self.domainName}" ~ ".lastIP";
  grammar DataFile {
    token TOP            { <line> };
    token line           { <domainKey> \t <lastipKey> \t <loginKey> \t <passwordKey> };
    token domainKey      { 'domain' \t <DOMAINNAME> };
    token lastipKey      { 'ip' \t <LASTIP> };
    token loginKey       { 'login' \t <LOGIN> };
    token passwordKey    { 'password' \t <PASSWORD> };
    token DOMAINNAME     { \w+ '.' \w+ };
    token LASTIP         { [\d ** 1..3] ** 4 % '.' };
    token LOGIN          { \w+ };
    token PASSWORD       { \w+ };
  }

  ##########################################################
method batchMode( @dataSet ) {
  my $elemNum = 0;
  for @dataSet -> $line {
    my $match = DataFile.parse($line);
    if DataFile.parse($line) {
      if $match<line><lastipKey><LASTIP> eq self.currentHostPublicIP { next; }
      else {
        ## current host ip and last ip do not match update the dataset array and update the DNS service
        %.lastIP = 'ip' => self.currentHostPublicIP;
        %.domainName = 'domain' => $match<line><domainKey><DOMAINNAME>;
        %.login = 'login' => $match<line><loginKey><LOGIN>;
        %.password = 'password' => $match<line><passwordKey><PASSWORD>;
        @data[$elemNum] = (  %domain ~ "\t" ~ %lastIP ~ "\t" ~  %login ~ "\t" ~  %password);
        self.updateIP();
      }
    }
    else { say "DataSet read error!"; exit; }
    $elemNum++;
  }
  return @dataSet;
}
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

      if @dataFile[1].Str eq self.currentHostPublicIP { self.outdated = False; } else { self.outdated = True; }
      $fh.close;
    } else {
      ## File does not exist, make new one
      open( $lastIPFile, :w).close;
      self.outdated = True;
    }
  }
  ##########################################################
  method updateIP() {
    # Make HTTP::UserAgent Object and set the useragent to Chrome/41.0 then set the time out
    # and then set the authorization's login and pasword.
    my $webAgent = HTTP::UserAgent.new(useragent => "Chrome/41.0");
    $webAgent.auth(self.login.values(), self.password.values() );
    $webAgent.timeout = 10;

    # Craft URL and make a GET response.  The get method will reachout to the URL provided on internet.
    my $response = $webAgent.get("https://domains.google.com/nic/update?hostname={self.domainName.values()}&myip={self.currentHostPublicIP}");
    # Handle the results of the get method.
    if $response.is-success {
      return $response.content;
      if $response.content ~~ / good / {
        my $fh = open(self.lastIPFile, :w);
        $fh.say( self.domainName.values() );
        $fh.say( self.currentHostPublicIP );
        $fh.say( self.login.values() );
        $fh.say( self.password.values() );
        $fh.close;
      }
    } else {
      return $response.status-line;
    }
  }

}
##########################################################
