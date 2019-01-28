use v6;

unit package ModelDB;

=begin pod

=head1 NAME

ModelDB::RelationshipSetup - internal bits managing relationships

=head1 DESCRIPTION

Performs setup required for relationships between tables.

=end pod

role RelationshipSetup[Str $relationship-name, Str $schema-ref] {
    #     method compose(Mu $package) {
    #         callsame;
    #         if self.has_accessor {
    #             my $name = self.name.substr(2);
    #             $package.^method_table{$name}.wrap(
    #                 method (|) {
    #                     (my $value = callsame)
    #                         andthen $value."_set-key-for-$relationship-name"($schema-ref);
    #                     $value;
    #                 }
    #             );
    #         }
    #     }
}

