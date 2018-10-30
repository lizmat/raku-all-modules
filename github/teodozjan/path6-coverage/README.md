# path6-coverage

Coverage does not support windows for now but can be easily fixed

## path-coverage

This tool helps to enforce java style rule where public class must be in same directory structure as package being declared.

    $ path-coverage lib/
    Inbox should be LacunaCookbuk::Model::Inbox or declared with my keyword
    MsgTag should be LacunaCookbuk::Model::MsgTag or declared with my keyword
    Ship should be LacunaCookbuk::Model::Ship or declared with my keyword


## path-provides

Generates easy to copy paste provides section. It is required to delete last comma manually.

      "provides"    : {
        "LacunaCookbuk::Id" : "lib/LacunaCookbuk/Id.pm6",
        "LacunaCookbuk::Client" : "lib/LacunaCookbuk/Client.pm6",
        "LacunaCookbuk::Logic::Commander" : "lib/LacunaCookbuk/Logic/Commander.pm6",
        ...,
    },
