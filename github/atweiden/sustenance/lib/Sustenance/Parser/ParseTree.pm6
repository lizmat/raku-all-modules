use v6;
use Sustenance::Types;

# class Food {{{

class Food
{
    has FoodName:D $.name is required;
    has ServingSize:D $.serving-size is required;
    has Calories:D $.calories is required;
    has Protein:D $.protein is required;
    has Carbohydrates:D $.carbohydrates is required;
    has Fat:D $.fat is required;

    submethod BUILD(
        Str:D :$!name!,
        Str:D :$!serving-size!,
        Numeric:D :$calories!,
        Numeric:D :$protein!,
        Numeric:D :$carbs!,
        Numeric:D :$fat!
        --> Nil
    )
    {
        $!calories = Rat($calories);
        $!protein = Rat($protein);
        $!carbohydrates = Rat($carbs);
        $!fat = Rat($fat);
    }

    method new(
        *%opts (
            Str:D :name($)! where .so,
            Str:D :serving-size($)! where .so,
            Numeric:D :calories($)! where * >= 0,
            Numeric:D :protein($)! where * >= 0,
            Numeric:D :carbs($)! where * >= 0,
            Numeric:D :fat($)! where * >= 0
        )
        --> Food:D
    )
    {
        self.bless(|%opts);
    }

    method hash(::?CLASS:D: --> Hash:D)
    {
        my %hash =
            :$.name,
            :$.serving-size,
            :$.calories,
            :$.protein,
            :$.carbohydrates,
            :$.fat;
    }
}

# end class Food }}}
# class Pantry {{{

class Pantry
{
    has Food:D @.food is required;

    method hash(::?CLASS:D: --> Hash:D)
    {
        my Hash:D @food = @.food.map({ .hash });
        my %hash = :@food;
    }
}

# end class Pantry }}}
# class Time {{{

class Time
{
    has UInt:D $.hour is required;
    has UInt:D $.minute is required;
    has Rat:D $.second is required;

    method hash(::?CLASS:D: --> Hash:D)
    {
        my %hash = :$!hour, :$!minute, :$!second;
    }
}

# generate C<Time> from C<hh:mm:ss> string
sub gen-time(Str:D $t --> Time:D) is export
{
    my (Str:D $h, Str:D $m, Str:D $s) = $t.split(':');
    my UInt:D $hour = Int($h);
    my UInt:D $minute = Int($m);
    my Rat:D $second = Rat($s);
    my Time $time .= new(:$hour, :$minute, :$second);
}

multi sub infix:<cmp>(
    Time:D $t1,
    Time:D $t2 where {
        .hour eqv $t1.hour
            && .minute eqv $t1.minute
                && .second eqv $t1.second
    }
    --> Order:D
) is export
{
    my Order:D $cmp = Same;
}

multi sub infix:<cmp>(
    Time:D $t1,
    Time:D $t2 where {
        .hour eqv $t1.hour
            && .minute eqv $t1.minute
    }
    --> Order:D
) is export
{
    my Order:D $cmp = $t1.second cmp $t2.second;
}

multi sub infix:<cmp>(
    Time:D $t1,
    Time:D $t2 where {
        .hour eqv $t1.hour
    }
    --> Order:D
) is export
{
    my Order:D $cmp = $t1.minute cmp $t2.minute;
}

multi sub infix:<cmp>(
    Time:D $t1,
    Time:D $t2
    --> Order:D
) is export
{
    my Order:D $cmp = $t1.hour cmp $t2.hour;
}

multi sub in-time-range(
    Time:D $time,
    Time:D $t1 where { $time cmp $t1 ~~ More|Same },
    Time:D $t2 where { $time cmp $t2 ~~ Less|Same }
    --> Bool:D
) is export
{
    my Bool:D $in-time-range = True;
}

multi sub in-time-range(
    Time:D $,
    Time:D $,
    Time:D $
    --> Bool:D
) is export
{
    my Bool:D $in-time-range = False;
}

# end class Time }}}
# class Portion {{{

class Portion
{
    has FoodName:D $.food is required;
    has Servings:D $.servings is required;

    submethod BUILD(
        FoodName:D :$!food!,
        Numeric:D :$servings!
        --> Nil
    )
    {
        $!servings = Rat($servings);
    }

    method new(
        *%opts (
            Str:D :food($)! where .so,
            Numeric:D :servings($)! where * >= 0
        )
        --> Portion:D
    )
    {
        self.bless(|%opts);
    }

    method hash(::?CLASS:D: --> Hash:D)
    {
        my %hash = :$.food, :$.servings;
    }
}

# end class Portion }}}
# class Meal {{{

class Meal
{
    has Date:D $.date is required;
    has Time:D $.time is required;
    has DateTime:D $.date-time is required;
    has Portion:D @.portion is required;

    submethod BUILD(
        Date:D :$!date!,
        :%time!,
        :@portion!
        --> Nil
    )
    {
        $!time = Time.new(|%time);
        my UInt:D ($year, $month, $day) = $!date.year, $!date.month, $!date.day;
        my %date = :$year, :$month, :$day;
        $!date-time = DateTime.new(|%date, |$!time.hash);
        @!portion = @portion.map(-> %portion { Portion.new(|%portion) });
    }

    method new(
        *%opts (
            Date:D :date($)!,
            :time(%)!,
            :portion(@)!
        )
        --> Meal:D
    )
    {
        self.bless(|%opts);
    }

    method hash(::?CLASS:D: --> Hash:D)
    {
        my %date = hash($.date);
        my %time = $.time.hash;
        my %date-time = hash($.date-time);
        my Hash:D @portion = @.portion.map({ .hash });
        my %hash = :%date, :%time, :%date-time, :@portion;
    }

    proto sub hash(|)
    {*}

    multi sub hash(DateTime:D $date-time --> Hash:D)
    {
        my (UInt:D $year, UInt:D $month, UInt:D $day) =
            $date-time.year, $date-time.month, $date-time.day;
        my (UInt:D $hour, UInt:D $minute, Rat:D $second) =
            $date-time.hour, $date-time.minute, $date-time.second;
        my %hash = :$year, :$month, :$day, :$hour, :$minute, :$second;
    }

    multi sub hash(Date:D $date --> Hash:D)
    {
        my (UInt:D $year, UInt:D $month, UInt:D $day) =
            $date.year, $date.month, $date.day;
        my %hash = :$year, :$month, :$day;
    }
}

# end class Meal }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
