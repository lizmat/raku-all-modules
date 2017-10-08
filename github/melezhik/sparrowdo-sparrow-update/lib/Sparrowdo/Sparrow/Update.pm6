use v6;

unit module Sparrowdo::Sparrow::Update;

use Sparrowdo;

our sub tasks (%args) {

  task_run  %(
    task => 'install git',
    plugin => 'package-generic',
    parameters => %( list => 'git' )
  );

  task_run  %(
    task => 'update outthentic',
    plugin => 'cpan-package',
    parameters => %( 
      list => 'https://github.com/melezhik/outthentic.git',
      http_proxy => input_params('HttpProxy'), 
      https_proxy => input_params('HttpsProxy'), 
    )
  );

  task_run  %(
    task => 'update sparrow',
    plugin => 'cpan-package',
    parameters => %( 

      list => 'https://github.com/melezhik/sparrow.git',
      http_proxy => input_params('HttpProxy'), 
      https_proxy => input_params('HttpsProxy'), 

    )
  );


}

