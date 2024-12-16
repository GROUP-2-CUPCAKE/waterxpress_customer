import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:waterxpress_customer/firebase_options.dart';
import 'app/modules/login/controllers/login_controller.dart';
import 'app/routes/app_pages.dart';
import 'package:get_storage/get_storage.dart';
import 'app/utils/loading.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final authC = Get.put(LoginController(), permanent: true);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: authC.streamAuthStatus,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            return ScreenUtilInit(
              designSize: const Size(375, 812), // Ukuran desain (misalnya i
              minTextAdapt: true,
              splitScreenMode: true,
              builder: (context, child) {
                return GetMaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: "WaterXpress",
                  initialRoute: AppPages.INITIAL,
                  getPages: AppPages.routes,
                  theme: ThemeData(
                    primarySwatch: Colors.indigo,
                  ),
                  builder: (context, widget) {
                    // Untuk memastikan ScreenUtil bekerja dengan benar
                    ScreenUtil.init(context);
                    return widget!;
                  },
                );
              },
            );
          }
          return LoadingView();
        });
  }
}

