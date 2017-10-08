
use Getopt::Advance;
use App::snippet;

unit module App::snippet::Common;

sub commonOptionSet(Str $std, @compiler, $default-compiler) is export {
    my $optset = OptionSet.new;
    $optset.append(
        'h|help=b'    => 'print this help.',
        'v|version=b' => 'print program version.',
    );
    $optset.append(
        :radio,
        'S=b' => 'pass -S to compiler.',
        'E=b' => 'pass -E to compiler.',
    );
    $optset.append(
        :multi,
        'l|=a' => 'pass -l<l> to compiler, i.e. link library.',
        'L|=a' => 'add library search path.',
        'i|=a' => 'append include file.',
        'I|=a' => 'add include search path.',
        'D|=a' => 'pass -D<D> to compiler, i.e. add macro define.',
        'pp=a' => 'add preprocess command to the code.',
    );
    $optset.append(
        :radio,
        'astyle=s' 		=> 'set astyle style',
        'clang-format=s'=> 'set clang-format style',
        'uncrustify=s'  => 'set uncrustify style',
    );
    $optset.append(
        'f=a'    => 'pass -<f> to compiler.',
        'flag=a' => 'pass --<flag> to compiler.'
    );
    $optset.push(
        '|main=s',
        'chang main header.',
        value => 'int main(void)',
    );
    $optset.push(
        '|end=s',
        'change user input code terminator.',
        value => '@@CODEEND',
    );
    $optset.push(
        'w|=b',
        'pass -Wall -Wextra -Werror to compiler.',
    );
    $optset.push(
        '|std=s',
        'set language standard version.',
        :value($std)
    );
    $optset.push(
        'c|compiler=s',
        "set compiler, available compiler are < {@compiler} >.",
        value => $default-compiler,
    );
    $optset.append(
        'e=a' => 'add code to generator.',
        'r=b' => 'ignore -e, allow user input code from stdin.',
        'o=s' => 'set output file, or will be auto generate',
    );
    $optset.append(
        'p|=b' => 'print code read from -e or -r.',
        '|debug=b' => 'open debug mode.',
        'clean=b/' => 'don\'t remove output file.',
    );
    $optset.push(
        'quite=b',
        'disable quite mode, open stdout and stderr.',
    );
    $optset.push(
        'args=a',
        'pass arguments to executable binary.',
    );
    $optset;
}

sub formatCode($optset, @code) is export {
	my $formater = "";
	
	given $optset {
		when *.get('clang-format').has-value {
			$formater = 'clang-format';
		}
		when *.get('astyle').has-value {
			$formater = 'astyle';
		}
		when *.get('uncrustify').has-value {
			$formater = 'uncrustify';
		}
		default {
			return ();
		}
	}
	
	my $code = &simpleFormater($formater, $optset{$formater})(@code);

	return [ $code, ];
}
