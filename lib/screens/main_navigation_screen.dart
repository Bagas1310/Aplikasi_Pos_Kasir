import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../data/models.dart';
import 'pos_catalog_screen.dart';
import 'product_management_screen.dart';
import 'sales_report_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final UserModel currentUser;

  const MainNavigationScreen({
    super.key,
    required this.currentUser,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final GlobalKey<PosCatalogScreenState> _posKey = GlobalKey<PosCatalogScreenState>();
  final GlobalKey<ProductManagementScreenState> _productKey = GlobalKey<ProductManagementScreenState>();
  final GlobalKey<SalesReportScreenState> _historyKey = GlobalKey<SalesReportScreenState>();
  final GlobalKey<SalesReportScreenState> _reportKey = GlobalKey<SalesReportScreenState>();

  void _onProductChanged() {
    _posKey.currentState?.loadProducts();
    _productKey.currentState?.loadProducts();
    _historyKey.currentState?.loadReport();
    _reportKey.currentState?.loadReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          PosCatalogScreen(
            key: _posKey,
            currentUser: widget.currentUser,
            onProductChanged: _onProductChanged,
          ),
          ProductManagementScreen(
            key: _productKey,
            onProductsUpdated: _onProductChanged,
          ),
          SalesReportScreen(
            key: _historyKey,
            currentUser: widget.currentUser,
            isHistoryOnly: true,
          ),
          SalesReportScreen(
            key: _reportKey,
            currentUser: widget.currentUser,
            isHistoryOnly: false,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            if (index == 0) _posKey.currentState?.loadProducts();
            if (index == 1) _productKey.currentState?.loadProducts();
            if (index == 2) _historyKey.currentState?.loadReport();
            if (index == 3) _reportKey.currentState?.loadReport();
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.card,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.point_of_sale_rounded),
              label: 'Kasir',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              label: 'Produk',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: 'Laporan',
            ),
          ],
        ),
      ),
    );
  }
}
