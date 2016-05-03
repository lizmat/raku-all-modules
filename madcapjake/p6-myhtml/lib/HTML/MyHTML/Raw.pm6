unit module HTML::MyHTML::Raw;

use NativeCall;

use HTML::MyHTML::Status;

=head2 Structs, Enums & Pointers

enum MyHTMLOptions is export (
  PARSE_MODE_DEFAULT      => 0x00,
  PARSE_MODE_SINGLE       => 0x01,
  PARSE_MODE_ALL_IN_ONE   => 0x02,
  PARSE_MODE_SEPARATELY   => 0x04,
  PARSE_MODE_WORKER_TREE  => 0x08,
  PARSE_MODE_WORKER_INDEX => 0x10,
  PARSE_MODE_TREE_INDEX   => 0x20
);

class MCharAsync is repr<CPointer> {}

class MyHTML is repr<CPointer> is export {}

#| A simple helper to build native pointers to files/stdout
class FILE is repr<CPointer> is export {
  sub fdopen(int64, Str) returns FILE is native { * }
  sub fopen(Str, Str) returns FILE is native { * }
  sub setvbuf(FILE, Blob, size_t) returns int64 is native { * }
  method fd(Int $fd) {
    my $fh = fdopen($fd, "w+");
    setvbuf($fh, Blob, 2) if $fd == 1;
    return $fh;
  }
  method path(Str $path) { fopen($path, "w+") }
}

class MyAttribute is repr<CPointer> {}

class Collection is repr<CStruct> is export {
  has CArray[Pointer] $.list;
  has size_t $.size;
  has size_t $.length;
}

class MyString is repr<CStruct> {
  has Str $.data;
  has size_t $.size;
  has size_t $.length;
  has MCharAsync $.mchar;
  has size_t $.node-idx;
}

class TreeNode is repr<CPointer> is export {}

class Tag is repr<CStruct> {}
class TagIndexNode is repr<CStruct> {
  has TagIndexNode $.next;
  has TagIndexNode $.prev;
  has TreeNode     $.node;
}
class TagIndexEntry is repr<CStruct> {
  has TagIndexNode $.first;
  has TagIndexNode $.last;
  has size_t       $.count;
}
class TagIndex is repr<CStruct> {
  has TagIndexEntry $.tags;
  has size_t        $.tags-length;
  has size_t        $.tags-size;
}

class Tree is repr<CPointer> is export {}

=head2 Subroutines

=head3 MyHTML

#| Create a MyHTML structure
#|
#| @return myhtml_t* if successful, otherwise an NULL value.
sub myhtml_create()
    returns MyHTML
    is native('myhtml')
    is export
    { * }

#| Allocating and Initialization resources for a MyHTML structure
#|
#| @param[in] myhtml_t*
#| @param[in] work options, how many threads will be.
#| Default: MyHTML_OPTIONS_PARSE_MODE_SEPARATELY
#|
#| @param[in] thread count, it depends on the choice of work options
#| Default: 1
#|
#| @param[in] queue size for a tokens. Dynamically increasing the
#| specified number here. Default: 4096
#|
#| @return MyHTML_STATUS_OK if successful, otherwise an error status value.
sub myhtml_init(MyHTML, int32, size_t, size_t)
    returns int32
    is native('myhtml')
    is export
    { * }

#| Clears queue and threads resources
#|
#| @param[in] myhtml_t*
sub myhtml_clean(MyHTML) is native('myhtml') is export { * }

#| Destroy of a MyHTML structure
#|
#| @param[in] myhtml_t*
#| @return NULL if successful, otherwise an MyHTML structure.
sub myhtml_destroy(MyHTML) is native('myhtml') is export { * }

#| Parsing HTML
#|
#| @param[in] previously created structure myhtml_tree_t*
#| @param[in] Input character encoding; Default: MyHTML_ENCODING_UTF_8 or MyHTML_ENCODING_DEFAULT or 0
#| @param[in] HTML
#| @param[in] HTML size
#|
#| All input character encoding decode to utf-8
#|
#| @return MyHTML_STATUS_OK if successful, otherwise an error status
sub myhtml_parse(Tree, int32, Blob, size_t)
    returns int32
    is native('myhtml')
    is export
    { * }

#| Parsing fragment of HTML
#|
#| @param[in] previously created structure myhtml_tree_t*
#| @param[in] Input character encoding; Default: MyHTML_ENCODING_UTF_8 or MyHTML_ENCODING_DEFAULT or 0
#| @param[in] HTML
#| @param[in] HTML size
#| @param[in] fragment base (root) tag id. Default: MyHTML_TAG_DIV if set 0
#| @param[in] fragment NAMESPACE. Default: MyHTML_NAMESPACE_HTML if set 0
#|
#| All input character encoding decode to utf-8
#|
#| @return MyHTML_STATUS_OK if successful, otherwise an error status
sub myhtml_parse_fragment(Tree, int32, Blob, size_t, int32, int32)
    returns int32
    is native('myhtml')
    is export
    { * }

