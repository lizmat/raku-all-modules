use v6;

#------------------------------------------------------------------------------
unit class Build;

use HTTP::UserAgent;
use Config::TOML;

# Set environment var TRAVIS to True to test for travis-ci setup

#-------------------------------------------------------------------------------
has Str $!SERVER-VERSION-MIN = '3.6.9';
has Str $!SERVER-VERSION-MAX = '4.0.5';

has Str $!dist-path;
has Str $!software;
has Str $!sandbox;
has Bool $!on-travis-appveyor;

has Hash $s-info = {
  linux => {
    download-site => "https://fastdl.mongodb.org/",
    path          => "linux/",
    archive       => "mongodb-linux-x86_64-SERVERVERSION",
    ext           => ".tgz",
  },

  win32 => {
    download-site => "https://downloads.mongodb.org/",
    path          => "win32/",
    archive       => "mongodb-win32-x86_64-2008plus-ssl-SERVERVERSION",
    ext           => ".zip",
  },
}

#-------------------------------------------------------------------------------
method build ( $!dist-path --> Int ) {

  # check environment
  $!on-travis-appveyor = ( ? %*ENV<TRAVIS> or ? %*ENV<APPVEYOR> );

  # init locations
  $!software = "$!dist-path/t/Software";
  $!sandbox = "$!dist-path/t/Sandbox";

  # get mongodb distribution and extract server executables
  self!get-server-exec;

  # build sandbox and configuration
  self!build-sandbox;

  # return success
  1
}

#-------------------------------------------------------------------------------
method !get-server-exec ( ) {

  # prepare locations
  my Str $path = "$!software/$!SERVER-VERSION-MIN";
  mkdir($path) unless $path.IO.e;
  $path = "$!software/$!SERVER-VERSION-MAX";
  mkdir($path) unless $path.IO.e;

  my Str $url;
  my Str $os-name = $*KERNEL.name;
  if $os-name eq 'linux' {
    $url = $s-info<linux><download-site> ~
           $s-info<linux><path> ~
           $s-info<linux><archive> ~
           $s-info<linux><ext>;

    for $!SERVER-VERSION-MIN, $!SERVER-VERSION-MAX -> $s-version {

      my Str $dest-path = "$!software/$s-version";
      chdir($dest-path);

      my Str $u = $url;
      $u ~~ s/SERVERVERSION/$s-version/;

      my $dist-dir = $s-info<linux><archive>;
      $dist-dir ~~ s/SERVERVERSION/$s-version/;

      self!download( $u, "$dist-dir$s-info<linux><ext>");

      my @cmd = 'tar', 'xvfz', "$dist-dir$s-info<linux><ext>",
                 '--strip-components=2';
      run |@cmd, "$dist-dir/bin/mongod";

      # user install tests not with mongos
      run |@cmd, "$dist-dir/bin/mongos" if $!on-travis-appveyor;

      chdir($!dist-path);

      # user install tests only with oldest in supported range
      last unless $!on-travis-appveyor;
    }
  }

#  elsif $os-name eq 'win32' {
#    # unzip with 7z: https://www.7-zip.org/download.html
#  }

  else {
    die "No (build) support for " ~ $*KERNEL.name ~
        ". Try install options --/build --/test.";
  }
}

#-------------------------------------------------------------------------------
method !download ( Str $url, Str $destination ) {

  return if $destination.IO.e;

  my $ua = HTTP::UserAgent.new;
  $ua.timeout = 10;

  my $response = $ua.get($url);

  if $response.is-success {
    $destination.IO.spurt( $response.content, :bin);
  }

  else {
    die $response.status-line;
  }
}

