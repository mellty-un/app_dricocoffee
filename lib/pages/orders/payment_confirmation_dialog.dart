import 'package:flutter/material.dart';
import 'package:application_pos_dricocoffee/providers/cart_providers.dart';
import 'package:application_pos_dricocoffee/pages/orders/receipt_dialog.dart';

class PaymentConfirmationDialog extends StatelessWidget {
  final int totalAmount;
  final String paymentMethod;
  final String customerName;
  final int itemCount;
  final List<CartItem> cartItems;
  final int cashAmount;
  final int change;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  
  final String? cashierName;
  final String? transactionCode;

  const PaymentConfirmationDialog({
    Key? key,
    required this.totalAmount,
    required this.paymentMethod,
    required this.customerName,
    required this.itemCount,
    required this.cartItems,
    required this.cashAmount,
    required this.change,
    required this.onConfirm,
    required this.onCancel,
    this.cashierName,
    this.transactionCode,
  }) : super(key: key);

  String _formatPrice(int price) {
    return 'Rp ${price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}';
  }

  void _handleConfirm(BuildContext context) {
    Navigator.pop(context);
    Navigator.pop(context);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ReceiptDialog(
        cartItems: cartItems,
        subtotal: totalAmount,
        total: totalAmount,
        cashAmount: cashAmount,
        change: change,
        paymentMethod: paymentMethod,
        cashierName: cashierName ?? "Kasir",
        customerName: customerName,
        transactionCode: transactionCode ?? "TRX${DateTime.now().millisecondsSinceEpoch}",
      ),
    );
    
    onConfirm();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 340,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),

            const Text(
              "Konfirmasi Transaction",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 22),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildInfoRow("Pelanggan", customerName),
                  const SizedBox(height: 12),

                  _buildInfoRow("Item", "$itemCount Produk"),
                  const SizedBox(height: 12),

                  _buildInfoRow("Metode pembayaran", paymentMethod),
                  const SizedBox(height: 12),

                  _buildInfoRow("Total", _formatPrice(totalAmount), isBold: true),
                  const SizedBox(height: 12),

                  _buildInfoRow("Cash", _formatPrice(cashAmount)),
                  const SizedBox(height: 12),

                  _buildInfoRow("Kembalian", _formatPrice(change), isBold: true),
                ],
              ),
            ),

  

            const SizedBox(height: 28),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.grey.shade400,
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _handleConfirm(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2C3E50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1,
                      ),
                      child: const Text(
                        "Confirm",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}