import 'package:application_pos_dricocoffee/pages/dashboard/customer_dashboard.dart';
import 'package:application_pos_dricocoffee/pages/dashboard/dashboard_pages.dart';
import 'package:application_pos_dricocoffee/pages/dashboard/transaction_dashboard.dart';
import 'package:application_pos_dricocoffee/services/supabase_services.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class StockProductDashboard extends StatefulWidget {
  const StockProductDashboard({super.key});

  @override
  State<StockProductDashboard> createState() => _StockProductDashboard();
}

class _StockProductDashboard extends State<StockProductDashboard> {
  List<Map<String, dynamic>> products = [];
  int totalTransactions = 0;
  int totalProducts = 0;
  int totalCustomers = 0;

  StreamSubscription? _ordersSubscription;
  StreamSubscription? _productsSubscription;
  StreamSubscription? _customersSubscription;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _setupRealtimeListeners();
  }

  Future<void> _loadInitialData() async {
    try {
      final ordersData = await SupabaseService.fetchOrders();
      final productsData = await SupabaseService.fetchProducts();
      final customersData = await SupabaseService.fetchCustomers();

      if (mounted) {
        setState(() {
          products = productsData.map((p) => {
            'name': p.name,
            'stock': p.stock,
            'product_id': p.productId,
          }).toList();
          totalTransactions = ordersData.length;
          totalProducts = productsData.length;
          totalCustomers = customersData.length;
        });
      }
    } catch (e) {
      print('Error loading initial data: $e');
    }
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    _productsSubscription?.cancel();
    _customersSubscription?.cancel();
    super.dispose();
  }

  void _setupRealtimeListeners() {
    _ordersSubscription = SupabaseService.client
        .from('orders')
        .stream(primaryKey: ['id'])
        .listen((ordersData) {
      if (mounted) {
        setState(() {
          totalTransactions = ordersData.length;
        });
      }
    });

    _productsSubscription = SupabaseService.client
        .from('products')
        .stream(primaryKey: ['product_id'])
        .order('name', ascending: true)
        .listen((productsData) {
      if (mounted) {
        setState(() {
          products = productsData.cast<Map<String, dynamic>>();
          totalProducts = productsData.length;
        });
      }
    });

    _customersSubscription = SupabaseService.client
        .from('customers')
        .stream(primaryKey: ['customer_id'])
        .listen((customersData) {
      if (mounted) {
        setState(() {
          totalCustomers = customersData.length;
        });
      }
    });
  }

  Widget _buildTopCard({
    required IconData icon,
    required String value,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    required double screenWidth,
  }) {
    double iconSize = screenWidth * 0.08;
    double fontSize = screenWidth * 0.065;
    double labelSize = screenWidth * 0.027;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.02,
            vertical: screenWidth * 0.055,
          ),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF2a3440) : const Color(0xFFEBEFF2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2A3440), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: iconSize,
                color: isActive ? Colors.white : Colors.black87,
              ),
              SizedBox(height: screenWidth * 0.04),
              Text(
                value,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: screenWidth * 0.015),
              Text(
                label,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: labelSize,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.white70 : const Color(0xFF36536B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockRow(String name, String stock, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.025,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double rightColumnWidth = screenWidth * 0.25;
          double leftColumnWidth = constraints.maxWidth - rightColumnWidth;

          return Row(
            children: [
              SizedBox(
                width: leftColumnWidth,
                child: Text(
                  name,
                  style: TextStyle(fontSize: screenWidth * 0.0375),
                ),
              ),
              SizedBox(
                width: rightColumnWidth,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    stock,
                    style: TextStyle(fontSize: screenWidth * 0.0375),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final headerPaddingTop = screenHeight * 0.055;
    final headerToCardsSpace = screenHeight * 0.065;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(screenWidth * 0.04),
          children: [
            Padding(
              padding: EdgeInsets.only(top: headerPaddingTop, bottom: screenHeight * 0.012),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => DashboardPages()),
                        (route) => false,
                      );
                    },
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: screenWidth * 0.08,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.085),
                  Text(
                    "Stock Product",
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: headerToCardsSpace),

            Row(
              children: [
                _buildTopCard(
                  icon: Icons.point_of_sale_outlined,
                  value: totalTransactions.toString(),
                  label: "Transaction",
                  screenWidth: screenWidth,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TransactionDashboard()),
                    );
                  },
                ),
                SizedBox(width: screenWidth * 0.03),
                _buildTopCard(
                  icon: Icons.inventory_2_outlined,
                  value: totalProducts.toString(),
                  label: "Stock Product",
                  isActive: true,
                  screenWidth: screenWidth,
                  onTap: () {},
                ),
                SizedBox(width: screenWidth * 0.03),
                _buildTopCard(
                  icon: Icons.people_alt_outlined,
                  value: totalCustomers.toString(),
                  label: "Customer",
                  screenWidth: screenWidth,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CustomerDashboard()),
                    );
                  },
                ),
              ],
            ),

            SizedBox(height: screenHeight * 0.025),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color(0xFFE0E0E0),
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.015,
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double rightColumnWidth = screenWidth * 0.25;
                        double leftColumnWidth = constraints.maxWidth - rightColumnWidth;

                        return Row(
                          children: [
                            SizedBox(
                              width: leftColumnWidth,
                              child: Text(
                                "Product",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.0375,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: rightColumnWidth,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "Stock",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.0375,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    child: Divider(
                      thickness: 2,
                      color: Color(0xFFE0E0E0),
                      height: 0,
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.005),

                  products.isEmpty
                      ? Padding(
                          padding: EdgeInsets.all(screenWidth * 0.08),
                          child: Center(
                            child: Text(
                              'No products yet',
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: products.map((product) {
                            return _buildStockRow(
                              product['name'] ?? 'Unknown Product',
                              product['stock']?.toString() ?? '0',
                              screenWidth,
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}