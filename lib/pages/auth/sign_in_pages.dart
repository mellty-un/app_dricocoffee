import 'package:application_pos_dricocoffee/pages/auth/register_pages.dart';
import 'package:application_pos_dricocoffee/pages/dashboard/dashboard_pages.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignInPages extends StatefulWidget {
  const SignInPages({super.key});

  @override
  State<SignInPages> createState() => _SignInPagesState();
}

class _SignInPagesState extends State<SignInPages> {
  bool obscurePassword = true;

  void _goToRegister() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const RegisterPages(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
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
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Let's get you signed in!",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w400,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // TOGGLE HEADER
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
                            Align(
                              alignment: Alignment.centerLeft,
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
                                  child: Center(
                                    child: Text(
                                      "Sign in",
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),

                                // REGISTER
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _goToRegister,
                                    child: Center(
                                      child: Text(
                                        "Register",
                                        style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
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
                    const SizedBox(height: 35),
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
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.only(right: 32),
                child: Align(
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
              ),

              const SizedBox(height: 65),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DashboardPages()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 13,
                    horizontal: 100,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF36536B),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 260),

              GestureDetector(
                onTap: _goToRegister,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(color: Colors.black87, fontSize: 14),
                        ),
                        TextSpan(
                          text: "Register",
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
