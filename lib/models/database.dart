import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  IntColumn get type => integer()(); // 1 = Pendapatan, 2 = Pengeluaran
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get categoryId => integer().references(Categories, #id)();
  IntColumn get amount => integer()();
  DateTimeColumn get date => dateTime()(); // Nama kolom: date
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class TransactionWithCategory {
  final Transaction transaction;
  final Category category;
  TransactionWithCategory(this.transaction, this.category);
}

@DriftDatabase(tables: [Categories, Transactions])
class AppDatabase extends _$AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // --- CRUD CATEGORY ---
  Future<List<Category>> getAllCategory(int type) async {
    return await (select(
      categories,
    )..where((tbl) => tbl.type.equals(type))).get();
  }

  // --- TRANSACTION ---
  Stream<List<TransactionWithCategory>> getTransactionByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final query = select(transactions).join([
      innerJoin(categories, categories.id.equalsExp(transactions.categoryId)),
    ])..where(transactions.date.isBetweenValues(startOfDay, endOfDay));

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithCategory(
          row.readTable(transactions),
          row.readTable(categories),
        );
      }).toList();
    });
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'my_money_db');
  }
}
