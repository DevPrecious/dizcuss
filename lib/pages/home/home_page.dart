import 'package:dizcuss/consts/color.dart';
import 'package:dizcuss/controllers/room_controller.dart';
import 'package:dizcuss/pages/chat/chat_page.dart';
import 'package:dizcuss/pages/home/make_room_page.dart';
import 'package:dizcuss/pages/home/widgets/app_bar_widget.dart';
import 'package:dizcuss/pages/home/widgets/room_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _roomController = Get.put(RoomController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const MakeRoomPage());
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBarWidget(
        text: 'Welcome back',
        name: FirebaseAuth.instance.currentUser!.displayName ?? 'Null',
        avatarUrl: FirebaseAuth.instance.currentUser!.photoURL ?? '',
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your room',
                    style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: greyColor,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Center(
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.to(() => const MakeRoomPage());
                            },
                            child: Text(
                              'Make room',
                              style: TextStyle(
                                color: Colors.grey.withOpacity(.8),
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                          SizedBox(width: 5.w),
                          Icon(
                            Icons.add_outlined,
                            color: Colors.grey.withOpacity(.8),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Obx(() {
                if (_roomController.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (_roomController.userRooms.isEmpty) {
                  return const Center(
                    child: Text(
                      'No rooms yet',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                return Column(
                  children:
                      _roomController.userRooms.map((room) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: RoomWidget(
                            name: room.name,
                            description: room.description,
                            createdAt: room.createdAt,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ChatPage(
                                        roomId: room.id,
                                        roomTitle: room.name,
                                      ),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                );
              }),
              SizedBox(height: 20.h),
              Text(
                'Trending rooms',
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
              ),
              SizedBox(height: 20.h),
              Obx(() {
                if (_roomController.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (_roomController.trendingRooms.isEmpty) {
                  return const Center(
                    child: Text(
                      'No trending rooms',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                return Column(
                  children:
                      _roomController.trendingRooms.map((room) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: RoomWidget(
                            name: room.name,
                            description: room.description,
                            createdAt: room.createdAt,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ChatPage(
                                        roomId: room.id,
                                        roomTitle: room.name,
                                      ),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
