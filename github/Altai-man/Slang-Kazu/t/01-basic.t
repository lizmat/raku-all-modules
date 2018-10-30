use v6;
#`(
Copyright ©  

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

)
use Test;
use Slang::Kazu;

is 一, 1, 'Literal 1';
is 九, 9, 'Literal 9';

is 十, 10, 'Literal 10';
is 十二, 12, 'Literal 12';
is 二十, 20, 'Literal 20';
is 二十五, 25, 'Literal 12';
is 九十六, 96, 'Literal 96';

is 百, 100, 'Literal 100';
is 百二, 102, 'Literal 102';
is 百五十一, 151, 'Literal 151';
is 二百, 200, 'Literal 200';
is 二百十, 210, 'Literal 210';

is 千, 1000, 'Literal 1000';
is 二千一 , 2001, 'Literal 2001';
is 一千九百二十三, 1923, 'Literal 1923';
is 二千十七, 2017, 'Literal 2017';
is 二千四十八 , 2048, 'Literal 2048';
is 二千百十一 , 2111, 'Literal 2111';
is 二千百一 , 2101, 'Literal 2101';

is 万, 10000, 'Literal 10000';
is 二万, 20000, 'Literal 20000';
is 一万百, 10100, 'Literal 10100';
is 九万七百九, 90709, 'Literal 90709';

# Single regex is exported.
is ~('一' ~~ /<single-kazu>/), "一";

# Grammar is exported
isnt Kazu.parse('一千九百二十三'), Any;

done-testing;
