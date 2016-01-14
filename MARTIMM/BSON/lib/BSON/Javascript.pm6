use v6;

package BSON {

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
  }
}