#| Parsing HTML in Single Mode.
#| No matter what was said during initialization MyHTML
#|
#| @param[in] previously created structure myhtml_tree_t*
#| @param[in] Input character encoding; Default: MyHTML_ENCODING_UTF_8 or MyHTML_ENCODING_DEFAULT or 0
#| @param[in] HTML
#| @param[in] HTML size
#|
#| All input character encoding decode to utf-8
#|
#| @return MyHTML_STATUS_OK if successful, otherwise an error status
sub myhtml_parse_single(Tree, int32, Blob, size_t)
    returns int32
    is native('myhtml')
    is export
    { * }

#| Parsing fragment of HTML in Single Mode.
#| No matter what was said during initialization MyHTML
#|
#| @param[in] previously created structure myhtml_tree_t*
#| @param[in] Input character encoding; Default: MyHTML_ENCODING_UTF_8 or MyHTML_ENCODING_DEFAULT or 0
#| @param[in] HTML
#| @param[in] HTML size
#| @param[in] fragment base (root) tag id. Default: MyHTML_TAG_DIV if set 0
#| @param[in] fragment NAMESPACE. Default: MyHTML_NAMESPACE_HTML if set 0
#|
#| All input character encoding decode to utf-8
#|
#| @return MyHTML_STATUS_OK if successful, otherwise an error status
sub myhtml_parse_fragment_single(Tree, int32, Blob, size_t, int32, int32)
    returns int32
    is native('myhtml')
    is export
    { * }

#| Parsing HTML chunk. For end parsing call myhtml_parse_chunk_end function
#|
#| @param[in] myhtml_tree_t*
#| @param[in] HTML
#| @param[in] HTML size
#|
#| @return MyHTML_STATUS_OK if successful, otherwise an error status
sub myhtml_parse_chunk(Tree, Blob, size_t)
    returns int32
    is native('myhtml')
    is export
    { * }

#| Parsing chunk of fragment HTML. For end parsing call myhtml_parse_chunk_end function
#|
#| @param[in] myhtml_tree_t*
#| @param[in] HTML
#| @param[in] HTML size
#| @param[in] fragment base (root) tag id. Default: MyHTML_TAG_DIV if set 0
#| @param[in] fragment NAMESPACE. Default: MyHTML_NAMESPACE_HTML if set 0
#|
#| @return MyHTML_STATUS_OK if successful, otherwise an error status
sub myhtml_parse_chunk_fragment(Tree, Blob, size_t, int32, int32)
    returns int32
    is native('myhtml')
    is export
    { * }

#| Parsing HTML chunk in Single Mode.
#| No matter what was said during initialization MyHTML
#|
#| @param[in] myhtml_tree_t*
#| @param[in] HTML
#| @param[in] HTML size
#|
#| @return MyHTML_STATUS_OK if successful, otherwise an error status
sub myhtml_parse_chunk_single(Tree, Blob, size_t)
    returns int32
    is native('myhtml')
    is export
    { * }

#| Parsing chunk of fragment of HTML in Single Mode.
#| No matter what was said during initialization MyHTML
#|
#| @param[in] myhtml_tree_t*
#| @param[in] HTML
#| @param[in] HTML size
#| @param[in] fragment base (root) tag id. Default: MyHTML_TAG_DIV if set 0
#| @param[in] fragment NAMESPACE. Default: MyHTML_NAMESPACE_HTML if set 0
#|
#| @return MyHTML_STATUS_OK if successful, otherwise an error status
sub myhtml_parse_chunk_fragment_single(Tree, Blob, size_t, int32, int32)
    returns int32
    is native('myhtml')
    is export
    { * }

#| End of parsing HTML chunks
#|
#| @param[in] myhtml_tree_t*
#|
#| @return MyHTML_STATUS_OK if successful, otherwise an error status
sub myhtml_parse_chunk_end(Tree) returns int32 is native('myhtml') is export { * }

=head3 Tree

#| Create a MyHTML_TREE structure
#|
#| @return myhtml_tree_t* if successful, otherwise an NULL value.
sub myhtml_tree_create() returns Tree is native('myhtml') is export { * }

#| Allocating and Initialization resources for a MyHTML_TREE structure
#|
#| @param[in] myhtml_tree_t*
#| @param[in] workmyhtml_t*
#|
#| @return MyHTML_STATUS_OK if successful, otherwise an error status
sub myhtml_tree_init(Tree, MyHTML) returns int32 is native('myhtml') is export { * }

#| Clears resources before new parsing
#|
#| @param[in] myhtml_tree_t*
sub myhtml_tree_clean(Tree) is native('myhtml') is export { * }

#| Add child node to node. If children already exists it will be added to the last
#|
#| @param[in] myhtml_tree_t*
#| @param[in] myhtml_tree_node_t* The node to which we add child node
#| @param[in] myhtml_tree_node_t* The node which adds
sub myhtml_tree_node_add_child(Tree, TreeNode, TreeNode) is native('myhtml') is export { * }

#| Add a node immediately before the existing node
#|
#| @param[in] myhtml_tree_t*
#| @param[in] myhtml_tree_node_t* add for this node
#| @param[in] myhtml_tree_node_t* add this node
sub myhtml_tree_node_insert_before(Tree, TreeNode, TreeNode) is native('myhtml') is export { * }

