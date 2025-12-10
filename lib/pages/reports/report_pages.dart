import 'package:application_pos_dricocoffee/pages/reports/profit_loss_pages.dart';
import 'package:application_pos_dricocoffee/pages/reports/sales_report_pages.dart';
import 'package:application_pos_dricocoffee/pages/reports/transactions_report_pages.dart';
import 'package:application_pos_dricocoffee/widgets/side_bar.dart';
import 'package:flutter/material.dart';

enum ReportTab { sales, transactions, profitLoss }

class ReportPages extends StatefulWidget {
  final ReportTab initialTab;

  const ReportPages({
    super.key,
    this.initialTab = ReportTab.sales,
  });

  @override
  State<ReportPages> createState() => _ReportPagesState();
}

class _ReportPagesState extends State<ReportPages> {
  late int selectedIndex;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final Color primary = const Color(0xFF36536B);

  final screens = const [
    SalesReportPages(),
    TransactionsReportPages(),
    ProfitLossPages(),
  ];

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialTab.index;
  }

  void _openSidebar(BuildContext context) {
    final size = MediaQuery.of(context).size;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (_) => Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: size.width < 600 ? size.width * 0.8 : 350,
              height: size.height * 0.9,
              margin: const EdgeInsets.only(top: 40, bottom: 60),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
                child: Material(
                  color: Colors.white,
                  child: const SideBar(currentPage: "Report"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final headerPaddingTop = screenHeight * 0.065;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const SideBar(currentPage: "Report"),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ===== HEADER =====
            Padding(
              padding: EdgeInsets.only(
                top: headerPaddingTop,
                bottom: screenHeight * 0.012,
                left: 16,
                right: 16,
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
                  const SizedBox(width: 8),
                  Text(
                    "Report & Print",
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // ===== TAB BUTTONS (Horizontal Scroll) =====
            Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  SizedBox(
                    width: 140,
                    child: _buildTabButton("Sales Reports", 0),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 140,
                    child: _buildTabButton("Reports", 1),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 140,
                    child: _buildTabButton("Loss Profit", 2),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ===== CONTENT =====
            Expanded(child: screens[selectedIndex]),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: primary,
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isSelected ? Colors.white : primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}