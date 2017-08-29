use v6;
use Test;
plan 1;

use Net::HTTP::Request;
use Net::HTTP::URL;

subtest {
   await (^5).map: -> $tid {
      start {
         for ^20 -> $index {
            my $url = Net::HTTP::URL.new("http://www.google.com/$tid/$index/");
            my %header = :Connection<keep-alive>, :User-Agent<perl6-net-http>, :Tid($tid), :Index($index);
            my $req = Net::HTTP::Request.new: :$url, :method<GET>, :%header;

            like ~$req, /GET\s\/$tid\/$index\//;
            like ~$req, /Tid\:\s$tid/;
            like ~$req, /Index\:\s$index/;
         }
      }
   }
}, 'https://github.com/ugexe/Perl6-Net--HTTP/issues/8 - thread interpolation while stringifying requests via "{...}"';

done-testing;