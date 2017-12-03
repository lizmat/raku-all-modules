# Terminal::Spinners
Simple spinners and progress bars for Perl 6.

## Install
```bash
zef install Terminal::Spinners
```

## Usage
Classic Spinner ```|/-\```
```perl
my $classic = Spinner.new;   # defaults to the classic spinner
my $promise = start sleep 2; # promise of your long running process
until $promise.status {
    $classic.next;           # prints the next spinner frame
}
```

Hash Progress Bar ```[##########..........]50.00%```
```perl
my $hash-bar = Bar.new;                # defaults to the hash progress bar
$hash-bar.show: 0e0;                   # print a 0% progress bar
for 1e0 .. 3000e0 {
    my $percent = $_ * 100e0 / 3000e0; # calculate a floating point percentage
    sleep 0.0002;                      # do iterative work here
    $hash-bar.show: $percent;          # print the progress bar and percent
}
```
## License
Terminal::Spinners is released under the MIT License.
