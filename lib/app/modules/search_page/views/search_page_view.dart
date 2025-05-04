import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kos29/app/routes/app_pages.dart';
import 'package:kos29/app/widgets/card_kost.dart';

import '../controllers/search_page_controller.dart';

class SearchPageView extends GetView<SearchPageController> {
  const SearchPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Cari Kos'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: GetBuilder<SearchPageController>(
          builder: (controller) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    textInputAction: TextInputAction.search,
                    keyboardType: TextInputType.text,
                    onFieldSubmitted: (value) {},
                    decoration: InputDecoration(
                      labelText: 'Cari Kost',
                      suffixIcon: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.search),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.teal),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.category.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ChoiceChip(
                          selectedColor: Colors.teal.withValues(alpha: 0.3),
                          backgroundColor: Colors.white,
                          labelStyle: const TextStyle(color: Colors.black),
                          label: Text(controller.category[index]),
                          selected: controller.selectedCategory == index,
                          onSelected: (value) {
                            if (value) {
                              controller.selectedCategory = index;
                              controller.update();
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  child: SizedBox(
                    height: Get.height / 1.4,
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => Get.toNamed(Routes.DETAIL_PAGE),
                          child: CardKost(),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
