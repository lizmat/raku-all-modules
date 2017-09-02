use v6;
use Test;
plan 2;

use Net::HTTP::Request;
use Net::HTTP::URL;

subtest {
   await (^5).map: -> $tid {
      start {
         for ^10 -> $index {
            my $url    = Net::HTTP::URL.new("http://www.google.com/$tid/$index/");
            my %header = :Connection<keep-alive>, :User-Agent<perl6-net-http>, :Tid($tid), :Index($index);
            my $req    = Net::HTTP::Request.new: :$url, :method<GET>, :%header;

            like ~$req, /GET\s\/$tid\/$index\/.+Tid\:\s$tid.+Index\:\s$index/, "tid:$tid index:$index";
         }
      }
   }
}, 'https://github.com/ugexe/Perl6-Net--HTTP/issues/8 - thread interpolation while stringifying requests via "{...}"';

subtest {
   my $request = Net::HTTP::Request.new(
      :url(Net::HTTP::URL.new("http://www.google.com/")),
      :method<GET>,
      :body("x" x (2 ** 16)),
      :header({}),
   );

   lives-ok { $request.raw().sink }
}, 'https://github.com/ugexe/Perl6-Net--HTTP/issues/11 - Net::HTTP::Request::raw explodes on large (> 64kb) requests';

done-testing;
