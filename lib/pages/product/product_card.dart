import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String image;
  final void Function(Offset tapPosition)? onMoreTap;

  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.image,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final isSmall = cardWidth < 150;
        final isMedium = cardWidth >= 150 && cardWidth < 200;
        
        final edgePadding = isSmall ? 8.0 : (isMedium ? 10.0 : 12.0);
        final innerPadding = isSmall ? 6.0 : (isMedium ? 8.0 : 12.0);
        
        final nameFontSize = isSmall ? 12.0 : (isMedium ? 13.0 : 15.0);
        final priceFontSize = isSmall ? 13.0 : (isMedium ? 14.0 : 15.0);
        
        final iconSize = isSmall ? 16.0 : 18.0;
        
        final borderRadius = isSmall ? 12.0 : 16.0;
        final imageBorderRadius = isSmall ? 8.0 : 12.0;

        return Container(
          margin: EdgeInsets.all(edgePadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  innerPadding,
                  innerPadding,
                  innerPadding,
                  0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: isSmall ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: nameFontSize,
                        ),
                      ),
                    ),
                    SizedBox(width: isSmall ? 4 : 8),
                    InkWell(
                      onTapDown: (d) => onMoreTap?.call(d.globalPosition),
                      child: Container(
                        padding: EdgeInsets.all(isSmall ? 4 : 6),
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(
                            isSmall ? 6 : 8,
                          ),
                        ),
                        child: Icon(
                          Icons.more_vert,
                          size: iconSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(innerPadding),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(imageBorderRadius),
                    child: _buildImage(isSmall),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  innerPadding,
                  0,
                  innerPadding,
                  innerPadding,
                ),
                child: Text(
                  price,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: priceFontSize,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImage(bool isSmall) {
    if (image.isEmpty) {
      return _placeholder(isSmall);
    }

    if (image.startsWith('http')) {
      return Image.network(
        image,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: isSmall ? 1.5 : 2,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('Error loading image: $error');
          return _placeholder(isSmall);
        },
      );
    }

    return _placeholder(isSmall);
  }

  Widget _placeholder(bool isSmall) {
    final iconSize = isSmall ? 30.0 : 50.0;
    final fontSize = isSmall ? 10.0 : 12.0;
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.coffee,
            size: iconSize,
            color: Colors.grey[600],
          ),
          SizedBox(height: isSmall ? 4 : 8),
          Text(
            'No Image',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}