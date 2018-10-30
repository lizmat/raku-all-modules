use Hiker::Model;

class MyApp::Model::Basic does Hiker::Model {
  method bind($req, $res) {
    $res.data<planet> = qw<WOT?>;
  }
}
