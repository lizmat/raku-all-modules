# Perl6 LibYAML

[![Build Status](https://travis-ci.org/CurtTilmes/perl6-libyaml.svg)](https://travis-ci.org/CurtTilmes/perl6-libyaml)

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

    $ git clone https://github.com/CurtTilmes/perl6-libyaml
    $ git clone https://github.com/yaml/libyaml
    $ (cd libyaml; make -f .makefile)
    $ export LD_LIBRARY_PATH=$PWD/libyaml/src/.libs
    $ cd perl6-libyaml
    $ zef install .

# Examples

## Simple

    use LibYAML;

    my $object = load-yaml("...YAML...");

    my $object = load-yaml-file("/my/file.yml");

    my $yaml-str = dump-yaml($object [, $object2, ...], ...options...);

    dump-yaml-file("/my/file.yml", $object [, $object2, ...], ...options...);

## Object-Oriented

    use LibYAML;

    my $parser = LibYAML::Parser.new;

    my $object = $parser.parse-string("...YAML...");

    my $object = $parser.parse-file("/my/file.yml");

    my $emitter = LibYAML::Emitter.new(...options...);

    my $yaml-str = $emitter.dump-string($object [, $object2, ...]);

    $emitter.dump-file("/my/file.yml", $object [, $object2, ... ]);

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

