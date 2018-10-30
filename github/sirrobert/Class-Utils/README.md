## Class::Utils

### role Has

Some of the core classes don't run through `bless` during object
creation (apparently for efficiency reasons).  This means that if you define
a class that inherits from Array, for example, you can't define properties
for the class using the normal `has` route.

The `Has` role addresses this by importing a new `new` that takes advantage
of bless.

#### Usage

The following code breaks.  If you try to access `$.foo` below, you get an
undefined `Any` value instead of `'bar'`.  

```
class MySet is Array {
  has $.foo = 'bar';
}

say MySet.new.foo;    # Any()
```

Fix this with `does Has` from `Class::Utils`:

```
use Class::Utils;

class MySet is Array does Has {
  has $.foo = 'bar';
}

say MySet.new.foo;    # bar
```

