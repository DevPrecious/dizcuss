import 'package:dizcuss/consts/color.dart';
import 'package:dizcuss/controllers/auth_controller.dart';
import 'package:dizcuss/pages/auth/auth_page.dart';
import 'package:dizcuss/pages/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:dizcuss/controllers/notification_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize OneSignal first
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("app_id");
  await OneSignal.Notifications.requestPermission(false);

  // Initialize Firebase and controllers
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Get.put(AuthController());
  Get.put(NotificationController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Set your design size here
      minTextAdapt: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Dizcuss',
          theme: ThemeData(
            textTheme: GoogleFonts.poppinsTextTheme(), // Use Google Fonts here
            colorScheme: ColorScheme.fromSeed(seedColor: backgroundColor),
          ),
          home: Obx(
            () =>
                AuthController.instance.isLoggedIn
                    ? const HomePage()
                    : const AuthPage(),
          ),
        );
      },
    );
  }
}
