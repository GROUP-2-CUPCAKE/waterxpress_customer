import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/lacak_pesanan_controller.dart';
import 'package:progress_tracker/progress_tracker.dart';

class LacakPesananView extends StatefulWidget {
  // const LacakPesananView({Key? key}) : super(key: key);

  @override
  _LacakPesananViewState createState() => _LacakPesananViewState();
}

class _LacakPesananViewState extends State<LacakPesananView> {
  // int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    final LacakPesananController controller = Get.put(LacakPesananController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lacak Pesanan'),
        automaticallyImplyLeading: false,
        centerTitle: true,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF40C4FF), Color(0xFF0288D1)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Column(
          children: [
            Card(
              color: const Color.fromARGB(255, 237, 246, 255),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // const Text(
                    // 'LACAK PESANAN',
                    // style: TextStyle(
                    // fontSize: 14,
                    // fontWeight: FontWeight.bold,
                    // ),
                    // ),
                    // const Divider(
                    // color: Colors.grey,
                    // thickness: 2,
                    // ),
                    // const SizedBox(height: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Obx(
                            () => ProgressTracker(
                              currentIndex: controller.index.value,
                              statusList: controller.statusList,
                              activeColor: Colors.green,
                              inActiveColor: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
