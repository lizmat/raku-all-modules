unit module Xoos::Test;
use DB::SQLite;

END {
  try { 'test.sqlite3'.IO.unlink; };
}

sub get-sqlite is export {
  my $db = DB::SQLite.new(:filename<test.sqlite3>);
  $db.connect;
  $db;
}

sub configure-sqlite is export {
  #hello table + data:
  my $db = DB::SQLite.new(:filename<test.sqlite3>);
  $db.connect;

  $db.execute(q:to/XYZ/);
  DROP TABLE IF EXISTS hello;
  XYZ

  $db.execute(q:to/XYZ/);
  CREATE TABLE hello (
    id  INTEGER PRIMARY KEY AUTOINCREMENT,
    txt TEXT
  );
  XYZ

  my $sth = $db.db.prepare(q:to/XYZ/);
    INSERT INTO hello (txt) VALUES (?);
  XYZ
  $sth.execute('hello world');
  for 0..20 {
    $sth.execute(('a'..'z').roll(10).join);
  }
  $sth.finish;



  #customer + order tables
  $db.execute(q:to/XYZ/);
  DROP TABLE IF EXISTS customer;
  XYZ
  $db.execute(q:to/XYZ/);
  CREATE TABLE customer (
    id  INTEGER PRIMARY KEY AUTOINCREMENT,
    name text,
    contact text,
    country text
  );
  XYZ
  $db.execute(q:to/XYZ/);
  DROP TABLE IF EXISTS `order`;
  XYZ
  $db.execute(q:to/XYZ/);
  CREATE TABLE `order` (
    id  INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER,
    status TEXT,
    order_date TIMESTAMP
  );
  XYZ

  $db.execute(q:to/XYZ/);
  DROP TABLE IF EXISTS `multikey`;
  XYZ
  $db.execute(q:to/XYZ/);
  CREATE TABLE `multikey` (
    key1 text,
    key2 text,
    val  text,
    PRIMARY KEY (`key1`, `key2`)
  );
  XYZ

}