#| Add a node immediately after the existing node
#|
#| @param[in] myhtml_tree_t*
#| @param[in] myhtml_tree_node_t* add for this node
#| @param[in] myhtml_tree_node_t* add this node
sub myhtml_tree_node_insert_after(Tree, TreeNode, TreeNode) is native('myhtml') is export { * }

#| Destroy of a MyHTML_TREE structure
#|
#| @param[in] myhtml_tree_t*
#|
#| @return NULL if successful, otherwise an MyHTML_TREE structure
sub myhtml_tree_destroy(Tree) returns Tree is native('myhtml') is export { * }

#| Get myhtml_t* from a myhtml_tree_t*
#|
#| @param[in] myhtml_tree_t*
#|
#| @return myhtml_t* if exists, otherwise a NULL value
sub myhtml_tree_get_myhtml(Tree) returns MyHTML is native('myhtml') is export { * }

#| Get myhtml_tag_t* from a myhtml_tree_t*
#|
#| @param[in] myhtml_tree_t*
#|
#| @return myhtml_tag_t* if exists, otherwise a NULL value
sub myhtml_tree_get_tag(Tree) returns Tag is native('myhtml') is export { * }

#| Get myhtml_tag_index_t* from a myhtml_tree_t*
#|
#| @param[in] myhtml_tree_t*
#|
#| @return myhtml_tag_index_t* if exists, otherwise a NULL value
sub myhtml_tree_get_tag_index(Tree) returns TagIndex is native('myhtml') is export { * }

#| Get Tree Document (Root of Tree)
#|
#| @param[in] myhtml_tree_t*
#|
#| @return myhtml_tree_node_t* if successful, otherwise a NULL value
sub myhtml_tree_get_document(Tree) returns TreeNode is native('myhtml') is export { * }

#| Get node HTML (Document -> HTML, Root of HTML Document)
#|
#| @param[in] myhtml_tree_t*
#|
#| @return myhtml_tree_node_t* if successful, otherwise a NULL value
sub myhtml_tree_get_node_html(Tree) returns TreeNode is native('myhtml') is export { * }

#| Get node BODY (Document -> HTML -> BODY)
#|
#| @param[in] myhtml_tree_t*
#|
#| @return myhtml_tree_node_t* if successful, otherwise a NULL value
sub myhtml_tree_get_node_body(Tree) returns TreeNode is native('myhtml') is export { * }

#| Get mchar_async_t object
#|
#| @param[in] myhtml_tree_t*
#|
#| @return mchar_async_t* if exists, otherwise a NULL value
sub myhtml_tree_get_mchar(Tree) returns MCharAsync is native('myhtml') is export { * }

#| Get node_id from main thread for mchar_async_t object
#|
#| @param[in] myhtml_tree_t*
#|
#| @return size_t, node id
sub myhtml_tree_get_mchar_node_id(Tree)
    returns size_t
    is native('myhtml')
    is export
    { * }

#| Print tree of a node. Print including current node
#|
#| @param[in] myhtml_tree_t*
#| @param[in] myhtml_tree_node_t*
#| @param[in] file handle, for example use stdout
#| @param[in] tab (\t) increment for pretty print, set 0
sub myhtml_tree_print_by_node(Tree, TreeNode, FILE, size_t)
    is native('myhtml')
    is export
    { * }

#| Print tree of a node. Print excluding current node
#|
#| @param[in] myhtml_tree_t*
#| @param[in] myhtml_tree_node_t*
#| @param[in] file handle, for example use stdout
#| @param[in] tab (\t) increment for pretty print, set 0
sub myhtml_tree_print_node_childs(Tree, TreeNode, FILE, size_t)
    is native('myhtml')
    is export
    { * }

#| Print a node
#|
#| @param[in] myhtml_tree_t*
#| @param[in] myhtml_tree_node_t*
#| @param[in] file handle, for example use stdout
sub myhtml_tree_print_node(Tree, TreeNode, FILE)
    is native('myhtml')
    is export
    { * }

#| Get first (begin) node of tree
#|
#| @param[in] myhtml_tree_t*
#|
#| @return myhtml_tree_node_t* if successful, otherwise a NULL value
sub myhtml_node_first(Tree)
    returns TreeNode
    is native('myhtml')
    is export
    { * }

#| Get nodes by tag id
#|
#| @param[in] myhtml_tree_t*
#| @param[in] myhtml_collection_t*, creates new collection if NULL
#| @param[in] tag id
#| @param[out] status of this operation
#|
#| @return myhtml_collection_t* if successful, otherwise an NULL value
sub myhtml_get_nodes_by_tag_id(Tree, Collection, int32, int32)
    returns Collection
    is native('myhtml')
    is export
    { * }

#| Get nodes by tag name
#|
#| @param[in] myhtml_tree_t*
#| @param[in] myhtml_collection_t*, creates new collection if NULL
#| @param[in] tag name
#| @param[in] tag name length
#| @param[out] status of this operation
#|
#| @return myhtml_collection_t* if successful, otherwise an NULL value
sub myhtml_get_nodes_by_name(Tree, Collection, Blob, size_t, int32)
    returns Collection
    is native('myhtml')
    is export
    { * }

#| Set character encoding for input stream
#|
#| @param[in] myhtml_tree_t*
#| @param[in] Input character encoding
#|
#| @return NULL if successful, otherwise an myhtml_collection_t* structure
sub myhtml_encoding_set(Tree, int32) is native('myhtml') is export { * }

