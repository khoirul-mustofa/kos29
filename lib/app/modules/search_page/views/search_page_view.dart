// search_page_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kos29/app/modules/search_page/controllers/search_page_controller.dart';
import 'package:kos29/app/widgets/card_kost.dart';

class SearchPageView extends StatefulWidget {
  const SearchPageView({super.key});

  @override
  State<SearchPageView> createState() => _SearchPageViewState();
}

class _SearchPageViewState extends State<SearchPageView> {
  final ScrollController _scrollController = ScrollController();
  final SearchPageController controller = Get.put(SearchPageController());

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !controller.isLoading &&
        controller.hasMore) {
      controller.fetchKostData(loadMore: true);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cari Kos'), centerTitle: true),
      body: GetBuilder<SearchPageController>(
        builder: (controller) {
          return RefreshIndicator(
            onRefresh: controller.refreshKost,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Cari Kost',
                      suffixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: controller.search,
                  ),
                ),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.category.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 16, right: 5),
                        child: ChoiceChip(
                          label: Text(controller.category[index]),
                          selected: controller.selectedCategory == index,
                          onSelected: (value) {
                            if (value) controller.changeCategory(index);
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child:
                      controller.kostList.isEmpty && !controller.isLoading
                          ? const Center(child: Text('Tidak ada data kos'))
                          : ListView.builder(
                            controller: _scrollController,
                            itemCount: controller.filteredKost.length + 1,
                            itemBuilder: (context, index) {
                              if (index < controller.filteredKost.length) {
                                final kost = controller.filteredKost[index];
                                return GestureDetector(
                                  onTap: () => controller.gotoDetailPage(kost),
                                  child: CardKost(kost: kost),
                                );
                              } else {
                                return controller.hasMore
                                    ? const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                    : const SizedBox();
                              }
                            },
                          ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
