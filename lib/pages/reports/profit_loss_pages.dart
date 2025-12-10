import 'package:application_pos_dricocoffee/widgets/reports/common_widget.dart';
import 'package:application_pos_dricocoffee/widgets/reports/drawer_menu.dart';
import 'package:flutter/material.dart';

class ProfitLossPages extends StatelessWidget {
  const ProfitLossPages({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final daily = [
      const SizedBox(height: 16),
      const ProfitSummaryGrid(
        revenue: "1.450.000",
        cost: "460.000",
        profit: "1.000.000",
        percent: "46%",
      ),
      const SizedBox(height: 20),
      const ProfitChartBox(),
      const SizedBox(height: 20),
      ProfitDetailList(
        data: [
          {
            "date": "Sunday, 18 Jan 2025",
            "revenue": "65.000",
            "cost": "40.000",
            "profit": "35.000",
          },
          {
            "date": "Monday, 19 Jan 2025",
            "revenue": "85.000",
            "cost": "40.000",
            "profit": "45.000",
          },
          {
            "date": "Tuesday, 20 Jan 2025",
            "revenue": "65.000",
            "cost": "20.000",
            "profit": "45.000",
          },
        ],
      ),
      const SizedBox(height: 80),
    ];

    final weekly = [
      const SizedBox(height: 16),
      const ProfitSummaryGrid(
        revenue: "1.450.000",
        cost: "460.000",
        profit: "1.000.000",
        percent: "46%",
      ),
      const SizedBox(height: 20),
      const ProfitChartBox(),
      const SizedBox(height: 20),
      ProfitDetailList(
        data: [
          {
            "date": "Week 3 Jan 2025",
            "revenue": "3.886.000",
            "cost": "2.350.000",
            "profit": "1.536.000",
          },
        ],
      ),
      const SizedBox(height: 80),
    ];

    final monthly = [
      const SizedBox(height: 16),
      const ProfitSummaryGrid(
        revenue: "1.450.000",
        cost: "460.000",
        profit: "1.000.000",
        percent: "46%",
      ),
      const SizedBox(height: 20),
      const ProfitChartBox(),
      const SizedBox(height: 20),
      ProfitDetailList(
        data: [
          {
            "date": "January 2025",
            "revenue": "8.234.000",
            "cost": "4.600.000",
            "profit": "3.634.000",
          },
        ],
      ),
      const SizedBox(height: 80),
    ];

    return ReportTabView(
      dailyContent: daily,
      weeklyContent: weekly,
      monthlyContent: monthly,
    );
  }
}