#| Get character encoding for current stream
#|
#| @param[in] myhtml_tree_t*
#|
#| @return myhtml_encoding_t
sub myhtml_encoding_get(Tree) is native('myhtml') is export { * }

=head3 Node

#| Get next sibling node
#|
#| @param[in] myhtml_tree_node_t*
#|
#| @return myhtml_tree_node_t* if exists, otherwise an NULL value
sub myhtml_node_next(TreeNode)
    returns TreeNode
    is native('myhtml')
    is export
    { * }

#| Get previous sibling node
#|
#| @param[in] myhtml_tree_node_t*
#|
#| @return myhtml_tree_node_t* if exists, otherwise an NULL value
sub myhtml_node_prev(TreeNode)
    returns TreeNode
    is native('myhtml')
    is export
    { * }

#| Get parent node
#|
#| @param[in] myhtml_tree_node_t*
#|
#| @return myhtml_tree_node_t* if exists, otherwise an NULL value
sub myhtml_node_parent(TreeNode)
    returns TreeNode
    is native('myhtml')
    is export
    { * }

#| Get child (first child) of node
#|
#| @param[in] myhtml_tree_node_t*
#|
#| @return myhtml_tree_node_t* if exists, otherwise an NULL value
sub myhtml_node_child(TreeNode)
    returns TreeNode
    is native('myhtml')
    is export
    { * }

#| Get last child of node
#|
#| @param[in] myhtml_tree_node_t*
#|
#| @return myhtml_tree_node_t* if exists, otherwise an NULL value
sub myhtml_node_last_child(TreeNode)
    returns TreeNode
    is native('myhtml')
    is export
    { * }

#| Create new node
#|
#| @param[in] myhtml_tree_t*
#| @param[in] tag id, see enum myhtml_tags
#| @param[in] enum myhtml_namespace
#|
#| @return myhtml_tree_node_t* if successful, otherwise a NULL value
sub myhtml_node_create(Tree, int32, int32)
    returns TreeNode
    is native('myhtml')
    is export
    { * }

#| Release allocated resources
#|
#| @param[in] myhtml_tree_t*
#| @param[in] myhtml_tree_node_t*
sub myhtml_node_free(Tree, TreeNode)
    is native('myhtml')
    is export
    { * }

#| Remove node of tree
#|
#| @param[in] myhtml_tree_t*
#| @param[in] myhtml_tree_node_t*
#|
#| @return myhtml_tree_node_t* if successful, otherwise a NULL value
sub myhtml_node_remove(TreeNode)
    returns TreeNode
    is native('myhtml')
    is export
    { * }

#| Remove node of tree and release allocated resources
#|
#| @param[in] myhtml_tree_t*
#| @param[in] myhtml_tree_node_t*
sub myhtml_node_delete(Tree, TreeNode) is native('myhtml') is export { * }

#| Remove nodes of tree recursively and release allocated resources
#|
#| @param[in] myhtml_tree_t*
#| @param[in] myhtml_tree_node_t*
sub myhtml_node_delete_recursive(Tree, TreeNode)
    is native('myhtml')
    is export
    { * }

#| The appropriate place for inserting a node. Insertion with validation.
#| If try insert <a> node to <table> node, then <a> node inserted before <table> node
#|
#| @param[in] myhtml_tree_t*
#| @param[in] target node
#| @param[in] insertion node
#|
#| @return insertion node if successful, otherwise a NULL value
sub myhtml_node_insert_to_appropriate_place(Tree, TreeNode, TreeNode)
    returns TreeNode
    is native('myhtml')
    is export
    { * }

#| Append to target node as last child. Insertion without validation.
#|
#| @param[in] myhtml_tree_t*
#| @param[in] target node
#| @param[in] insertion node
#|
#| @return insertion node if successful, otherwise a NULL value
sub myhtml_node_insert_append_child(Tree, TreeNode, TreeNode)
    returns TreeNode
    is native('myhtml')
    is export
    { * }

#| Append sibling node after target node. Insertion without validation.
#|
#| @param[in] myhtml_tree_t*
#| @param[in] target node
#| @param[in] insertion node
#|
#| @return insertion node if successful, otherwise a NULL value
sub myhtml_node_insert_after(Tree, TreeNode, TreeNode)
    returns TreeNode
    is native('myhtml')
    is export
    { * }

#| Append sibling node before target node. Insertion without validation.
#|
#| @param[in] myhtml_tree_t*
#| @param[in] target node
#| @param[in] insertion node
#|
#| @return insertion node if successful, otherwise a NULL value
sub myhtml_node_insert_before(Tree, TreeNode, TreeNode)
    returns TreeNode
    is native('myhtml')
    is export
    { * }

#| Add text for a node with convert character encoding.
#|
#| @param[in] myhtml_tree_t*
#| @param[in] target node
#| @param[in] text
#| @param[in] text length
#| @param[in] character encoding
#|
#| @return myhtml_string_t* if successful, otherwise a NULL value
sub myhtml_node_text_set(Tree, TreeNode, Blob, size_t, int32)
    returns MyString
    is native('myhtml')
    is export
    { * }


