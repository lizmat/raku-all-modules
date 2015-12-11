use v6;

package BSON {

  class Javascript {

    has Str $.javascript;
    has $.scope;

    has Bool $.has-javascript = False;
    has Bool $.has-scope = False;

    #---------------------------------------------------------------------------
    #
    submethod BUILD ( Str :$javascript, :$scope ) {

      # Store the attribute values. ? sets True if defined and filled.
      #
      $!javascript = $javascript;
      $!scope = $scope;

      $!has-javascript = ?$!javascript;
      $!has-scope = ?$!scope if $scope.^name ~~ 'BSON::Document';
    }
  }
}

