use Injector::Bind;
unit class Injector::Bind::Clone does Injector::Bind;

method bind-type {"clone"}
method get-obj   {$!obj .= clone}