#| Add text for a node with convert character encoding.
#|
#| @param[in] myhtml_tree_t*
#| @param[in] target node
#| @param[in] text
#| @param[in] text length
#| @param[in] character encoding
#|
#| @return myhtml_string_t* if successful, otherwise a NULL value
sub myhtml_node_text_set_with_charef(Tree, TreeNode, Blob, size_t, int32)
    returns MyString
    is native('myhtml')
    is export
    { * }

#| Get node namespace
#|
#| @param[in] myhtml_tree_node_t*
#|
#| @return enum myhtml_namespace
sub myhtml_node_namespace(TreeNode)
    returns int32
    is native('myhtml')
    is export
    { * }

#| Get node tag id
#|
#| @param[in] myhtml_tree_node_t*
#|
#| @return myhtml_tag_id_t
sub myhtml_node_tag_id(TreeNode)
    returns int32
    is native('myhtml')
    is export
    { * }

#| Get tag name by tag id
#|
#| @param[in] myhtml_tree_t*
#| @param[in] tag id
#| @param[out] optional, name length
#|
#| @return const char* if exists, otherwise a NULL value
sub myhtml_tag_name_by_id(Tree, int32)
    returns Str
    is native('myhtml')
    is export
    { * }

#| Get tag id by name
#|
#| @param[in] myhtml_tree_t*
#| @param[in] tag name
#| @param[in] tag name length
#|
#| @return tag id
sub myhtml_tag_id_by_name(Tree, Blob, size_t)
    returns int32
    is native('myhtml')
    is export
    { * }

#| Node has self-closing flag?
#|
#| @param[in] myhtml_tree_node_t*
#|
#| @return true or false (1 or 0)
sub myhtml_node_is_close_self(TreeNode)
    returns bool
    is native('myhtml')
    is export
    { * }

#| Get first attribute of a node
#|
#| @param[in] myhtml_tree_node_t*
#|
#| @return myhtml_tree_attr_t* if exists, otherwise an NULL value
sub myhtml_node_attribute_first(TreeNode)
    returns MyAttribute
    is native('myhtml')
    is export
    { * }

#| Get last attribute of a node
#|
#| @param[in] myhtml_tree_node_t*
#|
#| @return myhtml_tree_attr_t* if exists, otherwise an NULL value
sub myhtml_node_attribute_last(TreeNode)
    returns MyAttribute
    is native('myhtml')
    is export
    { * }

#| Get text of a node. Only for a MyHTML_TAG__TEXT or MyHTML_TAG__COMMENT tags
#|
#| @param[in] myhtml_tree_node_t*
#| @param[out] optional, text length
#|
#| @return const char* if exists, otherwise an NULL value
sub myhtml_node_text(TreeNode)
    returns Str
    is native('myhtml')
    is export
    { * }

#| Get myhtml_string_t object by Tree node
#|
#| @param[in] myhtml_tree_node_t*
#|
#| @return myhtml_string_t* if exists, otherwise an NULL value
sub myhtml_node_string(TreeNode)
    returns MyString
    is native('myhtml')
    is export
    { * }

=head3 MyAttribute

#| Get next sibling attribute of one node
#|
#| @param[in] myhtml_tree_attr_t*
#|
#| @return myhtml_tree_attr_t* if exists, otherwise an NULL value
sub myhtml_attribute_next(MyAttribute)
    returns MyAttribute
    is native('myhtml')
    is export
    { * }

#| Get previous sibling attribute of one node
#|
#| @param[in] myhtml_tree_attr_t*
#|
#| @return myhtml_tree_attr_t* if exists, otherwise an NULL value
sub myhtml_attribute_prev(MyAttribute)
    returns MyAttribute
    is native('myhtml')
    is export
    { * }

#| Get attribute namespace
#|
#| @param[in] myhtml_tree_attr_t*
#|
#| @return enum myhtml_namespace
sub myhtml_attribute_namespace(MyAttribute)
    returns int32
    is native('myhtml')
    is export
    { * }

#| Get attribute name (key)
#|
#| @param[in] myhtml_tree_attr_t*
#| @param[out] optional, name length
#|
#| @return const char* if exists, otherwise an NULL value
sub myhtml_attribute_name(MyAttribute)
    returns Str
    is native('myhtml')
    is export
    { * }

#| Get attribute value
#|
#| @param[in] myhtml_tree_attr_t*
#| @param[out] optional, value length
#|
#| @return const char* if exists, otherwise an NULL value
sub myhtml_attribute_value(MyAttribute)
    returns Str
    is native('myhtml')
    is export
    { * }

#| Get attribute by key
#|
#| @param[in] myhtml_tree_node_t*
#| @param[in] attr key name
#| @param[in] attr key name length
#|
#| @return myhtml_tree_attr_t* if exists, otherwise a NULL value
sub myhtml_attribute_by_key(TreeNode, Blob, size_t)
    returns MyAttribute
    is native('myhtml')
    is export
    { * }

