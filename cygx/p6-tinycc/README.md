# Name

TinyCC - The Tiny C Compiler

# Synopsis

```
    use TinyCC;

    # tells TinyCC where libtcc1.a can be found
    tcc.set(:L<.>);

    tcc.define(NAME => '"cygx"');
    tcc.compile(q:to/__END__/);
        int puts(const char *);
        int main(void) {
            puts("Hello, " NAME "!");
            return 0;
        }
        __END__

    tcc.run;
    tcc.delete;
```

# Description

Tries to load TinyCC from the shared library specified in `%*ENV<LIBTCC>`,
falling back to plain `'libtcc'`.

Alternatively, a list of candidates can be passed to the use statement:

    use TinyCC <path/1/libtcc.so path/2/libtcc.so>;

The current development version of TinyCC itself can be found at
[repo.or.cz/w/tinycc.git](http://repo.or.cz/w/tinycc.git); the embedding API
is documented in [libtcc.h](http://repo.or.cz/w/tinycc.git/blob/HEAD:/libtcc.h).

The `TCC` class provides the following methods:

    method new(:$state = api<new>()) { ... }

  * wraps `tcc_new`
  * calls `TCC.bless`

---

    method delete { ... }

  * wraps `tcc_delete`

---

    method path($path) { ... }

  * wraps `tcc_set_lib_path`

---

    multi method target($type) { ... }

  * wraps `tcc_set_output_type`

---

    multi method target(Bool :$MEM!) { ... }

  * calls `TCC.target`

---

    multi method target(Bool :$EXE!) { ... }

  * calls `TCC.target`

---

    multi method target(Bool :$DLL!) { ... }

  * calls `TCC.target`

---

    multi method target(Bool :$OBJ!) { ... }

  * calls `TCC.target`

---

    method compile($code) { ... }

  * wraps `tcc_compile_string`

---

    method run(*@args) { ... }

  * wraps `tcc_run`

---

    multi method set(:$I, :$isystem, :$L, :$l, :$nostdlib) { ... }

  * wraps `tcc_add_include_path`, `tcc_add_library`, `tcc_add_library_path`, `tcc_add_sysinclude_path`
  * calls `TCC.set`

---

    multi method set($opts) { ... }

  * wraps `tcc_set_options`

---

    multi method add(:$bin, :$c, :$asm, :$asmpp) { ... }

  * wraps `tcc_add_file`

---

    multi method add(*@srcfiles) { ... }

  * wraps `tcc_add_file`

---

    method define(*%defs) { ... }

  * wraps `tcc_define_symbol`

---

    method undef(*@defs) { ... }

  * wraps `tcc_undefine_symbol`

---

    method declare(*%symbols) { ... }

  * wraps `tcc_add_symbol`

---

    method relocate($ptr = RELOCATE_AUTO) { ... }

  * wraps `tcc_relocate`

---

    method memreq { ... }

  * wraps `tcc_relocate`

---

    method lookup($symbol) { ... }

  * wraps `tcc_get_symbol`

---

    method dump($file) { ... }

  * wraps `tcc_output_file`

---

    method on-error(&cb, :$payload) { ... }

  * wraps `tcc_set_error_func`

---



# Bugs and Development

Development happens at [GitHub](https://github.com/cygx/p6-tinycc). If you
found a bug or have a feature request, use the
[issue tracker](https://github.com/cygx/p6-tinycc/issues) over there.


# Copyright and License

Copyright (C) 2015 by <cygx@cpan.org>

Distributed under the
[Boost Software License, Version 1.0](http://www.boost.org/LICENSE_1_0.txt)
