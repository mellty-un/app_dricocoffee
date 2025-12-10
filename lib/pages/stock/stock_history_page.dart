import 'package:flutter/material.dart';
import 'package:application_pos_dricocoffee/services/supabase_services.dart';
import 'package:intl/intl.dart';

class StockHistoryPage extends StatefulWidget {
  const StockHistoryPage({super.key});

  @override
  State<StockHistoryPage> createState() => _StockHistoryPageState();
}

class _StockHistoryPageState extends State<StockHistoryPage> {
  List<Map<String, dynamic>> histories = [];
  bool isLoading = true;
  int? expandedIndex;
  // Track which item is expanded

  @override
  void initState() {
    super.initState();
    fetchHistories();
  }

  Future<void> fetchHistories() async {
    try {
      setState(() => isLoading = true);

      final data = await SupabaseService.fetchStockHistories(limit: 100);

      setState(() {
        histories = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetch stock histories: $e");
      setState(() => isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat riwayat: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String formatDate(String? dateString) {
    if (dateString == null) return '-';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String formatDateTime(String? dateString) {
    if (dateString == null) return '-';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final headerPaddingTop = screenHeight * 0.065;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ================= HEADER ======================
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
                      Icons.arrow_back,
                      size: screenWidth * 0.08,
                      color: Colors.black87,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "History",
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ================= CONTENT ======================
            Expanded(
              child: RefreshIndicator(
                onRefresh: fetchHistories,
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : histories.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: histories.length,
                        itemBuilder: (context, index) {
                          final history = histories[index];
                          final isExpanded = expandedIndex == index;
                          return _buildHistoryCard(history, index, isExpanded);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "Belum ada riwayat stock",
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: fetchHistories,
            icon: const Icon(Icons.refresh),
            label: const Text("Muat Ulang"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    Map<String, dynamic> history,
    int index,
    bool isExpanded,
  ) {
    final change = history['change'] as int;
    final isIncrease = change > 0;
    final productName =
        history['products']?['name'] ?? 'Produk Tidak Diketahui';
    final productImage = history['products']?['image'];
    final userName = history['profiles']?['name'] ?? 'User Tidak Diketahui';
    final orderId = history['order_id'];
    final beforeStock = history['before_stock'] ?? 0;
    final afterStock = history['after_stock'] ?? 0;
    final createdAt = formatDate(history['created_at']);
    final createdAtDetail = formatDateTime(history['created_at']);

    return GestureDetector(
      onTap: () {
        setState(() {
          expandedIndex = isExpanded ? null : index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // ========== SIMPLE VIEW (ALWAYS VISIBLE) ==========
            Row(
              children: [
                // Product Image
                // Product Image
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        productImage != null &&
                            productImage.toString().isNotEmpty
                        ? Image.network(
                            productImage.toString(),
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint("❌ Error loading image: $error");
                              debugPrint("URL: $productImage");
                              return const Icon(
                                Icons.broken_image,
                                color: Colors.red,
                                size: 24,
                              );
                            },
                          )
                        : const Icon(Icons.image, color: Colors.grey, size: 24),
                  ),
                ),
                const SizedBox(width: 12),

                // Product Name & Change
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${isIncrease ? '+' : ''}$change',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isIncrease ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),

                // Date & Stock
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      createdAt,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Stok: $afterStock',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // ========== DETAILED VIEW (WHEN EXPANDED) ==========
            if (isExpanded) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stock Change Detail
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStockBadge("Sebelum", beforeStock, Colors.grey),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.arrow_forward,
                          size: 18,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 12),
                        _buildStockBadge(
                          "Sesudah",
                          afterStock,
                          isIncrease ? Colors.green : Colors.red,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Divider(color: Colors.grey.shade300),
                    const SizedBox(height: 12),

                    // User
                    _detailRow(Icons.person_outline, "Oleh", userName),

                    const SizedBox(height: 10),

                    // Time Detail
                    _detailRow(Icons.access_time, "Waktu", createdAtDetail),

                    // Order ID (jika ada)
                    if (orderId != null) ...[
                      const SizedBox(height: 10),
                      _detailRow(
                        Icons.receipt_outlined,
                        "Order ID",
                        orderId.toString().substring(0, 8) + '...',
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStockBadge(String label, int stock, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            stock.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          "$label:",
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
