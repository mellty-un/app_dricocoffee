import 'package:application_pos_dricocoffee/models/product_models.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://sbzwwewovvbtzyvrvpeh.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNiend3ZXdvdnZidHp5dnJ2cGVoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA5OTY2MTgsImV4cCI6MjA3NjU3MjYxOH0.gMFWTAt6aQmfGetEFin4eoc90kE9E-Ibpnw_0AKo_AI';

  static final client = Supabase.instance.client;
  static String currentUserName = '';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
      final profile = await fetchCurrentUserProfile();
  if (profile != null) {
    currentUserName = profile['name'] ?? '';
    print('🔄 Auto load kasir: $currentUserName');
  }
}
  
  
  



  static Future<void> addStockHistory({
  required int productId,
  required int change,
  required int beforeStock,
  required int afterStock,
  String? orderId,
}) async {
  try {
    final userId = getCurrentUserId();
    
    if (userId == null) {
      throw Exception('User tidak login');
    }

    await client.from('stock_histories').insert({
      'product_id': productId,
      'user_id': userId,
      'change': change,
      'before_stock': beforeStock,
      'after_stock': afterStock,
      'order_id': orderId,
      'created_at': DateTime.now().toIso8601String(),
    });
    
    print(' Stock history added: product=$productId, change=$change');
  } catch (e) {
    print(' Error adding stock history: $e');
    rethrow;
  }
}


  // ==================== CUSTOMERS ====================


    // TAMBAHKAN FUNGSI INI DI SUPABASE SERVICE KAMU
  static Future<List<Map<String, dynamic>>> fetchCustomerOrderHistory(int customerId) async {
    try {
      final response = await client
          .from('orders')
          .select('''
            order_id,
            date,
            total_price,
            total_item,
            order_details!order_id (
              quantity,
              price,
              products ( name, image )
            )
          ''')
          .eq('customer_id', customerId)
          .order('date', ascending: false);

      // Ubah struktur biar lebih mudah dipakai
      List<Map<String, dynamic>> result = [];
      for (var order in response) {
        final items = order['order_details'] as List<dynamic>? ?? [];
        result.add({
          'order_id': order['order_id'],
          'date': order['date'],
          'total_price': order['total_price'] ?? 0,
          'total_item': order['total_item'] ?? 0,
          'items': items,
        });
      }
      return result;
    } catch (e) {
      print('Error fetchCustomerOrderHistory: $e');
      rethrow;
    }
  }
  
  static Future<int> getOrCreateCustomer(String customerName) async {
    try {
      final existingCustomers = await client
          .from('customers')
          .select('customer_id, name')
          .eq('name', customerName)
          .maybeSingle();

      if (existingCustomers != null) {
        print('✅ Customer found: ${existingCustomers['customer_id']} - ${existingCustomers['name']}');
        return existingCustomers['customer_id'] as int;
      }

      print('📝 Creating new customer: $customerName');
      final newCustomer = await client
          .from('customers')
          .insert({
            'name': customerName,
          })
          .select('customer_id')
          .single();

      print('✅ New customer created: ${newCustomer['customer_id']}');
      return newCustomer['customer_id'] as int;
      
    } catch (e) {
      print('❌ Error in getOrCreateCustomer: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchCustomers() async {
    try {
      final customersResponse = await client
          .from('customers')
          .select('customer_id, name, address, phone')
          .order('name', ascending: true);

      List<Map<String, dynamic>> customersWithOrders = [];

      for (var customer in customersResponse) {
        final customerId = customer['customer_id'] as int;
        
        final ordersResponse = await client
            .from('orders')
            .select('total_price, total_item')
            .eq('customer_id', customerId);

        int totalOrder = ordersResponse.length;
        
        int totalPrice = 0;
        for (var order in ordersResponse) {
          totalPrice += (order['total_price'] ?? 0) as int;
        }

        customersWithOrders.add({
          'customer_id': customerId,
          'name': customer['name'] ?? '',
          'address': customer['address'],
          'phone': customer['phone'],
          'total_order': totalOrder,
          'total_price': totalPrice,
        });
      }

      return customersWithOrders;
    } catch (e) {
      print('Error fetching customers: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchCustomerOrders(int customerId) async {
    try {
      final response = await client
          .from('orders')
          .select('order_id, date, total_price, total_item, payment_method')
          .eq('customer_id', customerId)
          .order('date', ascending: false);
      
      return (response as List).map((data) => data as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error fetching customer orders: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchOrderDetails(String orderId) async {
    try {
      final response = await client
          .from('order_details')
          .select('''
            id,
            quantity,
            price,
            discount,
            final_price,
            product_id,
            products(name, image)
          ''')
          .eq('order_id', orderId);
      
      return (response as List).map((data) => data as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error fetching order details: $e');
      rethrow;
    }
  }

  static Future<void> addCustomer(String name, String address, String phone) async {
    try {
      await client.from('customers').insert({
        "name": name,
        "address": address.isEmpty ? null : address,
        "phone": phone.isEmpty ? null : phone,
      });
    } catch (e) {
      print('Error adding customer: $e');
      rethrow;
    }
  }

  static Future<void> updateCustomer(int id, String name, String address, String phone) async {
    try {
      await client.from('customers').update({
        "name": name,
        "address": address.isEmpty ? null : address,
        "phone": phone.isEmpty ? null : phone,
      }).eq("customer_id", id);
    } catch (e) {
      print('Error updating customer: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getCustomers() async {
  try {
    final response = await client
        .from('customers')
        .select()
        .order('name', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    print('Error getting customers: $e');
    rethrow;
  }
}

  static Future<void> deleteCustomer(int id) async {
    try {
      await client.from('customers').delete().eq("customer_id", id);
    } catch (e) {
      print('Error deleting customer: $e');
      rethrow;
    }
  }

  // ==================== PRODUCTS ====================
static Stream<List<Product>> get productStream {
  return client
      .from('products')
      .stream(primaryKey: ['product_id'])
      .order('name', ascending: true)
      .map((List<Map<String, dynamic>> data) {
        final activeProducts = data.where((json) {
          final deletedAt = json['deleted_at'];
          final isDeleted = json['is_deleted'] == true;
          return deletedAt == null && !isDeleted;
        }).toList();
        
        return activeProducts
            .map((json) => Product.fromJson(json))
            .toList();
      });
}

static Future<List<Product>> fetchProducts() async {
  try {
    final response = await client
        .from('products')
        .select('*')
        .order('name', ascending: true);

    return (response as List)
        .map((json) => Product.fromJson(json))
        .toList();
  } catch (e) {
    print('Error fetching products: $e');
    return [];
  }
}

  static Future<void> addProduct({
    required String name,
    required int price,
    required int categoryId,
    required int stock,
    XFile? imageFile,
  }) async {
    String imageUrl = '';

    if (imageFile != null) {
      try {
        final ext = imageFile.name.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
        final path = 'products/$fileName';

        final bytes = await imageFile.readAsBytes();

        await client.storage.from('products').uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: 'image/$ext',
            upsert: false,
          ),
        );

        imageUrl = client.storage.from('products').getPublicUrl(path);
        print('Image uploaded: $imageUrl');
      } catch (e) {
        print('Error uploading image: $e');
        rethrow;
      }
    }

    try {
      await client.from('products').insert({
        'name': name,
        'price': price,
        'category_id': categoryId,
        'stock': stock,
        'image': imageUrl,
      });
      print('Product added successfully');
    } catch (e) {
      print('Error inserting product: $e');
      rethrow;
    }
  }

  static Future<void> updateProduct({
    required int productId,
    required String name,
    required int price,
    required int categoryId,
    required int stock,
    XFile? imageFile,
    required String oldImageUrl,
  }) async {
    String imageUrl = oldImageUrl;

    if (imageFile != null) {
      if (oldImageUrl.isNotEmpty && oldImageUrl.contains('supabase.co')) {
        try {
          final uri = Uri.parse(oldImageUrl);
          final fileName = uri.pathSegments.last;
          await client.storage.from('products').remove([fileName]);
        } catch (e) {
          print('Gagal hapus gambar lama: $e');
        }
      }

      try {
        final ext = imageFile.name.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
        final path = 'products/$fileName';

        final bytes = await imageFile.readAsBytes();
        await client.storage.from('products').uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: 'image/$ext'),
        );

        imageUrl = client.storage.from('products').getPublicUrl(path);
      } catch (e) {
        print('Error upload gambar baru: $e');
      }
    }

    await client.from('products').update({
      'name': name,
      'price': price,
      'category_id': categoryId,
      'stock': stock,
      'image': imageUrl,
    }).eq('product_id', productId);
  }

static Future<void> deleteProduct(int productId, String imageUrl) async {
  try {
    await client
        .from('stock_histories')
        .delete()
        .eq('product_id', productId);

    await client
        .from('order_details')
        .delete()
        .eq('product_id', productId);

    if (imageUrl.isNotEmpty && imageUrl.contains('supabase.co')) {
      final uri = Uri.parse(imageUrl);
      final fileName = uri.pathSegments.last;
      await client.storage.from('products').remove([fileName]);
    }

    await client
        .from('products')
        .delete()
        .eq('product_id', productId);

    print("Product deleted successfully");
  } catch (e) {
    print("Error delete: $e");
    rethrow;
  }
}
  // ==================== CATEGORIES ====================
  
  static Future<List<Map<String, dynamic>>> fetchCategories() async {
    try {
      final response = await client
          .from('categories')
          .select('category_id, name')
          .order('name', ascending: true);
      
      return (response as List).map((data) => data as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow;
    }
  }

  // ==================== ORDERS ====================
  
  static Future<List<Map<String, dynamic>>> fetchOrders() async {
    try {
      final response = await client
          .from('orders')
          .select('''
            order_id,
            date,
            total_price,
            total_item,
            payment_method,
            customer_id,
            customers(name),
            user_id,
            profiles(name)
          ''')
          .order('date', ascending: false);
      
      return (response as List).map((data) => data as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error fetching orders: $e');
      rethrow;
    }
  }

static Future<String?> createOrder({
  required int totalPrice,
  required int totalItem,
  required int customerId,
  required String paymentMethod,
  required String userId,
  required List<Map<String, dynamic>> orderItems,
}) async {
  try {
    print('Creating order for customer_id: $customerId');
    print('User ID for order: $userId');

    final orderResponse = await client
        .from('orders')
        .insert({
          "total_price": totalPrice,
          "total_item": totalItem,
          "customer_id": customerId,        
          "payment_method": paymentMethod,
          "user_id": userId,
        })
        .select('order_id')         
        .single();

    final String orderId = orderResponse['order_id'] as String;
    print('Order created with ID: $orderId');

    List<Map<String, dynamic>> orderDetailsData = orderItems.map((item) {
      return {
        "order_id": orderId,                   
        "product_id": item['product_id'],
        "quantity": item['quantity'],
        "price": item['price'],
        "discount": item['discount'] ?? 0,
        "final_price": item['final_price'],
      };
    }).toList();

    await client.from('order_details').insert(orderDetailsData);
    print('${orderDetailsData.length} order details inserted');

    for (var item in orderItems) {
      final int productId = item['product_id'] as int;
      final int quantity = item['quantity'] as int;

      final productResponse = await client
          .from('products')
          .select('stock')
          .eq('product_id', productId)
          .single();

      final int currentStock = productResponse['stock'] as int;
      final int newStock = currentStock - quantity;

      await client
          .from('products')
          .update({"stock": newStock}).eq("product_id", productId);

      await client.from('stock_histories').insert({
        "product_id": productId,
        "user_id": userId,
        "order_id": orderId,
        "before_stock": currentStock,
        "after_stock": newStock,
        "change": -quantity,
      });

      print('Stock updated for product $productId: $currentStock → $newStock');
    }

    print('Order completed successfully!');
    return orderId;
  } catch (e) {
    print('Error creating order: $e');
    rethrow;
  }
}
  // ==================== STOCK HISTORIES ====================
  
static Future<List<Map<String, dynamic>>> fetchStockHistories({
  int? productId,
  int limit = 50,
}) async {
  try {
    var query = client
        .from('stock_histories')
        .select('''
          riwayat_id,
          before_stock,
          after_stock,
          change,
          created_at,
          product_id,
          products(name, image),
          user_id,
          profiles(name),
          order_id
        ''')
        .order('created_at', ascending: false)
        .limit(limit);
    
    final response = await query;
    
    return (response as List).map((data) => data as Map<String, dynamic>).toList();
  } catch (e) {
    print('Error fetching stock histories: $e');
    rethrow;
  }
}
  static Future<void> addStockAdjustment({
    required int productId,
    required String userId,
    required int changeAmount,
    required String reason,
  }) async {
    try {
      final productResponse = await client
          .from('products')
          .select('stock')
          .eq('product_id', productId)
          .single();

      final currentStock = productResponse['stock'] as int;
      final newStock = currentStock + changeAmount;

      await client.from('products').update({
        "stock": newStock,
      }).eq("product_id", productId);

      await client.from('stock_histories').insert({
        "product_id": productId,
        "user_id": userId,
        "before_stock": currentStock,
        "after_stock": newStock,
        "change": changeAmount,
      });
    } catch (e) {
      print('Error adding stock adjustment: $e');
      rethrow;
    }
  }

  
  static Future<Map<String, dynamic>?> fetchCurrentUserProfile() async {
    try {
      final user = client.auth.currentUser;
      if (user == null) return null;

      final response = await client
          .from('profiles')
          .select('user_id, name, role, created_at')
          .eq('user_id', user.id)
          .single();

      return response;
    } catch (e) {
      print('Error fetching user profile: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    try {
      final response = await client
          .from('profiles')
          .select('user_id, name, role, created_at')
          .order('name', ascending: true);
      
      return (response as List).map((data) => data as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error fetching users: $e');
      rethrow;
    }
  }

  static Future<void> updateUserProfile({
    required String userId,
    required String name,
    required String role,
  }) async {
    try {
      await client.from('profiles').update({
        "name": name,
        "role": role,
        "updated_at": DateTime.now().toIso8601String(),
      }).eq("user_id", userId);
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // ==================== AUTHENTICATION ====================


  static Future<void> signUp({
    required String email,
    required String password,
    required String name,
    String role = 'officer',
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await client.from('profiles').insert({
          "user_id": response.user!.id,
          "name": name,
          "role": role,
        });
      }
    } catch (e) {
      print('Error signing up: $e');
      rethrow;
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  static bool isAuthenticated() {
    return client.auth.currentUser != null;
  }

  /// Get current user ID
  static String? getCurrentUserId() {
    final userId = client.auth.currentUser?.id;
    print(' Current User ID: $userId'); 
    return userId;
  }
}