use v6;
use Base64;

unit module Eav;

#our sub products-attribute-set() {
#    attributeSet => %{
#        attributeSetName => 'DeleteMe',
#        entityTypeId     => 4,
#        sortOrder        => 0
#    },
#    skeletonId => 4
#}
#
our sub eav-attribute-sets-update() {
    attributeSet => %{
        attributeSetName => 'DeleteMeModified',
        entityTypeId     => 4,
        sortOrder        => 0
    }
}

our sub eav-attribute-sets {
    entityTypeCode => 'catalog_product',
    attributeSet   => %{
        attributeSetName => 'DeleteMe',
        entityTypeId     => 4,
        sortOrder        => 0
    },
    skeletonId => 4
}

