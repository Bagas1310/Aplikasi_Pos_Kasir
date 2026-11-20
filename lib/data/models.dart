class UserModel {
  final int? id;
  final String username;
  final String password;
  final String storeName;
  final String cashierName;

  UserModel({
    this.id,
    required this.username,
    required this.password,
    required this.storeName,
    required this.cashierName,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'username': username,
      'password': password,
      'store_name': storeName,
      'cashier_name': cashierName,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      username: map['username'] as String,
      password: map['password'] as String,
      storeName: map['store_name'] as String,
      cashierName: map['cashier_name'] as String,
    );
  }
}

class ProductModel {
  final int? id;
  final String name;
  final String category;
  final int price;
  final int stock;

  ProductModel({
    this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      category: map['category'] as String,
      price: map['price'] as int,
      stock: map['stock'] as int,
    );
  }

  ProductModel copyWith({
    int? id,
    String? name,
    String? category,
    int? price,
    int? stock,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      stock: stock ?? this.stock,
    );
  }
}

class CartItemModel {
  final ProductModel product;
  int qty;

  CartItemModel({
    required this.product,
    this.qty = 1,
  });

  int get subtotal => product.price * qty;
}

class TransactionModel {
  final int? id;
  final int userId;
  final int totalAmount;
  final int payAmount;
  final int changeAmount;
  final String createdAt;
  final List<TransactionItemModel>? items;

  TransactionModel({
    this.id,
    required this.userId,
    required this.totalAmount,
    required this.payAmount,
    required this.changeAmount,
    required this.createdAt,
    this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'total_amount': totalAmount,
      'pay_amount': payAmount,
      'change_amount': changeAmount,
      'created_at': createdAt,
    };
  }

  factory TransactionModel.fromMap(
    Map<String, dynamic> map, {
    List<TransactionItemModel>? items,
  }) {
    return TransactionModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      totalAmount: map['total_amount'] as int,
      payAmount: map['pay_amount'] as int,
      changeAmount: map['change_amount'] as int,
      createdAt: map['created_at'] as String,
      items: items,
    );
  }
}

class TransactionItemModel {
  final int? id;
  final int transactionId;
  final int productId;
  final String? productName;
  final int? productPrice;
  final int qty;
  final int subtotal;

  TransactionItemModel({
    this.id,
    required this.transactionId,
    required this.productId,
    this.productName,
    this.productPrice,
    required this.qty,
    required this.subtotal,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'transaction_id': transactionId,
      'product_id': productId,
      'qty': qty,
      'subtotal': subtotal,
    };
  }

  factory TransactionItemModel.fromMap(Map<String, dynamic> map) {
    return TransactionItemModel(
      id: map['id'] as int?,
      transactionId: map['transaction_id'] as int,
      productId: map['product_id'] as int,
      productName: map['product_name'] as String?,
      productPrice: map['product_price'] as int?,
      qty: map['qty'] as int,
      subtotal: map['subtotal'] as int,
    );
  }
}
