use v6;
use lib 'lib';
use Test;
use Config::TOML::Parser::Actions;
use Config::TOML::Parser::Grammar;

plan 7;

# string grammar-actions tests {{{
# --- basic string equivalency tests {{{

subtest
{
    # The following strings are byte-for-byte equivalent:
    my Str $str1 = Q:to/EOF/;
    "The quick brown fox jumps over the lazy dog."
    EOF
    $str1 .= trim;

    my Str $str2 = Q:to/EOF/;
    """
    The quick brown \


      fox jumps over \
        the lazy dog."""
    EOF
    $str2 .= trim;

    my Str $str3 = Q:to/EOF/;
    """\
           The quick brown \
           fox jumps over \
           the lazy dog.\
           """
    EOF
    $str3 .= trim;

    my Config::TOML::Parser::Actions $actions .= new;
    my $match-str1 = Config::TOML::Parser::Grammar.parse(
        $str1,
        :$actions,
        :rule<string>
    );
    my $match-str2 = Config::TOML::Parser::Grammar.parse(
        $str2,
        :$actions,
        :rule<string>
    );
    my $match-str3 = Config::TOML::Parser::Grammar.parse(
        $str3,
        :$actions,
        :rule<string>
    );

    is(
        $match-str1.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($str1, :rule<string>)] - 1 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal basic string successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-str2.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($str2, :rule<string>)] - 2 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal basic multiline string
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-str3.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($str3, :rule<string>)] - 3 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal basic multiline string
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-str1.made ~~ $match-str2.made,
        True,
        q:to/EOF/
        ♪ [Byte-for-byte string equivalency] - 4 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-str1.made ~~ $match-str2.made
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-str1.made ~~ $match-str3.made,
        True,
        q:to/EOF/
        ♪ [Byte-for-byte string equivalency] - 5 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-str1.made ~~ $match-str3.made
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-str2.made ~~ $match-str3.made,
        True,
        q:to/EOF/
        ♪ [Byte-for-byte string equivalency] - 6 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-str2.made ~~ $match-str3.made
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# --- end basic string equivalency tests }}}
# --- literal string equivalency tests {{{

subtest
{
    my Str $str4 = Q:to/EOF/;
    '''
    The first newline is
    trimmed in raw strings.
       All other whitespace
       is preserved.
    '''
    EOF
    $str4 .= trim;

    my Str $str5 = Q:to/EOF/;
    '''The first newline is
    trimmed in raw strings.
       All other whitespace
       is preserved.
    '''
    EOF
    $str5 .= trim;

    my Config::TOML::Parser::Actions $actions .= new;
    my $match-str4 = Config::TOML::Parser::Grammar.parse(
        $str4,
        :$actions,
        :rule<string>
    );
    my $match-str5 = Config::TOML::Parser::Grammar.parse(
        $str5,
        :$actions,
        :rule<string>
    );

    is(
        $match-str4.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($str4, :rule<string>)] - 7 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal literal string
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-str5.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($str5, :rule<string>)] - 8 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal literal multiline string
        ┃   Success   ┃    successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-str4.made ~~ $match-str5.made,
        True,
        q:to/EOF/
        ♪ [Byte-for-byte string equivalency] - 9 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-str4.made ~~ $match-str5.made
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# --- end literal string equivalency tests }}}
# --- base64 tests {{{

