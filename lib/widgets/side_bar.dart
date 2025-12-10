import 'package:application_pos_dricocoffee/pages/auth/sign_in_pages.dart';
import 'package:application_pos_dricocoffee/pages/cashier/cashier_pages.dart';
import 'package:application_pos_dricocoffee/pages/customer/customer_pages.dart';
import 'package:application_pos_dricocoffee/pages/dashboard/dashboard_pages.dart';
import 'package:application_pos_dricocoffee/pages/product/product_pages.dart';
import 'package:application_pos_dricocoffee/pages/reports/report_pages.dart';
import 'package:application_pos_dricocoffee/pages/stock/stock_pages.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class SideBar extends StatefulWidget {
  final String currentPage;
  const SideBar({super.key, this.currentPage = "Dashboard"});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  late String activePage;
  User? user;
  String userName = "User";
  String userEmail = "-";
  String userRole = "Admin";

  @override
  void initState() {
    super.initState();
    activePage = widget.currentPage;
    user = supabase.auth.currentUser;
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      if (user != null) {
        final response = await supabase
            .from('profiles')
            .select('name, role')
            .eq('user_id', user!.id)
            .single();

        setState(() {
          userName = response['name'] ?? "User";
          userRole = response['role'] ?? "Admin";
          userEmail = user?.email ?? "-";
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      setState(() {
        userName = user?.email?.split('@')[0] ?? "User";
        userEmail = user?.email ?? "-";
      });
    }
  }

  String getInitials(String name) {
    List<String> nameParts = name.trim().split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else if (nameParts.isNotEmpty && nameParts[0].isNotEmpty) {
      return nameParts[0]
          .substring(0, nameParts[0].length >= 2 ? 2 : 1)
          .toUpperCase();
    }
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 230,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 90, 8, 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(60),
              bottomRight: Radius.circular(60),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.only(left: 5, right: 20, bottom: 25),
                child: Row(
                  children: [
                    Container(
                      width: 25,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF36536b),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Image.asset(
                          "assets/images/drico_logo.png",
                          width: 70,
                          height: 90,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "DRICO",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF36536b),
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          "COFFEE",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            

              Padding(
                padding: const EdgeInsets.only(left: 5, right: 16, bottom: 25),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: const Color(0xFFe4e8eb),

                      child: Text(
                        getInitials(userName),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1C1C1C),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            userEmail,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:  const Color(0xFFEBEFF2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              userRole,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    menuItem(
                      Icons.dashboard_outlined,
                      "Dashboard",
                      active: activePage == "Dashboard",
                      onTap: () =>
                          navigateTo(const DashboardPages(), "Dashboard"),
                    ),
                    menuItem(
                      Icons.point_of_sale_outlined,
                      "Cashier",
                      active: activePage == "Cashier",
                      onTap: () => navigateTo(const CashierPages(), "Cashier"),
                    ),
                    menuItem(
                      Icons.inventory_2_outlined,
                      "Product",
                      active: activePage == "Product",
                      onTap: () => navigateTo(const ProductPages(), "Product"),
                    ),
                    menuItem(
                      Icons.people_outline,
                      "Customer",
                      active: activePage == "Customer",
                      onTap: () =>
                          navigateTo(const CustomerPages(), "Customer"),
                    ),
                    menuItem(
                      Icons.storage_outlined,
                      "Stock",
                      active: activePage == "Stock",
                      onTap: () => navigateTo(const StockPages(), "Stock"),
                    ),
                    menuItem(
                      Icons.receipt_long_outlined,
                      "Report",
                      active: activePage == "Report",
                      onTap: () => navigateTo(const ReportPages(), "Report"),
                    ),
                    const SizedBox(height: 10),

                    menuItem(
                      Icons.logout_outlined,
                      "Logout",
                      active: false,
                      onTap: () => _showLogoutDialog(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void navigateTo(Widget page, String pageName) {
    Navigator.pop(context);

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF36536b), width: 1),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Logout",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C1C1C),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Are you sure you want to logout?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),

                const SizedBox(height: 22),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        side: const BorderSide(color: Color(0xFF36536b)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Color(0xFF36536b),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF36536b),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        await supabase.auth.signOut();

                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignInPages(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      child: const Text(
                        "Logout",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget menuItem(
    IconData icon,
    String title, {
    required bool active,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          decoration: BoxDecoration(
            color: active ? const Color(0xFF36536b) : const Color(0xFFe4e8eb),
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 22, color: active ? Colors.white : Colors.black),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: active ? Colors.white : Colors.black,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
