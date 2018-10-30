use Xoo::Model;
unit class X::Model::Multikey does Xoo::Model['multikey'];

has @.columns = [
  key1 => {
    type           => 'text',
    is-primary-key => True,
  },
  key2 => {
    type           => 'text',
    is-primary-key => True,
  },
  val  => {
    type => 'text',
  },
];
