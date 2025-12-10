import 'package:application_pos_dricocoffee/pages/customer/customer_card.dart';
import 'package:application_pos_dricocoffee/pages/customer/customer_dialog.dart';
import 'package:application_pos_dricocoffee/services/supabase_services.dart';
import 'package:application_pos_dricocoffee/widgets/side_bar.dart';
import 'package:flutter/material.dart';

class CustomerPages extends StatefulWidget {
  const CustomerPages({super.key});

  @override
  State<CustomerPages> createState() => _CustomerPagesState();
}

class _CustomerPagesState extends State<CustomerPages> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> filteredCustomers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCustomers();
    _searchController.addListener(_filterCustomers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _navigateToHistory(Map<String, dynamic> customer) {
    Navigator.pushNamed(
      context,
      '/customer-history',
      arguments: {
        'customerId': customer['customer_id'],
        'customerName': customer['name'] ?? 'Customer',
      },
    );
  }
  
  
  Future<void> fetchCustomers() async {
    setState(() => isLoading = true);
    
    try {
      final data = await SupabaseService.fetchCustomers();
      if (!mounted) return;
      
      setState(() {
        customers = data;
        filteredCustomers = data;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading customers: $e");
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading customers: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _filterCustomers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredCustomers = customers;
      } else {
        filteredCustomers = customers.where((customer) {
          final name = customer['name']?.toString().toLowerCase() ?? '';
          final phone = customer['phone']?.toString().toLowerCase() ?? '';
          return name.contains(query) || phone.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _showAddEditDialog({Map<String, dynamic>? customer}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => CustomerDialog(
        customer: customer,
        isEdit: customer != null,
      ),
    );

   if (result == true && mounted) {
  await fetchCustomers();
  setState(() {}); 
}

    }
  
Future<void> _deleteCustomer(Map<String, dynamic> customer) async {
  final bool? result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => DeleteConfirmationDialog(
      customerName: customer['name'] ?? 'Customer ini',
      customerId: customer['customer_id'] as int,
    ),
  );

  if (result == true && mounted) {
    await fetchCustomers();
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Customer berhasil dihapus'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
  drawer: const SideBar(currentPage: "Customer"),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchCustomers,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, size: 32, color: Colors.black87),
                      onPressed: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      "Customer",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.black26),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.black54),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: "Search",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  InkWell(
                    onTap: () => _showAddEditDialog(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: const Row(
                        children: [
                          Text(
                            "Add Customer",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.add_box, size: 26),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                ),

              if (!isLoading && filteredCustomers.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'No customers yet'
                              : 'No customers found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (!isLoading && filteredCustomers.isNotEmpty)
                Column(
                  children: filteredCustomers.map((customer) {
                    return CustomerCard(
                      customer: customer,
                      onEdit: () => _showAddEditDialog(customer: customer),
                      onDelete: () => _deleteCustomer(customer),
                      onHistory: () => _navigateToHistory(customer),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}