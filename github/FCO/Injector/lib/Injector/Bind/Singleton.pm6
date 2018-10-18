use Injector::Bind;
unit class Injector::Bind::Singleton does Injector::Bind;

method bind-type {"singleton"}
method get-obj   {$!obj //= $.instantiate}
