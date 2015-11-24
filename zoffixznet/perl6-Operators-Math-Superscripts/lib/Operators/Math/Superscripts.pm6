use v6;
unit package Operators::Math::Superscripts:version<1.001002>;

multi postfix:<⁰> ($n) is export { $n ** 0 }
multi postfix:<¹> ($n) is export { $n ** 1 }
multi postfix:<²> ($n) is export { $n ** 2 }
multi postfix:<³> ($n) is export { $n ** 3 }
multi postfix:<⁴> ($n) is export { $n ** 4 }
multi postfix:<⁵> ($n) is export { $n ** 5 }
multi postfix:<⁶> ($n) is export { $n ** 6 }
multi postfix:<⁷> ($n) is export { $n ** 7 }
multi postfix:<⁸> ($n) is export { $n ** 8 }
multi postfix:<⁹> ($n) is export { $n ** 9 }

multi postfix:<⁻¹> ($n) is export { $n ** -1 }
multi postfix:<⁻²> ($n) is export { $n ** -2 }
multi postfix:<⁻³> ($n) is export { $n ** -3 }
multi postfix:<⁻⁴> ($n) is export { $n ** -4 }
multi postfix:<⁻⁵> ($n) is export { $n ** -5 }
multi postfix:<⁻⁶> ($n) is export { $n ** -6 }
multi postfix:<⁻⁷> ($n) is export { $n ** -7 }
multi postfix:<⁻⁸> ($n) is export { $n ** -8 }
multi postfix:<⁻⁹> ($n) is export { $n ** -9 }
