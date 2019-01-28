use v6;

use ModelDB::Column;
use ModelDB::Model;

=begin pod

=head1 DESCRIPTION

This is the ClassHOW for describe objects declared using the C<model> keyword. It provides metadata tying the local Perl representation of the table view to the underlying representation. This includes information about the primary key, indexes, and columns.

=head1 METHODS

=head2 method id-column

    has Str $.id-column is rw

=head2 method index

    has %.index;

=head2 method columns

    method columns($model --> Seq)

=head2 method column-names

    method column-names($mdoel --> Seq)

=head2 method compose

    method compose(Mu \type)

=end pod

class MetamodelX::DBModelHOW is Metamodel::ClassHOW {
    has Str $.id-column is rw;
    has %.index;

    # method add_attribute(Mu $obj, Mu $meta_attr) {
    #     nextwith($obj, $meta_attr but ModelDB::Column);
    # }
    method columns($model) {
        $model.^attributes.grep(ModelDB::Column)
    }

    method column-names($model) {
        $model.^attributes.grep(ModelDB::Column)».column-name;
    }

    method compose(Mu \type) {
        self.add_parent(type, ModelDB::Model);
        self.Metamodel::ClassHOW::compose(type);
    }
}

