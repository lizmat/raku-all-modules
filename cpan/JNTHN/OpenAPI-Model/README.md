NAME
====

OpenAPI::Model - work with OpenAPI documents in terms of a set of Perl 6 objects.

SYNOPSIS
========

    # Just fully qualified names available (OpenAPI::Model::Operation)
    use OpenAPI::Model;
    # Or get short names for model objects imported (Operation)
    use OpenAPI::Model :elements;

    # Load an existing document from YAML (returns OpenAPI::Model::OpenAPI):
    my $api = OpenAPI::Model.from-yaml($yaml-doc);
    # Or from JSON:
    my $api = OpenAPI::Model.from-json($json-doc);

    # Dig into the document (automatically resolves references within the
    # document):
    for $api.paths.kv -> $path, $object {
        say "At $path you can:";
        for <get post put delete> -> $method {
            with $object."$method"() {
                say " - do a $method.uc() request";
            }
        }
    }

    # References to external schemas are also possible (we won't go trying
    # to download anything for you, and expect an `OpenAPI::Model::OpenAPI`
    # instance for each one). These are used to resolve external references.
    my %external = 'http://some.organization/schema/foobar' =>
        OpenAPI::Model.from-yaml(slurp('foobar.yaml'));
    my $api = OpenAPI::Model.from-yaml($yaml-doc, :%external);

DESCRIPTION
===========

OpenAPI::Model is a library that provides Perl 6 object layers upon OpenAPI documents.

AUTHOR
======

Alexander Kiryuhin <alexander.kiryuhin@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Edument Central Europe sro.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

