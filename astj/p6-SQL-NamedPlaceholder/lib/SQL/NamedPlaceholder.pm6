use v6;

unit module SQL::NamedPlaceholder;

my regex placeholder { <[A..Za..z_]><[A..Za..z0..9_-]>* }
my regex operator { '=' || '<=' || '<' || '>=' || '>' || '<>' || '!=' || '<=>' }
my token column-quote { <[`"]> }
sub bind-named (Str $query is copy, %bind-hash --> List) is export {
    my @bind-list;

    # replace question marks as placeholder. e.g. [`hoge` = ?] to [`hoge` = :hoge]
    $query ~~ s:g/($<cq>=(<column-quote>?)$<key>=(<placeholder>)$<cq>\s*<operator>\s*)\?/$0\:$0<key>/;

    $query ~~ s:g/\:(<placeholder>)/{
        die "'$0' does not exist in bind hash" unless %bind-hash{$0}:exists;
        my $value = %bind-hash{$0};
        @bind-list.push(|$value);
        $value ~~ List ?? $value.map({"?"}).join(", ") !! '?'
    }/;
    return [ $query, @bind-list ];
}

=begin pod

=head1 NAME

SQL::NamedPlaceholder - extension of placeholder

=head1 SYNOPSIS

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


=head1 DESCRIPTION

SQL::NamedPlaceholder is extension of placeholder. This enable more readable and robust code.

=head1 FUNCTION

=begin item
[$sql, $bind] = bind-named($sql, $hash);

The $sql parameter is SQL string which contains named placeholders. The $hash parameter is map of bind parameters.

The returned $sql is new SQL string which contains normal placeholders ('?'), and $bind is List of bind parameters.
=end item

=head1 SYNTAX

=begin item
:foobar

Replace as placeholder which uses value from $hash{foobar}.

=end item

=begin item
foobar = ?, foobar > ?, foobar < ?, foobar <> ?, etc.

This is same as 'foobar (op.) :foobar'.

=end item

=head1 AUTHOR

astj <asato.wakisaka@gmail.com>

=head1 ORIGINAL AUTHOR

This module is port of L<SQL::NamedPlaceholder in Perl5|https://github.com/cho45/SQL-NamedPlaceholder>.

Author of original SQL::NamedPlaceholder in Perl5 is cho45 <cho45@lowreal.net>.

=head1 SEE ALSO

L<SQL::NamedPlaceholder in Perl5|https://github.com/cho45/SQL-NamedPlaceholder>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the Artistic License 2.0.

Original Perl5's SQL::NamedPlaceholder is licensed under following terms:

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=end pod
