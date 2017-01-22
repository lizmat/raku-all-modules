use v6.c;

unit package BSON:auth<https://github.com/MARTIMM>;

#`{{
#-----------------------------------------------------------------------------
class X::Parse-regex is Exception {
  has $.operation;                      # Operation method
  has $.error;                          # Parse error

  method message () {
    return "\n$!operation\() error: $!error\n";
  }
}
}}

#-----------------------------------------------------------------------------
class Regex {

  has Str $.regex;
  has Str $.options;

  #---------------------------------------------------------------------------
  submethod BUILD ( Str:D :$regex, Str :$options = '' ) {

    # Store the attribute values.
    # MongoDB uses Perl 5! compatible regular expressions.
    # See also: http://docs.mongodb.org/manual/reference/operator/query/regex/
    #
#`{{
Wait until bug is fixed in perl6: Cannot use match here. Error is caused by
reference of match to this class instead of the proper one.

    die X::Parse-regex.new(
      :operation('Regex.new'),
      :error("Options may only be one of 'imxlsu'")
    ) unless $options ~~ m/ ^ <[imxlsu]>* $ /;
}}
    $!regex = $regex;
    $!options = $options;
  }

  #---------------------------------------------------------------------------
  method perl ( Int $indent = 0 --> Str ) {
    $indent = 0 if $indent < 0;

    my Str $perl = "BSON::Regex.new(\n";
    my $rex-i1 = '  ' x ($indent + 1);
    $perl ~= "$rex-i1\:regex\('$!regex'),\n";
    $perl ~= "$rex-i1\:options\('$!options'))\n" if ? $!options;
    $perl ~= '  ' x $indent ~ ")";
  }
}




=finish
  #---------------------------------------------------------------------------
  method encode ( ) {
    encode-cstring($!regex) ~ encode-cstring($!options);
  }

  #---------------------------------------------------------------------------
#TODO Remove duplicate sub into other module
  sub encode-cstring ( Str:D $s --> Buf ) {
    die X::Parse-document.new(
      :operation('encode-cstring()'),
      :error('Forbidden 0x00 sequence in $s')
    ) if $s ~~ /\x00/;

    return $s.encode() ~ Buf.new(0x00);
  }

  #---------------------------------------------------------------------------
  method decode (
    Buf:D $b,
    Int:D $index1 is copy,
    Int:D $index2 is copy,
    --> BSON::Regex
  ) {
    BSON::Regex.new(
      :regex(decode-cstring( $b, $index1)),
      :options(decode-cstring( $b, $index2))
    );
  }

  #-----------------------------------------------------------------------------
#TODO Remove duplicate sub into other module
  sub decode-cstring ( Buf:D $b, Int:D $index is rw --> Str ) {

    my @a;
    my $l = $b.elems;

    while $b[$index] !~~ 0x00 and $index < $l {
      @a.push($b[$index++]);
    }

    # This takes only place if there are no 0x0 characters found until the
    # end of the buffer which is almost never.
    #
    die X::Parse-document.new(
      :operation<decode-cstring>,
      :error('Missing trailing 0x00')
    ) unless $index < $l and $b[$index++] ~~ 0x00;

    return Buf.new(@a).decode();
  }
