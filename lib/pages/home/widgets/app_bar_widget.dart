import 'package:dizcuss/consts/color.dart';
import 'package:dizcuss/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.text,
    this.isBack = false,
  });

  final String name;
  final String avatarUrl;
  final String text;
  final bool isBack;

  @override
  Size get preferredSize => Size.fromHeight(73.h);

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    return PreferredSize(
      preferredSize: Size.fromHeight(73.h),
      child: AppBar(
        backgroundColor: appBarColor,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      isBack
                          ? GestureDetector(
                            onTap: () => Get.back(),
                            child: Icon(Icons.arrow_back, color: Colors.white),
                          )
                          : Container(),
                      isBack ? SizedBox(width: 30.w) : Container(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            text,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () async {
                      await authController.signOut();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: greyColor,
                      ),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(avatarUrl),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
