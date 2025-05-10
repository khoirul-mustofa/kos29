import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/auth_reset_password_controller.dart';

class AuthResetPasswordView extends GetView<AuthResetPasswordController> {
  const AuthResetPasswordView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AuthResetPasswordView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'AuthResetPasswordView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
