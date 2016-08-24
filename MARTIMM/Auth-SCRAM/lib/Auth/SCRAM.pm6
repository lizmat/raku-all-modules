use v6c;

use Digest::HMAC;
use OpenSSL::Digest;
use Base64;

use PKCS5::PBKDF2;

#-------------------------------------------------------------------------------
unit package Auth;

#-------------------------------------------------------------------------------
class SCRAM {

  has Str $!username;
  has Str $!password;
  has Str $!authzid = '';
  has Bool $!strings-are-prepped = False;

  # Name of digest, usable values are sha1 and sha256
  has Callable $!CGH;
  has PKCS5::PBKDF2 $!pbkdf2;

  # Client side and server side communication. Pick one or the other.
  has $!client-side;
  has $!server-side;

  # Normalization of username and password can be skipped if normal
  # ASCII is used
  has Bool $!skip-saslprep = False;

  # Set these values before creating the messages
  # Nonce size in bytes
  has Int $.c-nonce-size is rw = 24;
  has Str $.c-nonce is rw;
  has Str $.reserved-mext is rw;
  has Hash $.extensions is rw = %();

  # Strings used for communication
  has Str $!gs2-header;
  has Str $!client-first-message-bare;
  has Str $!client-first-message;

  has Str $!server-first-message;
  has Str $!s-nonce;
  has Buf $!s-salt;
  has Int $!s-iter;

  has Buf $!salted-password;
  has Buf $!client-key;
  has Buf $!stored-key;

  has Str $!channel-binding;
  has Str $!client-final-without-proof;
  has Str $!client-final-message;
  has Str $!auth-message;
  has Buf $!client-signature;
  has Buf $!client-proof;

  has Str $!server-final-message;
  has Buf $!server-key;
  has Buf $!server-signature;

  #-----------------------------------------------------------------------------
  submethod BUILD (
    Str:D :$username!,
    Str:D :$password!,

    Callable :$CGH = &sha1,
    Str :$authzid,
    :$client-side,
    :$server-side,
  ) {

    $!username = $username;
    $!password = $password;
    $!authzid = $authzid;

    $!CGH = $CGH;
    $!pbkdf2 .= new(:$CGH);

    # Check client or server object capabilities
    if $client-side.defined {
      die 'Only a client or server object must be chosen'
          if $server-side.defined;

      die 'message object misses some methods'
          unless self!test-methods(
            $client-side,
            <message1 message2 mangle-password clean-up error>
          );

      $!client-side = $client-side;
    }

    elsif $server-side.defined {
      die 'Server object misses some methods'
          unless self!test-methods(
            $server-side,
            <message1 message2 clean-up error>
          );

      $!server-side = $server-side;
    }

    else {
      die 'At least a client or server object must be chosen';
    }
  }

  #-----------------------------------------------------------------------------
  method skip-saslprep ( Bool:D :$skip ) {

    $!skip-saslprep = $skip;
    $!strings-are-prepped = False unless $skip;
  }

  #-----------------------------------------------------------------------------
  method start-scram( ) {

    # Can only done from client so check client object
    die 'No client object defined' unless $!client-side.defined;

    # Prepare message and send to server. Returns server-first-message
    self!client-first-message;
    $!server-first-message = $!client-side.message1($!client-first-message);
#say "server first message: ", $!server-first-message;

    my Str $error = self!process-server-first;
    if ?$error {
      $!client-side.error($error);
      return fail($error);
    }

    # Prepare for second round ... `doiinggg' :-P
    self!client-final-message;
    $!server-final-message = $!client-side.message2($!client-final-message);
#say "server final message: ", $!server-final-message;
    $error = self!verify-server;
    if ?$error {
      $!client-side.error($error);
      return fail($error);
    }

    '';
  }

  #-----------------------------------------------------------------------------
  method !client-first-message ( ) {

    # check state of strings
    unless $!strings-are-prepped {

      $!username = self!saslPrep($!username);
#      $!password = self!saslPrep($!password);
      $!authzid = self!saslPrep($!authzid) if ?$!authzid;
      $!strings-are-prepped = True;
    }

    self!set-gs2header;
#say "gs2 header: ", $!gs2-header;

    self!set-client-first;
#say "client first message bare: ", $!client-first-message-bare;
#say "client first message: ", $!client-first-message-bare;

  }

  #-----------------------------------------------------------------------------
  method !set-gs2header ( ) {

    my $aid = ($!authzid.defined and $!authzid.chars) ?? "a=$!authzid" !! '';
    $!gs2-header = "n,$aid";
  }

