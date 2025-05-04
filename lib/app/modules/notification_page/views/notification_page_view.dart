import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/notification_page_controller.dart';

class NotificationPageView extends GetView<NotificationPageController> {
  const NotificationPageView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NotificationPageView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'NotificationPageView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
