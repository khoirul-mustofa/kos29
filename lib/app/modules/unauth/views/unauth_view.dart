import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/unauth_controller.dart';

class UnauthView extends GetView<UnauthController> {
  const UnauthView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UnauthView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'UnauthView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
