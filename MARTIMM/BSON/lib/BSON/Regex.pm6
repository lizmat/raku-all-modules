use v6;

package BSON {
  class Regex {

    has Str $.regex;
    has Str $.options;

    submethod BUILD ( :$regex, :$options) {

      # Store the attribute values. Sort the options first.
      # MongoDB uses Perl 5! compatible regular expressions.
      # See also: http://docs.mongodb.org/manual/reference/operator/query/regex/
      #
      $!regex = $regex // '';
      $!options = ($options // '').split('').sort.join;
    }
  }
}
