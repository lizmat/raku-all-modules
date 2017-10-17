use v6;
#`(
Copyright © Moritz Lenz moritz.lenz@gmail.com

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
use Grammar::ErrorReporting;

grammar MyTest does Grammar::ErrorReporting {
    token TOP {
        '(' ~ ')' \d+
    }
}

throws-like { MyTest.parse('(1') }, X::Grammar::ParseError,
    error-position => 2,
    goal => "')'",
    line => 1,
    target => '(1',
    message => /'Cannot parse'/,
    ;

grammar MyTest2 does Grammar::ErrorReporting {
    token TOP {
        .. \n . <.error('OH NOEZ')>
    }
}

throws-like { MyTest2.parse("ab\ncdef") }, X::Grammar::ParseError,
    error-position => 4,
    goal => !*.defined,
    line => 2,
    msg => 'OH NOEZ',
    ;


done-testing;
