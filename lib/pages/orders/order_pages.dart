import 'package:application_pos_dricocoffee/pages/orders/cash_dialog.dart';
import 'package:application_pos_dricocoffee/pages/orders/receipt_dialog.dart';
import 'package:application_pos_dricocoffee/providers/cart_providers.dart';
import 'package:application_pos_dricocoffee/services/supabase_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderPages extends StatefulWidget {
  final List<CartItem> cartItems;
  final int subtotal;
  final int discount;
  final int ppn;
  final int total;

  const OrderPages({
    Key? key,
    required this.cartItems,
    required this.subtotal,
    required this.discount,
    required this.ppn,
    required this.total,
  }) : super(key: key);

  @override
  State<OrderPages> createState() => _OrderPagesState();
}

class _OrderPagesState extends State<OrderPages> {
  double headerPaddingTop = 20;
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _discountController = TextEditingController(
    text: '0',
  );
  String _selectedPaymentMethod = '';
  String cashierName = SupabaseService.currentUserName;

  bool _isLoading = false;

  int _cashAmount = 0;
  int _change = 0;

  int? _customerId;

  late int currentDiscount;
  late int currentTotal;

  @override
  void initState() {
    super.initState();
    currentDiscount = widget.discount;
    currentTotal = widget.total;
  }

  void _updateDiscount() {
    setState(() {
      currentDiscount = int.tryParse(_discountController.text) ?? 0;
      currentTotal = widget.subtotal + widget.ppn - currentDiscount;
    });
  }

  String _formatPrice(int price) {
    return 'Rp ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  void _showCashDialog() {
    if (_customerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon masukkan nama customer terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final cart = Provider.of<CartProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => CashDialog(
        totalAmount: currentTotal,
        customerName: _customerController.text.trim(),

        cartItems: cart.items,

        onPaymentConfirmed: (cashAmount, change) {
          setState(() {
            _cashAmount = cashAmount;
            _change = change;
          });
          _submitOrder();
        },
      ),
    );
  }

  Future<void> _submitOrder() async {
    if (_customerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon masukkan nama customer'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedPaymentMethod.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon pilih metode pembayaran'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print(' Starting order submission...');

      final customerId = await SupabaseService.getOrCreateCustomer(
        _customerController.text.trim(),
      );
      print(' Customer ID: $customerId');

      final userId = SupabaseService.getCurrentUserId();

      if (userId == null) {
        throw Exception('User tidak terautentikasi');
      }
      print(' User ID: $userId');
      print(
        ' User Email: ${SupabaseService.client.auth.currentUser?.email}',
      ); // ✅ DEBUG

      int totalItems = widget.cartItems.fold(
        0,
        (sum, item) => sum + item.quantity,
      );

      List<Map<String, dynamic>> orderItems = [];

      for (var item in widget.cartItems) {
        int itemSubtotal = item.price * item.quantity;
        int itemDiscount = widget.subtotal > 0
            ? ((itemSubtotal * currentDiscount) / widget.subtotal).round()
            : 0;
        int itemFinalPrice = itemSubtotal - itemDiscount;

        orderItems.add({
          'product_id': item.productId,
          'quantity': item.quantity,
          'price': item.price,
          'discount': itemDiscount,
          'final_price': itemFinalPrice,
        });
      }
      print('✅ Order items prepared: ${orderItems.length} items');

      final orderId = await SupabaseService.createOrder(
        totalPrice: currentTotal,
        totalItem: totalItems,
        customerId: customerId,
        paymentMethod: _selectedPaymentMethod,
        userId: userId,
        orderItems: orderItems,
      );

      if (orderId != null && mounted) {
        print(' Order created successfully: $orderId');

        final cart = Provider.of<CartProvider>(context, listen: false);
        cart.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pesanan berhasil! Order ID: ${orderId.substring(0, 8)}...',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print(' Error in _submitOrder: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(' Gagal memproses pesanan: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.only(
                top: headerPaddingTop,
                bottom: 10,
                left: 4,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Orders",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Customer',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _customerController,
                      decoration: const InputDecoration(
                        hintText: '',
                        hintStyle: TextStyle(color: Colors.grey),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Item',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),

                  ...widget.cartItems.map((item) => _buildOrderItem(item)),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey, width: 1.9),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow('Diskon', currentDiscount),
                        const SizedBox(height: 6),
                        _buildSummaryRow('Pajak (PPN)', widget.ppn),
                        const SizedBox(height: 12),
                        _buildSummaryRow('Total:', currentTotal, isTotal: true),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Payment Method',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPaymentMethod('Cash', Icons.payments_outlined),
                      const SizedBox(width: 20),
                      _buildPaymentMethod('Qris', Icons.qr_code_2_rounded),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              color: Colors.white,
              child: SizedBox(
                height: 50,
                width: 200,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D3E50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: Colors.grey.shade400,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Order',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey, width: 1.9),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.image.isNotEmpty
                  ? Image.network(item.image, fit: BoxFit.cover)
                  : const Icon(Icons.coffee, size: 32, color: Colors.brown),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatPrice(item.price),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF2D3E50),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF2D3E50),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${item.quantity}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, int value, {bool isTotal = false}) {
    if (label == 'Diskon') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          SizedBox(
            width: 100,
            height: 32,
            child: TextField(
              controller: _discountController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              onChanged: (value) => _updateDiscount(),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? Colors.black87 : Colors.grey.shade700,
          ),
        ),
        Text(
          _formatPrice(value),
          style: TextStyle(
            fontSize: isTotal ? 17 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethod(String method, IconData icon) {
    final bool isSelected = _selectedPaymentMethod == method;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedPaymentMethod = method);

        if (method == 'Cash') {
          _showCashDialog();
        }
      },
      child: Container(
        width: 100,
        height: 140,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2D3E50) : Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isSelected ? const Color(0xFF2D3E50) : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 6),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 40,
                color: isSelected
                    ? const Color(0xFF2D3E50)
                    : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              method,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _customerController.dispose();
    _discountController.dispose();
    super.dispose();
  }
}
