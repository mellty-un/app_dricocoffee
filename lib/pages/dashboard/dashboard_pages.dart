import 'dart:async';

import 'package:application_pos_dricocoffee/pages/dashboard/customer_dashboard.dart';
import 'package:application_pos_dricocoffee/pages/dashboard/stock_product_dashboard.dart';
import 'package:application_pos_dricocoffee/pages/dashboard/transaction_dashboard.dart';
import 'package:application_pos_dricocoffee/services/supabase_services.dart';
import 'package:application_pos_dricocoffee/widgets/bar_chart_widget.dart';
import 'package:application_pos_dricocoffee/widgets/line_chart_widget.dart';
import 'package:application_pos_dricocoffee/widgets/side_bar.dart';
import 'package:flutter/material.dart';

class DashboardPages extends StatefulWidget {
  const DashboardPages({super.key});

  @override
  State<DashboardPages> createState() => _DashboardPagesState();
}

class _DashboardPagesState extends State<DashboardPages> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int selectedCardIndex = -1; 

  List<Map<String, dynamic>> customers = [];
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
      final customersData = await SupabaseService.getCustomers();

      if (mounted) {
        setState(() {
          customers = customersData;
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
        .listen((productsData) {
      if (mounted) {
        setState(() {
          totalProducts = productsData.length;
        });
      }
    });

    _customersSubscription = SupabaseService.client
        .from('customers')
        .stream(primaryKey: ['customer_id'])
        .order('name', ascending: true)
        .listen((customersData) {
      if (mounted) {
        setState(() {
          customers = customersData.cast<Map<String, dynamic>>();
          totalCustomers = customersData.length;
        });
      }
    });
  }

  Widget _buildTopCard({
    required int index,
    required IconData icon,
    required String value,
    required String label,
    required VoidCallback onTap,
    required double screenWidth,
  }) {
    final bool isActive = selectedCardIndex == index;

    double iconSize = screenWidth * 0.08;
    double fontSize = screenWidth * 0.065;
    double labelSize = screenWidth * 0.027;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedCardIndex = index;
          });
          onTap();
        },
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

  Widget _cardContainer({
    required String title,
    required Widget chart,
    required double screenWidth,
    required double screenHeight,
  }) {
    return Container(
      height: screenHeight * 0.35,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFFf7f9fa),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Expanded(child: chart),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final headerPaddingTop = screenHeight * 0.055;
    final headerToCardsSpace = screenHeight * 0.065;
    final cardsToChartSpace = screenHeight * 0.025;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const SideBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(screenWidth * 0.04),
          children: [
            // ===== HEADER =====
            Padding(
              padding: EdgeInsets.only(
                top: headerPaddingTop,
                bottom: screenHeight * 0.012,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.menu,
                      size: screenWidth * 0.08,
                      color: Colors.black87,
                    ),
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                  SizedBox(width: screenWidth * 0.085),
                  Text(
                    "Dashboard",
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
                  index: 0,
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
                  index: 1,
                  icon: Icons.inventory_2_outlined,
                  value: totalProducts.toString(),
                  label: "Stock Product",
                  screenWidth: screenWidth,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => StockProductDashboard()),
                    );
                  },
                ),
                SizedBox(width: screenWidth * 0.03),
                _buildTopCard(
                  index: 2,
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

            SizedBox(height: cardsToChartSpace),

            _cardContainer(
              title: "Sales Overview",
              chart: const BarChartWidget(),
              screenWidth: screenWidth,
              screenHeight: screenHeight,
            ),

            SizedBox(height: cardsToChartSpace),

            _cardContainer(
              title: "Daily Sales",
              chart: const LineChartWidget(),
              screenWidth: screenWidth,
              screenHeight: screenHeight,
            ),
          ],
        ),
      ),
    );
  }
}