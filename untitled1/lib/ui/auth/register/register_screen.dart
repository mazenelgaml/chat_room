
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller/register_controller.dart';




class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RegisterController controller = Get.put(RegisterController());

    void togglePasswordVisibility() {
      controller.obscureText.value = !controller.obscureText.value;
    }
    return Scaffold(
      body: Container(
        height: Get.height,
        width:Get.width,
        decoration: BoxDecoration(
        gradient: LinearGradient(
        colors: [Color(0xFF7E57C2), Color(0xFF2575FC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    ),
    ),
    child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Form(
    key: controller.formKey,
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Row(
    children: [
    Text(
    "Hi there",
    style: TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 22,
    ),
    ),
    Icon(
    Icons.waving_hand,
    color: Colors.yellow,
    size: 30,
    ),
    ],
    ),
    SizedBox(height: 16),
    Text(
    "Welcome back",
    style: TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    ),
    ),
    SizedBox(height: 16),
    Center(
    child: SizedBox(
    width: Get.width * 0.9,
    child: TextFormField(

    controller: controller.userNameController,
    keyboardType: TextInputType.emailAddress,
    decoration: InputDecoration(
    hintText: "username",
    hintStyle:  TextStyle(color: Color(0xff7E57C2).withOpacity(0.4)),
    filled: true,
    fillColor: Colors.white,
    prefixIcon: const Icon(Icons.email, color: Color(0xff6A11CB)),
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(20.0),
    borderSide: BorderSide.none,
    ),
    ),
    validator: controller.validateEmail,
    ),
    ),
    ),
    SizedBox(height: 16),
    Center(
    child: SizedBox(
    width: Get.width * 0.9,
    child: Obx(() => TextFormField(
    controller: controller.passwordController,
    obscureText: controller.obscureText.value,
    keyboardType: TextInputType.text,
    decoration: InputDecoration(
    hintText: "password",
    hintStyle: TextStyle(color: Color(0xff7E57C2).withOpacity(0.4)),
    filled: true,
    fillColor: Colors.white,
    prefixIcon: const Icon(Icons.lock, color: Color(0xff6A11CB)),
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(20.0),
    borderSide: BorderSide.none,
    ),
    suffixIcon: IconButton(
    icon: Icon(
    controller.obscureText.value
    ? Icons.visibility_off
        : Icons.visibility,
    color: Color(0xff7E57C2).withOpacity(0.8),
    ),
    onPressed: togglePasswordVisibility,
    ),
    ),
    validator: controller.validatePassword,
    )),
    ),
    ),
    SizedBox(height: 16),
              controller.isLoading?Center(child: CircularProgressIndicator(),):GestureDetector(
                onTap:(){ controller.logIn(context);},
                child: Container(
                  width: Get.width * 0.9,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Color(0xff7E57C2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xff7E57C2)),
                  ),
                  child: Center(
                    child: Text(
                      "Register",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
