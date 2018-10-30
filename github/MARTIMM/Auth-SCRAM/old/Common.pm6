use v6c;

use Digest::HMAC;
use OpenSSL::Digest;
use PKCS5::PBKDF2;

#-------------------------------------------------------------------------------
unit package Auth;

class SCRAM::Common {

  has PKCS5::PBKDF2 $!pbkdf2;
  has Callable $!CGH;

  #-----------------------------------------------------------------------------
  submethod BUILD ( Callable :$CGH = &sha1 ) {

    $!pbkdf2 .= new(:$CGH);
  }

  #-----------------------------------------------------------------------------
  method !derive-key (
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
}
