import 'dart:ui';
import 'package:application_pos_dricocoffee/pages/cashier/cart_pages.dart';
import 'package:application_pos_dricocoffee/pages/cashier/cashier_card.dart';
import 'package:application_pos_dricocoffee/widgets/category_item.dart';
import 'package:application_pos_dricocoffee/services/supabase_services.dart';
import 'package:application_pos_dricocoffee/widgets/side_bar.dart';
import 'package:application_pos_dricocoffee/providers/cart_providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CashierPages extends StatefulWidget {
  const CashierPages({super.key});

  @override
  State<CashierPages> createState() => _CashierPagesState();
}

class _CashierPagesState extends State<CashierPages> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  double headerPaddingTop = 20;
  List<Map<String, dynamic>> categories = [];
  int selectedIndex = 0;
  List<Map<String, dynamic>> allProducts = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  String searchKeyword = "";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    try {
      final categoriesData = await SupabaseService.fetchCategories();
      final productsData = await SupabaseService.fetchProducts();

      setState(() {
        categories = categoriesData;

        allProducts = productsData.map((product) {
          return {
            'product_id': product.productId,
            'name': product.name,
            'price': 'Rp ${_formatPrice(product.price)}',
            'raw_price': product.price,
            'image': product.image.isNotEmpty ? product.image : '',
            'category_id': product.categoryId,
            'stock': product.stock,
          };
        }).toList();

        isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading products: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

List<Map<String, dynamic>> getFilteredProducts() {
  List<Map<String, dynamic>> filtered = allProducts.where((p) {
    final name = p["name"].toString().toLowerCase();
    final query = searchKeyword.toLowerCase();
    return name.contains(query);
  }).toList();

  if (selectedIndex == 0) {
    return filtered;
  }

  int selectedCategoryId = categories[selectedIndex - 1]["category_id"];

  return filtered
      .where((p) => p["category_id"] == selectedCategoryId)
      .toList();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const SideBar(currentPage: "Cashier"),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Consumer<CartProvider>(
                builder: (context, cart, child) {
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: headerPaddingTop,
                          bottom: 10,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.menu,
                                size: 38,
                                color: Colors.black87,
                              ),
                              onPressed: () {
                                _scaffoldKey.currentState?.openDrawer();
                              },
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Cashier",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const Spacer(),
                            Stack(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.shopping_cart,
                                    size: 28,
                                    color: Colors.black87,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CartPages(),
                                      ),
                                    );
                                  },
                                ),
                                if (cart.itemCount > 0)
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 16,
                                        minHeight: 16,
                                      ),
                                      child: Text(
                                        '${cart.itemCount}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.black12, width: 2),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: searchController,
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
                      const SizedBox(height: 34),
                      SizedBox(
                        width: double.infinity,
                        height: 140,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 150,
                              padding: const EdgeInsets.only(
                                left: 20,
                                top: 14,
                                bottom: 18,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2D3E50),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "COFFEE DAY",
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.8,
                                      height: 1.0,
                                    ),
                                  ),
                                  SizedBox(height: 18),
                                  Text(
                                    "Enjoy your day\nwith coffee",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                      height: 1.4,
                                      fontStyle: FontStyle.italic,
                                      letterSpacing: 2,
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
                                height: 110,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "Menu",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
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
                      ),
                      const SizedBox(height: 30),

                      getFilteredProducts().isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(40),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.shopping_basket_outlined,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No products available',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: getFilteredProducts().length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 20,
                                    crossAxisSpacing: 16,
                                    childAspectRatio: 0.75,
                                  ),
                              itemBuilder: (context, index) {
                                final item = getFilteredProducts()[index];
                                return CashierCard(
                                  name: item["name"],
                                  price: item["price"],
                                  image: item["image"],
                                  productId: item["product_id"],
                                  stock: item["stock"],
                                  rawPrice: item["raw_price"],
                                  categoryId: item["category_id"],
                                );
                              },
                            ),
                    ],
                  );
                },
              ),
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
      onTap: () {
        setState(() => selectedIndex = index);
      },
    );
  }
}
