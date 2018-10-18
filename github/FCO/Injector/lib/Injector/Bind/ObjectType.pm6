use Injector::Bind;
unit class Injector::Bind::ObjectType does Injector::Bind;

method bind-type {"object-type"}
method get-obj   {$!obj.WHAT}
