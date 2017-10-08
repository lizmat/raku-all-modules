# path6-coverage

## path-coverage

low quality big power 

    $path-coverage
    Inbox should be LacunaCookbuk::Model::Inbox or declared with my keyword
    MsgTag should be LacunaCookbuk::Model::MsgTag or declared with my keyword
    Ship should be LacunaCookbuk::Model::Ship or declared with my keyword

Even though it is nothing illegal to have package diffrent than file name. It is may be bad practice.

## path-provides

Generates easy to copy paste provides section. It is required to delete last comma manually.

      "provides"    : {
        "LacunaCookbuk::Id" : "lib/LacunaCookbuk/Id.pm6",
        "LacunaCookbuk::Client" : "lib/LacunaCookbuk/Client.pm6",
        "LacunaCookbuk::Logic::Commander" : "lib/LacunaCookbuk/Logic/Commander.pm6",
        ...,
    },
