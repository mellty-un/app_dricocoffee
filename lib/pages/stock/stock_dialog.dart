import 'package:application_pos_dricocoffee/services/supabase_services.dart';
import 'package:flutter/material.dart';
import '../../models/product_models.dart';

class StockDialog extends StatefulWidget {
  final Product product;
  final VoidCallback onSuccess;

  const StockDialog({
    super.key,
    required this.product,
    required this.onSuccess,
  });

  @override
  State<StockDialog> createState() => _StockDialogState();
}

class _StockDialogState extends State<StockDialog> {
  late TextEditingController nameC;
  late TextEditingController stockC;
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    nameC = TextEditingController(text: widget.product.name);
    stockC = TextEditingController(text: widget.product.stock.toString());
  }

  @override
  void dispose() {
    nameC.dispose();
    stockC.dispose();
    super.dispose();
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final newStock = int.parse(stockC.text);
      final oldStock = widget.product.stock;

      await SupabaseService.updateProduct(
        productId: widget.product.productId,
        name: nameC.text.trim(),
        price: widget.product.price,
        categoryId: widget.product.categoryId!,
        stock: newStock,
        oldImageUrl: widget.product.image ?? "",
      );

      if (newStock != oldStock) {
        await SupabaseService.addStockHistory(
          productId: widget.product.productId,
          change: newStock - oldStock,
          beforeStock: oldStock,
          afterStock: newStock,
          orderId: null,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        _showSuccessPopup(context, "Update Success");
        widget.onSuccess();
      }
    } catch (e) {
      setState(() {
        errorMessage = "Gagal update produk. Coba lagi.";
      });
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  static void _showSuccessPopup(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (ctx) {
        Future.delayed(const Duration(seconds: 2), () {
          if (ctx.mounted) Navigator.pop(ctx);
        });
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 50),
                padding: const EdgeInsets.fromLTRB(32, 70, 32, 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 50),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: 320,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  child: const Icon(Icons.close, size: 24),
                  onTap: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: nameC,
                decoration: InputDecoration(
                  labelText: "Nama Produk",
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Nama produk tidak boleh kosong";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: stockC,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Stok",
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Stok tidak boleh kosong";
                  }
                  if (int.tryParse(value) == null) {
                    return "Stok harus berupa angka saja";
                  }
                  if (int.parse(value) < 0) {
                    return "Stok tidak boleh negatif";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _updateProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Update",
                          style:
                              TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