#-------------------------------------------------------------------------------
method !build-sandbox ( ) {

  my Int $start-portnbr = 65010;
  my Hash $server-config = {};

  # prepare locations
  mkdir( $!sandbox, 0o700) unless $!sandbox.IO.e;

  $server-config<server> = {
    :nojournal,
    :fork,
    :verbose<vv>,
#      :ipv6,
#      :quiet,
#      :logappend,
  }

  # install both server version configurations when on test servers
  if $!on-travis-appveyor {

    my Str $src = 'Travis-ci' if ?%*ENV<TRAVIS>;
    $src = 'Appveyor' if !$src and ?%*ENV<APPVEYOR>;

    my Int $port-number;

    for 's1',*.succ ... 's8' -> $server-key {
      my Str $version =
         $server-key lt 's4' ?? $!SERVER-VERSION-MIN !! $!SERVER-VERSION-MAX;

      # add some directories
      my Str $server-dir = "$!sandbox/Server-$server-key";
      mkdir( $server-dir, 0o700) unless $server-dir.IO ~~ :d;
      my Str $datadir = $server-dir ~ '/m.data';
      mkdir( $datadir, 0o700) unless $datadir.IO ~~ :d;

      # setup config for complete testing on test servers
      $server-config<locations>{$server-key} = {
        :mongod("$!software/$version/mongod"),
        :mongos("$!software/$version/mongos"),
        :server-path($!sandbox),
        :logpath<m.log>,
        :pidfilepath<m.pid>,
        :dbpath<m.data>,
        :server-subdir("Server-$server-key"),
      };

      $port-number = self!find-next-free-port($start-portnbr);
      $start-portnbr = $port-number + 1;
      $server-config<server>{$server-key} = {
        :port($port-number),
      };

      $server-config<server>{$server-key}<replicate1> = {
        :oplogSize(128),
        :replSet<first_replicate>,
      };

      if $server-key eq 's1' {
        $server-config<server><s1><replicate2> = {
          :oplogSize(128),
          :replSet<second_replicate>,
        };

        $server-config<server><s1><authenticate> = {
          :auth,
        };
      }
    }
  }

  # install oldest server version configuration when user install
  else {

    # add some directories
    my Str $server-dir = "$!sandbox/Server-s1";
    mkdir( $server-dir, 0o700) unless $server-dir.IO ~~ :d;
    my Str $datadir = $server-dir ~ '/m.data';
    mkdir( $datadir, 0o700) unless $datadir.IO ~~ :d;

    # prepare for user install tests only
    $server-config<locations> = {
      :mongod("$!software/$!SERVER-VERSION-MIN/mongod"),
      :server-path($!sandbox),
      :logpath<m.log>,
      :pidfilepath<m.pid>,
      :dbpath<m.data>,
    };

    $server-config<locations><s1> = {
      :server-subdir<Server-s1>,
    };

    $server-config<server><s1> = {
      :port(self!find-next-free-port($start-portnbr)),
    };
  }

  # save config in sandbox
  "$!sandbox/config.toml".IO.spurt(
    to-toml( $server-config, :margin-between-tables(2), :indent-subkeys(2))
  );
}

#-------------------------------------------------------------------------------
=begin comment
  Test for usable port number
  According to https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers

  Dynamic, private or ephemeral (lasting for a very short time) ports

  The range 49152-65535 (2**15+2**14 to 2**16-1) contains dynamic or
  private ports that cannot be registered with IANA. This range is used
  for private, or customized services or temporary purposes and for automatic
  allocation of ephemeral ports.

  According to  https://en.wikipedia.org/wiki/Ephemeral_port

  Many Linux kernels use the port range 32768 to 61000.
  FreeBSD has used the IANA port range since release 4.6.
  Previous versions, including the Berkeley Software Distribution (BSD), use
  ports 1024 to 5000 as ephemeral ports.[2]

  Microsoft Windows operating systems through XP use the range 1025-5000 as
  ephemeral ports by default.
  Windows Vista, Windows 7, and Server 2008 use the IANA range by default.
  Windows Server 2003 uses the range 1025-5000 by default, until Microsoft
  security update MS08-037 from 2008 is installed, after which it uses the
  IANA range by default.
  Windows Server 2008 with Exchange Server 2007 installed has a default port
  range of 1025-60000.
  In addition to the default range, all versions of Windows since Windows 2000
  have the option of specifying a custom range anywhere within 1025-365535.
=end comment

method !find-next-free-port ( Int $start-portnbr --> Int ) {

  # Search from port 65000 until the last of possible port numbers for a free
  # port. this will be configured in the mongodb config file. At least one
  # should be found here.
  #
  my Int $port-number;
  for $start-portnbr ..^ 2**16 -> $port {
    my $s = IO::Socket::INET.new( :host('localhost'), :$port);
    $s.close;

    # On connect failure there was no service available on that port and
    # an exception is thrown. Catch and save
    CATCH {
      default {
        $port-number = $port;
        last;
      }
    }
  }

  $port-number
}
