use Hiker::Route;

class MyApp::Controller::Basic does Hiker::Route {
  has $.path = '/';
  has $.template = 'basic.mustache';
  has $.model = 'MyApp::Model::Basic';

  method handler($req, $res) {
    $res.headers<Content-Type> = 'text/plain';
  }
}

class MyApp::Controller::Regex does Hiker::Route {
  has $.path = /.*/;
  has $.template = '404.mustache';

  method handler($req, $res) {
    $res.headers<Content-Type> = 'text/plain';
  }
}
