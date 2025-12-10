import 'package:application_pos_dricocoffee/widgets/reports/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:application_pos_dricocoffee/widgets/reports/drawer_menu.dart';

class SalesReportPages extends StatelessWidget {
  const SalesReportPages({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TOP SELLING DATA
    final topSellingData = [
      {"name": "Macchiato", "price": "18.000", "units": 18000},
      {"name": "Matcha Latte", "price": "18.000", "units": 18000},
      {"name": "Caramel Latte", "price": "18.000", "units": 18000},
      {"name": "Croissant", "price": "13.000", "units": 13000},
      {"name": "Pizza Cheese", "price": "24.000", "units": 24000},
    ];

    // RECENT TRANSACTIONS
    final recentData = [
      {
        "name": "Putri",
        "total": "42.000",
        "items": "2 Cold Brew",
        "time": "13:33"
      },
      {
        "name": "Dhea",
        "total": "60.000",
        "items": "3 Macchiato\n1 Pizza Cheese",
        "time": "14:52"
      },
      {
        "name": "Samuail",
        "total": "18.000",
        "items": "1 Iced Black",
        "time": "14:33"
      },
      {
        "name": "Dhea",
        "total": "60.000",
        "items": "3 Macchiato\n1 Pizza Cheese",
        "time": "14:52"
      },
    ];

    /// ======================
    /// DAILY CONTENT
    /// ======================
    final daily = [
      const SizedBox(height: 8),

      GridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.3, // MIRIP SEPERTI GAMBAR
        ),
        children: const [
          SummaryCard(
            title: "Top Sales",
            amount: "960.000",
            subtitle: "",
            icon: Icons.show_chart,
          ),
          SummaryCard(
            title: "Transaction",
            amount: "38",
            subtitle: "",
            icon: Icons.receipt_long,
          ),
          SummaryCard(
            title: "Item Sold",
            amount: "120",
            subtitle: "",
            icon: Icons.shopping_bag_outlined,
          ),
          SummaryCard(
            title: "Customer",
            amount: "38",
            subtitle: "",
            icon: Icons.people_outline,
          ),
        ],
      ),

      const SizedBox(height: 20),
      TopSellingList(items: topSellingData),
      const SizedBox(height: 20),
      RecentTransactions(transactions: recentData),
      const SizedBox(height: 80),
    ];

    /// ======================
    /// WEEKLY CONTENT
    /// ======================
    final weekly = [
      const SizedBox(height: 8),
      GridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.3,
        ),
        children: const [
          SummaryCard(
            title: "Top Sales",
            amount: "1.200.000",
            subtitle: "",
            icon: Icons.show_chart,
          ),
          SummaryCard(
            title: "Transaction",
            amount: "76",
            subtitle: "",
            icon: Icons.receipt_long,
          ),
          SummaryCard(
            title: "Item Sold",
            amount: "145",
            subtitle: "",
            icon: Icons.shopping_bag_outlined,
          ),
          SummaryCard(
            title: "Customer",
            amount: "76",
            subtitle: "",
            icon: Icons.people_outline,
          ),
        ],
      ),

      const SizedBox(height: 20),
      TopSellingList(items: topSellingData),
      const SizedBox(height: 20),
      RecentTransactions(transactions: recentData),
      const SizedBox(height: 80),
    ];

    /// ======================
    /// MONTHLY CONTENT
    /// ======================
    final monthly = [
      const SizedBox(height: 8),
      GridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.3,
        ),
        children: const [
          SummaryCard(
            title: "Top Sales",
            amount: "1.400.000",
            subtitle: "",
            icon: Icons.show_chart,
          ),
          SummaryCard(
            title: "Transaction",
            amount: "109",
            subtitle: "",
            icon: Icons.receipt_long,
          ),
          SummaryCard(
            title: "Item Sold",
            amount: "200",
            subtitle: "",
            icon: Icons.shopping_bag_outlined,
          ),
          SummaryCard(
            title: "Customer",
            amount: "109",
            subtitle: "",
            icon: Icons.people_outline,
          ),
        ],
      ),

      const SizedBox(height: 20),
      TopSellingList(items: topSellingData),
      const SizedBox(height: 20),
      RecentTransactions(transactions: recentData),
      const SizedBox(height: 80),
    ];

    return ReportTabView(
      dailyContent: daily,
      weeklyContent: weekly,
      monthlyContent: monthly,
    );
  }
}
