import 'package:dizcuss/consts/color.dart';
import 'package:dizcuss/controllers/room_controller.dart';
import 'package:dizcuss/pages/home/widgets/app_bar_widget.dart';
import 'package:dizcuss/pages/home/widgets/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MakeRoomPage extends StatefulWidget {
  const MakeRoomPage({super.key});

  @override
  State<MakeRoomPage> createState() => _MakeRoomPageState();
}

class _MakeRoomPageState extends State<MakeRoomPage> {
  final _formKey = GlobalKey<FormState>();
  final _roomNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isPrivate = false;

  final _roomController = Get.put(RoomController());

  Future<void> _createRoom() async {
    if (!_formKey.currentState!.validate()) return;

    await _roomController.createRoom(
      name: _roomNameController.text,
      description: _descriptionController.text,
      isPrivate: _isPrivate,
    );
  }

  @override
  void dispose() {
    _roomNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBarWidget(
        text: 'Create Room',
        name: FirebaseAuth.instance.currentUser!.displayName ?? 'Null',
        avatarUrl: FirebaseAuth.instance.currentUser!.photoURL ?? '',
        isBack: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              controller: _roomNameController,
              labelText: 'Room Name',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a room name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _descriptionController,
              labelText: 'Description',
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a room description';
                }
                return null;
              },
            ),
            // const SizedBox(height: 16),
            // SwitchListTile(
            //   title: const Text('Private Room'),
            //   subtitle: const Text('Only invited members can join'),
            //   value: _isPrivate,
            //   onChanged: (value) => setState(() => _isPrivate = value),
            //   tileColor: Colors.white,
            //   shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            // ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _roomController.isLoading ? null : _createRoom,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Obx(
                () =>
                    _roomController.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Create Room'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
