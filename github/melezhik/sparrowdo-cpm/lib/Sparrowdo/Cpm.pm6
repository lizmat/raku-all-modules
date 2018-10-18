use v6;

unit module Sparrowdo::Cpm;

use Sparrowdo;


our sub tasks (%args) {

  # set_spl %( app-cpm-dev => 'https://github.com/melezhik/app-cpm.git');

  task_run  %(
    task => 'install App::cpm',
    plugin => 'cpan-package',
    parameters => %( 
      list        => 'App::cpm',
      http_proxy  => input_params('HttpProxy'),
      https_proxy => input_params('HttpsProxy'),
 
    )
  );

    task_run  %(
      task => 'install CPAN modules',
      plugin => 'app-cpm',
      parameters => %(
        list          => %args<list>,
        verbose       => %args<verbose>,
        user          => %args<user>,
        install-base  => %args<install-base>,
        http_proxy    => input_params('HttpProxy'),
        https_proxy   => input_params('HttpsProxy'),        
      );
    );
    
}

