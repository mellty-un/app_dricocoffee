import 'dart:async';
import 'dart:ui';
import 'package:application_pos_dricocoffee/pages/product/product_dialogs.dart';
import 'package:application_pos_dricocoffee/widgets/category_item.dart';
import 'package:application_pos_dricocoffee/services/supabase_services.dart';
import 'package:application_pos_dricocoffee/pages/product/product_card.dart';
import 'package:application_pos_dricocoffee/widgets/side_bar.dart';
import 'package:application_pos_dricocoffee/models/product_models.dart';
import 'package:flutter/material.dart';

class ProductPages extends StatefulWidget {
  const ProductPages({super.key});

  @override
  State<ProductPages> createState() => _ProductPagesState();
}

class _ProductPagesState extends State<ProductPages> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Map<String, dynamic>> categories = [];
  int selectedIndex = 0;
  Rect? selectedCardRect;
  bool showMenu = false;
  Offset popupPosition = Offset.zero;
  Product? selectedProduct;
  int? selectedCardIndex;
  bool isEditActive = true;

  TextEditingController searchController = TextEditingController();
  String searchKeyword = "";

  List<Product> filterProductList(List<Product> products) {
    if (searchKeyword.isEmpty) return products;

    return products.where((p) {
      final name = p.name.toLowerCase();
      return name.contains(searchKeyword.toLowerCase());
    }).toList();
  }

  List<GlobalKey> cardKeys = [];
  StreamSubscription<List<Product>>? _productSubscription;

  Widget _toggleButton({
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 22,
            color: active ? Colors.black : Colors.black87,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchCategories();

    _productSubscription = SupabaseService.productStream.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _productSubscription?.cancel();
    super.dispose();
  }

  Future<void> fetchCategories() async {
    try {
      final data = await SupabaseService.fetchCategories();
      setState(() {
        categories = data;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error loading categories: $e")));
      }
    }
  }

  String getCategoryNameById(int categoryId) {
    final category = categories.firstWhere(
      (cat) => cat['category_id'] == categoryId,
      orElse: () => {'name': 'Unknown'},
    );
    return category['name'];
  }

  void _showPopupMenu(int index, Offset buttonPosition, Product product) {
    final renderBox =
        cardKeys[index].currentContext?.findRenderObject() as RenderBox?;

    if (renderBox != null) {
      final cardPosition = renderBox.localToGlobal(Offset.zero);
      final cardSize = renderBox.size;

      setState(() {
        selectedProduct = product;
        selectedCardIndex = index;
        selectedCardRect = Rect.fromLTWH(
          cardPosition.dx,
          cardPosition.dy,
          cardSize.width,
          cardSize.height,
        );
        showMenu = true;
        popupPosition = buttonPosition;
      });
    }
  }

  void _closeMenu() {
    setState(() {
      showMenu = false;
      selectedProduct = null;
      selectedCardIndex = null;
      isEditActive = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;
    final isLargeScreen = screenWidth >= 600;

    final headerPaddingTop = isSmallScreen
        ? 20.0
        : (isMediumScreen ? 35.0 : 45.0);
    final menuIconSize = isSmallScreen ? 32.0 : 38.0;
    final titleFontSize = isSmallScreen ? 20.0 : 24.0;
    final searchPadding = isSmallScreen ? 12.0 : 14.0;
    final bannerHeight = isSmallScreen
        ? 120.0
        : (isMediumScreen ? 130.0 : 140.0);
    final menuTitleSize = isSmallScreen ? 22.0 : 26.0;

    final crossAxisCount = isSmallScreen ? 2 : (isLargeScreen ? 3 : 2);
    final childAspectRatio = isSmallScreen ? 0.7 : 0.75;
    final gridSpacing = isSmallScreen ? 12.0 : (isMediumScreen ? 16.0 : 20.0);

    return Scaffold(
      key: _scaffoldKey,
      drawer: const SideBar(currentPage: "Product"),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: ListView(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: headerPaddingTop,
                    bottom: isSmallScreen ? 8 : 10,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.menu,
                          size: menuIconSize,
                          color: Colors.black87,
                        ),
                        onPressed: () {
                          _scaffoldKey.currentState?.openDrawer();
                        },
                      ),
                      SizedBox(width: isSmallScreen ? 20 : 34),
                      Text(
                        "Product",
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isSmallScreen ? 18 : 25),

                // Search Bar
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 16,
                    vertical: searchPadding,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      isSmallScreen ? 20 : 24,
                    ),
                    border: Border.all(color: Colors.black12, width: 2),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: isSmallScreen ? 6 : 10),

                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              searchKeyword = value;
                            });
                          },
                          decoration: const InputDecoration.collapsed(
                            hintText: "Search",
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: isSmallScreen ? 24 : 34),

                // Banner
                SizedBox(
                  width: double.infinity,
                  height: bannerHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: double.infinity,
                        height: bannerHeight + 10,
                        padding: EdgeInsets.only(
                          left: isSmallScreen ? 16 : 20,
                          top: isSmallScreen ? 10 : 14,
                          bottom: isSmallScreen ? 14 : 18,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D3E50),
                          borderRadius: BorderRadius.circular(
                            isSmallScreen ? 16 : 20,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "COFFEE DAY",
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: isSmallScreen ? 12 : 14,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.8,
                                height: 1.0,
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 14 : 18),
                            Text(
                              "Enjoy your day\nwith coffee",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 18 : 22,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                                fontStyle: FontStyle.italic,
                                letterSpacing: isSmallScreen ? 1.5 : 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: -10,
                        top: -15,
                        bottom: -10,
                        child: Image.asset(
                          "assets/images/cb.png",
                          height: bannerHeight - 30,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isSmallScreen ? 20 : 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Menu",
                      style: TextStyle(
                        fontSize: menuTitleSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await ProductDialogs.showAddDialog(
                          context,
                          categories,
                          () => setState(() {}),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(
                            isSmallScreen ? 10 : 12,
                          ),
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: isSmallScreen ? 20 : 24,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 20 : 30),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final categoryWidth = (constraints.maxWidth - 30) / 4;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildCategory(
                          index: 0,
                          title: "All",
                          icon: Icons.grid_view_rounded,
                        ),
                        buildCategory(
                          index: 1,
                          title: "Coffee",
                          icon: Icons.coffee_rounded,
                        ),
                        buildCategory(
                          index: 2,
                          title: "Non\nCoffee",
                          icon: Icons.local_drink_rounded,
                        ),
                        buildCategory(
                          index: 3,
                          title: "Snack",
                          icon: Icons.breakfast_dining_rounded,
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: isSmallScreen ? 20 : 30),

                StreamBuilder<List<Product>>(
                  stream: SupabaseService.productStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Text("Error: ${snapshot.error}"),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => setState(() {}),
                                child: const Text("Retry"),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.inbox,
                                size: isSmallScreen ? 48 : 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No products available",
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Tap + to add a product",
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 12 : 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final allProducts = snapshot.data!;
                    List<Product> filteredProducts = allProducts;

                    if (selectedIndex != 0) {
                      filteredProducts = filteredProducts
                          .where((p) => p.categoryId == selectedIndex)
                          .toList();
                    }

                    if (searchKeyword.isNotEmpty) {
                      filteredProducts = filteredProducts.where((p) {
                        return p.name.toLowerCase().contains(
                          searchKeyword.toLowerCase(),
                        );
                      }).toList();
                    }

                    if (filteredProducts.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.filter_list_off,
                                size: isSmallScreen ? 48 : 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No products in ${getCategoryNameById(selectedIndex)}",
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    cardKeys = List.generate(
                      filteredProducts.length,
                      (_) => GlobalKey(),
                    );

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredProducts.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: gridSpacing,
                        crossAxisSpacing: gridSpacing,
                        childAspectRatio: childAspectRatio,
                      ),
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        final isSelectedCard =
                            selectedProduct?.productId == product.productId;

                        return Opacity(
                          opacity: showMenu && isSelectedCard ? 0.0 : 1.0,
                          child: IgnorePointer(
                            ignoring: showMenu,
                            child: ProductCard(
                              key: cardKeys[index],
                              name: product.name,
                              price:
                                  "Rp ${product.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                              image: product.image,
                              onMoreTap: (pos) =>
                                  _showPopupMenu(index, pos, product),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          if (showMenu)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(color: Colors.black.withOpacity(0.1)),
              ),
            ),

          if (showMenu)
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeMenu,
                child: Container(color: Colors.transparent),
              ),
            ),

          if (showMenu &&
              selectedProduct != null &&
              selectedCardIndex != null &&
              selectedCardRect != null)
            Positioned(
              left: selectedCardRect!.left,
              top: selectedCardRect!.top,
              width: selectedCardRect!.width,
              height: selectedCardRect!.height,
              child: IgnorePointer(
                child: ProductCard(
                  name: selectedProduct!.name,
                  price:
                      "Rp ${selectedProduct!.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                  image: selectedProduct!.image,
                  onMoreTap: (_) {},
                ),
              ),
            ),

          if (showMenu)
            Positioned(
              left: _calculatePopupX(context),
              top: _calculatePopupY(),
              child: _buildPopupMenu(),
            ),
        ],
      ),
    );
  }

  Widget buildCategory({
    required int index,
    required String title,
    required IconData icon,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    double cardWidth = screenWidth < 360 ? 70 : (screenWidth < 480 ? 80 : 90);
    double cardHeight = screenWidth < 360
        ? 95
        : (screenWidth < 480 ? 110 : 125);

    return CategoryCard(
      icon: icon,
      title: title,
      isSelected: selectedIndex == index,
      radius: 50,
      width: cardWidth,
      height: cardHeight,
      topSpacing: 10,
       textSpacing: 2,
      circleTopOffset: 6, 
      onTap: () {
        setState(() => selectedIndex = index);
      },
    );
  }

  Widget _buildPopupMenu() {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 44,
        height: 140,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.black.withOpacity(0.15), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              alignment: isEditActive
                  ? Alignment.topCenter
                  : Alignment.bottomCenter,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _toggleButton(
                  icon: Icons.edit_outlined,
                  active: isEditActive,
                  onTap: () async {
                    setState(() => isEditActive = true);

                    await ProductDialogs.showEditDialog(
                      context,
                      selectedProduct!,
                      categories,
                      _closeMenu,
                      () => setState(() {}),
                    );
                  },
                ),
                _toggleButton(
                  icon: Icons.delete_outline,
                  active: !isEditActive,
                  onTap: () async {
                    setState(() => isEditActive = false);

                    await ProductDialogs.showDeleteDialog(
                      context,
                      selectedProduct!,
                      () {
                        _closeMenu();
                        setState(() {});
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _calculatePopupX(BuildContext context) {
    const popupWidth = 52;
    final screenWidth = MediaQuery.of(context).size.width;

    final cardRightSpace = screenWidth - selectedCardRect!.right;

    if (cardRightSpace > popupWidth) {
      return selectedCardRect!.right + 4;
    }

    return selectedCardRect!.left - popupWidth - 4;
  }

  double _calculatePopupY() {
    return selectedCardRect!.top + (selectedCardRect!.height / 2) - 90;
  }
}
