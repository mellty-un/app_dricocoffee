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

class _ReportTabViewState extends State<ReportTabView> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> currentContent = _selectedIndex == 0
        ? widget.dailyContent
        : _selectedIndex == 1
            ? widget.weeklyContent
            : widget.monthlyContent;

    return Column(
      children: [
        const SizedBox(height: 12),
        
        // === TAB SELECTOR ===
        Container(
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFEC3D16), 
            borderRadius: BorderRadius.circular(25),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: _selectedIndex == 0
                    ? Alignment.centerLeft
                    : _selectedIndex == 1
                        ? Alignment.center
                        : Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: 1 / 3,
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3EEEB), 
                      borderRadius: BorderRadius.circular(21),
                    ),
                  ),
                ),
              ),
              
              // === BUTTON TEXT ===
              Row(
                children: [
                  _buildTabButton("Daily", 0),
                  _buildTabButton("Weekly", 1),
                  _buildTabButton("Monthly", 2),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // === CONTENT AREA ===
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: currentContent,
            ),
          ),
        ),
      ],
    );
  }

  // === BUILD TAB BUTTON ===
  Widget _buildTabButton(String text, int index) {
    final bool isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Container(
          height: 50,
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected 
                  ? Colors.black      
                  : Colors.white,      
            ),
          ),
        ),
      ),
    );
  }
}