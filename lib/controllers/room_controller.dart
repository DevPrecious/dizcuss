import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dizcuss/models/room.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class RoomController extends GetxController {
  final _isLoading = false.obs;
  final _rooms = <Room>[].obs;
  final _userRooms = <Room>[].obs;
  final _trendingRooms = <Room>[].obs;

  bool get isLoading => _isLoading.value;
  List<Room> get rooms => _rooms;
  List<Room> get userRooms => _userRooms;
  List<Room> get trendingRooms => _trendingRooms;

  @override
  void onInit() {
    super.onInit();
    fetchRooms();
  }

  Future<void> createRoom({
    required String name,
    required String description,
    required bool isPrivate,
  }) async {
    try {
      _isLoading.value = true;

      final user = FirebaseAuth.instance.currentUser!;
      await FirebaseFirestore.instance.collection('rooms').add({
        'name': name.trim(),
        'description': description.trim(),
        'isPrivate': isPrivate,
        'createdBy': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'members': [user.uid],
        'lastMessage': null,
        'lastMessageTime': null,
      });

      await fetchRooms();
      Get.back();
      Get.snackbar(
        'Success',
        'Room created successfully!',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error creating room: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> fetchRooms() async {
    try {
      _isLoading.value = true;
      final user = FirebaseAuth.instance.currentUser!;

      // Fetch user's rooms (rooms where user is a member)
      final userRoomsQuery =
          await FirebaseFirestore.instance
              .collection('rooms')
              .where('members', arrayContains: user.uid)
              .orderBy('createdAt', descending: true)
              .get();

      _userRooms.value =
          userRoomsQuery.docs.map((doc) => Room.fromFirestore(doc)).toList();

      // Fetch trending rooms (public rooms with most members)
      final trendingRoomsQuery =
          await FirebaseFirestore.instance
              .collection('rooms')
              .where('isPrivate', isEqualTo: false)
              .orderBy('members', descending: true)
              .limit(10)
              .get();

      _trendingRooms.value =
          trendingRoomsQuery.docs
              .map((doc) => Room.fromFirestore(doc))
              .toList();

      // Combine all rooms
      _rooms.value = [..._userRooms, ..._trendingRooms];
    } catch (e) {
      print(e.toString());
      Get.snackbar(
        'Error',
        'Error fetching rooms: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }
}
