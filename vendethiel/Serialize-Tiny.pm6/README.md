Serialize::Tiny
===============


A very bare-bones module that serializes an instance's public attributes.

### Examples

```perl6
class A {
  has $.pub;
  has $!priv;
}

use Serialize::Tiny;
say serialize(A.new(:5pub));
#=> {:a(5)}<>
```
