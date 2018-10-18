use Injector::Bind;
unit class Injector::Bind::Instance does Injector::Bind;

method bind-type {"instance"}
method get-obj   {$.instantiate}
