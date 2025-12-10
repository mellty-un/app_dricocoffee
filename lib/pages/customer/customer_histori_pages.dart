import 'package:flutter/material.dart';
import 'package:application_pos_dricocoffee/services/supabase_services.dart';

class CustomerHistoriPages extends StatefulWidget {
  final int customerId;
  final String customerName;

  const CustomerHistoriPages({
    super.key,
    required this.customerId,
    required this.customerName,
  });

  @override
  State<CustomerHistoriPages> createState() => _CustomerHistoriPagesState();
}

class _CustomerHistoriPagesState extends State<CustomerHistoriPages> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    setState(() => isLoading = true);
    try {
      final data = await SupabaseService.fetchCustomerOrderHistory(widget.customerId);
      setState(() {
        orders = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat riwayat'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2,'0')}/${date.month.toString().padLeft(2,'0')}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _formatPrice(int amount) {
    return amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
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
                      Icons.arrow_back_ios_new,
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
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : orders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                "Belum ada riwayat pesanan",
                                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: fetchOrders,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: orders.length,
                            itemBuilder: (context, index) {
                              final order = orders[index];

                              final items = (order['items'] as List<dynamic>?) ?? [];
                              final firstItem = items.isNotEmpty ? items[0] : null;
                              final product = firstItem?['products'] as Map<String, dynamic>?;

                              final totalItems = items.fold(0, (sum, item) => sum + (item['quantity'] as int? ?? 0));
                              final totalPrice = order['total_price'] as int? ?? 0;
                              final orderDate = order['date'] as String?;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                padding: const EdgeInsets.all(16),
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
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Container(
                                        width: 72,
                                        height: 72,
                                        color: Colors.grey[200],
                                        child: product?['image'] != null && (product?['image'] as String).isNotEmpty
                                            ? Image.network(
                                                product?['image'],
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => const Icon(Icons.local_cafe, color: Colors.brown, size: 36),
                                              )
                                            : const Icon(Icons.local_cafe, color: Colors.brown, size: 36),
                                      ),
                                    ),

                                    const SizedBox(width: 16),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product?['name'] ?? 'Pesanan',
                                            style: const TextStyle(
                                              fontSize: 16.5,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (totalItems > 1)
                                            Text(
                                              "+${totalItems - 1} item lainnya",
                                              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                            ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Rp ${_formatPrice(totalPrice)}",
                                            style: const TextStyle(
                                              fontSize: 19,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2D3748),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // TANGGAL & TOTAL ITEM
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          _formatDate(orderDate ?? ''),
                                          style: const TextStyle(fontSize: 12.5, color: Colors.black54),
                                        ),
                                        const SizedBox(height: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2D3748),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            "$totalItems item",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}