#| Added attribute to tree node
#|
#| @param[in] myhtml_tree_t*
#| @param[in] myhtml_tree_node_t*
#| @param[in] attr key name
#| @param[in] attr key name length
#| @param[in] attr value name
#| @param[in] attr value name length
#| @param[in] character encoding; Default: MyHTML_ENCODING_UTF_8 or MyHTML_ENCODING_DEFAULT or 0
#|
#| @return created myhtml_tree_attr_t* if successful, otherwise a NULL value
sub myhtml_attribute_add(Tree, TreeNode, Blob, size_t, Blob, size_t, int32)
    returns MyAttribute
    is native('myhtml')
    is export
    { * }

#| Remove attribute reference. Do not release the resources
#|
#| @param[in] myhtml_tree_node_t*
#| @param[in] myhtml_tree_attr_t*
#|
#| @return myhtml_tree_attr_t* if successful, otherwise a NULL value
sub myhtml_attribute_remove(TreeNode, MyAttribute)
    returns MyAttribute
    is native('myhtml')
    is export
    { * }

#| Remove attribute by key reference. Do not release the resources
#|
#| @param[in] myhtml_tree_node_t*
#| @param[in] attr key name
#| @param[in] attr key name length
#|
#| @return myhtml_tree_attr_t* if successful, otherwise a NULL value
sub myhtml_attribute_remove_by_key(TreeNode, Str, size_t)
    returns MyAttribute
    is native('myhtml')
    is export
    { * }

#| Remove attribute and release allocated resources
#|
#| @param[in] myhtml_tree_t*
#| @param[in] myhtml_tree_node_t*
#| @param[in] myhtml_tree_attr_t*
sub myhtml_attribute_delete(Tree, TreeNode, MyAttribute)
    is native('myhtml')
    is export
    { * }

#| Release allocated resources
#|
#| @param[in] myhtml_tree_t*
#| @param[in] myhtml_tree_attr_t*
sub myhtml_attribute_free(Tree, MyAttribute)
    is native('myhtml')
    is export
    { * }

=head3 TagIndex

#| Create tag index structure
#|
#| @param[in] myhtml_tag_t*
#|
#| @return myhtml_tag_index_t* if successful, otherwise a NULL value
sub myhtml_tag_index_create(Tag)
    returns TagIndex
    is native('myhtml')
    is export
    { * }

#| Allocating and Initialization resources for a tag index structure
#|
#| @param[in] myhtml_tag_t*
#| @param[in] myhtml_tag_index_t*
#|
#| @return MyHTML_STATUS_OK if successful, otherwise an error status.
sub myhtml_tag_index_init(Tag, TagIndex)
    returns int32
    is native('myhtml')
    is export
    { * }

#| Clears tag index
#|
#| @param[in] myhtml_tag_t*
#| @param[in] myhtml_tag_index_t*
sub myhtml_tag_index_clean(Tag, TagIndex) is native('myhtml') { * }

#| Free allocated resources
#|
#| @param[in] myhtml_tag_t*
#| @param[in] myhtml_tag_index_t*
#|
#| @return NULL if successful, otherwise an myhtml_tag_index_t* structure
sub myhtml_tag_index_destroy(Tag, TagIndex)
    returns TagIndex
    is native('myhtml')
    is export
    { * }

#| Adds myhtml_tree_node_t* to tag index
#|
#| @param[in] myhtml_tag_t*
#| @param[in] myhtml_tag_index_t*
#| @param[in] myhtml_tree_node_t*
#|
#| @return MyHTML_STATUS_OK if successful, otherwise an error status.
sub myhtml_tag_index_add(Tag, TagIndex, TreeNode)
    returns int32
    is native('myhtml')
    is export
    { * }

#| Get root tag index. Is the initial entry for a tag. It contains statistics and other items by tag
#|
#| @param[in] myhtml_tag_index_t*
#| @param[in] myhtml_tag_id_t
#|
#| @return myhtml_tag_index_entry_t* if successful, otherwise a NULL value.
sub myhtml_tag_index_entry(TagIndex, int32)
    returns TagIndexEntry
    is native('myhtml')
    is export
    { * }

#| Get first index node for tag
#|
#| @param[in] myhtml_tag_index_t*
#| @param[in] myhtml_tag_id_t
#|
#| @return myhtml_tag_index_node_t* if exists, otherwise a NULL value.
sub myhtml_tag_index_first(TagIndex, int32)
    returns TagIndexNode
    is native('myhtml')
    is export
    { * }

#| Get last index node for tag
#|
#| @param[in] myhtml_tag_index_t*
#| @param[in] myhtml_tag_id_t
#|
#| @return myhtml_tag_index_node_t* if exists, otherwise a NULL value.
sub myhtml_tag_index_last(TagIndex, int32)
    returns TagIndexNode
    is native('myhtml')
    is export
    { * }

#| Get next index node for tag, by index node
#|
#| @param[in] myhtml_tag_index_node_t*
#|
#| @return myhtml_tag_index_node_t* if exists, otherwise a NULL value.
sub myhtml_tag_index_next(TagIndexNode)
    returns TagIndexNode
    is native('myhtml')
    is export
    { * }

#| Get previous index node for tag, by index node
#|
#| @param[in] myhtml_tag_index_node_t*
#|
#| @return myhtml_tag_index_node_t* if exists, otherwise a NULL value.
sub myhtml_tag_index_prev(TagIndexNode)
    returns TagIndexNode
    is native('myhtml')
    is export
    { * }

