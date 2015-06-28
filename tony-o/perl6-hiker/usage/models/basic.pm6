use Hiker::Model;

class MyApp::Model::Basic does Hiker::Model {
  method bind($req, $res) {
    $res.data<model-says> = qw<WOT?>;
  }
}
