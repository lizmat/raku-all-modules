unit module Koos::Test;
use DBIish;

sub configure-sqlite is export {
  #hello table + data:
  my $db = DBIish.connect('SQLite', :database<test.sqlite3>);
  $db.do(q:to/XYZ/);
  DROP TABLE IF EXISTS hello;
  XYZ

  $db.do(q:to/XYZ/);
  CREATE TABLE hello (
    id  INTEGER PRIMARY KEY AUTOINCREMENT,
    txt TEXT
  );
  XYZ

  my $sth = $db.prepare(q:to/XYZ/);
    INSERT INTO hello (txt) VALUES (?);
  XYZ
  $sth.execute('hello world');
  for 0..20 {
    $sth.execute(('a'..'z').roll(10).join);
  }
  $sth.finish;



  #customer + order tables
  $db.do(q:to/XYZ/);
  DROP TABLE IF EXISTS customer;
  XYZ
  $db.do(q:to/XYZ/);
  CREATE TABLE customer (
    id  INTEGER PRIMARY KEY AUTOINCREMENT,
    name text,
    contact text,
    country text
  );
  XYZ
  $db.do(q:to/XYZ/);
  DROP TABLE IF EXISTS `order`;
  XYZ
  $db.do(q:to/XYZ/);
  CREATE TABLE `order` (
    id  INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER,
    status TEXT,
    order_date TIMESTAMP
  );
  XYZ

  $db.do(q:to/XYZ/);
  DROP TABLE IF EXISTS `multikey`;
  XYZ
  $db.do(q:to/XYZ/);
  CREATE TABLE `multikey` (
    key1 text,
    key2 text,
    val  text,
    PRIMARY KEY (`key1`, `key2`)
  );
  XYZ

  $db.dispose;
}
