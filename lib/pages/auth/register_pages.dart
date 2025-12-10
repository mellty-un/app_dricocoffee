import 'package:application_pos_dricocoffee/pages/dashboard/dashboard_pages.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class RegisterPages extends StatefulWidget {
  const RegisterPages({super.key});

  @override
  State<RegisterPages> createState() => _RegisterPagesState();
}

class _RegisterPagesState extends State<RegisterPages> {
  bool obscurePassword = true;
  final TextEditingController roleController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoadingPage = true;
  bool isAdmin = false;
  bool isSubmitting = false;

  String? nameError;
  String? emailError;
  String? passwordError;
  String? roleError;

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    final user = supabase.auth.currentUser;

    if (user != null) {
      try {
        final response = await supabase
            .from('profiles')
            .select('role')
            .eq('user_id', user.id)
            .single();

        if (response['role'] == 'admin') {
          if (mounted) setState(() => isAdmin = true);
        }
      } catch (e) {}
    }

    if (mounted) {
      setState(() => isLoadingPage = false);
    }
  }

  bool _canRegister() {
    final user = supabase.auth.currentUser;
    if (user == null) return true;
    return isAdmin;
  }

  String _registerButtonText() {
    final user = supabase.auth.currentUser;
    if (user == null) return "Register";
    return isAdmin ? "Register" : "Hanya Admin";
  }

  Future<void> _registerNewUser() async {
    setState(() {
      nameError = emailError = passwordError = roleError = null;
    });
    bool hasError = false;

    if (nameController.text.trim().isEmpty) {
      nameError = "Nama wajib diisi";
      hasError = true;
    }
    if (emailController.text.trim().isEmpty) {
      emailError = "Email wajib diisi";
      hasError = true;
    } else if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(emailController.text.trim())) {
      emailError = "Format email tidak valid";
      hasError = true;
    } else if (!emailController.text.trim().toLowerCase().endsWith(
      '@gmail.com',
    )) {
      emailError = "Hanya email @gmail.com yang diperbolehkan";
      hasError = true;
    }
    if (passwordController.text.isEmpty) {
      passwordError = "Password wajib diisi";
      hasError = true;
    } else if (passwordController.text.length < 6) {
      passwordError = "Password minimal 6 karakter";
      hasError = true;
    }
    if (roleController.text.isEmpty) {
      roleError = "Pilih role terlebih dahulu";
      hasError = true;
    }
    if (hasError) {
      setState(() {});
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final authResponse = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (authResponse.user == null) {
        throw Exception(
          'Gagal membuat akun. Email mungkin sudah terdaftar atau cek koneksi internet.',
        );
      }

      final userId = authResponse.user!.id;

      final String chosenRole = roleController.text == 'Admin'
          ? 'admin'
          : 'officer';
      await supabase.from('profiles').insert({
        'user_id': userId,
        'name': nameController.text.trim(),
        'role': chosenRole,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User berhasil dibuat!'),
          backgroundColor: Colors.green,
        ),
      );

      await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (chosenRole == 'admin') {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const DashboardPages()),
            (route) => false,
          );
        }
      } else {
        if (mounted) Navigator.pop(context);
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Auth Error: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } on PostgrestException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Database Error: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  void _goBackToSignIn() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingPage) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFF36536B),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(28),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -75,
                            right: -11,
                            child: Opacity(
                              opacity: 0.15,
                              child: Image.asset(
                                'assets/images/drico_logo.png',
                                width: 150,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Let's get you Registered ",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: -25,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 320,
                        height: 55,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E9ED),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Stack(
                          children: [
                            AnimatedAlign(
                              duration: const Duration(milliseconds: 250),
                              alignment: Alignment.centerRight,
                              child: Container(
                                width: 165,
                                height: 55,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEC3D16),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _goBackToSignIn,
                                    child: Center(
                                      child: Text(
                                        "Sign in",
                                        style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      "Register",
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 120),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    TextField(
                      controller: roleController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: "As",
                        filled: true,
                        fillColor: const Color(0xFFE5E9ED),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        errorText: roleError,
                        suffixIcon: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (v) =>
                              setState(() => roleController.text = v),
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: "Admin",
                              child: Text("Admin"),
                            ),
                            const PopupMenuItem(
                              value: "Officer",
                              child: Text("Officer"),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: "Name",
                        filled: true,
                        fillColor: const Color(0xFFE5E9ED),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        errorText: nameError,
                      ),
                    ),

                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: "Email",
                        filled: true,
                        fillColor: const Color(0xFFE5E9ED),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        errorText: emailError,
                      ),
                    ),

                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        hintText: "Password",
                        filled: true,
                        fillColor: const Color(0xFFE5E9ED),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        errorText: passwordError,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(right: 32),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => setState(
                            () => obscurePassword = !obscurePassword,
                          ),
                          child: Text(
                            obscurePassword ? "Show password" : "Hide password",
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 65),

                    GestureDetector(
                      onTap: _canRegister() ? _registerNewUser : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 13,
                          horizontal: 90,
                        ),
                        decoration: BoxDecoration(
                          color: _canRegister()
                              ? const Color(0xFF2A3440)
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _registerButtonText(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    if (supabase.auth.currentUser != null && !isAdmin) ...[
                      const SizedBox(height: 20),
                      const Text(
                        "Hanya Admin yang boleh menambah user baru",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    const SizedBox(height: 130),

                    GestureDetector(
                      onTap: _goBackToSignIn,
                      child: RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "Already have an account? ",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                            TextSpan(
                              text: "Sign in",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
