use Test;
use BSON::Document;

#-------------------------------------------------------------------------------
subtest {

  my BSON::Document $d .= new: (
    documents => []
  );

  my Buf $b = $d.encode;
  say $b;

}, 'empty array';


#-------------------------------------------------------------------------------
done-testing;
