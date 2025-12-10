import 'package:application_pos_dricocoffee/pages/stock/stock_card.dart';
import 'package:application_pos_dricocoffee/pages/stock/stock_dialog.dart';
import 'package:application_pos_dricocoffee/pages/stock/stock_history_page.dart';
import 'package:application_pos_dricocoffee/services/supabase_services.dart';
import 'package:application_pos_dricocoffee/models/product_models.dart';
import 'package:flutter/material.dart';
import 'package:application_pos_dricocoffee/widgets/side_bar.dart';

class StockPages extends StatefulWidget {
  const StockPages({super.key});

  @override
  State<StockPages> createState() => _StockPagesState();
}

class _StockPagesState extends State<StockPages> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  List<Product> products = [];
  List<Product> filteredProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ====================== FILTER PRODUCTS ==========================
  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredProducts = products;
      } else {
        filteredProducts = products.where((product) {
          return product.name.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  // ====================== FETCH DATA ==========================
  Future<void> fetchProducts() async {
    try {
      setState(() => isLoading = true);

      final fetchedProducts = await SupabaseService.fetchProducts();

      setState(() {
        products = fetchedProducts;
        filteredProducts = fetchedProducts;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetch products: $e");
      setState(() => isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat produk: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final headerPaddingTop = screenHeight * 0.065;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const SideBar(currentPage: "Stock"),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ================= HEADER (MENU + TITLE) ======================
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
                    "Stock Produk",
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // ================= SEARCH & HISTORY ======================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xffF2F4F7),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Search",
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StockHistoryPage(),
                          ),
                        );
                      },
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xffF2F4F7),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Center(
                          child: Text(
                            "History",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= CONTENT ======================
            Expanded(
              child: RefreshIndicator(
                onRefresh: fetchProducts,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // ================= LOADING ======================
                    if (isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      ),

                    // ================= EMPTY STATE ======================
                    if (!isLoading && filteredProducts.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                _searchController.text.isNotEmpty
                                    ? Icons.search_off
                                    : Icons.inventory_2_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchController.text.isNotEmpty
                                    ? "Produk tidak ditemukan"
                                    : "Belum ada produk",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              if (_searchController.text.isEmpty) ...[
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: fetchProducts,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text("Muat Ulang"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black87,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                    // ================= PRODUCT LIST ======================
                    if (!isLoading && filteredProducts.isNotEmpty)
                      Column(
                        children: filteredProducts.map((product) {
                          return StockCard(
                            product: product,
                            onEdit: () async {
                              await showDialog(
                                context: context,
                                builder: (context) => StockDialog(
                                  product: product,
                                  onSuccess: fetchProducts,
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}