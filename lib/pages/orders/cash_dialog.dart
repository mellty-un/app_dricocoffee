import 'package:application_pos_dricocoffee/pages/orders/payment_confirmation_dialog.dart';
import 'package:application_pos_dricocoffee/providers/cart_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CashDialog extends StatefulWidget {
  final int totalAmount;
  final String customerName;
  final List<CartItem> cartItems;
  final Function(int, int) onPaymentConfirmed;
  
  final String? cashierName;
  final String? transactionCode;

  const CashDialog({
    Key? key,
    required this.totalAmount,
    required this.customerName,
    required this.cartItems,    
    required this.onPaymentConfirmed,
    this.cashierName,
    this.transactionCode,
  }) : super(key: key);

  @override
  State<CashDialog> createState() => _CashDialogState();
}

class _CashDialogState extends State<CashDialog> {
  final TextEditingController _cashController = TextEditingController();
  int _change = 0;

  void _calculateChange() {
    final cleaned = _cashController.text.replaceAll(RegExp(r'[^0-9]'), "");
    final cashAmount = int.tryParse(cleaned) ?? 0;
    setState(() => _change = cashAmount - widget.totalAmount);
  }

  void _validateAndPay() {
    final rawText = _cashController.text.replaceAll(RegExp(r'[^0-9]'), "");

    if (rawText.isEmpty) {
      _showError("Masukkan nominal pembayaran.");
      return;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(rawText)) {
      _showError("Input pembayaran hanya boleh angka.");
      return;
    }

    final cash = int.parse(rawText);

    if (cash < widget.totalAmount) {
      _showError("Uang kurang dari total pembayaran.");
      return;
    }

    print("=== DEBUG CashDialog ===");
    print("Cart Items: ${widget.cartItems.length}");
    for (var item in widget.cartItems) {
      print("  - ${item.name} x${item.quantity} @ ${item.price}");
    }
    print("Total: ${widget.totalAmount}");
    print("Cash: $cash");
    print("Change: ${cash - widget.totalAmount}");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentConfirmationDialog(
        totalAmount: widget.totalAmount,
        paymentMethod: "Cash",
        customerName: widget.customerName,
        itemCount: widget.cartItems.length,
        cartItems: widget.cartItems,
        cashAmount: cash,
        change: cash - widget.totalAmount,
        cashierName: widget.cashierName,
        transactionCode: widget.transactionCode,
        onConfirm: () {
          widget.onPaymentConfirmed(cash, cash - widget.totalAmount);
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "amount of money",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 24),

            TextField(
              controller: _cashController,
              onChanged: (v) => _calculateChange(),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                prefixText: "Rp. ",
                prefixStyle: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                hintText: "0",
                hintStyle: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black26,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              height: 1.5,
              color: Colors.black26,
            ),

            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFFD0D5DD),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _validateAndPay,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF334155),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Payment",
                        style: TextStyle(
                          fontSize: 15,
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

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }
}