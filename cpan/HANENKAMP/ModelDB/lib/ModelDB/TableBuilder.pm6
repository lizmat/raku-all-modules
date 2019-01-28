use v6;

unit package ModelDB;

=begin pod

=head1 NAME

ModelDB::TableBuilder - internal schema helper

=head1 DESCRIPTION

Helps to setup table objects when declared with the C<is table> trait in a schema.

=end pod

role TableBuilder[Str $table] {
    method compose(Mu $package) {
        callsame;
        my $attr = self;
        if $attr.has_accessor {
            my $name = self.name.substr(2);
            $package.^method_table{$name}.wrap(
                method (|) {
                    without $attr.get_value(self) {
                        $attr.set_value(self,
                            $attr.type.new(
                                table  => $table,
                                schema => self,
                            )
                        );
                    }
                    callsame;
                }
            );
        }
    }
}

