use v6.c;

use Base64;

#-------------------------------------------------------------------------------
unit package Auth;

#TODO Implement server side
#TODO Keep information when calculated. User requst boolean
#     and username/password/authzid must be kept the same. This saves time.

#-------------------------------------------------------------------------------
role SCRAM::Client {

  has Str $!username;
  has Str $!password;
  has Str $!authzid = '';

  # Client side and server side communication. Pick one or the other.
  has $!client-object;

  # Set these values before creating the messages
  # Nonce size in bytes
  has Int $.c-nonce-size is rw = 24;
  has Str $.c-nonce is rw;
#TODO use of reserved mext and extensions
  has Str $.reserved-mext is rw;
  has Hash $.extensions is rw = %();

  # Strings used for communication
  has Str $!gs2-bind-flag;
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
  # Need to install BUILD method to comply with the does operator in Auth::SCRAM
  submethod BUILD (

    Str :$username, Str :$password, Str :$authzid,
    Bool :$case-preserved-profile = True,
    Callable :$CGH, :$client-object,
  ) { }

  #-----------------------------------------------------------------------------
  method init (
    Str:D :$username!,
    Str:D :$password!,
    Str :$authzid,
    :$client-object!
  ) {

    $!username = $username;
    $!password = $password;
    $!authzid = $authzid;
    $!client-object = $client-object;

    die 'message object misses some methods'
      unless self.test-methods(
        $client-object,
        < client-first client-final error >
      );
  }

  #-----------------------------------------------------------------------------
  method start-scram( --> Str ) {

    # Prepare message which must go to the server. Server returns a
    # its first server message.
    self!client-first-message;
    $!server-first-message = $!client-object.client-first($!client-first-message);
#say "server first message: ", $!server-first-message;

    my Str $error = self!process-server-first;
    if ?$error {
      $!client-object.error($error);
      return $error;
    }

    # Prepare the second and final message. Server returns its final message
    self!client-final-message;
    $!server-final-message = $!client-object.client-final($!client-final-message);
    $error = self!verify-server;
    if ?$error {
      $!client-object.error($error);
      return $error;
    }

    $!client-object.cleanup if $!client-object.^can('cleanup');
    '';
  }

  #-----------------------------------------------------------------------------
  method !client-first-message ( ) {

    self!set-gs2header;
    self!set-client-first;
  }

  #-----------------------------------------------------------------------------
  method !set-gs2header ( ) {

#TODO extensions
#TODO normalize authzid?
    my $aid = ($!authzid.defined and $!authzid.chars) ?? "a=$!authzid" !! '';

    $!gs2-bind-flag = 'n';
    $!gs2-header = "$!gs2-bind-flag,$aid";
  }

  #-----------------------------------------------------------------------------
  method !set-client-first ( ) {

    $!client-first-message-bare = 
      ( $!reserved-mext.defined and $!reserved-mext.chars )
        ?? "m=$!reserved-mext,"
        !! '';

    my Str $uname = self.encode-name($!username);
    $uname = self.normalize( $uname, :prep-username, :!enforce);
    $!client-first-message-bare ~= "n=$uname,";

    $!c-nonce = encode-base64(
      Buf.new((for ^$!c-nonce-size { (rand * 256).Int })),
      :str
    ) unless ? $!c-nonce;

    $!client-first-message-bare ~= "r=$!c-nonce";

    # Not needed anymore, necessary to reset to prevent reuse by hackers
    # So when user needs its own nonce again, set it before starting scram.
    $!c-nonce = Str;
#TODO used later to check returned server nonce, so not yet resetting it here?!

    # Only single character keynames are taken
    my Str $ext = (
      map -> $k, $v { next if $k.chars > 1; "$k=$v"; }, $!extensions.kv
    ).join(',');

    $!client-first-message-bare ~= ",$ext" if ?$ext;

    $!client-first-message = "$!gs2-header,$!client-first-message-bare";
  }

  #-----------------------------------------------------------------------------
  method !client-final-message ( ) {

    $!salted-password = self.derive-key(
      :$!username, :$!password, :$!authzid, :!enforce
      :salt($!s-salt), :iter($!s-iter),
      :helper-object($!client-object)
    );

    $!client-key = self.client-key($!salted-password);
    $!stored-key = self.stored-key($!client-key);

    # biws is from encode-base64( 'n,,', :str)
#TODO gs2-header [ cbind-data ]
    $!channel-binding = "c=biws";
    $!client-final-without-proof = "$!channel-binding,r=$!s-nonce";

    $!auth-message = 
      ( $!client-first-message-bare,
        $!server-first-message,
        $!client-final-without-proof
      ).join(',');

    $!client-signature = self.client-signature( $!stored-key, $!auth-message);
    $!client-proof = self.XOR( $!client-key, $!client-signature);

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
#TODO Check if it starts with client nonce

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

      $!server-key = self.server-key($!salted-password);
      $!server-signature = self.server-signature( $!server-key, $!auth-message);

      if encode-base64( $!server-signature, :str) ne $sv {
        $error = 'Server verification failed';
      }
    }

    else {
      $error = 'Server response not recognized';
    }

    $error;
  }
}
