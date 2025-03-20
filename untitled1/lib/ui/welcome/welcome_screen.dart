import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled1/ui/auth/log_in/log_in_screen.dart';
import 'package:untitled1/ui/auth/register/register_screen.dart';



class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/welcome.png", width: 200),
                const SizedBox(height: 20),
                Text(
                  "مرحبًا بك 👋",
                  style: GoogleFonts.cairo(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "اختر طريقة الدخول",
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 40),
                _buildButton("Sign in", Colors.white, Color(0xff7E57C2), Icons.login, () {
                 Get.to(()=>LoginScreen());
                }),
                const SizedBox(height: 15),
                _buildButton("Sign up", Colors.white, Color(0xff2575FC), Icons.person_add, () {
                  Get.to(()=>RegisterScreen());
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, Color textColor, Color bgColor, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: 220,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: textColor),
        label: Text(text, style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 5,
        ),
      ),
    );
  }
}
