import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'kasirkita.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        store_name TEXT NOT NULL,
        cashier_name TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        price INTEGER NOT NULL,
        stock INTEGER NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        total_amount INTEGER NOT NULL,
        pay_amount INTEGER NOT NULL,
        change_amount INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      );
    ''');

    await db.execute('''
      CREATE TABLE transaction_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        qty INTEGER NOT NULL,
        subtotal INTEGER NOT NULL,
        FOREIGN KEY (transaction_id) REFERENCES transactions (id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products (id)
      );
    ''');

    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    await db.insert('users', {
      'username': 'budi',
      'password': '123',
      'store_name': 'Kedai Kopi Nusantara',
      'cashier_name': 'Kasir: Budi',
    });

    final defaultProducts = [
      {'name': 'Kopi Susu Gula Aren', 'category': 'Minuman', 'price': 15000, 'stock': 24},
      {'name': 'Americano Dingin', 'category': 'Minuman', 'price': 18000, 'stock': 30},
      {'name': 'Caramel Macchiato', 'category': 'Minuman', 'price': 22000, 'stock': 15},
      {'name': 'Matcha Latte', 'category': 'Minuman', 'price': 20000, 'stock': 18},
      {'name': 'Teh Tarik Hangat', 'category': 'Minuman', 'price': 12000, 'stock': 20},
      {'name': 'Croissant Butter', 'category': 'Makanan', 'price': 18000, 'stock': 12},
      {'name': 'Nasi Goreng Spesial', 'category': 'Makanan', 'price': 25000, 'stock': 20},
      {'name': 'Mie Goreng Jawa', 'category': 'Makanan', 'price': 22000, 'stock': 16},
      {'name': 'Kentang Goreng Keju', 'category': 'Snack', 'price': 15000, 'stock': 25},
      {'name': 'Roti Bakar Cokelat', 'category': 'Snack', 'price': 14000, 'stock': 22},
      {'name': 'Cireng Krispi', 'category': 'Snack', 'price': 12000, 'stock': 3},
    ];

    for (final product in defaultProducts) {
      await db.insert('products', product);
    }
  }

  Future<UserModel?> login(String username, String password) async {
    final db = await database;
    final res = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username.trim(), password.trim()],
      limit: 1,
    );

    if (res.isNotEmpty) {
      return UserModel.fromMap(res.first);
    }
    return null;
  }

  Future<int> register(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<List<ProductModel>> getProducts({
    String? category,
    String? query,
    bool? lowStockOnly,
  }) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (category != null && category.isNotEmpty && category != 'Semua') {
      whereClause += 'category = ?';
      whereArgs.add(category);
    }

    if (query != null && query.trim().isNotEmpty) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'name LIKE ?';
      whereArgs.add('%${query.trim()}%');
    }

    if (lowStockOnly == true) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'stock <= ?';
      whereArgs.add(5);
    }

    final res = await db.query(
      'products',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'id ASC',
    );

    return res.map((e) => ProductModel.fromMap(e)).toList();
  }

  Future<int> insertProduct(ProductModel product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<int> updateProduct(ProductModel product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> createTransaction({
    required int userId,
    required int totalAmount,
    required int payAmount,
    required int changeAmount,
    required List<CartItemModel> items,
  }) async {
    final db = await database;
    final nowIso = DateTime.now().toIso8601String();

    return await db.transaction<int>((txn) async {
      final transactionId = await txn.insert('transactions', {
        'user_id': userId,
        'total_amount': totalAmount,
        'pay_amount': payAmount,
        'change_amount': changeAmount,
        'created_at': nowIso,
      });

      for (final item in items) {
        if (item.product.id == null) continue;

        await txn.insert('transaction_items', {
          'transaction_id': transactionId,
          'product_id': item.product.id,
          'qty': item.qty,
          'subtotal': item.subtotal,
        });

        await txn.rawUpdate(
          'UPDATE products SET stock = stock - ? WHERE id = ?',
          [item.qty, item.product.id],
        );
      }

      return transactionId;
    });
  }

  Future<List<TransactionModel>> getTransactions({int? userId}) async {
    final db = await database;
    final res = await db.query(
      'transactions',
      where: userId != null ? 'user_id = ?' : null,
      whereArgs: userId != null ? [userId] : null,
      orderBy: 'id DESC',
    );

    List<TransactionModel> transactions = [];
    for (final row in res) {
      final tId = row['id'] as int;
      final items = await getTransactionItems(tId);
      transactions.add(TransactionModel.fromMap(row, items: items));
    }
    return transactions;
  }

  Future<List<TransactionItemModel>> getTransactionItems(int transactionId) async {
    final db = await database;
    final res = await db.rawQuery('''
      SELECT ti.*, p.name as product_name, p.price as product_price
      FROM transaction_items ti
      JOIN products p ON ti.product_id = p.id
      WHERE ti.transaction_id = ?
    ''', [transactionId]);

    return res.map((e) => TransactionItemModel.fromMap(e)).toList();
  }

  Future<Map<String, dynamic>> getSalesSummary() async {
    final db = await database;
    final totalQuery = await db.rawQuery('''
      SELECT 
        COALESCE(SUM(total_amount), 0) as total_omzet,
        COUNT(id) as total_transaksi
      FROM transactions
    ''');

    final omzet = totalQuery.first['total_omzet'] as num? ?? 0;
    final count = totalQuery.first['total_transaksi'] as int? ?? 0;

    return {
      'total_omzet': omzet.toInt(),
      'total_transaksi': count,
    };
  }
}
