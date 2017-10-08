unit package JSON::WebToken;

use v6;
our $VERSION = '0.0.1';

use JSON::Fast;
use MIME::Base64;
use JSON::WebToken::Constants;
use JSON::WebToken::Exception;

our $ALGORITHM_MAP = {
    # for JWS
    HS256  => 'HMAC',
    HS384  => 'HMAC',
    HS512  => 'HMAC',
#    RS256  => 'RSA',
#    RS384  => 'RSA',
#    RS512  => 'RSA',
#    ES256  => 'EC',
#    ES384  => 'EC',
#    ES512  => 'EC',
    none   => 'NONE',

    # for JWE
#    RSA1_5           => 'RSA',
#    'RSA-OAEP'       => 'OAEP',
#    A128KW           => '',
#    A256KW           => '',
#    dir              => 'NONE',
#    'ECDH-ES'        => '',
#    'ECDH-ES+A128KW' => '',
#    'ECDH-ES+A256KW' => '',

    # for JWK
#    EC  => 'EC',
#    RSA => 'RSA',
};

our $DEFAULT_ALLOWED_ALGORITHMS = [ grep { $_ ne "none" }, (keys %$ALGORITHM_MAP) ];

sub encode is export {
  my ($claims, $secret, $algorithm, $extra_headers) = @_;
  $algorithm     ||= 'HS256';
  $extra_headers ||= {};

  unless ($claims.defined) {
    throw-error({
      code    => ERROR_JWT_INVALID_PARAMETER,
      message => 'Error: $claims must be specified'
    })
  }
  unless ($claims ~~ Hash) {
    throw-error({
      code    => ERROR_JWT_INVALID_PARAMETER,
      message => "Usage: encode($claims [, $secret, $algorithm, \%$extra_headers ])",
    });
  }

  my $header = {
    alg => $algorithm,
    %$extra_headers,
  };
  $algorithm = $header{'alg'};

  if ($algorithm ne 'none' && !defined $secret) {
    throw-error({
      code    => ERROR_JWT_MISSING_SECRET,
      message => 'secret must be specified',
    });
  }

  my $header_segment  = MIME::Base64.encode-str(to-json $header);
  my $claims_segment  = MIME::Base64.encode-str(to-json $claims);
  my $signature_input = join '.', $header_segment, $claims_segment;

  my $signature = _sign($algorithm, $signature_input, $secret);
  return join '.', $signature_input, MIME::Base64.encode-str($signature);
}

sub encode_jwt is export {
  encode(@_);
}

