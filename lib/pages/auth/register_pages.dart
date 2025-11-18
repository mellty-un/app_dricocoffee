import 'package:application_pos_dricocoffee/pages/dashboard/dashboard_pages.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPages extends StatefulWidget {
  const RegisterPages({super.key});

  @override
  State<RegisterPages> createState() => _RegisterPagesState();
}

class _RegisterPagesState extends State<RegisterPages> {
  bool obscurePassword = true;
  final TextEditingController roleController = TextEditingController();

  void _goBackToSignIn() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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

                  // TOGGLE BUTTON
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
                    // ROLE selector
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
                        suffixIcon: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) {
                            setState(() {
                              roleController.text = value;
                            });
                          },
                          itemBuilder: (context) => [
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

                    // Name
                    TextField(
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
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Email
                    TextField(
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
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Password
                    TextField(
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
                      ),
                    ),

                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
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

                    const SizedBox(height: 65),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DashboardPages(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 13,
                          horizontal: 90,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A3440),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          "Register",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

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
