import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/history_search_controller.dart';

class HistorySearchView extends GetView<HistorySearchController> {
  const HistorySearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Riwayat Pencarian'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // child: ListView.builder(
        //   physics: const BouncingScrollPhysics(),
        //   itemCount: 10,
        //   itemBuilder: (context, index) {
        //     return index == 9
        //         ? Column(
        //           children: [
        //             InkWell(
        //               onTap: () {
        //                 Get.toNamed(Routes.DETAIL_PAGE);
        //               },
        //               borderRadius: BorderRadius.circular(12),
        //               // child: const CardKost(),
        //             ),
        //             const SizedBox(height: 100),
        //           ],
        //         )
        //         : InkWell(
        //           onTap: () {
        //             Get.toNamed(Routes.DETAIL_PAGE);
        //           },
        //           borderRadius: BorderRadius.circular(12),
        //           // child: const CardKost(),
        //         );
        //   },
        // ),
      ),
    );
  }
}
