use NativeCall;
use Test;

#`(
sub cmark_node_new( int32 )
    returns Pointer
    is export
    is native('cmark') { * }
sub cmark_node_get_type( Pointer )
    returns int32
    is export
    is native('cmark') { * }
sub cmark_node_free( Pointer )
    is export
    is native('cmark') { * }

my $ptr = cmark_node_new( 7 );
is cmark_node_get_type( $ptr ), 7;
cmark_node_free( $ptr );
)

class Node is repr('CPointer') {
sub cmark_node_new( int32 )
    returns Node
    is export
    is native('cmark') { * }
sub cmark_node_get_type( Node )
    returns int32
    is export
    is native('cmark') { * }
sub cmark_node_free( Node )
    is export
    is native('cmark') { * }

	method new( :$type ) {
		cmark_node_new( $type );
	}
	method type {
		return cmark_node_get_type( self );
	}
	submethod DESTROY {
		cmark_node_free( self );
	}
}

my $n = Node.new( :type( 7 ) );
is $n.type, 7;
