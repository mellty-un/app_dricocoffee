import 'package:application_pos_dricocoffee/models/transaction_modepl.dart';
import 'package:application_pos_dricocoffee/pages/dashboard/customer_dashboard.dart';
import 'package:application_pos_dricocoffee/pages/dashboard/dashboard_pages.dart';
import 'package:application_pos_dricocoffee/pages/dashboard/stock_product_dashboard.dart';
import 'package:application_pos_dricocoffee/services/supabase_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class TransactionDashboard extends StatefulWidget {
  const TransactionDashboard({super.key});

  @override
  State<TransactionDashboard> createState() => _TransactionDashboardState();
}

class _TransactionDashboardState extends State<TransactionDashboard> {
  List<TransactionItem> transactions = [];
  int totalTransactions = 0;
  int totalProducts = 0;
  int totalCustomers = 0;

  StreamSubscription? _ordersSubscription;
  StreamSubscription? _productsSubscription;
  StreamSubscription? _customersSubscription;

  @override
  void initState() {
    super.initState();
    _setupRealtimeListeners();
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
        .order('date', ascending: false)
        .listen((ordersData) async {
      
      List<TransactionItem> loadedTransactions = [];
      
      for (var order in ordersData) {
        String formattedDate = _formatDate(order['date']);
        
        String customerName = 'Guest';
        if (order['customer_id'] != null) {
          try {
            final customerData = await SupabaseService.client
                .from('customers')
                .select('name')
                .eq('customer_id', order['customer_id'])
                .single();
            
            customerName = customerData['name'] ?? 'Guest';
          } catch (e) {
            print('Error fetching customer: $e');
          }
        }
        
        String amount = _formatCurrency(order['total_price'] ?? 0);
        
        loadedTransactions.add(TransactionItem(
          title: customerName,
          date: formattedDate,
          amount: amount,
          status: 'Success',
        ));
      }

      if (mounted) {
        setState(() {
          transactions = loadedTransactions;
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
        .listen((customersData) {
      if (mounted) {
        setState(() {
          totalCustomers = customersData.length;
        });
      }
    });
  }

  String _formatDate(dynamic dateValue) {
    try {
      DateTime date;
      if (dateValue is String) {
        date = DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        date = dateValue;
      } else {
        return 'Invalid Date';
      }
      
      return DateFormat('dd/MM/yyyy, hh:mm a').format(date);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  String _formatCurrency(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    final headerPaddingTop = screenHeight * 0.055;
    final headerToCardsSpace = screenHeight * 0.065;
    final titleTopSpace = screenHeight * 0.035;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(screenWidth * 0.04),
          children: [
            /// HEADER
            Padding(
              padding: EdgeInsets.only(top: headerPaddingTop, bottom: screenHeight * 0.012),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DashboardPages()),
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
                    "Transaksi",
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
                  isActive: true,
                  screenWidth: screenWidth,
                  onTap: () {},
                ),
                SizedBox(width: screenWidth * 0.03),
                _buildTopCard(
                  icon: Icons.inventory_2_outlined,
                  value: totalProducts.toString(),
                  label: "Stock Product",
                  screenWidth: screenWidth,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => StockProductDashboard()),
                    );
                  },
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
                      MaterialPageRoute(
                          builder: (_) => CustomerDashboard()),
                    );
                  },
                ),
              ],
            ),

            SizedBox(height: titleTopSpace),

            Text(
              "Transaction",
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: screenHeight * 0.02),

            transactions.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.08),
                      child: Text(
                        'No transactions yet',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: transactions.map((item) {
                      return Container(
                        margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              spreadRadius: 1,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Color(0xFF4CAF50),
                              size: screenWidth * 0.095,
                            ),
                            SizedBox(width: screenWidth * 0.037),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.018),
                                  Text(
                                    item.date,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.03,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.end,
                              children: [
                                Text(
                                  item.amount,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.045,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.018),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.025,
                                    vertical: screenHeight * 0.0025,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    item.status,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.025,
                                      color: Color(0xFF4CAF50),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}