sub decode is export {
    my ($jwt, $secret, $verify_signature=Nil, $accepted_algorithms=Nil) = @_;

    if ($accepted_algorithms ~~ Array) {
        # do nothing
    }
    elsif ($accepted_algorithms.defined) {
        if ($accepted_algorithms ~~ /^[01]$/) {
            die 'accept_algorithm "none" is deprecated';
            $accepted_algorithms = !!$accepted_algorithms ??
                [@$DEFAULT_ALLOWED_ALGORITHMS, "none"] !!  $DEFAULT_ALLOWED_ALGORITHMS;
        }
        else {
            $accepted_algorithms = [ $accepted_algorithms ];
        }
    }
    else {
        $accepted_algorithms = $DEFAULT_ALLOWED_ALGORITHMS;
    }

    unless ($jwt.defined) {
      throw-error({
        code    => ERROR_JWT_INVALID_PARAMETER,
        message => 'Usage: decode($jwt [, $secret, $verify_signature, $accepted_algorithms ])',
      });
    }

    $verify_signature = 1 unless $verify_signature.defined;
    if ($verify_signature && !$secret.defined) {
      throw-error({
        code    => ERROR_JWT_MISSING_SECRET,
        message => 'secret must be specified',
      });
    }

    my $segments = [ split '.', $jwt ];
    unless (@$segments.elems >= 2 && @$segments.elems <= 4) {
      throw-error({
        code    => ERROR_JWT_INVALID_SEGMENT_COUNT,
        message => "Not enough or too many segments by $jwt",
      });
    }

    my ($header_segment, $claims_segment, $crypto_segment) = @$segments;
    my $signature_input = join '.', $header_segment, $claims_segment;

    my ($header, $claims, $signature);
    {
      $header    = from-json MIME::Base64.decode-str($header_segment);
      $claims    = from-json MIME::Base64.decode-str($claims_segment);
      $signature = MIME::Base64.decode-str($crypto_segment) if $header{'alg'} ne 'none' && $verify_signature;
      CATCH {
        default {
          throw-error({
            code    => ERROR_JWT_INVALID_SEGMENT_ENCODING,
            message => 'Invalid segment encoding',
          });
        }
      }
    }

    return $claims unless $verify_signature;

    my $algorithm = $header{'alg'};
    unless ( grep { $_ eq $algorithm }, (@$accepted_algorithms) ) {
      throw-error({
        code    => ERROR_JWT_UNACCEPTABLE_ALGORITHM,
        message => "Algorithm \"$algorithm\" is not acceptable. Followings are accepted:" ~ join(",", @$accepted_algorithms),
      });
    }

    if ($secret ~~ Code) {
        $secret = $secret($header, $claims);
    }

    if ($algorithm eq 'none' and $crypto_segment) {
      throw-error({
        code    => ERROR_JWT_UNWANTED_SIGNATURE,
        message => 'Signature must be the empty string when alg is none',
      });
    }

    unless (_verify($algorithm, $signature_input, $secret, $signature)) {
      throw-error({
        code    => ERROR_JWT_INVALID_SIGNATURE,
        message => "Invalid signature by $signature",
      });
    }

    return $claims;
}

sub decode_jwt is export {
  decode(@_);
}

my (%class_loaded, %alg_to_class);
sub add_signing_algorithm is export {
    my ($algorithm) = @_;
    my $alg-name = $algorithm.^name;
    unless ($algorithm) {
      throw-error({
        code    => ERROR_JWT_INVALID_PARAMETER,
        message => 'Usage: add_signing_algorithm($algorithm, $signing_class)',
      });
    }
    push(@$DEFAULT_ALLOWED_ALGORITHMS, $alg-name);
    $ALGORITHM_MAP{$alg-name} = $algorithm;
    %alg_to_class{$alg-name} = $algorithm;
}

sub _sign {
    my ($algorithm, $message, $secret) = @_;
    return '' if $algorithm eq 'none';
    #_ensure_class_loaded($algorithm).sign;
    _ensure_class_loaded($algorithm).sign($algorithm, $message, $secret);
}

sub _verify {
    my ($algorithm, $message, $secret, $signature) = @_;
    return 1 if $algorithm eq 'none';
    _ensure_class_loaded($algorithm).verify($algorithm, $message, $secret, $signature);
}

sub _ensure_class_loaded {
  my ($algorithm) = @_;
  return %alg_to_class{$algorithm} if %alg_to_class{$algorithm};

  my $klass = $ALGORITHM_MAP{$algorithm};
  unless ($klass) {
      throw-error({
          code    => ERROR_JWT_NOT_SUPPORTED_SIGNING_ALGORITHM,
          message => "`$algorithm` is Not supported siging algorithm",
      });
  }

  my $signing_class = $klass ~~ s/^\+// ?? $klass !! "JSON::WebToken::Crypt::$klass";
  return $signing_class if %class_loaded{$signing_class};

  my $to_return;
  if (_is_not_inner_package $signing_class) {
    require ::($signing_class);
    $to_return = ::($signing_class).new;
  } else {
  }

  %class_loaded{$signing_class} = 1;
  %alg_to_class{$algorithm}     = $to_return;
  return %alg_to_class{$algorithm};
}

sub _is_not_inner_package {
  my ($klass) = @_;
  return ::($klass) ~~ Failure;
}

=finish