subtest
{
    # t/data/openssl.pem
    my Str $openssl-pem-perl = slurp 't/data/openssl.pem';
    $openssl-pem-perl .= trim;
    my Str $openssl-pem-toml = Q:to/EOF/;
    '''
    -----BEGIN RSA PRIVATE KEY-----
    MIIEpQIBAAKCAQEA58VK2N1YSSMWtAVSHQJRYrITij3LVbsZkcavx0ljZe8N0QeA
    I13mTeq+WC1+5Nhcxd2AG1dFXaDJ7HhvMd9HWj04IoOmWcnaTN3OWwu03blp11+R
    cHDqvOmq/2O5JEe3/XGLHnqkYw48X1+3VB7cEoxVgHVOT0yn92s4YTkM7feaqJjZ
    5osAI+wHgWK6RY4FQVZZ9BTe1aKd3Gf+mpsXvKgqI3w2wucqgS6/jpONxLL7N+/t
    BAHUbirC0HBqvDtIgev3Ali9I+JK/XO0uaUdXLxpfxlPs3biBFcgrvIMShttcGSq
    aAcPsGuv23zgBvDd5avGeV/5yYdvj1iFZuq/HwIDAQABAoIBAQCcTVQlnlhcslos
    O25d++Mw4REGaJgJD+21fr2qcxaidq3lqt5Ce5/GKioFw2DRKgyer7smNRulgbrL
    S4kJpB81fxWtSQVVhig/MFJq2iE2akUzptKpdq0Hi7nzE6iXC/rL49fDTUgxOTeD
    xkQXadxWcedzgyi1l+eqltdl0ZijndAz6dNb0aoFXww2Qks0V/PR7Q7/o72wVWwN
    l9yxK7ax8qd0xtu5MNAASGqe7UY+RJHSLs4rvhqaNqtDNb7Ejn8JOmNgUS48cWuj
    +oNmkUul2EkkJcbIVJd4r26zobGvlSw0Mh3YnlCvWkV+0rgDYaQRpJ7IPs4boOPW
    a8eeu7ORAoGBAPq9SP2+viSsdX1nhi5yjJnAwgsyLq5x5KnqRGdy4rqM57pXeZ4+
    5oXoz/7v8p1xAHTrMw/UT1HMfGt7KwLV5qaX9Ryv3HwoH9gHJbhLNPNqcjq6qhDa
    1UegYIrXcKwsVCbLwIbq5OnVnoV6By4PChEDP0JH8rz0SSBYOlL5uwJXAoGBAOyi
    IHFsfAzxnwSiXss1/oFnSQgyr/XIgNkmnIrjEW6j+higesU7RCIT8gDmaCURaXXu
    qwKfzf+QDza3t1PzEPPRYqMkI2u0FR2VAuedFD7Tob0HObbEr7bSsbaXP+pYwv8o
    qvYu8WGUmvz5hze6ab46er1biG+ccdKvms+o7/x5AoGBAJhMZsxxkk72TbrpKbCG
    tW4ijfp89avR1CF9ASWQu7SyJ4Kg5WdAL4dA3S2tk0EcRTm/Ltm7jJ5TxXMHch2b
    zSh9fk15aEQlnwn5dWjWjYgYrN+NSAVK1mdWO625pF9/4XFbK0sH3BlIPqw2bawF
    SIkC3uakiwVIoC48SNjjhTqrAoGAX9PYJ5azNdqzdwD6OnkHNAhLvxInx/UGmOnW
    AzipWpD1OvviO/UgRlylaE/mZPyEJMoeXtWwaopAXvxPNaP9fX+R3ldIMNmgo3Yw
    0vL9u+OgYBiI+sb0EamJZlQiAhkn/oTNlxyzi7zOdxvl8l9/axXrlrt2qRxFy/hp
    TScw6KECgYEArnBka86pT7O7IPNid+XYfPhY7DQY11+80Qf06lZtGS7gxptno0B1
    nn5dnEBQFyGbAFivXdEwBZqKzwFeRj94++dPtEeytxPoMHn/FCfrtpcU5K+D8xuU
    8kC2NCdXD7B2vJSC8KYh1QLDCB99wQOprti9JsgGWAQB369zNZmXxkk=
    -----END RSA PRIVATE KEY-----'''
    EOF
    $openssl-pem-toml .= trim;

    # t/data/ssh-ed25519
    my Str $ssh-ed25519-perl = slurp 't/data/ssh-ed25519';
    $ssh-ed25519-perl .= trim;
    my Str $ssh-ed25519-toml = Q:to/EOF/;
    '''
    -----BEGIN OPENSSH PRIVATE KEY-----
    b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
    QyNTUxOQAAACDGRb34PwO5METgCnk5YZJMIWICmiajU50EYFfiItMT2gAAAJBJr2mhSa9p
    oQAAAAtzc2gtZWQyNTUxOQAAACDGRb34PwO5METgCnk5YZJMIWICmiajU50EYFfiItMT2g
    AAAEAU/lzbG5m1GrVut3mGx3/NbU7KnJWvB/1eKSXyg7jCh8ZFvfg/A7kwROAKeTlhkkwh
    YgKaJqNTnQRgV+Ii0xPaAAAACmhlbGxvQHRvbWwBAgM=
    -----END OPENSSH PRIVATE KEY-----'''
    EOF
    $ssh-ed25519-toml .= trim;

    # t/data/ssh-ed25519.pub
    my Str $ssh-ed25519-pub-perl = slurp 't/data/ssh-ed25519.pub';
    $ssh-ed25519-pub-perl .= trim;
    my Str $ssh-ed25519-pub-toml = Q:to/EOF/;
    '''
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZFvfg/A7kwROAKeTlhkkwhYgKaJqNTnQRgV+Ii0xPa hello@toml'''
    EOF
    $ssh-ed25519-pub-toml .= trim;

    my Config::TOML::Parser::Actions $actions .= new;
    my $match-openssl-pem-toml = Config::TOML::Parser::Grammar.parse(
        $openssl-pem-toml,
        :$actions,
        :rule<string>
    );
    my $match-ssh-ed25519-toml = Config::TOML::Parser::Grammar.parse(
        $ssh-ed25519-toml,
        :$actions,
        :rule<string>
    );
    my $match-ssh-ed25519-pub-toml = Config::TOML::Parser::Grammar.parse(
        $ssh-ed25519-pub-toml,
        :$actions,
        :rule<string>
    );

    is(
        $match-openssl-pem-toml.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($openssl-pem-toml, :rule<string>)] - 10 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal literal multiline string
        ┃   Success   ┃    (openssl.pem) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-ssh-ed25519-toml.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($ssh-ed25519-toml, :rule<string>)] - 11 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal literal multiline string
        ┃   Success   ┃    (ssh-ed25519) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-ssh-ed25519-pub-toml.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($ssh-ed25519-pub-toml, :rule<string>)] - 12 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal literal multiline string
        ┃   Success   ┃    (ssh-ed25519.pub) successfully
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $openssl-pem-perl ~~ $match-openssl-pem-toml.made,
        True,
        q:to/EOF/
        ♪ [Byte-for-byte string equivalency] - 13 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $openssl-pem-perl ~~ $match-openssl-pem-toml.made
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $ssh-ed25519-perl ~~ $match-ssh-ed25519-toml.made,
        True,
        q:to/EOF/
        ♪ [Byte-for-byte string equivalency] - 14 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $ssh-ed25519-perl ~~ $match-ssh-ed25519-toml.made
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $ssh-ed25519-pub-perl ~~ $match-ssh-ed25519-pub-toml.made,
        True,
        q:to/EOF/
        ♪ [Byte-for-byte string equivalency] - 15 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $ssh-ed25519-pub-perl ~~
        ┃   Success   ┃        $match-ssh-ed25519-pub-toml.made
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# --- end base64 tests }}}
# end string grammar-actions tests }}}
# number grammar-actions tests {{{
# --- integer tests {{{