#| Get myhtml_tree_node_t* by myhtml_tag_index_node_t*
#|
#| @param[in] myhtml_tag_index_node_t*
#|
#| @return myhtml_tree_node_t* if exists, otherwise a NULL value.
sub myhtml_tag_index_tree_node(TagIndexNode)
    returns TreeNode
    is native('myhtml')
    is export
    { * }

#| Get count of elements in index by tag id
#|
#| @param[in] myhtml_tag_index_t*
#| @param[in] tag id
#|
#| @return count of elements
sub myhtml_tag_index_entry_count(TagIndex, int32)
    returns size_t
    is native('myhtml')
    is export
    { * }

=head3 Collection

#| Create collection
#|
#| @param[in] list size
#| @param[out] optional, status of operation
#|
#| @return myhtml_collection_t* if successful, otherwise an NULL value
sub myhtml_collection_create(size_t, int32 is rw)
    returns Collection
    is native('myhtml')
    is export
    { * }

#| Clears collection
#|
#| @param[in] myhtml_collection_t*
sub myhtml_collection_clean(Collection)
    is native('myhtml')
    is export
    { * }

#| Destroy allocated resources
#|
#| @param[in] myhtml_collection_t*
#|
#| @return NULL if successful, otherwise an myhtml_collection_t* structure
sub myhtml_collection_destroy(Collection)
    is native('myhtml')
    is export
    { * }

#| Check size by length and increase if necessary
#|
#| @param[in] myhtml_collection_t*
#| @param[in] count of add nodes
#|
#| @return NULL if successful, otherwise an myhtml_collection_t* structure
sub myhtml_collection_check_size(Collection, size_t)
    returns int32
    is native('myhtml')
    is export
    { * }

=head3 Encoding

#| Convert Unicode Codepoint to UTF-16LE
#|
#| I advise not to use UTF-16! Use UTF-8 and be happy!
#|
#| @param[in] Codepoint
#| @param[in] Data to set characters. Data length is 2 or 4 bytes
#|   data length must be always available 4 bytes
#|
#| @return size character set
sub codepoint-to-utf16(size_t, Str)
    returns size_t
    is native('myhtml')
    is symbol<myhtml_encoding_codepoint_to_ascii_utf_16>
    is export
    { * }

#| Detect character encoding
#|
#| Now available for detect UTF-8, UTF-16LE, UTF-16BE
#| and Russians: windows-1251,  koi8-r, iso-8859-5, x-mac-cyrillic, ibm866
#| Other in progress
#|
#| @param[in]  text
#| @param[in]  text length
#| @param[out] detected encoding
#|
#| @return true if encoding found, otherwise false
sub myhtml_encoding_detect(Blob, size_t, int32 is rw)
    returns bool
    is native('myhtml')
    is export
    { * }

#| Detect Russian character encoding
#|
#| Now available for detect windows-1251,  koi8-r, iso-8859-5, x-mac-cyrillic, ibm866
#|
#| @param[in]  text
#| @param[in]  text length
#| @param[out] detected encoding
#|
#| @return true if encoding found, otherwise false
sub myhtml_encoding_detect_russian(Blob, size_t, int32 is rw)
    returns bool
    is native('myhtml')
    is export
    { * }

#| Detect Unicode character encoding
#|
#| Now available for detect UTF-8, UTF-16LE, UTF-16BE
#|
#| @param[in]  text
#| @param[in]  text length
#| @param[out] detected encoding
#|
#| @return true if encoding found, otherwise false
sub mythml_encoding_detect_unicode(Blob, size_t, int32 is rw)
    returns bool
    is native('myhtml')
    is export
    { * }

#| Detect Unicode character encoding by BOM
#|
#| Now available for detect UTF-8, UTF-16LE, UTF-16BE
#|
#| @param[in]  text
#| @param[in]  text length
#| @param[out] detected encoding
#|
#| @return true if encoding found, otherwise false
sub myhtml_encoding_detect_bom(Blob, size_t, int32 is rw)
    returns bool
    is native('myhtml')
    is export
    { * }

#| Detect Unicode character encoding by BOM. Cut BOM if will be found
#|
#| Now available for detect UTF-8, UTF-16LE, UTF-16BE
#|
#| @param[in]  text
#| @param[in]  text length
#| @param[out] detected encoding
#| @param[out] new text position
#| @param[out] new size position
#|
#| @return true if encoding found, otherwise false
sub myhtml_encoding_detect_and_cut_bom(Blob, size_t, int32 is rw, Blob is rw, size_t is rw)
    returns bool
    is native('myhtml')
    is export
    { * }

=head3 MyString

#| Init myhtml_string_t structure
#|
#| @param[in] mchar_async_t*. It can be obtained from myhtml_tree_t object
#|  (see myhtml_tree_get_mchar function) or create manualy
#|  For each Tree creates its object, I recommend to use it (myhtml_tree_get_mchar).
#|
#| @param[in] node_id. For all threads (and Main thread) identifier that is unique.
#|  if created mchar_async_t object manually you know it, if not then take from the Tree
#|  (see myhtml_tree_get_mchar_node_id)
#|
#| @param[in] myhtml_string_t*. It can be obtained from myhtml_tree_node_t object
#|  (see myhtml_node_string function) or create manualy
#|
#| @param[in] data size. Set the size you want for char*
#|
#| @return char* of the size if successful, otherwise a NULL value
sub myhtml_string_init(MCharAsync, size_t, MyString, size_t)
    returns Str
    is native('myhtml')
    is export
    { * }

