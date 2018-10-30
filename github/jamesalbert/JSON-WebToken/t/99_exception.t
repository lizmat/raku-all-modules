use v6;
use Test;
use JSON::WebToken;
use JSON::WebToken::Constants;

plan 15;

subtest {
    {
      encode_jwt;
      CATCH {
        default {
          like $_.message, rx/'Error: $claims'/;
          is $_.payload{'code'}, ERROR_JWT_INVALID_PARAMETER;
        }
      }
    };
};

subtest {
    {
      my $claims = { foo => 'bar' };
      encode_jwt $claims;
      CATCH {
        default {
          like $_.message, rx/"secret must be specified"/;
          is $_.payload{'code'}, ERROR_JWT_MISSING_SECRET;
        }
      }
    };
};

subtest {
    {
      my $claims = [];
      encode_jwt $claims, 'secret';
      CATCH {
        default {
          like $_.message, rx/"Usage: encode"/;
          is $_.payload{'code'}, ERROR_JWT_INVALID_PARAMETER;
        }
      }
    };
};


subtest {
    {
      my $claims = { foo => 'bar' };
      encode_jwt $claims, 'secret', 'XXXX';
      CATCH {
        default {
          like $_.message, rx/"`XXXX` is Not supported siging algorithm"/;
          is $_.payload{'code'}, ERROR_JWT_NOT_SUPPORTED_SIGNING_ALGORITHM;
        }
      }
    };
};


subtest {
    {
      decode_jwt;
      CATCH {
        default {
          like $_.message, rx/"Usage: decode"/;
          is $_.payload{'code'}, ERROR_JWT_INVALID_PARAMETER;
        }
      }
    };
};


subtest {
    {
      decode_jwt 'x.y.z.foo.bar', 'secret';
      CATCH {
        default {
          like $_.message, rx/"Not enough or too many segments"/;
          is $_.payload{'code'}, ERROR_JWT_INVALID_SEGMENT_COUNT;
        }
      }
    };
};


subtest {
    {
      decode_jwt 'x', 'secret';
      CATCH {
        default {
          like $_.message, rx/"Not enough or too many segments"/;
          is $_.payload{'code'}, ERROR_JWT_INVALID_SEGMENT_COUNT;
        }
      }
    };
};


subtest {
    {
      decode_jwt 'x.y.z', 'secret';
      CATCH {
        default {
          like $_.message, rx/"Invalid segment encoding"/;
          is $_.payload{'code'}, ERROR_JWT_INVALID_SEGMENT_ENCODING;
        }
      }
    };
};


subtest {
    my $claims = { foo => 'bar' };
    my $jwt = encode_jwt $claims, 'secret';
    {
      decode_jwt $jwt, 'foo';
      CATCH {
        default {
          like $_.message, rx/"Invalid signature"/;
          is $_.payload{'code'}, ERROR_JWT_INVALID_SIGNATURE;
        }
      }
    };
};


subtest {
    my $claims = { foo => 'bar' };
    my $jwt = encode_jwt $claims, '', 'none';
    {
      decode_jwt "$jwt"~"xxx", 'foo';
      CATCH {
        default {
          like $_.message, rx/'Algorithm "none" is not acceptable'/;
          is $_.payload{'code'}, ERROR_JWT_UNACCEPTABLE_ALGORITHM;
        }
      }
    };
};


subtest {
    my $claims = { foo => 'bar' };
    my $jwt = encode_jwt $claims, '', 'none';
    {
      decode_jwt $jwt, "", 1, 0;
      CATCH {
        default {
          like $_.message, rx/'Algorithm "none" is not acceptable'/;
          is $_.payload{'code'}, ERROR_JWT_UNACCEPTABLE_ALGORITHM;
        }
      }
    };
};


subtest {
    my $claims = { foo => 'bar' };
    my $jwt = encode_jwt $claims, 'secret', 'HS256';
    ok decode_jwt "$jwt", 'secret', 1, ["HS256"];
    ok decode_jwt "$jwt", 'secret', 1, "HS256";
    {
      decode_jwt "$jwt", 'secret', 1, ["RS256"];
      CATCH {
        default {
          like $_.message, rx/'Algorithm "HS256" is not acceptable. Followings are accepted:RS256'/;
          is $_.payload{'code'}, ERROR_JWT_UNACCEPTABLE_ALGORITHM;
        }
      }
    };


};


subtest {
    my $claims = { foo => 'bar' };
    my $jwt = encode_jwt $claims, '', 'none';
    {
      decode_jwt "$jwt"~"xxx", 'foo', 1, "none";
      CATCH {
        default {
          like $_.message, rx/"Signature must be the empty string when alg is none"/;
          is $_.payload{'code'}, ERROR_JWT_UNWANTED_SIGNATURE;
        }
      }
    };
};


subtest {
    my $claims = { foo => 'bar' };
    my $jwt = encode_jwt $claims, 'secret';
    {
      decode_jwt $jwt;
      CATCH {
        default {
          like $_.message, rx/"secret must be specified"/;
          is $_.payload{'code'}, ERROR_JWT_MISSING_SECRET;
        }
      }
    };
};


subtest {
    my $claims = { foo => 'bar' };
    my $jwt = encode_jwt $claims, 'secret';
    my $got = decode_jwt $jwt, Nil, 0;
    is-deeply $got, { foo => 'bar' };
};
