# DB::Model::Easy

## Introduction

A simple set of base classes for building easy database models.

## Example Model Library

```perl
    use DB::Model::Easy;
    class MyModel::User is DB::Model::Easy::Row {
      has $.id;
      has $.name is rw;
      has $.age  is rw;
      has $.job  is rw;

      ## Rules for mapping database columns to object attributes.
      ## 'id' is a primary key, auto-generated. The column for 'job' is called 'position'.
      has @.fields = 'id' => {:primary, :auto}, 'name', 'age', 'job' => 'position';
    }
    class MyModel is DB::Model::Easy {
      has $.rowclass = MyModel::User;
      method getUserById ($id) {
        self.get.with(:id($id)).row;
      }
    }

    my $model = MyModel.new(:$table, driver => $db<driver>, opts => $db<opts>);
    my $user = $model.getUserById($uid);

    ## Let's get a list of other users with the same job as our own.
    my $others = $model.get.with(:job($user.job)).and.not(:id($user.id)).rows;

    ...
```

## Notes

This was originally a part of 
[WWW::App::MVC](https://github.com/supernovus/perl6-www-app-mvc/), 
but I've split it off as its own library for those who may want to use it 
separately.

## TODO

 * Add tests.

## Author

Timothy Totten. Catch me on #perl6 as 'supernovus'.

## License

Artistic License 2.0

