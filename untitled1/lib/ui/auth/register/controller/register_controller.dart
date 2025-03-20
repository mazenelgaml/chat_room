import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../rooms_list/rooms_list_screen.dart';


class RegisterController extends GetxController {
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  RxBool isChecked = false.obs;
  RxBool obscureText = true.obs;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isLoading = false;

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال البريد الإلكتروني';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال كلمة المرور';
    }
    return null;
  }

  void toggleRememberMe(bool? newValue) {
    isChecked.value = newValue ?? false;
  }

  void onLoginPressed(BuildContext context) async {
    if (formKey.currentState?.validate() ?? false) {
      await logIn(context);
    }
  }
  Future<void> logIn(BuildContext context) async {
    print("enter");
    isLoading = true;
    update();

    final Dio dio = Dio(
      BaseOptions(
        baseUrl: "http://a41.chat.agora.io",
        validateStatus: (status) => status != null && status < 500,
        headers: {
          "Authorization":"Bearer 007eJxTYJjKsO6IschNI5cHzKo9jMd2/mupuyXb0CRlxvOQoYU34Z0Cg3lisnGyiXGqoblRsklqWlJiqrFxYkqKRXJyqkFyklHypbTb6Q2BjAwdX7czMjKwMjAyMDGA+AwMAE7VHmA="
        }
      ),
    );

    try {
      final response = await dio.post(
        "/411314433/1515795/users",

        data: {
          "username": userNameController.text.trim(),
          "password": passwordController.text.trim()
        },
        options: Options(headers: {
          "Content-Type": "application/json",
        }),
      );

      if (response.statusCode == 200) {
        print("success");
        Get.to(() => RoomListScreen(
          chatUser: userNameController.text.trim(),
          chatPassword: passwordController.text.trim(),
        ));
      } else {
        print("Login failed: ${response.statusCode}");
      }
    } catch (e) {
      print("Error during login: $e");
    } finally {
      isLoading = false;
      update();
      dio.close();
    }
  }

}

