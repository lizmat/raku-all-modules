no precompilation;
use Injector::Storage;
use Injector::Bind;
use Injector::Bind::Singleton;
use Injector::Bind::Instance;
use Injector::Bind::Clone;
use Injector::Bind::ObjectType;
use Injector::Injected::Attribute;
use Injector::Injected::Variable;

my %lifecycle = $*REPO
    .repo-chain
    .flatmap(*.loaded)
    .map({::(.Str)})
    .grep({
        .^name
        .starts-with("Injector::Bind::")
    })
    .map({.bind-type => $_})
;

my Injector::Storage $storage .= new;

sub undefined(Mu:U $type) { so / <!after ':'> ':U' $/ given $type.^name }

sub create-bind(
    $var,
    Str:D   :$name      = ""            ,
    Mu:U    :$type                      ,
    Capture :$capture   = \()           ,
    Str     :$lifecycle is copy;
) {
    if $lifecycle and not %lifecycle{$lifecycle}:exists {
        die "Unknow lifecycle '{$lifecycle}'"
    }
    $lifecycle //= undefined($type) ?? "object-type" !! "singleton";
    my Injector::Bind $bind = %lifecycle{$lifecycle}.new: :$type, :$name, :$capture;
    $storage.add: $bind;
    $var.prepare-inject: $bind
}

multi trait_mod:<is>(Attribute:D $attr, Bool :$injected!) is export {
    trait_mod:<is>($attr, :injected{});
}
multi trait_mod:<is>(Attribute:D $attr, Str :$injected!) is export {
    trait_mod:<is>($attr, :injected{:name($injected)});
}
multi trait_mod:<is>(
    Attribute:D $attr,
    :%injected! (
        Str:D   :$name       = ""  ,
        Capture :$capture    = \() ,
        Str     :$lifecycle
    )
) is export {
    $attr does Injector::Injected::Attribute;
    create-bind $attr, :type($attr.type), |%injected
}

multi trait_mod:<is>(Variable:D $v, Bool :$injected!) {
    trait_mod:<is>($v, :injected{})
}
multi trait_mod:<is>(Variable:D $v, Str :$injected!) {
    trait_mod:<is>($v, :injected{:name($injected)})
}
multi trait_mod:<is>(
    Variable:D $v,
    :%injected! (
        Str:D   :$name      = ""            ,
        Capture :$capture   = \()           ,
        Str     :$lifecycle
    )
) {
    $v does Injector::Injected::Variable;
    create-bind $v, :type($v.var.WHAT), |%injected
}

sub note-storage is export {note $storage.gist}

multi bind(Mu $obj, *%pars) is export { bind :$obj, |%pars }
multi bind(
    Mu      :$obj!                     ,
    Mu:U    :$to       = $obj.WHAT     ,
    Str     :$name     = ""            ,
    Capture :$capture                  ,
	Bool    :$override
) is export {
    die "Bind not found for name '$name' and type {$to.^name}"
		unless $storage.add-obj: $obj, :type($to), :$name, :$override;
}
