use v6;
use String::CamelCase;
use Test;

subtest {

    is wordsplit('AD'),               'AD';
    is wordsplit('YearBBS'),          <Year BBS>;
    is wordsplit('ClientADClient'),   <Client AD Client>;
    is wordsplit('ad'),               <ad>;
    is wordsplit('year_bbs'),         <year bbs>;
    is wordsplit('client_ad_client'), <client ad client>;
    is wordsplit('ad_client'),        <ad client>;
    is wordsplit('ADClient-HogeFuga'), <AD Client Hoge Fuga>;

}, 'Test wordsplit';

done-testing;
