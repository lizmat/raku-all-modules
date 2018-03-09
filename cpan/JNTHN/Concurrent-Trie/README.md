# Concurrent::Trie

A lock-free trie (Text Retrieval) data structure, safe for concurrent use.

## Synopsis

    use Concurrent::Trie;

    my $trie = Concurrent::Trie.new;
    say $trie.contains('brie');         # False
    say so $trie;                       # False
    say $trie.elems;                    # 0

    $trie.insert('brie');
    say $trie.contains('brie');         # True
    say so $trie;                       # True
    say $trie.elems;                    # 1

    $trie.insert('babybel');
    $trie.insert('gorgonzola');
    say $trie.elems;                    # 3
    say $trie.entries();                # (gorgonzola babybel brie)
    say $trie.entries('b');             # (babybel brie)

## Overview

A trie stores strings as a tree, with each level in the tree representing a
character in the string (so the tree's maximum depth is equal to the number
of characters in the longest entry). A trie is especially useful for prefix
searches, where all entries with a given prefix are required, since this is
obtained simply by walking the tree according to the prefix, and then visiting
all nodes below that point to find entries.

This is a lock-free trie. Checking if the trie contains a particular string
never blocks. Iterating the entries never blocks either, and will provide a
snapshot of all the entries at the time the `entries` method was called. An
insertion uses optimistic concurrency control, building an updated tree and
then trying to commit it. This offers a global progress bound: if one thread
fails to insert, it's because another thread did a successful insert.

This data structure is well suited to auto-complete style features in
concurrent applications, where new entries and lookups may occur when, for
example, processing web requests in parallel.

## Methods

### insert(Str $value --> Nil)

Inserts the passed string value into the trie.

### contains(Str $value --> Bool)

Checks if the passed string value is in the trie. Returns `True` if so, and
`False` otherwise.

### entries($prefix = '' --> Seq)

Returns a lazy iterator of all entries in the trie with the specified prefix.
If no prefix is passed, the default is the empty prefix, meaning that a call
like `$trie.entries()` will iterate all entries in the trie. The order of the
results is not defined.

The results will be a snapshot of what was in the trie at the point `entries`
was called; additions after that point will not be in the `entries` list.

### elems(--> Int)

Gets the number of entries in the trie. The data structure maintains a count,
making this O(1) (as opposed to `$trie.entries.elems`, which would be O(n)).

### Bool()

Returns `True` if the number of entries in the trie is non-zero, and `False`
otherwise.
