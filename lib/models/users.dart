import 'package:drift/drift.dart';

@DataClassName('User')
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text().customConstraint('UNIQUE NOT NULL')();
  TextColumn get password => text()();
  DateTimeColumn get created_at => dateTime()();
  DateTimeColumn get updated_at => dateTime()();
}

