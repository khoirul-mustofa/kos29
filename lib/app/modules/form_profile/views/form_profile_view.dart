import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/form_profile_controller.dart';

class FormProfileView extends GetView<FormProfileController> {
  const FormProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Formulir Profil'),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: CircleAvatar(
                  radius: 50,
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: CircleAvatar(
                  radius: 50,
                ),
              )
            ],
          ),
        ));
  }
}