#| Increase the current size for myhtml_string_t object
#|
#| @param[in] mchar_async_t*. See description for myhtml_string_init function
#| @param[in] node_id. See description for myhtml_string_init function
#| @param[in] myhtml_string_t*. See description for myhtml_string_init function
#| @param[in] data size. Set the new size you want for myhtml_string_t object
#|
#| @return char* of the size if successful, otherwise a NULL value
sub myhtml_string_realloc(MCharAsync, size_t, MyString, size_t)
    returns Str
    is native('myhtml')
    is export
    { * }

#| Clean myhtml_string_t object. In reality, data length set to 0
#| Equivalently: myhtml_string_length_set(str, 0);
#|
#| @param[in] myhtml_string_t*. See description for myhtml_string_init function
sub myhtml_string_clean(MyString)
    is native('myhtml')
    is export
    { * }

#| Clean myhtml_string_t object. Equivalently: memset(str, 0, sizeof(myhtml_string_t))
#|
#| @param[in] myhtml_string_t*. See description for myhtml_string_init function
sub myhtml_string_clean_all(MyString)
    is native('myhtml')
    is export
    { * }

#| Release all resources for myhtml_string_t object
#|
#| @param[in] myhtml_string_t*. See description for myhtml_string_init function
#| @param[in] call free function for current object or not
#|
#| @return NULL if destroy_obj set true, otherwise a current myhtml_string_t object
sub myhtml_string_destroy(MyString, bool)
    returns MyString
    is native('myhtml')
    is export
    { * }

#| Get data (char*) from a myhtml_string_t object
#|
#| @param[in] myhtml_string_t*. See description for myhtml_string_init function
#|
#| @return char* if exists, otherwise a NULL value
sub myhtml_string_data(MyString)
    returns Str
    is native('myhtml')
    is export
    { * }

#| Get data length from a myhtml_string_t object
#|
#| @param[in] myhtml_string_t*. See description for myhtml_string_init function
#|
#| @return data length
sub myhtml_string_length(MyString)
    returns size_t
    is native('myhtml')
    is export
    { * }

#| Get data size from a myhtml_string_t object
#|
#| @param[in] myhtml_string_t*. See description for myhtml_string_init function
#|
#| @return data size
sub myhtml_string_size(MyString)
    returns size_t
    is native('myhtml')
    is export
    { * }

#| Set data (char *) for a myhtml_string_t object.
#|
#| Attention!!! Attention!!! Attention!!!
#|
#| You can assign only that it has been allocated from functions:
#| myhtml_string_data_alloc
#| myhtml_string_data_realloc
#| or obtained manually created from mchar_async_t object
#|
#| Attention!!! Do not try set char* from allocated by malloc or realloc!!!
#|
#| @param[in] myhtml_string_t*. See description for myhtml_string_init function
#| @param[in] you data to want assign
#|
#| @return assigned data if successful, otherwise a NULL value
sub myhtml_string_data_set(MyString, Str)
    returns Str
    is native('myhtml')
    is export
    { * }

#| Set data size for a myhtml_string_t object.
#|
#| @param[in] myhtml_string_t*. See description for myhtml_string_init function
#| @param[in] you size to want assign
#|
#| @return assigned size
sub myhtml_string_size_set(MyString, size_t)
    returns size_t
    is native('myhtml')
    is export
    { * }

#| Set data length for a myhtml_string_t object.
#|
#| @param[in] myhtml_string_t*. See description for myhtml_string_init function
#| @param[in] you length to want assign
#|
#| @return assigned length
sub myhtml_string_length_set(MyString, size_t)
    returns size_t
    is native('myhtml')
    is export
    { * }


#| Allocate data (char*) from a mchar_async_t object
#|
#| @param[in] mchar_async_t*. See description for myhtml_string_init function
#| @param[in] node id. See description for myhtml_string_init function
#| @param[in] you size to want assign
#|
#| @return data if successful, otherwise a NULL value
sub myhtml_string_data_alloc(MCharAsync, size_t, size_t)
    returns Str
    is native('myhtml')
    is export
    { * }

#| Allocate data (char*) from a mchar_async_t object
#|
#| @param[in] mchar_async_t*. See description for myhtml_string_init function
#| @param[in] node id. See description for myhtml_string_init function
#| @param[in] old data
#| @param[in] how much data is copied from the old data to new data
#| @param[in] new size
#|
#| @return data if successful, otherwise a NULL value
sub myhtml_string_data_realloc(MCharAsync, size_t, Str, size_t, size_t)
    returns Str
    is native('myhtml')
    is export
    { * }

#| Release allocated data
#|
#| @param[in] mchar_async_t*. See description for myhtml_string_init function
#| @param[in] node id. See description for myhtml_string_init function
#| @param[in] data to release
#|
#| @return data if successful, otherwise a NULL value
sub myhtml_string_data_free(MCharAsync, size_t, Str)
    is native('myhtml')
    is export
    { * }
