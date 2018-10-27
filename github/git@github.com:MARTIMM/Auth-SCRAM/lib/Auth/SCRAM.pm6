use v6.c;

use Digest::HMAC;
use OpenSSL::Digest;
use PKCS5::PBKDF2;
use Unicode::PRECIS;
use Unicode::PRECIS::Identifier::UsernameCaseMapped;
use Unicode::PRECIS::Identifier::UsernameCasePreserved;
use Unicode::PRECIS::FreeForm::OpaqueString;

#-------------------------------------------------------------------------------
unit package Auth;

#TODO Keep information when calculated. User request boolean
#     and username/password/authzid must be kept the same. This saves time.

#-------------------------------------------------------------------------------
class SCRAM {

  has Bool $!role-imported = False;
  has PKCS5::PBKDF2 $!pbkdf2;
  has Callable $!CGH;
  has Bool $!case-preserved-profile;

#`{{
  #-----------------------------------------------------------------------------
  submethod BUILD (

    Str :$username,
    Str :$password,
    Str :$authzid,
    Bool :$case-preserved-profile = True,

    Callable :$CGH = &sha1,
    :$helper-object,
    Bool :$client-helper = True,
  ) {

    $!CGH = $CGH;
    $!pbkdf2 .= new(:$CGH);
    $!case-preserved-profile = $case-preserved-profile;

    # Check client or server object capabilities
    if $client-helper {
      die 'No username and/or password provided'
        unless ? $username and ? $password;

      if not $!role-imported {
        need Auth::SCRAM::Client;
        import Auth::SCRAM::Client;
        $!role-imported = True;
      }
      self does Auth::SCRAM::Client;
      self.init( :$username, :$password, :$authzid, :client-object($helper-object));
    }

    else {

      if not $!role-imported {
        need Auth::SCRAM::Server;
        import Auth::SCRAM::Server;
        $!role-imported = True;
      }
      self does Auth::SCRAM::Server;
      self.init(:server-object($helper-object));
    }
  }
}}

  #-----------------------------------------------------------------------------
  # Client interface init
  multi submethod BUILD (

    Str :$username!,
    Str :$password!,
    Str :$authzid,
    Bool :$case-preserved-profile = True,

    Callable :$CGH = &sha1,
    :$client-object!,
  ) {

    $!CGH = $CGH;
    $!pbkdf2 .= new(:$CGH);
    $!case-preserved-profile = $case-preserved-profile;

    if not $!role-imported {
      need Auth::SCRAM::Client;
      import Auth::SCRAM::Client;
      $!role-imported = True;
    }

    self does Auth::SCRAM::Client;
    self.init(
      :$username, :$password, :$authzid, :$client-object
    );
  }

  #-----------------------------------------------------------------------------
  # Server interface init
  multi submethod BUILD (

    Bool :$case-preserved-profile = True,
    Callable :$CGH = &sha1,
    :$server-object!,
  ) {

    $!CGH = $CGH;
    $!pbkdf2 .= new(:$CGH);
    $!case-preserved-profile = $case-preserved-profile;

    if not $!role-imported {
      need Auth::SCRAM::Server;
      import Auth::SCRAM::Server;
      $!role-imported = True;
    }

    self does Auth::SCRAM::Server;
    self.init(:$server-object);
  }

  #-----------------------------------------------------------------------------
  method derive-key (
    Str:D :$username is copy, Str:D :$password is copy,
    Str :$authzid, Bool :$enforce = False,
    Buf:D :$salt, Int:D :$iter,
    Any:D :$helper-object
    --> Buf
  ) {

#TODO normalize authzid?
    $username = self.normalize( $username, :prep-username, :$enforce);
    $password = self.normalize( $password, :!prep-username, :$enforce);

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
  method normalize (
    Str:D $text, Bool:D :$prep-username!, :$enforce = False
    --> Str
  ) {

    my TestValue $prepped-text;
    my $operation = $enforce ?? 'enforce' !! 'prepare';

    # Normalize username
    if $prep-username {

#      # Some character protection changes
#      $prepped-text = self.encode-name($prepped-text);

      # Case preserved profile
      if $!case-preserved-profile {
         my Unicode::PRECIS::Identifier::UsernameCasePreserved $upi-ucp .= new;
         $prepped-text = $upi-ucp."$operation"($text);
         die "Username $text not accepted" if $prepped-text ~~ Bool;
      }

      # Case mapped profile
      else {
         my Unicode::PRECIS::Identifier::UsernameCaseMapped $upi-ucp .= new;
         $prepped-text = $upi-ucp."$operation"($text);
         die "Username $text not accepted" if $prepped-text ~~ Bool;
      }
    }

    # Normalize password
    else {
      my Unicode::PRECIS::FreeForm::OpaqueString $upf-os .= new;
      $prepped-text = $upf-os."$operation"($text);
      die "Password not accepted" if $prepped-text ~~ Bool;
    }

    $prepped-text;
  }

  #-----------------------------------------------------------------------------
  method encode-name ( Str $name is copy --> Str ) {

    $name ~~ s:g/ '=' /=3d/;
    $name ~~ s:g/ ',' /=2c/;

    $name;
  }

  #-----------------------------------------------------------------------------
  method decode-name ( Str $name is copy --> Str ) {

    $name ~~ s:g:i/ '=2c' /,/;
    $name ~~ s:g:i/ '=3d' /=/;

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
