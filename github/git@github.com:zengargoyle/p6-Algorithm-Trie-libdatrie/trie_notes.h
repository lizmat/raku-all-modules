/**
 * @file trie.h
 * @brief Trie data type and functions
 *
 * Trie is a kind of digital search tree, an efficient indexing method with
 * O(1) time complexity for searching. Comparably as efficient as hashing,
 * trie also provides flexibility on incremental matching and key spelling
 * manipulation. This makes it ideal for lexical analyzers, as well as
 * spelling dictionaries.
 *
 * This library is an implementation of double-array structure for representing
 * trie, as proposed by Junichi Aoe. The details of the implementation can be
 * found at http://linux.thai.net/~thep/datrie/datrie.html
 *
 * A Trie is associated with an AlphaMap, a map between actual alphabet
 * characters and the raw characters used to walk through trie.
 * You can define the alphabet set by adding ranges of character codes
 * to it before associating it to a trie. And the keys to be added to the trie
 * must comprise only characters in such ranges. Note that the size of the
 * alphabet set is limited to 256 (TRIE_CHAR_MAX + 1), and the AlphaMap
 * will map the alphabet characters to raw codes in the range 0..255
 * (0..TRIE_CHAR_MAX). The alphabet character ranges need not be continuous,
 * but the mapped raw codes will be continuous, for the sake of compactness
 * of the trie.
 *
 * A new Trie can be created in memory using trie_new(), saved to file using
 * trie_save(), and loaded later with trie_new_from_file().
 * It can even be embeded in another file using trie_fwrite() and read back
 * using trie_fread().
 * After use, Trie objects must be freed using trie_free().
 *
 * Operations on trie include:
 *
 * - Add/delete entries with trie_store() and trie_delete()
 * - Retrieve entries with trie_retrieve()
 * - Walk through trie stepwise with TrieState and its functions
 *   (trie_root(), trie_state_walk(), trie_state_rewind(),
 *   trie_state_clone(), trie_state_copy(),
 *   trie_state_is_walkable(), trie_state_walkable_chars(),
 *   trie_state_is_single(), trie_state_get_data().
 *   And do not forget to free TrieState objects with trie_state_free()
 *   after use.)
 * - Enumerate all keys using trie_enumerate()
 * - Iterate entries using TrieIterator and its functions
 *   (trie_iterator_new(), trie_iterator_next(), trie_iterator_get_key(),
 *   trie_iterator_get_data().
 *   And do not forget to free TrieIterator objects with trie_iterator_free()
 *   after use.)
 */

#define __TRIEDEFS_H
typedef uint32 AlphaChar;
#define ALPHA_CHAR_ERROR (~(AlphaChar)0)
/*# XXX:unused typedef unsigned char TrieChar; */
#define TRIE_CHAR_TERM '\0'
#define TRIE_CHAR_MAX 255
typedef int32 TrieIndex;
#define TRIE_INDEX_ERROR 0
#define TRIE_INDEX_MAX 0x7fffffff
typedef int32 TrieData;
#define TRIE_DATA_ERROR -1

#define __ALPHA_MAP_H
typedef struct _AlphaMap AlphaMap;
AlphaMap * alpha_map_new ();
AlphaMap * alpha_map_clone (const AlphaMap *a_map);
void alpha_map_free (AlphaMap *alpha_map);
int alpha_map_add_range (AlphaMap *alpha_map, AlphaChar begin, AlphaChar end);
int alpha_char_strlen (const AlphaChar *str);
int alpha_char_strcmp (const AlphaChar *str1, const AlphaChar *str2);

#define __TRIE_H
typedef struct _Trie Trie;
typedef struct _TrieState TrieState;
typedef struct _TrieIterator TrieIterator;
typedef uint32 Bool
typedef Bool (*TrieEnumFunc) (const AlphaChar *key, TrieData key_data, void *user_data);
Trie * trie_new (const AlphaMap *alpha_map);
Trie * trie_new_from_file (const char *path);
Trie * trie_fread (FILE *file);
void trie_free (Trie *trie);
int trie_save (Trie *trie, const char *path);
int trie_fwrite (Trie *trie, FILE *file);
Bool trie_is_dirty (const Trie *trie);
Bool trie_retrieve (const Trie *trie, const AlphaChar *key, TrieData *o_data);
Bool trie_store (Trie *trie, const AlphaChar *key, TrieData data);
Bool trie_store_if_absent (Trie *trie, const AlphaChar *key, TrieData data);
Bool trie_delete (Trie *trie, const AlphaChar *key);
Bool trie_enumerate (const Trie *trie, TrieEnumFunc enum_func, void *user_data);

TrieState * trie_root (const Trie *trie);
TrieState * trie_state_clone (const TrieState *s);
void trie_state_copy (TrieState *dst, const TrieState *src);
void trie_state_free (TrieState *s);
void trie_state_rewind (TrieState *s);
Bool trie_state_walk (TrieState *s, AlphaChar c);
Bool trie_state_is_walkable (const TrieState *s, AlphaChar c);
int trie_state_walkable_chars (const TrieState *s, AlphaChar chars[], int chars_nelm);
#define trie_state_is_terminal(s) trie_state_is_walkable((s),TRIE_CHAR_TERM)
Bool trie_state_is_single (const TrieState *s);
#define trie_state_is_leaf(s) (trie_state_is_single(s) && trie_state_is_terminal(s))
TrieData trie_state_get_data (const TrieState *s);

TrieIterator * trie_iterator_new (TrieState *s);
void trie_iterator_free (TrieIterator *iter);
Bool trie_iterator_next (TrieIterator *iter);
AlphaChar * trie_iterator_get_key (const TrieIterator *iter);
TrieData trie_iterator_get_data (const TrieIterator *iter);

