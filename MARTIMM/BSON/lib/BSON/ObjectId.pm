use v6;

package BSON {

  class ObjectId {

    # Represents ObjectId BSON type described in
    # http://dochub.mongodb.org/core/objectids
    #
    has Buf $.oid;


    multi method new( Buf $b ) {
      die 'ObjectId must be exactly 12 bytes' unless $b.elems ~~ 12;
      self.bless( *, oid => $b);
    }

    multi method new( Str $s ) {
      my @a = map { :16( $_ ) }, $s.comb(/../);
      my Buf $b = Buf.new(@a);
      die 'ObjectId must be exactly 12 bytes' unless $b.elems ~~ 12;
      self.bless( *, oid => $b);
    }

    method Buf ( ) {
      return $.oid;
    }

    method perl ( ) {
      my $s = '';
      for $.oid.list {
        $s ~= ( $_ +> 4 ).fmt('%x') ~ ( $_ % 16 ).fmt('%x');
      }

      return 'ObjectId( "' ~ $s ~ '" )';
    }
  }
}
