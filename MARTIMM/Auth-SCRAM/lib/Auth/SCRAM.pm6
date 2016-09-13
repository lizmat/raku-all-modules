use v6c;

use Digest::HMAC;
use OpenSSL::Digest;
use PKCS5::PBKDF2;

#-------------------------------------------------------------------------------
unit package Auth;

#TODO Implement server side
#TODO Keep information when calculated. User requst boolean
#     and username/password/authzid must be kept the same. This saves time.

#-------------------------------------------------------------------------------
#class SCRAM::Client { ... }
#class SCRAM::Server { ... }

class SCRAM {

#  trusts Auth::SCRAM::Client;
#  trusts Auth::SCRAM::Server;

  has Bool $!role-imported = False;
  has PKCS5::PBKDF2 $!pbkdf2;
  has Callable $!CGH;
  has Bool $!skip-sasl-prep = False;

  #-----------------------------------------------------------------------------
  submethod BUILD (

    Str :$username,
    Str :$password,
    Str :$authzid,

    Callable :$CGH = &sha1,
    :$client-side,
    :$server-side,
  ) {

    $!CGH = $CGH;
    $!pbkdf2 .= new(:$CGH);

    # Check client or server object capabilities
    if $client-side.defined {
      die 'No username and/or password provided'
        unless ? $username and ? $password;

      die 'Only a client or server object must be chosen'
        if $server-side.defined;


      if not $!role-imported {
        need Auth::SCRAM::Client;
        import Auth::SCRAM::Client;
        $!role-imported = True;
      }
      self does Auth::SCRAM::Client;
      self.init( :$username, :$password, :$authzid, :$client-side);
    }

    elsif $server-side.defined {

      if not $!role-imported {
        need Auth::SCRAM::Server;
        import Auth::SCRAM::Server;
        $!role-imported = True;
      }
      self does Auth::SCRAM::Server;
      self.init(:$server-side);
    }

    else {
      die 'At least a client or server object must be chosen';
    }
  }

  #-----------------------------------------------------------------------------
  method skip-sasl-prep ( Bool:D :$skip ) {

    $!skip-sasl-prep = $skip;
  }

  #-----------------------------------------------------------------------------
  method derive-key (
    Str :$username, Str:D :$password, Str :$authzid,
    Buf:D :$salt, Int:D :$iter,
    Any:D :$helper-object
    --> Buf
  ) {

    # Using named arguments, the clients object doesn't need to
    # support all variables as long as a Buf is returned
    my Buf $mangled-password;
    if $helper-object.^can('mangle-password') {
      $mangled-password = $helper-object.mangle-password(
        :$username, :$password, :$authzid
      );
    }

    else {
      $mangled-password = Buf.new($password.encode);
    }

    $!pbkdf2.derive( $mangled-password, $salt, $iter);
  }

  #-----------------------------------------------------------------------------
  method client-key ( Buf $salted-password --> Buf ) {

    hmac( $salted-password, 'Client Key', &$!CGH);
  }

  #-----------------------------------------------------------------------------
  method stored-key ( Buf $client-key --> Buf ) {

    $!CGH($client-key);
  }

  #-----------------------------------------------------------------------------
  method client-signature ( Buf $stored-key, Str $auth-message --> Buf ) {

    hmac( $stored-key, $auth-message, &$!CGH);
  }

  #-----------------------------------------------------------------------------
  method server-key ( Buf $salted-password --> Buf ) {

    hmac( $salted-password, 'Server Key', &$!CGH);
  }

  #-----------------------------------------------------------------------------
  method server-signature ( Buf $server-key, Str $auth-message --> Buf ) {

    hmac( $server-key, $auth-message, &$!CGH);
  }

  #-----------------------------------------------------------------------------
  method XOR ( Buf $x1, Buf $x2 --> Buf ) {

    my Buf $x3 .= new;
    for ^($x1.elems) -> $i {
      $x3[$i] = $x1[$i] +^ $x2[$i];
    }

    $x3;
  }

  #-----------------------------------------------------------------------------
  method sasl-prep ( Str:D $text --> Str ) {

    my Str $prepped-text = $text;

    unless $!skip-sasl-prep {
#TODO prep string

    }

    # Some character protection changes
    $prepped-text = self!encode-name($prepped-text);
  }

  #-----------------------------------------------------------------------------
  method !encode-name ( Str $name is copy --> Str ) {

    $name ~~ s:g/ '=' /=3d/;
    $name ~~ s:g/ ',' /=2c/;

    $name;
  }

  #-----------------------------------------------------------------------------
  method test-methods ( $obj, @methods --> Bool ) {

    my Bool $all-there = True;
    for @methods -> $method {
      if !? $obj.^can($method) {
        $all-there = False;
        last;
      }
    }

    $all-there;
  }
}
