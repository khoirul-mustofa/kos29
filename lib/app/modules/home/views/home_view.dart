import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kos29/app/routes/app_pages.dart';
import 'package:kos29/app/style/app_colors.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  HomeView({super.key});

  @override
  final controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        leading:
            controller.prfController.currentUser != null
                ? Center(
                  child: Container(
                    margin: EdgeInsets.only(left: 5),
                    width: 40,
                    height: 40,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(
                        '${controller.prfController.currentUser?.photoURL}',
                      ),
                    ),
                  ),
                )
                : null,
        title: Text(
          'IndiKos',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
            fontFamily: 'Varela',
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.toNamed(Routes.NOTIFICATION_PAGE);
            },
            icon: Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GetBuilder<HomeController>(
            builder: (controller) {
              return Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hey ${controller.prfController.currentUser?.displayName ?? 'kamu'} 😎',
                      style: TextStyle(
                        fontSize: 22,
                        color: const Color.fromARGB(255, 65, 77, 72),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '#Dapatkan Kemudahan',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Cari dan Temukan Kos Terdekat!',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => Get.toNamed(Routes.SEARCH_PAGE),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search),
                            Text('Cari kos dimana?'),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: BouncingScrollPhysics(),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 8,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: List.generate(4, (index) {
                          final List category = [
                            'Terdekat',
                            'Termurah',
                            'Termahal',
                            'Terbaik',
                          ];

                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  height: 64,
                                  width: 74,
                                  decoration: BoxDecoration(
                                    color:
                                        index == 0
                                            ? Colors.blue.shade50
                                            : index == 1
                                            ? Colors.green.shade50
                                            : index == 2
                                            ? Colors.red.shade50
                                            : Colors.yellow.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(child: Icon(Icons.home)),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  category[index],
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Kunjungan Terakhir',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 50,
                      width: Get.width,
                      margin: EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withAlpha(50)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Anda belum pernah melakukan kunjungan kos dimanapun.',
                        ),
                      ),
                    ),
                    Container(
                      height: 140,
                      width: Get.width,
                      margin: EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withAlpha(50)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            margin: EdgeInsets.all(10),
                            padding: EdgeInsets.all(10),
                            width: 130,
                            height: Get.height,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey,
                              image: DecorationImage(
                                image: AssetImage(
                                  'assets/images/home-template.jpeg',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 2,
                            children: [
                              SizedBox(height: 10),
                              Text(
                                'Kost Bapak budi jaya',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 5),
                              SizedBox(
                                width: Get.width * 0.5,
                                child: Text(
                                  'Jl. Raya Cibubur No. 1, RT.3/RW.1, Cibubur, Kec. Cibubur, Kota Bandung, Jawa Barat 40151',
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  maxLines: 2,
                                ),
                              ),
                              SizedBox(height: 5),
                              SizedBox(
                                width: Get.width * 0.5,
                                child: Text(
                                  '2.5 km',
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 4,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Rp. 1.000.000',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Rekomendasi Terdekat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: BouncingScrollPhysics(),
                      child: Row(
                        children: List.generate(5, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: Get.width * 0.5,
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.appGreyAlpa50,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 120,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          image: DecorationImage(
                                            image: NetworkImage(
                                              'https://picsum.photos/id/${index + 1}/200/300',
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'Kost Bapak budi jaya',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      SizedBox(
                                        width: Get.width * 0.5,
                                        child: Text(
                                          'Jl. Raya Cibubur No. 1, RT.3/RW.1, Cibubur, Kec. Cibubur, Kota Bandung, Jawa Barat 40151',
                                          style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12,
                                          ),
                                          maxLines: 4,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      SizedBox(
                                        width: Get.width * 0.5,
                                        child: Text(
                                          '2.5 km',
                                          style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                          maxLines: 4,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Rp. 1.000.000',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 100),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
