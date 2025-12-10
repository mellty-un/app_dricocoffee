import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartWidget extends StatelessWidget {
  const BarChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity, 
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 400,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceBetween,
              maxY: 100,
              minY: 0,
              barTouchData: BarTouchData(enabled: false),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),

              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 20,
                    reservedSize: 32,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const style = TextStyle(fontSize: 12);
                      switch (value.toInt()) {
                        case 0:
                          return Text("Jun", style: style);
                        case 1:
                          return Text("Jul", style: style);
                        case 2:
                          return Text("Aug", style: style);
                        case 3:
                          return Text("Sep", style: style);
                        case 4:
                          return Text("Oct", style: style);
                        case 5:
                          return Text("Nov", style: style);
                        case 6:
                          return Text("Dec", style: style);
                        default:
                          return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ),

              barGroups: [
                _bar(0, 80),
                _bar(1, 40),
                _bar(2, 70),
                _bar(3, 100),
                _bar(4, 30),
                _bar(5, 100),
                _bar(6, 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BarChartGroupData _bar(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 40, 
          borderRadius: BorderRadius.circular(20),
          color: Color(0xFF35506A),
        ),
      ],
    );
  }
}
