import 'dart:io';
import 'package:application_pos_dricocoffee/services/supabase_services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:application_pos_dricocoffee/models/product_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductDialogs {
  static Future<void> showAddDialog(
    BuildContext context,
    List<Map<String, dynamic>> categories,
    Function onProductAdded,
  ) async {
    final client = Supabase.instance.client;

    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    XFile? selectedImage;

    String? nameError;
    String? priceError;
    String? stockError;
    String? categoryError;
    String? imageError;

    final validCategories = categories
        .where((cat) => cat['category_id'] != 0)
        .toList();
    String? selectedCategoryId = validCategories.isNotEmpty
        ? validCategories.first['category_id'].toString()
        : null;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: 420,
                constraints: const BoxConstraints(
                  maxWidth: 480,
                  minWidth: 340,
                  maxHeight: 720,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFebeff2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey, width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    const Padding(
                      padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Center(
                        child: Text(
                          "Add Product",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Name Product",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: nameController,
                              decoration: cleanInputDecoration(
                                hintText: '',
                                errorText: nameError,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  nameError = validateName(value);
                                });
                              },
                            ),
                            const SizedBox(height: 16),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Category",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      DropdownButtonFormField<String>(
                                        value: selectedCategoryId,
                                        decoration: cleanInputDecoration(
                                          errorText: categoryError,
                                        ),
                                        items: validCategories.map((cat) {
                                          return DropdownMenuItem(
                                            value: cat['category_id']
                                                .toString(),
                                            child: Text(
                                              cat['name'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          setState(() {
                                            selectedCategoryId = val;
                                            categoryError = validateCategory(
                                              val,
                                            );
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Stock",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: stockController,
                                        keyboardType: TextInputType.text,
                                        decoration: cleanInputDecoration(
                                          hintText: '',
                                          errorText: stockError,
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            stockError = null;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            const Text(
                              "Price",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: priceController,
                              keyboardType: TextInputType.text,
                              decoration: cleanInputDecoration(
                                hintText: 'Masukkan harga',
                                errorText: priceError,
                              ).copyWith(prefixText: 'Rp '),
                              onChanged: (value) {
                                setState(() {
                                  priceError = null;
                                });
                              },
                            ),
                            const SizedBox(height: 16),

                            const Text(
                              "Image",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () async {
                                try {
                                  final picker = ImagePicker();
                                  final picked = await picker.pickImage(
                                    source: ImageSource.gallery,
                                    imageQuality: 85,
                                    maxWidth: 1920,
                                    maxHeight: 1920,
                                  );
                                  if (picked != null) {
                                    final bytes = await picked.readAsBytes();
                                    if (bytes.length > 5 * 1024 * 1024) {
                                      setState(() {
                                        imageError =
                                            'Ukuran gambar harus kurang dari 5MB';
                                        selectedImage = null;
                                      });
                                      _showErrorSnackBar(
                                        context,
                                        'Gambar terlalu besar. Maksimal 5MB',
                                      );
                                      return;
                                    }
                                    setState(() {
                                      selectedImage = picked;
                                      imageError = null;
                                    });
                                  }
                                } catch (e) {
                                  _showErrorSnackBar(
                                    context,
                                    'Gagal memilih gambar: $e',
                                  );
                                }
                              },
                              child: Container(
                                height: selectedImage == null ? 56 : 200,
                                width: selectedImage == null
                                    ? MediaQuery.of(context).size.width * 0.45
                                    : double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: imageError != null
                                        ? Colors.red
                                        : const Color(0xFF475569),
                                    width: 1.6,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.09),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                      spreadRadius: -3,
                                    ),
                                  ],
                                ),
                                child: selectedImage == null
                                    ?  const SizedBox()
                                    : Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            child: _buildImagePreviewFromXFile(
                                              selectedImage!,
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(
                                                  0.6,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    selectedImage = null;
                                                    imageError = null;
                                                  });
                                                },
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                constraints:
                                                    const BoxConstraints(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            if (imageError != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  left: 12,
                                ),
                                child: Text(
                                  imageError!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                side: const BorderSide(
                                  color: Color(0xFF475569),
                                  width: 1.6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final name = nameController.text.trim();
                                final priceText = priceController.text.trim();
                                final stockText = stockController.text.trim();

                                setState(() {
                                  nameError = validateName(name);
                                  priceError = validatePrice(priceText);
                                  stockError = validateStock(stockText);
                                  categoryError = validateCategory(
                                    selectedCategoryId,
                                  );
                                });

                                if (nameError != null ||
                                    priceError != null ||
                                    stockError != null ||
                                    categoryError != null) {
                                  _showErrorSnackBar(
                                    context,
                                    'Mohon perbaiki semua kesalahan sebelum menyimpan',
                                  );
                                  return;
                                }

                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );

                                try {
                                  final priceNumeric = priceText.replaceAll(
                                    RegExp(r'[^0-9]'),
                                    '',
                                  );
                                  final stockNumeric = stockText.replaceAll(
                                    RegExp(r'[^0-9]'),
                                    '',
                                  );

                                  String imageUrl = '';
                                  if (selectedImage != null) {
                                    final ext = selectedImage!.name
                                        .split('.')
                                        .last;
                                    final fileName =
                                        '${DateTime.now().millisecondsSinceEpoch}.$ext';
                                    final path = 'products/$fileName';
                                    final bytes = await selectedImage!
                                        .readAsBytes();

                                    await client.storage
                                        .from('products')
                                        .uploadBinary(
                                          path,
                                          bytes,
                                          fileOptions: FileOptions(
                                            contentType: 'image/$ext',
                                            upsert: false,
                                          ),
                                        );
                                    imageUrl = client.storage
                                        .from('products')
                                        .getPublicUrl(path);
                                  }

                                  await client.from('products').insert({
                                    'name': name,
                                    'price': int.parse(priceNumeric),
                                    'category_id': int.parse(
                                      selectedCategoryId!,
                                    ),
                                    'stock': int.parse(stockNumeric),
                                    'image': imageUrl,
                                  });

                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    Navigator.pop(dialogContext);
                                    onProductAdded();

                                    _showSuccessPopup(
                                      context,
                                      'Add Product Success',
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    _showErrorSnackBar(
                                      context,
                                      'Gagal menambahkan produk: ${e.toString()}',
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF475569),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                "Save",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Future<void> showEditDialog(
    BuildContext context,
    Product product,
    List<Map<String, dynamic>> categories,
    VoidCallback onClose,
    VoidCallback onRefresh,
  ) async {
    final nameController = TextEditingController(text: product.name);
    final priceController = TextEditingController(
      text: product.price.toString(),
    );
    final stockController = TextEditingController(
      text: product.stock.toString(),
    );

    XFile? selectedImage;
    String? currentImageUrl = product.image.isNotEmpty ? product.image : null;

    String? nameError;
    String? priceError;
    String? stockError;
    String? categoryError;
    String? imageError;

    final validCategories = categories
        .where((cat) => cat['category_id'] != 0)
        .toList();
    String selectedCategoryId = product.categoryId.toString();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: 420,
                constraints: const BoxConstraints(
                  maxWidth: 480,
                  minWidth: 340,
                  maxHeight: 720,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFebeff2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey, width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Center(
                        child: Text(
                          "Edit Product",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Image",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () async {
                                try {
                                  final picker = ImagePicker();
                                  final picked = await picker.pickImage(
                                    source: ImageSource.gallery,
                                    imageQuality: 85,
                                    maxWidth: 1920,
                                    maxHeight: 1920,
                                  );
                                  if (picked != null) {
                                    final bytes = await picked.readAsBytes();
                                    if (bytes.length > 5 * 1024 * 1024) {
                                      setState(() {
                                        imageError =
                                            'Image size must be less than 5MB';
                                      });
                                      _showErrorSnackBar(
                                        context,
                                        'Image too large. Maximum size is 5MB',
                                      );
                                      return;
                                    }
                                    setState(() {
                                      selectedImage = picked;
                                      imageError = null;
                                    });
                                  }
                                } catch (e) {
                                  _showErrorSnackBar(
                                    context,
                                    'Failed to pick image: $e',
                                  );
                                }
                              },
                              child: Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: imageError != null
                                        ? Colors.red
                                        : const Color(0xFF475569),
                                    width: 1.6,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: selectedImage != null
                                          ? _buildImagePreviewFromXFile(
                                              selectedImage!,
                                            )
                                          : (currentImageUrl != null &&
                                                currentImageUrl.startsWith(
                                                  'http',
                                                ))
                                          ? Image.network(
                                              currentImageUrl,
                                              fit: BoxFit.contain,
                                              width: double.infinity,
                                              height: double.infinity,
                                              errorBuilder: (_, __, ___) =>
                                                  const Center(
                                                    child: Icon(
                                                      Icons.image,
                                                      size: 60,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                            )
                                          : const Center(
                                              child: Icon(
                                                Icons.image,
                                                size: 60,
                                                color: Colors.grey,
                                              ),
                                            ),
                                    ),
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          color: Colors.black.withOpacity(0.0),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.camera_alt_outlined,
                                            size: 40,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (imageError != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  left: 12,
                                ),
                                child: Text(
                                  imageError!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),

                            const Text(
                              "Name Product",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: nameController,
                              decoration: cleanInputDecoration(
                                hintText: '',
                                errorText: nameError,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  nameError = validateName(value);
                                });
                              },
                            ),
                            const SizedBox(height: 16),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Category",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      DropdownButtonFormField<String>(
                                        value: selectedCategoryId,
                                        decoration: cleanInputDecoration(
                                          errorText: categoryError,
                                        ),
                                        items: validCategories.map((cat) {
                                          return DropdownMenuItem(
                                            value: cat['category_id']
                                                .toString(),
                                            child: Text(
                                              cat['name'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          setState(() {
                                            selectedCategoryId = val!;
                                            categoryError = validateCategory(
                                              val,
                                            );
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Stock",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: stockController,
                                        keyboardType: TextInputType.text,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          LengthLimitingTextInputFormatter(5),
                                        ],
                                        decoration: cleanInputDecoration(
                                          hintText: '0',
                                          errorText: stockError,
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            stockError = validateStock(value);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Price
                            const Text(
                              "Price",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: priceController,
                              keyboardType: TextInputType.text,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(9),
                              ],
                              decoration: cleanInputDecoration(
                                hintText: 'Enter price',
                                errorText: priceError,
                              ).copyWith(prefixText: 'Rp '),
                              onChanged: (value) {
                                setState(() {
                                  priceError = validatePrice(value);
                                });
                              },
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                side: const BorderSide(
                                  color: Color(0xFF475569),
                                  width: 1.6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final name = nameController.text.trim();
                                final priceText = priceController.text
                                    .replaceAll(RegExp(r'[^0-9]'), '');
                                final stockText = stockController.text.trim();

                                setState(() {
                                  nameError = validateName(name);
                                  priceError = validatePrice(priceText);
                                  stockError = validateStock(stockText);
                                  categoryError = validateCategory(
                                    selectedCategoryId,
                                  );
                                });

                                if (nameError != null ||
                                    priceError != null ||
                                    stockError != null ||
                                    categoryError != null) {
                                  _showErrorSnackBar(
                                    context,
                                    'Please fix all errors before saving',
                                  );
                                  return;
                                }

                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );

                                try {
                                  await SupabaseService.updateProduct(
                                    productId: product.productId,
                                    name: name,
                                    price: int.parse(priceText),
                                    categoryId: int.parse(selectedCategoryId),
                                    stock: int.parse(stockText),
                                    imageFile: selectedImage,
                                    oldImageUrl: product.image,
                                  );

                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    Navigator.pop(dialogContext);

                                    onClose();
                                    _showSuccessPopup(
                                      context,
                                      "updated successfully!",
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    _showErrorSnackBar(
                                      context,
                                      'Failed to update product: ${e.toString()}',
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF475569),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                "Save",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

static Future<void> showDeleteDialog(
  BuildContext context,
  Product product,
  VoidCallback onSuccess,
) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 60),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              
              const Text(
                "Delete",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                "Are you sure you want to delete this product?",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 26),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 90,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: const BorderSide(color: Color(0xFF475569)),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  /// Delete Button
                  SizedBox(
                    width: 90,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          await SupabaseService.deleteProduct(
                            product.productId,
                            product.image,
                          );

                          if (context.mounted) Navigator.pop(context);
                          if (context.mounted) Navigator.pop(context); 

                          _showSuccessPopup(context, 'Delete Success');
                          onSuccess();
                        } catch (e) {
                          if (context.mounted) Navigator.pop(context);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Failed to delete: $e")),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF475569),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Delete",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    },
  );
}


  static String? validateName(String value) {
    if (value.trim().isEmpty) {
      return 'Nama produk wajib diisi';
    }
    if (value.trim().length < 3) {
      return 'Nama produk minimal 3 karakter';
    }
    if (value.trim().length > 100) {
      return 'Nama produk maksimal 100 karakter';
    }
    return null;
  }

  static String? validatePrice(String value) {
    final numericValue = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (numericValue.isEmpty) {
      return 'Harga harus berisi angka saja';
    }

    final parsedValue = int.tryParse(numericValue);
    if (parsedValue == null) {
      return 'Format harga tidak valid';
    }

    if (parsedValue <= 0) {
      return 'Harga harus lebih dari 0';
    }

    if (parsedValue > 999999999) {
      return 'Harga terlalu tinggi';
    }

    return null;
  }

  static String? validateStock(String value) {
    if (value.trim().isEmpty) {
      return 'Stok berupa angka';
    }

    final numericValue = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (numericValue.isEmpty) {
      return 'Stok harus berisi angka saja';
    }

    final stock = int.tryParse(numericValue);
    if (stock == null) {
      return 'Format stok tidak valid';
    }

    if (stock < 0) {
      return 'Stok tidak boleh negatif';
    }

    if (stock > 99999) {
      return 'Stok terlalu tinggi (maks 99999)';
    }

    return null;
  }

  static String? validateCategory(String? categoryId) {
    if (categoryId == null || categoryId.isEmpty) {
      return 'Silakan pilih kategori';
    }
    return null;
  }

  static InputDecoration cleanInputDecoration({
    String? hintText,
    String? errorText,
  }) {
    return InputDecoration(
      hintText: hintText,
      errorText: errorText,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF475569), width: 1.6),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF475569), width: 1.6),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF475569), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.6),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
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
                   mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      message,
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

  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
      ),
    );
  }


  static Widget _buildImagePreviewFromXFile(XFile file) {
    if (kIsWeb) {
      return Image.network(
        file.path,
        fit: BoxFit.contain,
        width: double.infinity,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.image, size: 50, color: Colors.grey),
      );
    } else {
      return Image.file(
        File(file.path),
        fit: BoxFit.contain,
        width: double.infinity,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.image, size: 50, color: Colors.grey),
      );
    }
  }
}
