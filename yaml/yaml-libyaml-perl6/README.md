# Perl6 LibYAML

[![Build Status](https://travis-ci.org/yaml/yaml-libyaml-perl6.svg)](https://travis-ci.org/yaml/yaml-libyaml-perl6)

A [Perl 6](https://perl6.org/) interface to
[LibYAML](https://github.com/yaml/libyaml), a [YAML](http://yaml.org/)
1.1 parser and emitter.

# INSTALLATION

You must get and install [libyaml](https://github.com/yaml/libyaml)
first. Then you can install LibYAML with zef:

    zef install LibYAML

## Install from Sources

You can install this LibYAML module from source (optionally also using the
libyaml C code sources) like this:

    $ git clone https://github.com/yaml/yaml-libyaml-perl6
    $ git clone https://github.com/yaml/libyaml
    $ (cd libyaml; make -f .makefile)
    $ export LD_LIBRARY_PATH=$PWD/libyaml/src/.libs
    $ cd perl6-libyaml
    $ zef install .

# Examples

Note: This is a parser and emitter. The interface will probably change.
If you want to load and dump YAML, take a look at
[YAML.pm6](https://github.com/yaml/yaml-perl6).

    use LibYAML;

    my $parser = LibYAML::Parser.new;

    my $emitter = LibYAML::Emitter.new(...options...);

Originally LibYAML combined loading and parsing, dumping and emitting.  The load
and dump parts have been extracted, modified and moved to yaml/yaml-perl6.

Documentation will be added when we figure out the API we want to use.

# Emitter options

    :encoding = YAML_ANY_ENCODING
                YAML_UTF8_ENCODING (default)
                YAML_UTF16LE_ENCODING
                YAML_UTF16BE_ENCODING

    :sequence-style = YAML_BLOCK_SEQUENCE_STYLE (default)
                      YAML_FLOW_SEQUENCE_STYLE

    :mapping-style = YAML_BLOCK_MAPPING_STYLE (default)
                     YAML_FLOW_MAPPING_STYLE

    :header or :!header  Output `---` header (default if more than one object output)

    :footer or :!footer  Output `...` footer (default false)

    :canonical or :!canonical

    :indent = 2 .. 9 (default 2)

    :width = width of line, default = -1, infinite

    :unicode or :!unicode (default True)

    :break = YAML_LN_BREAK (default)
             YAML_CR_BREAK
             YAML_CRLN_BREAK

# Errors

Throws exceptions `X::LibYAML::Parser-Error` or
`X::LibYAML::Emitter-Error` on error.

# SEE ALSO

[YAMLish](https://github.com/Leont/yamlish) is a pure-perl6 module for
YAML that doesn't rely on an external library like `LibYAML` does.

[YAML.pm6](https://github.com/yaml/yaml-perl6) is a loader and dumper, which
uses LibYAML as a backend.

