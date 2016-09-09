use v6c;

use Base64;

#-------------------------------------------------------------------------------
unit package Auth;

#TODO Implement server side
#TODO Keep information when calculated. User requst boolean
#     and username/password/authzid must be kept the same. This saves time.

#-------------------------------------------------------------------------------
role SCRAM::Server {

  has Str $!username;
  has Str $!password;
  has Str $!authzid = '';
#  has Bool $!strings-are-prepped = False;

  has $!server-side;

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
  has Int $.s-nonce-size is rw = 18;
  has Str $.s-nonce is rw;
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

  has Str $!error-message;
  #-----------------------------------------------------------------------------
  method init ( :$server-side! ) {

    $!server-side = $server-side;

    die 'message object misses some methods'
      unless self.test-methods(
        $server-side,
        < credentials server-first server-final error >
      );
  }

  #-----------------------------------------------------------------------------
  method generate-user-credentials (
    Str :$username, Str :$password,
    Buf :$salt, Int :$iter,
    Any :$helper-object

    --> Hash
  ) {

    my Buf $salted-password = self.derive-key(
      :$username, :$password,
      :$salt, :$iter,
      :$helper-object,
    );

    my Buf $client-key = self.client-key($salted-password);
    my Buf $stored-key = self.stored-key($client-key);
    my Buf $server-key = self.server-key($salted-password);

    %( iter => $iter,
       salt => encode-base64( $salt, :str),
       stored-key => encode-base64( $stored-key, :str),
       server-key => encode-base64( $server-key, :str)
    );
  }

  #-----------------------------------------------------------------------------
  method start-scram( Str:D :$client-first-message! --> Str ) {

    $!client-first-message = $client-first-message;
    my Str $error = self!process-client-first;
    return self!process-error($error) if ?$error;

    $error = self!server-first-message;
    return self!process-error($error) if ?$error;

    $!client-final-message = $!server-side.server-first($!server-first-message);

    $error = self!process-client-final;
    return self!process-error($error) if ?$error;

    $error = $!server-side.server-final(
      'v=' ~ encode-base64( $!server-signature, :str)
    );
    return self!process-error($error) if ?$error;

    $!server-side.cleanup if $!server-side.^can('cleanup');

    '';
  }

  #-----------------------------------------------------------------------------
  method !process-client-first ( --> Str ) {

#say "PC 1st: $!client-first-message";
    # First get the gs2 header
    for $!client-first-message.split( ',', 3) {

      when /^ <[ny]> $/ {
        $!gs2-bind-flag = $_;
      }

      when /^ 'p=' / {
        $!gs2-bind-flag = $_;
        $!gs2-bind-flag ~~ s/^ 'p=' //;
      }

      when /^ 'a=' / {
        $!authzid = $_;
        $!authzid ~~ s/^ 'a=' //;
      }

      when /^ $/ {
        # no authzid
      }

      default {

        $!client-first-message-bare = $_;

        for .split(',') {
          when /^ 'n=' / {
            $!username = $_;
            $!username ~~ s/^ 'n=' //;
            $!username ~~ m:g/ '=' $<code>=[.?.?] /;

            for @$/ -> $c {
              return 'invalid-encoding' unless $c<code> ~~ m:i/ '2c' | '3d' /;
            }
          }

          when /^ 'r=' / {
            $!c-nonce = $_;
            $!c-nonce ~~ s/^ 'r=' //;
          }

          # According to rfc this is for future extensibility. When used
          # the server should always error. This works now when
          # $!server-side.mext() and $!server-side.extension() are not defined.
          when /^ 'm=' / {
            $!reserved-mext = $_;
            $!reserved-mext ~~ s/^ 'm=' //;

            my Bool $mext-accept = False;
            $mext-accept = $!server-side.mext($!reserved-mext)
              if $!server-side.^can('mext');
            return 'extensions-not-supported' unless $mext-accept;
          }

          when /^ 'p=' / {
            $!gs2-bind-flag = $_;
            $!gs2-bind-flag ~~ s/^ 'p=' //;
          }

          default {
            my $extension = $_;
            $extension ~~ s/^ $<ename>=. '=' $<eval>=(.+) $//;

            my Bool $ext-accept = False;
            $ext-accept = $!server-side.extension( $/<ename>.Str, $/<eval>.Str)
              if $!server-side.^can('extension');
            return 'extensions-not-supported' unless $ext-accept;
#TODO gather extensions
          }
        }
      }
    }

    if ? $!username and ? $!authzid and $!server-side.^can('authzid') {
      return "other-error"
        unless $!server-side.authzid( $!username, $!authzid);
    }
    
    '';
  }

  #-----------------------------------------------------------------------------
  # server-first-message =
  #                   [reserved-mext ","] nonce "," salt ","
  #                   iteration-count ["," extensions]
  method !server-first-message ( ) {

    my Hash $credentials = $!server-side.credentials(
      $!username, $!authzid
    );
    return 'unknown-user' unless $credentials.elems;

    $!s-salt = Buf.new(decode-base64($credentials<salt>));
    $!s-iter = $credentials<iter>;

    $!s-nonce = encode-base64(
      Buf.new((for ^$!s-nonce-size { (rand * 256).Int })),
      :str
    ) unless ? $!s-nonce;

    my $s1stm = ? $!reserved-mext ?? "m=$!reserved-mext," !! '';
    $s1stm ~= "r=$!c-nonce$!s-nonce"
              ~ ",s=" ~ encode-base64( $!s-salt, :str)
              ~ ",i=$!s-iter";
    $s1stm ~= $!extensions.elems
              ?? ',' ~ ( map -> $k, $v { next if $k.chars > 1; "$k=$v"; },
                   $!extensions.kv
                 ).join(',')
              !! '';

    $!server-first-message = $s1stm;

    '';
  }

  #-----------------------------------------------------------------------------
  method !process-client-final ( --> Str ) {

#say "PC 1st: $!client-final-message";
    for $!client-final-message.split(',') {
      when /^ 'c=' / {
        $!channel-binding = $_;
        $!channel-binding ~~ s/^ 'c=' //;
      }

      when /^ 'r=' / {
        my Str $nonce = $_;
        $nonce ~~ s/^ 'r=' //;
        return 'invalid-encoding' if $nonce ne $!c-nonce ~ $!s-nonce;
      }

      when /^ 'p=' / {

        my Str $proof = $_;
        my $client-final-without-proof = $!client-final-message;
        $client-final-without-proof ~~ s/ ',' $proof $//;

        $!auth-message = [~] $!client-first-message-bare,
                             ',', $!server-first-message,
                             ',', $client-final-without-proof;

        $proof ~~ s/^ 'p=' //;
        $!client-proof = Buf.new(decode-base64($proof));

#say "AML $!auth-message";

        my Hash $credentials = $!server-side.credentials(
          $!username, $!authzid
        );
        return 'unknown-user' unless $credentials.elems;

        $!stored-key = Buf.new(decode-base64($credentials<stored-key>));
        $!client-signature = self.client-signature(
          $!stored-key, $!auth-message
        );
        $!client-key = self.XOR( $!client-proof, $!client-signature);

        my Str $st-key = encode-base64( self.stored-key($!client-key), :str);
#say "Stored-keys: $st-key, $credentials<stored-key>";
        return 'invalid-proof' if $st-key ne $credentials<stored-key>;

        $!server-key = Buf.new(decode-base64($credentials<server-key>));
        $!server-signature = self.server-signature(
          $!server-key, $!auth-message
        );
      }

      default {
#TODO extensions processing
      }
    }

    '';
  }

  #-----------------------------------------------------------------------------
  method !process-error ( Str $error ) {
  
    $!error-message = "e=$error";
    $!server-side.error($!error-message);
    
    $!error-message;
  }
}
