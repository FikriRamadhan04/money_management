import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

// 1. Tabel Kategori
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  IntColumn get type => integer()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// 2. Tabel Transaksi
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get categoryId =>
      integer().references(Categories, #id)(); // Foreign Key
  IntColumn get amount => integer()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Categories, Transactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // --- CRUD CATEGORY ---

  Future<List<Category>> getAllCategory(int type) async {
    return await (select(
      categories,
    )..where((tbl) => tbl.type.equals(type))).get();
  }

  Future<int> updateCategoryRepo(int id, String name) async {
    return await (update(categories)..where((tbl) => tbl.id.equals(id))).write(
      CategoriesCompanion(name: Value(name)),
    );
  }

  Future<int> deleteCategoryRepo(int id) async {
    return await (delete(categories)..where((tbl) => tbl.id.equals(id))).go();
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'my_money_db');
  }
}
