import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../rooms_list/rooms_list_screen.dart';

class LoginController extends GetxController {
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
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: "http://a41.chat.agora.io",
        validateStatus: (status) => status != null && status < 500,
          headers: {
            "Authorization":"Bearer 007eJxTYJjKsO6IschNI5cHzKo9jMd2/mupuyXb0CRlxvOQoYU34Z0Cg3lisnGyiXGqoblRsklqWlJiqrFxYkqKRXJyqkFyklHypbTb6Q2BjAwdX7czMjKwMjAyMDGA+AwMAE7VHmA="
          }
      ),
    );

    isLoading = true;
    update();

    try {
      final response = await dio.get(
        "/411314433/1515795/users/${userNameController.text.trim()}",
        options: Options(headers: {
          "Content-Type": "application/json",
        }),
      );

      if (response.statusCode == 200) {
        Get.off(()=>RoomListScreen(chatUser: userNameController.text.trim(), chatPassword: passwordController.text.trim(),));

      } else {

      }
    } catch (e) {
      print('خطأ تسجيل الدخول: $e');

    } finally {
      isLoading = false;
      update();
    }
  }
}

// نموذج لاستخراج التوكن من الاستجابة
class GetTokenModel {
  final String token;

  GetTokenModel({required this.token});

  factory GetTokenModel.fromJson(Map<String, dynamic> json) {
    return GetTokenModel(
      token: json['token'] as String,
    );
  }
}
