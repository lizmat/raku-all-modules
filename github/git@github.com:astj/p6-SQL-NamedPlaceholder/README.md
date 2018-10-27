[![Build Status](https://travis-ci.org/astj/p6-SQL-NamedPlaceholder.svg?branch=master)](https://travis-ci.org/astj/p6-SQL-NamedPlaceholder)

NAME
====

SQL::NamedPlaceholder - extension of placeholder

SYNOPSIS
========

    use SQL::NamedPlaceholder;

    my ($sql, $bind) = bind-named(q[
        SELECT *
        FROM entry
        WHERE
            user_id = :user_id
    ], {
        user_id => $user_id
    });

    $dbh.prepare($sql).execute(|$bind);

DESCRIPTION
===========

SQL::NamedPlaceholder is extension of placeholder. This enable more readable and robust code.

FUNCTION
========

  * [$sql, $bind] = bind-named($sql, $hash);

    The $sql parameter is SQL string which contains named placeholders. The $hash parameter is map of bind parameters.

    The returned $sql is new SQL string which contains normal placeholders ('?'), and $bind is List of bind parameters.

SYNTAX
======

  * :foobar

    Replace as placeholder which uses value from $hash{foobar}.

  * foobar = ?, foobar > ?, foobar < ?, foobar <> ?, etc.

    This is same as 'foobar (op.) :foobar'.

AUTHOR
======

astj <asato.wakisaka@gmail.com>

ORIGINAL AUTHOR
===============

This module is port of [SQL::NamedPlaceholder in Perl5](https://github.com/cho45/SQL-NamedPlaceholder).

Author of original SQL::NamedPlaceholder in Perl5 is cho45 <cho45@lowreal.net>.

SEE ALSO
========

[SQL::NamedPlaceholder in Perl5](https://github.com/cho45/SQL-NamedPlaceholder)

LICENSE
=======

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

Original Perl5's SQL::NamedPlaceholder is licensed under following terms:

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.
