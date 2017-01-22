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

for $usersearch.next -> $user { ... }

"User count: {$usersearch.count}".say;
```

###cr[U]d

```perl6
for $usersearch.next -> $user { 
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
# SELECT * FROM table WHERE 
#      (username = 'user1' or username = 'user2') 
#   OR (joindate > ?)
#   OR (rating = 'lame' and decimal < 50);
# with ? = (time - 5000) 

$orm.search('table', {
  -raw => ' strftime(\'%Y%m%d\', joindate) = strftime(\'%Y%m%d\', \'now\') ' 
});
# SELECT * FROM table WHERE strftime('%Y%m%d', joindate) = strftime('%Y%m%d', 'now'); 
```

###Joining Tables

```perl6
my $orm = qw<initialize your orm as above>;

#initialize some data
my $user = $orm.create('user');
$user.set('username', 'user1');
$user.set('password', 'user1-pass!');
$user.set('source', 'facebook');
$user.save; #$user.id is now an actual value, yay

my $profile = $orm.create('profile');
$profile.set('name', 'tim tow dee');
$profile.set('uid', $user.id);
$profile.set('source', 'facebook');
$profile.save;

#here we'll query them as one unit
my @users = $orm.search('user', { #user table will be our main table
  '-join' => {
    '-table' => 'profile', #join the profile table to user
    '-type'  => 'inner',   #user an inner join, the default is 'left outer'
    '-on'    => {
      '-and' => {
        'uid' => 'DBORMID', #these are autoquoted where the key from the pair is quoted for the joining table and the value is quoted for the main table
                            #you can also use things like a pair here, ie: ('-lt' => 'some other column in user table')
        'source' => 'source', #becomes "profile"."source" = "user"."source" in the SQL 
      }
    }
  },
  '"profile"."name"' => ('-ne' => ''), #normal 'where' parameters, notice that quoting the table and field name for the joined table *may* be necessary
}).all;

for my $user (@users) {
  $user.get(qw<any field from either the profile or user table here>);
}
```

The way that the internals work on the `-on` key value pairs is that the `.key` is from the table to be joined, and the `.value` for the parent table. So, the pair of `'uid' => 'DBORMID'` translates to `profile.uid` and `user.DBORMID`, respectively.  You can avoid this behavior by providing the table names as part of the field, IE `'profile.uid' => 'user.DBORMID'`

Caveats:

* There isn't a mechanism to use a raw value in the `'-on'` section of the join.  
* There is also only one join possible right now.  

Both of those features are being worked on.



##Bugs, comments, feature requests? 

Yes, there are probably bugs.  Put 'em in the github bugs area or catch me in #perl6 on freenode.

##License

Whatever, it's free.  Do what you want with it.

######Other crap

[@tony-o](https://www.gittip.com/tony-o/)