subtest
{
    # Integers are whole numbers. Positive numbers may be prefixed with
    # a plus sign. Negative numbers are prefixed with a minus sign.
    my Str $int1 = Q{+99};
    my Str $int2 = Q{42};
    my Str $int3 = Q{0};
    my Str $int4 = Q{-17};
    my Str $int5 = Q{1_000};

    # For large numbers, you may use underscores to enhance
    # readability. Each underscore must be surrounded by at least one digit.
    my Str $int6 = Q{5_349_221};
    my Str $int7 = Q{1_2_3_4_5};

    # 64 bit (signed long) range expected (−9,223,372,036,854,775,808
    # to 9,223,372,036,854,775,807).
    my Str $int8 = Q{-9223372036854775808};
    my Str $int9 = Q{9223372036854775807};

    my Config::TOML::Parser::Actions $actions .= new;
    my $match-int1 = Config::TOML::Parser::Grammar.parse(
        $int1,
        :$actions,
        :rule<number>
    );
    my $match-int2 = Config::TOML::Parser::Grammar.parse(
        $int2,
        :$actions,
        :rule<number>
    );
    my $match-int3 = Config::TOML::Parser::Grammar.parse(
        $int3,
        :$actions,
        :rule<number>
    );
    my $match-int4 = Config::TOML::Parser::Grammar.parse(
        $int4,
        :$actions,
        :rule<number>
    );
    my $match-int5 = Config::TOML::Parser::Grammar.parse(
        $int5,
        :$actions,
        :rule<number>
    );
    my $match-int6 = Config::TOML::Parser::Grammar.parse(
        $int6,
        :$actions,
        :rule<number>
    );
    my $match-int7 = Config::TOML::Parser::Grammar.parse(
        $int7,
        :$actions,
        :rule<number>
    );
    my $match-int8 = Config::TOML::Parser::Grammar.parse(
        $int8,
        :$actions,
        :rule<number>
    );
    my $match-int9 = Config::TOML::Parser::Grammar.parse(
        $int9,
        :$actions,
        :rule<number>
    );

    is(
        $match-int1.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($int1, :rule<number>)] - 16 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal integer successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-int2.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($int2, :rule<number>)] - 17 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal integer successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-int3.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($int3, :rule<number>)] - 18 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal integer successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-int4.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($int4, :rule<number>)] - 19 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal integer successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-int5.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($int5, :rule<number>)] - 20 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal integer successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-int6.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($int6, :rule<number>)] - 21 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal integer successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-int7.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($int7, :rule<number>)] - 22 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal integer successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-int8.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($int8, :rule<number>)] - 23 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal integer successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-int9.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($int9, :rule<number>)] - 24 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal integer successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-int1.made.WHAT,
        Int,
        q:to/EOF/
        ♪ [Is integer?] - 25 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-int1.made.WHAT ~~ Int
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-int2.made.WHAT,
        Int,
        q:to/EOF/
        ♪ [Is integer?] - 26 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-int2.made.WHAT ~~ Int
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-int3.made.WHAT,
        Int,
        q:to/EOF/
        ♪ [Is integer?] - 27 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-int3.made.WHAT ~~ Int
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-int4.made.WHAT,
        Int,
        q:to/EOF/
        ♪ [Is integer?] - 28 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-int4.made.WHAT ~~ Int
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-int5.made.WHAT,
        Int,
        q:to/EOF/
        ♪ [Is integer?] - 29 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-int5.made.WHAT ~~ Int
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-int6.made.WHAT,
        Int,
        q:to/EOF/
        ♪ [Is integer?] - 30 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-int6.made.WHAT ~~ Int
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-int7.made.WHAT,
        Int,
        q:to/EOF/
        ♪ [Is integer?] - 31 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-int7.made.WHAT ~~ Int
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-int8.made.WHAT,
        Int,
        q:to/EOF/
        ♪ [Is integer?] - 32 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-int8.made.WHAT ~~ Int
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-int9.made.WHAT,
        Int,
        q:to/EOF/
        ♪ [Is integer?] - 33 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-int9.made.WHAT ~~ Int
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-int1.made,
        99,
        q:to/EOF/
        ♪ [Is expected integer value?] - 34 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-int1.made == 99
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-int2.made,
        42,
        q:to/EOF/
        ♪ [Is expected integer value?] - 35 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-int2.made == 42
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-int3.made,
        0,
        q:to/EOF/
        ♪ [Is expected integer value?] - 36 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-int3.made == 0
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-int4.made,
        -17,
        q:to/EOF/
        ♪ [Is expected integer value?] - 37 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-int4.made == -17
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-int5.made,
        1000,
        q:to/EOF/
        ♪ [Is expected integer value?] - 38 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-int5.made == 1000
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-int6.made,
        5349221,
        q:to/EOF/
        ♪ [Is expected integer value?] - 39 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-int6.made == 5349221
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-int7.made,
        12345,
        q:to/EOF/
        ♪ [Is expected integer value?] - 40 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-int7.made == 12345
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-int8.made,
        -9223372036854775808,
        q:to/EOF/
        ♪ [Is expected integer value?] - 41 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-int8.made == -9223372036854775808
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-int9.made,
        9223372036854775807,
        q:to/EOF/
        ♪ [Is expected integer value?] - 42 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-int9.made == 9223372036854775807
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# --- end integer tests }}}
# --- float tests {{{

