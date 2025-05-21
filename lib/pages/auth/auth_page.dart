import 'package:dizcuss/consts/color.dart';
import 'package:dizcuss/controllers/auth_controller.dart';
import 'package:dizcuss/pages/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:icon_icons/icon_icons.dart';
import 'package:lottie/lottie.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/lotties/ball.json'),
          SizedBox(height: 30.h),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SizedBox(
              width: double.infinity,
              height: 40.h,
              child: GetBuilder<AuthController>(
                init: authController,
                builder: (controller) {
                  return ElevatedButton(
                    onPressed: () async {
                      bool isLoggedIn = await controller.login();

                      if (isLoggedIn) {
                        Get.off(() => const HomePage());
                      }

                      // Get.snackbar('Error', 'Something went wrong');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appBarColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconIcons.idea(),
                        SizedBox(width: 20.w),
                        Text(
                          'Join or Login with Gmail.',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
