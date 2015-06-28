use v6;

package BSON {

  class Javascript {

    has Str $.javascript;
    has Hash $.scope;

    has Bool $.has_javascript = False;
    has Bool $.has_scope = False;


    submethod BUILD ( Str :$javascript, Hash :$scope) {
      # Store the attribute values. ? sets True if defined and filled.
      #
      $!javascript = $javascript;
      $!scope = $scope;

      $!has_javascript = ?$!javascript;
      $!has_scope = ?$!scope;
    }
  }
}

