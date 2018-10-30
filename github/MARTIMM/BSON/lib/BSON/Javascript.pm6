use v6.c;

#------------------------------------------------------------------------------
unit package BSON:auth<github:MARTIMM>;

use BSON;

#------------------------------------------------------------------------------
class Javascript {

  has Str $.javascript;
  has $.scope;
  has Buf $!encoded-scope;

  has Bool $.has-javascript = False;
  has Bool $.has-scope = False;

  #---------------------------------------------------------------------------
  submethod BUILD (
    Str :$!javascript,
    :$!scope where (.^name eq 'BSON::Document' or $_ ~~ Any)
  ) {

    $!has-javascript = ?$!javascript;
    $!has-scope = ?$!scope;
    $!encoded-scope = $!scope.encode if $!has-scope;
  }

  #---------------------------------------------------------------------------
  method perl ( Int $indent = 0 --> Str ) {
    $indent = 0 if $indent < 0;

    my Str $perl = "BSON::Javascript.new\(";
    my $jvs-i1 = '  ' x ($indent + 1);
    my $jvs-i2 = '  ' x ($indent + 2);
    if $!javascript {
      $perl ~= "\n$jvs-i1\:javascript\(\n";
      $perl ~= (map {$jvs-i2 ~ $_}, $!javascript.lines).join("\n");
      $perl ~= "\n$jvs-i1)";

      if $!scope {
        $perl ~= ",\n";
      }

      else {
        $perl ~= "\n";
      }
    }

    if $!scope {
      $perl ~= $jvs-i1 ~ ":scope\(\n{$!scope.perl($indent+2)}";
      $perl ~= $jvs-i1 ~ ")\n";
    }

    $perl ~= '  ' x $indent ~ ")";
  }

  #---------------------------------------------------------------------------
  method encode ( --> Buf ) {

    my Buf $js;
    if $!has-javascript {
      $js = encode-string($!javascript);
      $js ~= $!encoded-scope if $!has-scope;
    }

    else {
      die X::BSON.new(
        :operation<encode>, :type<Javscript>,
        :error('cannot process empty javascript code')
      );
    }

    $js
  }

  #---------------------------------------------------------------------------
  method decode (
    Buf:D $b, Int:D $index is copy, :$bson-doc, Buf :$scope
    --> BSON::Javascript
  ) {

    my $js;
    if ?$scope and ?$bson-doc {

      $bson-doc.decode($scope);
      $js = BSON::Javascript.new(
        :javascript( decode-string( $b, $index)), :scope($bson-doc)
      );
    }

    else {

      $js = BSON::Javascript.new( :javascript( decode-string( $b, $index)));
    }
  }
}
