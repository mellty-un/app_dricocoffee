import 'package:flutter/material.dart';

class ReportTabView extends StatefulWidget {
  final List<Widget> dailyContent;
  final List<Widget> weeklyContent;
  final List<Widget> monthlyContent;

  const ReportTabView({
    Key? key,
    required this.dailyContent,
    required this.weeklyContent,
    required this.monthlyContent,
  }) : super(key: key);

  @override
  State<ReportTabView> createState() => _ReportTabViewState();
}

class _ReportTabViewState extends State<ReportTabView>
    with SingleTickerProviderStateMixin {
  int _selected = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> content = _selected == 0
        ? widget.dailyContent
        : _selected == 1
            ? widget.weeklyContent
            : widget.monthlyContent;

    return Column(
      children: [
        const SizedBox(height: 12),
        
        // === TAB BAR CONTAINER ===
        Container(
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: const Color(0xFF36536b),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(21),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: const Color(0xFF36536b), 
                borderRadius: BorderRadius.circular(21),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF36536b),
              labelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              onTap: (i) => setState(() => _selected = i),
              tabs: const [
                Tab(text: "Daily"),
                Tab(text: "Weekly"),
                Tab(text: "Monthly"),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // === CONTENT AREA ===
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: content,
            ),
          ),
        ),
      ],
    );
  }
}