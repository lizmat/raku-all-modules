use v6;

unit module Sparrowdo::Core::DSL::CPAN::Package;

use Sparrowdo;


multi sub cpan-package-install ( @list, %opts ) is export {

    my %params = Hash.new;

    %params<list> = join ' ', @list;

    %params<install-base> = %opts<install-base> if %opts<install-base>:exists; 
    %params<user> = %opts<user> if %opts<user>:exists; 
    %params<http_proxy> = input_params('HttpProxy') if input_params('HttpProxy').defined; 
    %params<https_proxy> = input_params('HttpsProxy') if input_params('HttpsProxy').defined; 

    task_run  %(
      task => "install cpan packages: " ~ (join ' ', @list),
      plugin => 'cpan-package',
      parameters => %params 
    );

}

multi sub cpan-package ( @list, %opts ) is export { cpan-package-install @list, %opts  } # alias

multi sub cpan-package-install ( $list, %opts ) is export {

    my %params = Hash.new;

    %params<list> = $list;

    %params<install-base> = %opts<install-base> if %opts<install-base>:exists; 
    %params<user> = %opts<user> if %opts<user>:exists; 
    %params<http_proxy> = input_params('HttpProxy') if input_params('HttpProxy').defined; 
    %params<https_proxy> = input_params('HttpsProxy') if input_params('HttpsProxy').defined; 

    task_run  %(
      task => "install cpan packages: $list",
      plugin => 'cpan-package',
      parameters => %params 
    );

}

multi sub cpan-package ( $list, %opts ) is export { cpan-package-install  $list, %opts  } # alias
 