subtest
{
    # A float consists of an integer part (which may be prefixed with a
    # plus or minus sign) followed by a fractional part and/or an exponent
    # part. If both a fractional part and exponent part are present,
    # the fractional part must precede the exponent part.

    # fractional
    my Str $float1 = Q{+1.0};
    my Str $float2 = Q{3.1415};
    my Str $float3 = Q{-0.01};

    # exponent
    my Str $float4 = Q{5e+22};
    my Str $float5 = Q{1e6};
    my Str $float6 = Q{-2E-2};

    # both
    my Str $float7 = Q{6.626e-34};

    # A fractional part is a decimal point followed by one or more digits.

    # An exponent part is an E (upper or lower case) followed by an
    # integer part (which may be prefixed with a plus or minus sign).

    # Similar to integers, you may use underscores to enhance
    # readability. Each underscore must be surrounded by at least
    # one digit.
    my Str $float8 = Q{9_224_617.445_991_228_313};
    my Str $float9 = Q{1e1_000};

    my Config::TOML::Parser::Actions $actions .= new;
    my $match-float1 = Config::TOML::Parser::Grammar.parse(
        $float1,
        :$actions,
        :rule<number>
    );
    my $match-float2 = Config::TOML::Parser::Grammar.parse(
        $float2,
        :$actions,
        :rule<number>
    );
    my $match-float3 = Config::TOML::Parser::Grammar.parse(
        $float3,
        :$actions,
        :rule<number>
    );
    my $match-float4 = Config::TOML::Parser::Grammar.parse(
        $float4,
        :$actions,
        :rule<number>
    );
    my $match-float5 = Config::TOML::Parser::Grammar.parse(
        $float5,
        :$actions,
        :rule<number>
    );
    my $match-float6 = Config::TOML::Parser::Grammar.parse(
        $float6,
        :$actions,
        :rule<number>
    );
    my $match-float7 = Config::TOML::Parser::Grammar.parse(
        $float7,
        :$actions,
        :rule<number>
    );
    my $match-float8 = Config::TOML::Parser::Grammar.parse(
        $float8,
        :$actions,
        :rule<number>
    );
    my $match-float9 = Config::TOML::Parser::Grammar.parse(
        $float9,
        :$actions,
        :rule<number>
    );

    is(
        $match-float1.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($float1, :rule<number>)] - 43 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal float successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-float2.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($float2, :rule<number>)] - 44 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal float successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-float3.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($float3, :rule<number>)] - 45 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal float successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-float4.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($float4, :rule<number>)] - 46 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal float successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-float5.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($float5, :rule<number>)] - 47 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal float successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-float6.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($float6, :rule<number>)] - 48 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal float successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-float7.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($float7, :rule<number>)] - 49 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal float successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-float8.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($float8, :rule<number>)] - 50 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal float successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-float9.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($float9, :rule<number>)] - 51 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal float successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-float1.made.WHAT,
        Rat,
        q:to/EOF/
        ♪ [Is float?] - 52 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-float1.made.WHAT ~~ Rat
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-float2.made.WHAT,
        Rat,
        q:to/EOF/
        ♪ [Is float?] - 53 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-float2.made.WHAT ~~ Rat
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-float3.made.WHAT,
        Rat,
        q:to/EOF/
        ♪ [Is float?] - 54 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-float3.made.WHAT ~~ Rat
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-float4.made.WHAT,
        Num,
        q:to/EOF/
        ♪ [Is float?] - 55 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-float4.made.WHAT ~~ Num
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-float5.made.WHAT,
        Num,
        q:to/EOF/
        ♪ [Is float?] - 56 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-float5.made.WHAT ~~ Num
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-float6.made.WHAT,
        Num,
        q:to/EOF/
        ♪ [Is float?] - 57 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-float6.made.WHAT ~~ Num
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-float7.made.WHAT,
        Num,
        q:to/EOF/
        ♪ [Is float?] - 58 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-float7.made.WHAT ~~ Num
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-float8.made.WHAT,
        Rat,
        q:to/EOF/
        ♪ [Is float?] - 59 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-float8.made.WHAT ~~ Rat
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-float9.made.WHAT,
        Num,
        q:to/EOF/
        ♪ [Is float?] - 60 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-float9.made.WHAT ~~ Num
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-float1.made,
        1.0,
        q:to/EOF/
        ♪ [Is expected float value?] - 61 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-float1.made == 1.0
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-float2.made,
        3.1415,
        q:to/EOF/
        ♪ [Is expected float value?] - 62 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-float2.made == 3.1415
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-float3.made,
        -0.01,
        q:to/EOF/
        ♪ [Is expected float value?] - 63 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-float3.made == -0.01
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-float4.made,
        5e22,
        q:to/EOF/
        ♪ [Is expected float value?] - 64 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-float4.made == 5e22
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-float5.made,
        1e6,
        q:to/EOF/
        ♪ [Is expected float value?] - 65 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-float5.made == 1e6
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-float6.made,
        -2e-2,
        q:to/EOF/
        ♪ [Is expected float value?] - 66 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-float6.made == -2E-2
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-float7.made,
        6.626e-34,
        q:to/EOF/
        ♪ [Is expected float value?] - 67 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-float7.made == 6.626e-34
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-float8.made,
        9224617.445991228313,
        q:to/EOF/
        ♪ [Is expected float value?] - 68 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-float8.made == 9224617.445991228313
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-float9.made,
        1e1000,
        q:to/EOF/
        ♪ [Is expected float value?] - 69 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-float9.made == 1e1000
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# --- end float tests }}}
# end number grammar-actions tests }}}
# boolean grammar-actions tests {{{

