#Quicky ORM

What is it?  It's a lazy ORM that I threw together because I end up prototyping a lot of things before building them out with proper schemas.  So, it's meant for lazy column typing and minimal code from the user side.

##How it works

The DB::ORM::Quicky::Model (you'll never have to instantiate this object) degrades column types in the order of Int, Num, Str to whatever an equivalent type is in the selected DB.  Essentially to `integer`, `float`, `varchar` columns.  `varchar` type columns auto resize if the width isn't great enough to hold the requested value.

The model also tracks what columns were changed and *only* updates those fields.


##Example - CRUD (Create Read Update Delete)

For the examples, I'll use SQLite and keep comments to a minimum.

###Depends
[DBIish](https://github.com/perl6/DBIish/)

###[C]rud

```perl6
use DB::ORM::Quicky;

my $orm = DB::ORM::Quicky.new;

$orm.connect(
  driver  => 'SQLite', 
  options => %( 
    database => 'local.sqlite3',
  )
);

#the `users` table does NOT exist yet.
my $newuser = $orm.create('users'); #this is creating a new 'row', not necessarily a new table 

#the `users` table exists with no columns or just a `DBORMID` 
#  column (only in SQLite) yet.

$newuser.set({
  username => 'tony-o',
  password => 'top secret',
  age      => 6,
  rating   => 'lame',
  decimal  => 6.66,
});

$newuser.save;  #at this point all required columns are checked or created
```

###c[R]ud

```perl6
my $usersearch = $orm.search('users', { rating => 'lame' });

my @users = $usersearch; #array of all users with 'lame' rating

for $usersearch->next -> $user { ... }

"User count: {$usersearch.count}".say;
```

###cr[U]d

```perl6
for $usersearch->next -> $user { 
  $user.set({ 
    joindate => time, #decided we want to track when a user signed up
  });
  $user.save;
}
```

###cru[D]

```perl6
$orm.search('users', { }).delete; #delete all of our users
```

##More "Advanced" Querying

The ORM can take a lot of different types of values.  The usual example by code follows:

```perl6
$orm.search('table', {
  '-or' => [ #-and is also valid
    { 
      username => ['user1', 'user2']
    },
    {
      joindate => ('-gt' => time - 5000), # -gt and -lt both work
    },
    '-and' => [
      rating  => 'lame',
      decimal => ('-lt' => 50),
    ]
  ]
});
# SELECT * FROM table WHERE (username = 'user1' or username = 'user2') OR (joindate > ?);
# with ? = (time - 5000) 

$orm.search('table', {
  -raw => ' dateformat(joindate, \'YYYYMMDD\') = today(\'YYYYMMDD\'); ' 
  # have no idea if this is valid in sqlite
});
# SELECT * FROM table WHERE dateformat(joindate, 'YYYYMMDD') = today('YYYYMMDD'); 
```

##Bugs, comments, feature requests? 

Yes, there are probably bugs.  Put 'em in the github bugs area or catch me in #perl6 on freenode.

##License

Whatever, it's free.  Do what you want with it.

######Other crap

[@tony-o](https://www.gittip.com/tony-o/)

