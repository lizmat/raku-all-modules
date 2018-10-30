## Introduction

```perl6
use LMDB;

# Open the database in some-dir, Note the binding!
my %DB := LMDB::DB.open(:path<some-dir>);

# Now you can use %DB a a common lazy hash:

%DB<A B C D E> = <a b c d e>;  # Put some values

say %DB<A>;       # 'a'
say %DB<D>:exists # True

%DB<B>:delete;
say %DB<B>:exists # False

# To preserve your data, don't forget a commit:
%DB.commit

# The lmdb library has many features, see its documentation for access its full
powers and please see t/01-basic for the details.
```