subtest
{
    # Booleans are just the tokens you're used to. Always lowercase.
    my Str $bool1 = Q{true};
    my Str $bool2 = Q{false};

    my Config::TOML::Parser::Actions $actions .= new;
    my $match-bool1 = Config::TOML::Parser::Grammar.parse(
        $bool1,
        :$actions,
        :rule<boolean>
    );
    my $match-bool2 = Config::TOML::Parser::Grammar.parse(
        $bool2,
        :$actions,
        :rule<boolean>
    );

    is(
        $match-bool1.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($bool1, :rule<boolean>)] - 70 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal boolean successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-bool2.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($bool2, :rule<boolean>)] - 71 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal boolean successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-bool1.made.WHAT,
        Bool,
        q:to/EOF/
        ♪ [Is boolean?] - 72 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-bool1.made.WHAT ~~ Bool
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-bool2.made.WHAT,
        Bool,
        q:to/EOF/
        ♪ [Is boolean?] - 73 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-bool2.made.WHAT ~~ Bool
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-bool1.made,
        True,
        q:to/EOF/
        ♪ [Is expected boolean value?] - 74 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-bool1.made ~~ True
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-bool2.made,
        False,
        q:to/EOF/
        ♪ [Is expected boolean value?] - 75 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-bool2.made ~~ False
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# end boolean grammar-actions tests }}}
# datetime grammar-actions tests {{{

