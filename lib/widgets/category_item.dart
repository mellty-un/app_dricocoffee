import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final double? radius;
  final double? width;
  final double? height;
  final double? topSpacing;
  final double? circleTopOffset; 
  final VoidCallback onTap;
  final double textSpacing; 

  const CategoryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.radius,
    this.width,
    this.height,
    this.topSpacing,
    this.circleTopOffset, 
     this.textSpacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        final cardWidth = width ?? availableWidth.clamp(50.0, 80.0);
        final cardHeight = height ?? (cardWidth * 1.6).clamp(70.0, 120.0);
        final borderRadius = radius ?? (cardWidth * 0.25).clamp(12.0, 20.0);

        final iconContainerSize = (cardWidth * 0.75).clamp(40.0, 60.0);
        final iconSize = (iconContainerSize * 0.45).clamp(20.0, 28.0);

        final fontSize = (cardWidth * 0.15).clamp(9.0, 11.0);

        final circleOffset = circleTopOffset ?? 12;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: cardWidth,
            height: cardHeight,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF232C39)
                  : const Color(0xFFF1F3F6),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // CIRCLE ICON
                Positioned(
                  top: circleOffset, 
                  child: Container(
                    width: iconContainerSize,
                    height: iconContainerSize,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Icon(
                      icon,
                      size: iconSize,
                      color: isSelected
                          ? const Color(0xFF2B3A4A)
                          : const Color(0xFFAAAAAA),
                    ),
                  ),
                ),
   SizedBox(height: textSpacing),
                // TEXT
                Positioned(
                  bottom: 10,
                  left: 6,
                  right: 6,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black87,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
