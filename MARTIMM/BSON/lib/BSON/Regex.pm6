use v6;

package BSON {

  #-----------------------------------------------------------------------------
  class X::Parse is Exception {
    has $.operation;                      # Operation method
    has $.error;                          # Parse error

    method message () {
      return "\n$!operation\() error: $!error\n";
    }
  }

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

      die X::Parse.new(
        :operation('Regex.new'),
        :error("Options may only be one of 'imxlsu'")
      ) unless $options ~~ m/ ^ <[imxlsu]>* $ /;
}}
      $!regex = $regex;
      $!options = $options;
    }
  }
}