subtest
{
    # Datetimes are RFC 3339 dates.
    my Str $date-time1 = Q{1979-05-27T07:32:00Z};
    my Str $date-time2 = Q{1979-05-27T00:32:00-07:00};
    my Str $date-time3 = Q{1979-05-27T00:32:00.999999-07:00};
    my Str $date-time4 = Q{1979-05-27T07:32:00};
    my Str $date-time5 = Q{1979-05-27T00:32:00.999999};
    my Str $date-time6 = Q{1979-05-27};

    # assume UTC when local offset unspecified in TOML dates
    my Config::TOML::Parser::Actions $actions .= new(:date-local-offset(0));
    my $match-date-time1 = Config::TOML::Parser::Grammar.parse(
        $date-time1,
        :$actions,
        :rule<date>
    );
    my $match-date-time2 = Config::TOML::Parser::Grammar.parse(
        $date-time2,
        :$actions,
        :rule<date>
    );
    my $match-date-time3 = Config::TOML::Parser::Grammar.parse(
        $date-time3,
        :$actions,
        :rule<date>
    );
    my $match-date-time4 = Config::TOML::Parser::Grammar.parse(
        $date-time4,
        :$actions,
        :rule<date>
    );
    my $match-date-time5 = Config::TOML::Parser::Grammar.parse(
        $date-time5,
        :$actions,
        :rule<date>
    );
    my $match-date-time6 = Config::TOML::Parser::Grammar.parse(
        $date-time6,
        :$actions,
        :rule<date>
    );

    is(
        $match-date-time1.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($date-time1, :rule<date>)] - 76 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal datetime successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-date-time2.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($date-time2, :rule<date>)] - 77 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal datetime successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-date-time3.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($date-time3, :rule<date>)] - 78 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal datetime successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-date-time4.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($date-time4, :rule<date>)] - 79 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal datetime successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-date-time5.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($date-time5, :rule<date>)] - 80 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal datetime successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-date-time6.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($date-time6, :rule<date>)] - 81 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses string literal datetime successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-date-time1.made.WHAT,
        DateTime,
        q:to/EOF/
        ♪ [Is datetime?] - 82 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-date-time1.made.WHAT ~~ DateTime
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-date-time2.made.WHAT,
        DateTime,
        q:to/EOF/
        ♪ [Is datetime?] - 83 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-date-time2.made.WHAT ~~ DateTime
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-date-time3.made.WHAT,
        DateTime,
        q:to/EOF/
        ♪ [Is datetime?] - 84 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-date-time3.made.WHAT ~~ DateTime
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-date-time4.made.WHAT,
        DateTime,
        q:to/EOF/
        ♪ [Is datetime?] - 85 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-date-time4.made.WHAT ~~ DateTime
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-date-time5.made.WHAT,
        DateTime,
        q:to/EOF/
        ♪ [Is datetime?] - 86 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-date-time5.made.WHAT ~~ DateTime
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-date-time6.made.WHAT,
        DateTime,
        q:to/EOF/
        ♪ [Is datetime?] - 87 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-date-time6.made.WHAT ~~ DateTime
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-date-time1.made,
        '1979-05-27T07:32:00Z',
        q:to/EOF/
        ♪ [Is expected datetime value?] - 88 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-date-time1.made
        ┃   Success   ┃        ~~ '1979-05-27T07:32:00Z'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-date-time2.made,
        '1979-05-27T00:32:00-07:00',
        q:to/EOF/
        ♪ [Is expected datetime value?] - 89 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-date-time2.made
        ┃   Success   ┃        ~~ '1979-05-27T00:32:00-07:00'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-date-time3.made,
        '1979-05-27T00:32:00.999999-07:00',
        q:to/EOF/
        ♪ [Is expected datetime value?] - 90 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-date-time3.made
        ┃   Success   ┃        ~~ '1979-05-27T00:32:00.999999-07:00'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-date-time4.made,
        '1979-05-27T07:32:00Z',
        q:to/EOF/
        ♪ [Is expected datetime value?] - 91 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-date-time4.made
        ┃   Success   ┃        ~~ '1979-05-27T07:32:00Z'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-date-time5.made,
        '1979-05-27T00:32:00.999999Z',
        q:to/EOF/
        ♪ [Is expected datetime value?] - 92 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-date-time5.made
        ┃   Success   ┃        ~~ '1979-05-27T00:32:00.999999Z'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-date-time6.made,
        '1979-05-27T00:00:00Z',
        q:to/EOF/
        ♪ [Is expected datetime value?] - 93 of 93
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-date-time6.made
        ┃   Success   ┃        ~~ '1979-05-27T00:00:00Z'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# end datetime grammar-actions tests }}}

# vim: ft=perl6 fdm=marker fdl=0
