use v6;

class BSON::Javascript {

  has Str $.javascript;
  has Hash $.scope;
  
  submethod BUILD ( Str :$javascript, Hash :$scope) {
  
      # Store the attribute values.
      #
      $!javascript = $javascript // '';
      $!scope = $scope;
  }
}
