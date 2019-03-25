use DB::Xoos::Model;
unit class X::Model::Multikey does DB::Xoos::Model['multikey'];

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
