use Hiker::Route;

class MyApp::Controller::Basic does Hiker::Route {
  has $.path = '/';
  has $.template = 'basic.pt';
  has $.model = 'MyApp::Model::Basic';

  method handler($req, $res) {
    $res.headers<Content-Type> = 'text/plain';
    $res.data<what> = 'variables';
    True;
  }
}

class MyApp::Controller::Regex does Hiker::Route {
  has $.path = /.+/;
  has $.template = '404.pt';

  method handler($req, $res) {
    $res.headers<Content-Type> = 'text/plain';
  }
}
