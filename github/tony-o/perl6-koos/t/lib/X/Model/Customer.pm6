use Koos::Model;
unit class X::Model::Customer does Koos::Model['customer', 'X::Row::Customer'];

has @.columns = [
  id => {
    type           => 'integer',
    nullable       => False,
    is-primary-key => True,
    auto-increment => 1,
  },
  name => {
    type           => 'text',
  },
  contact => {
    type => 'text',
  },
  country => {
    type => 'text',
  },
];

has @.relations = [
  orders => { :has-many, :model<Order>, :relate(id => 'customer_id') },
  open_orders => { :has-many, :model<Order>, :relate(id => 'customer_id', '+status' => 'open') },
  completed_orders => { :has-many, :model<Order>, :relate(id => 'customer_id', '+status' => 'closed') },
];
