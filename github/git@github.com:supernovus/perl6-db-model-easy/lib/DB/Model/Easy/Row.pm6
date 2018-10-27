## An abstract class foundation to use with your row classes.
## You MUST define a @.fields member, which maps database columns, 
## to object attributes.

use v6;

class DB::Model::Easy::Row {
  
  has $.model;                 ## The parent DB model object.
  has $.primary-key = 'id';    ## The default if not otherwise specified.
  has $.new-item    = False;   ## Is this a new item?

  method get-attrs {
    my %attrs;
    for self.^attributes -> $attr {
      my $name = $attr.name.subst(/^['$'|'@'|'%']'!'/, '');
      %attrs{$name} = $attr;
    }
    return %attrs;
  }

  ## Construct a Row
  method init (:$model!, :%data!, :$new-item?) {
    my %attrs = self.get-attrs;
    if ! %attrs.exists('fields') { die "no @.fields defined in Row class."; }
    $!model = $model;
    $!new-item = $new-item;
    for @.fields -> $field {
      my $attr_name;
      my $data_name;
      if $field ~~ Pair {
        $attr_name = $field.key;
        my $fieldopts = $field.value;
        if $fieldopts ~~ Str {
          $data_name = $fieldopts;
        }
        elsif $fieldopts ~~ Hash && $fieldopts.exists('column') {
          $data_name = $fieldopts<column>;
        }
        else {
          $data_name = $attr_name;
        }

        if $fieldopts ~~ Hash && $fieldopts.exists('primary') {
          $!primary-key = $data_name;
        }
      }
      elsif $field ~~ Str {
        $attr_name = $field;
        $data_name = $field;
      }
      else {
        die "unknown field type: {$field.WHAT}";
      }

      ## We only set the field if it exists as a column and an attribute.
      if %attrs.exists($attr_name) && %data.exists($data_name) {
        my $value = %data{$data_name};
        my $load = "on-load-$attr_name";
        if self.can($load) {
          $value = self."$load"($value);
        }
        %attrs{$attr_name}.set_value(self, $value);
      }
    }
    return self;
  }

  method new (:$model!, :%data!, :$new-item?) {
    self.bless(*).init(:$model, :%data, :$new-item);
  }

  ## Save the row to the database.
  ## This needs some extra work to allow it to create new records with
  ## manually specified primary keys rather than assuming the use of 
  ## auto-increment. Also, I want to implement a system similar to that
  ## which I use in Nano.php, where on an update, only fields that have
  ## been modified are included in the UPDATE statement.
  method save {
    my @fields; ## A list of fields to set.
    my @values; ## A list of values to set.
    my $insert = $.new-item;
    my $get-pk = False;
    my $primary-value;
    my %attrs = self.get-attrs;
    for @.fields -> $field {
      my $attr_name;
      my $data_name;
      my $fieldopts;
      if $field ~~ Pair {
        $attr_name = $field.key;
        $fieldopts = $field.value;
        if $fieldopts ~~ Str {
          $data_name = $fieldopts;
        }
        elsif $fieldopts ~~ Hash && $fieldopts.exists('column') {
          $data_name = $fieldopts<column>;
        }
        else {
          $data_name = $attr_name;
        }
      }
      elsif $field ~~ Str {
        $attr_name = $field;
        $data_name = $field;
      }
      else {
        die "unknown field type: {$field.WHAT}";
      }

      if %attrs.exists($attr_name) {
        my $value = %attrs{$attr_name}.get_value(self);
        my $save = "on-save-$attr_name";
        if self.can($save) {
          $value = self."$save"($value);
        }
        if $data_name eq $!primary-key {
          if $value.defined {
            $primary-value = $value;
            if ! $insert {
              next;
            }
          }
          else {
            if $fieldopts ~~ Hash && $fieldopts<auto> {
              $insert = True;
              $get-pk = True;
              next;
            }
            else {
              die "No primary key defined.";
            }
          }
        }
        if $value.defined {
          @fields.push: $data_name;
          @values.push: $value;
        }
        elsif $fieldopts ~~ Hash && $fieldopts<required> {
          die "Required field $attr_name not defined.";
        }
      }
    }
    my $fc = @fields.elems;
    my $vc = @values.elems;
    if ($fc == 0 || $vc == 0 || $fc != $vc) {
      die "Invalid data when attempting to save a DB Row.";
    }
    my $sql;
    if $insert {
      my $fc = @values.elems;
      my @q  = '?' xx $fc;
      my $fields = @fields.join(', ');
      my $values = @q.join(', ');
      $sql = "INSERT INTO {$.model.table} ($fields) VALUES ($values);";
    }
    else {
      $sql = "UPDATE {$.model.table} SET";
      my @set;
      for @fields -> $field {
        @set.push: " $field=?";
      }
      $sql ~= @set.join(',');
      $sql ~= " WHERE {$!primary-key} = $primary-value";
    }
    my $sth = $.model.prepare($sql);
    $sth.execute(|@values);

    $!new-item = False;

    if $insert {
      ## Find our new id. We know the other fields, so lets query from them.
      my $query = "SELECT {$!primary-key} FROM {$.model.table} WHERE";
      my @where;
      for @fields -> $field {
        @where.push: " $field = ?";
      }
      $query ~= @where.join(', ');
      $query ~= ' LIMIT 1';
      my $newitem = $.model.prepare($query);
      $newitem.execute(|@values);
      my $newrow = $newitem.fetchrow;
      if $newrow.defined && $newrow[0].defined {
        %attrs{$!primary-key}.set_value(self, $newrow[0]);
      }
    }   
  } ## end method save()

} ## end class DB::Model::Easy::Row

