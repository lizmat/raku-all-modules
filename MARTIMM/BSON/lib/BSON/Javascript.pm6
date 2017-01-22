use v6.c;
use BSON;

unit package BSON:auth<https://github.com/MARTIMM>;

class Javascript {

  has Str $.javascript;
  has $.scope;

  has Bool $.has-javascript = False;
  has Bool $.has-scope = False;

  #---------------------------------------------------------------------------
  submethod BUILD ( Str :$javascript, :$scope ) {

    # Store the attribute values. ? sets True if defined and filled.
    #
    $!javascript = $javascript;
    $!scope = $scope;

    $!has-javascript = ?$!javascript;
    $!has-scope = ?$!scope if $scope.^name ~~ 'BSON::Document';
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

    my Buf $b;

    if $!has-javascript {
      my Buf $js = encode-string($!javascript);

      if $!has-scope {
        my Buf $scope = $!scope.encode;
        $b = [~] $js, $scope;
      }

      else {
        $b = $js;
      }
    }

    else {
      die X::BSON::Parse-document.new(
        :operation('encode Javscript'),
        :error('cannot process empty javascript code')
      );
    }

    $b;
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


