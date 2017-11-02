use v6;
use Test;
use BSON;
use BSON::Document;
use BSON::Javascript;

#-------------------------------------------------------------------------------
subtest "Javacsript", {

  my Str $javascript = 'function(x){return x;}';
  my BSON::Javascript $js .= new(:$javascript);

  my BSON::Document $d1 .= new: (:$js,);
  my Buf $b1 = $d1.encode;
  my Buf $b2 =
    [~] Buf.new(0x0D),                              # BSON javascript
       'js'.encode, Buf.new(0x00),                  # 'js'
        encode-int32($javascript.chars + 1),
          $javascript.encode, Buf.new(0x00),        # javascript code
        Buf.new(0x00);                              # end of document
  is-deeply encode-int32($b2.elems + 4) ~ $b2, $b1, # prepend size to b2
            'check encoded javascript';

  my BSON::Document $d2 .= new($b1);
  is-deeply $d1, $d2, 'decoded doc is same as original';
}

#-------------------------------------------------------------------------------
subtest "Javacsript with scope", {

  my Str $javascript = 'function(x){return x;}';
  my BSON::Document $scope .= new: (nn => 10, a1 => 2);
  my BSON::Javascript $js-scope .= new( :$javascript, :$scope);

  my BSON::Document $d1 .= new: (:$js-scope,);
  my Buf $b1 = $d1.encode;
  my Buf $b2 =
    [~] Buf.new(0x0F),                              # BSON javascript with scope
       'js-scope'.encode, Buf.new(0x00),            # 'js-scope'
        encode-int32($javascript.chars + 1),
          $javascript.encode, Buf.new(0x00),        # javascript code
          $scope.encode,                            # encoded scope
        Buf.new(0x00);                              # end of document
  is-deeply encode-int32($b2.elems + 4) ~ $b2, $b1, # prepend size to b2
            'check encoded javascript';

  my BSON::Document $d2 .= new($b1);
  is-deeply $d1, $d2, 'decoded doc is same as original';
}

#-------------------------------------------------------------------------------
subtest "Javacsript with scope, twice", {

  my Str $javascript = 'function(x){return x;}';
  my BSON::Document $scope .= new: (nn => 10, a1 => 2);
  my BSON::Javascript $js-scope .= new( :$javascript, :$scope);

  my BSON::Document $d1 .= new: ( :jsc1($js-scope), :jsc2($js-scope.clone));
  my Buf $b1 = $d1.encode;

#`{{
  my Buf $b2 =
    [~] Buf.new(0x0F),                              # BSON javascript with scope
       'js-scope'.encode, Buf.new(0x00),            # 'js-scope'
        encode-int32($javascript.chars + 1),
          $javascript.encode, Buf.new(0x00),        # javascript code
          $scope.encode,                            # encoded scope
        Buf.new(0x00);                              # end of document
  is-deeply encode-int32($b2.elems + 4) ~ $b2, $b1, # prepend size to b2
            'check encoded javascript';
}}
  my BSON::Document $d2 .= new($b1);
  is-deeply $d1, $d2, 'decoded doc is same as original';
}

#-------------------------------------------------------------------------------
# Cleanup
done-testing;
