import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../data/database_helper.dart';
import '../data/models.dart';
import 'checkout_screen.dart';

class PosCatalogScreen extends StatefulWidget {
  final UserModel currentUser;
  final VoidCallback? onProductChanged;

  const PosCatalogScreen({
    super.key,
    required this.currentUser,
    this.onProductChanged,
  });

  @override
  State<PosCatalogScreen> createState() => PosCatalogScreenState();
}

class PosCatalogScreenState extends State<PosCatalogScreen> {
  final List<String> _categories = ['Semua', 'Minuman', 'Makanan', 'Snack'];
  String _selectedCategory = 'Semua';
  final TextEditingController _searchController = TextEditingController();

  List<ProductModel> _products = [];
  final Map<int, int> _cart = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    final list = await DatabaseHelper.instance.getProducts(
      category: _selectedCategory,
      query: _searchController.text,
    );

    setState(() {
      _products = list;
      _isLoading = false;
    });
  }

  int get _cartItemCount {
    return _cart.values.fold(0, (sum, qty) => sum + qty);
  }

  int get _cartTotalPrice {
    int total = 0;
    for (final entry in _cart.entries) {
      final product = _products.firstWhere(
        (p) => p.id == entry.key,
        orElse: () => ProductModel(
          id: entry.key,
          name: '',
          category: '',
          price: 0,
          stock: 0,
        ),
      );
      total += product.price * entry.value;
    }
    return total;
  }

  void _addToCart(ProductModel product) {
    if (product.id == null || product.stock <= 0) return;

    final currentQty = _cart[product.id!] ?? 0;
    if (currentQty < product.stock) {
      setState(() {
        _cart[product.id!] = currentQty + 1;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stok produk telah mencapai batas'),
          duration: Duration(seconds: 1),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _removeFromCart(ProductModel product) {
    if (product.id == null) return;
    final currentQty = _cart[product.id!] ?? 0;
    if (currentQty <= 1) {
      setState(() {
        _cart.remove(product.id!);
      });
    } else {
      setState(() {
        _cart[product.id!] = currentQty - 1;
      });
    }
  }

  Future<void> _navigateToCheckout() async {
    if (_cart.isEmpty) return;

    final List<CartItemModel> cartItemList = [];
    for (final entry in _cart.entries) {
      final product = _products.firstWhere(
        (p) => p.id == entry.key,
        orElse: () => ProductModel(
          id: entry.key,
          name: 'Produk',
          category: '',
          price: 0,
          stock: 0,
        ),
      );
      cartItemList.add(CartItemModel(product: product, qty: entry.value));
    }

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          currentUser: widget.currentUser,
          initialCartItems: cartItemList,
        ),
      ),
    );

    if (result == true) {
      setState(() {
        _cart.clear();
      });
      await loadProducts();
      widget.onProductChanged?.call();
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'minuman':
        return Icons.coffee_rounded;
      case 'makanan':
        return Icons.restaurant_rounded;
      case 'snack':
        return Icons.lunch_dining_rounded;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              color: AppColors.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.currentUser.storeName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.currentUser.cashierName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primaryBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.wifi_off_rounded,
                              size: 14,
                              color: AppColors.primaryDark,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Offline POS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => loadProducts(),
                    decoration: InputDecoration(
                      hintText: 'Cari menu...',
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                loadProducts();
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (ctx, i) => const SizedBox(width: 8),
                      itemBuilder: (ctx, index) {
                        final cat = _categories[index];
                        final isSelected = cat == _selectedCategory;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedCategory = cat;
                            });
                            loadProducts();
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.card,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.border,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : _products.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.search_off_rounded,
                                size: 56,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Produk tidak ditemukan',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _products.length,
                          itemBuilder: (ctx, index) {
                            final product = _products[index];
                            final qty = _cart[product.id] ?? 0;
                            final isLowStock = product.stock <= 5;

                            return Container(
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.border),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: AppColors.background,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          _getCategoryIcon(product.category),
                                          size: 40,
                                          color: AppColors.primary.withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    product.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        CurrencyHelper.format(product.price),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isLowStock ? AppColors.dangerLight : AppColors.background,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: isLowStock ? AppColors.danger.withValues(alpha: 0.3) : AppColors.border,
                                          ),
                                        ),
                                        child: Text(
                                          'Stok: ${product.stock}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: isLowStock ? AppColors.danger : AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  if (qty == 0)
                                    SizedBox(
                                      width: double.infinity,
                                      height: 36,
                                      child: ElevatedButton(
                                        onPressed: product.stock > 0
                                            ? () => _addToCart(product)
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primaryLight,
                                          foregroundColor: AppColors.primaryDark,
                                          elevation: 0,
                                          padding: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            side: const BorderSide(color: AppColors.primaryBorder),
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.add, size: 16),
                                            SizedBox(width: 4),
                                            Text(
                                              'Tambah',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: AppColors.primaryBorder),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          InkWell(
                                            onTap: () => _removeFromCart(product),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              child: Icon(Icons.remove, size: 16, color: AppColors.primaryDark),
                                            ),
                                          ),
                                          Text(
                                            '$qty',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                              color: AppColors.primaryDark,
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () => _addToCart(product),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              child: Icon(Icons.add, size: 16, color: AppColors.primaryDark),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      bottomSheet: _cart.isNotEmpty
          ? Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.slateBar,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '$_cartItemCount Item • Total: ${CurrencyHelper.format(_cartTotalPrice)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _navigateToCheckout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Bayar',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