  #-----------------------------------------------------------------------------
  method !set-client-first ( ) {

    $!client-first-message-bare = 
      ( $!reserved-mext.defined and $!reserved-mext.chars )
        ?? "m=$!reserved-mext,"
        !! '';

    $!client-first-message-bare ~= "n=$!username,";

    unless ? $!c-nonce {
      $!c-nonce = encode-base64(
        Buf.new((for ^$!c-nonce-size { (rand * 256).Int }))
        , :str
      );
    }

    $!client-first-message-bare ~= "r=$!c-nonce";

    # Not needed anymore, neccesary to reset to prevent reuse by hackers
    # So when user needs its own nonce again, set it before starting scram.
    $!c-nonce = Str;

    # Only single character keynames are taken
    my Str $ext = (
      map -> $k, $v { next if $k.chars > 1; "$k=$v"; }, $!extensions.kv
    ).join(',');

    $!client-first-message-bare ~= ",$ext" if ?$ext;

    $!client-first-message = "$!gs2-header,$!client-first-message-bare";
  }

  #-----------------------------------------------------------------------------
  method !client-final-message ( ) {

    # Using named arguments, the clients object doesn't need to
    # support all variables as long as a Buf is returned
    my Buf $user-mangled-password = $!client-side.mangle-password(
      :$!username, :$!password, :$!authzid
    );

    $!salted-password = $!pbkdf2.derive(
      $user-mangled-password,
      $!s-salt,
      $!s-iter
    );
#say "SP: ", $!salted-password;

    $!client-key = hmac( $!salted-password, 'Client Key', &$!CGH);
    $!stored-key = $!CGH($!client-key);

    # biws is from encode-base64( 'n,,', :str)
    #TODO gs2-header [ cbind-data ]
    $!channel-binding = "c=biws";
    $!client-final-without-proof = "$!channel-binding,r=$!s-nonce";

    $!auth-message = 
      ( $!client-first-message-bare,
        $!server-first-message,
        $!client-final-without-proof
      ).join(',');

    $!client-signature = hmac( $!stored-key, $!auth-message, &$!CGH);

    $!client-proof .= new;
    for ^($!client-key.elems) -> $i {
      $!client-proof[$i] = $!client-key[$i] +^ $!client-signature[$i];
    }

    $!client-final-message =
      [~] $!client-final-without-proof,
          ',p=',
          encode-base64( $!client-proof, :str);
  }

  #-----------------------------------------------------------------------------
  method !process-server-first ( --> Str ) {

    my Str $error = '';

    $error = 'Undefined first server message' unless ? $!server-first-message;
    return $error if $error;

    ( my $nonce, my $salt, my $iter) = $!server-first-message.split(',');

    $nonce ~~ s/^ 'r=' //;
    $error = 'no nonce found' if !? $nonce or !?$/; # Check s/// operation too
    return $error if $error;

    $salt ~~ s/^ 's=' //;
    $error = 'no salt found' if !? $salt or !?$/;
    return $error if $error;

    $iter ~~ s/^ 'i=' //;
    $error = 'no iteration count found' if !? $iter or !?$/;
    return $error if $error;

    $!s-nonce = $nonce;
    $!s-salt = decode-base64( $salt, :bin);
    $!s-iter = $iter.Int;

    $error;
  }

  #-----------------------------------------------------------------------------
  method !verify-server ( --> Str ) {

    my Str $error = '';

    if $!server-final-message ~~ m/^ 'e=' / {
      # error
    }

    elsif $!server-final-message ~~ m/^ 'v=' / {
      # verify server
      my Str $sv = $!server-final-message;
      $sv ~~ s/^ 'v=' //;

      $!server-key = hmac( $!salted-password, 'Server Key', &$!CGH);
      $!server-signature = hmac( $!server-key, $!auth-message, &$!CGH);

      if encode-base64( $!server-signature, :str) ne $sv {
        $error = 'Server verification failed';
      }
    }

    else {
      $error = 'Server response not recognized';
    }

    $error;
  }

  #-----------------------------------------------------------------------------
  method !saslPrep ( Str:D $text --> Str ) {

    my Str $prepped-text = $text;
    unless $!skip-saslprep {
      # prep string
    }

    # never skip this
    $prepped-text = self!encode-name($prepped-text);
  }

  #-----------------------------------------------------------------------------
  method !decode-name ( Str $name is copy --> Str ) {

    $name ~~ s:g/ '=2c' /,/;
    $name ~~ s:g/ '=3d' /=/;
  }

  #-----------------------------------------------------------------------------
  method !encode-name ( Str $name is copy --> Str ) {

    $name ~~ s:g/ '=' /=3d/;
    $name ~~ s:g/ ',' /=2c/;

    $name;
  }

  #-----------------------------------------------------------------------------
  method !test-methods ( $obj, @methods --> Bool ) {

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
