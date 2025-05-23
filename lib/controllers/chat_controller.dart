import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dizcuss/controllers/auth_controller.dart';
import 'package:dizcuss/controllers/notification_controller.dart';
import 'package:dizcuss/models/poll.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String roomId;
  final messages = RxList<Map<String, dynamic>>([]);
  final isLoading = false.obs;

  // Available reactions
  static const reactions = ['❤️', '👍', '👎', '😂', '😮', '😢'];

  ChatController({required this.roomId});

  @override
  void onInit() {
    super.onInit();
    _listenToMessages();
  }

  void _listenToMessages() {
    isLoading.value = true;
    _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            messages.value =
                snapshot.docs.map((doc) {
                  final data = doc.data();
                  if (data['type'] == 'poll') {
                    data['poll'] = Poll.fromMap(data['pollData']);
                  }
                  return {...data, 'id': doc.id};
                }).toList();
            isLoading.value = false;
          },
          onError: (error) {
            print('Error fetching messages: $error');
            isLoading.value = false;
          },
        );
  }

  Future<void> sendMessage(String text, {Map<String, dynamic>? replyTo}) async {
    if (text.trim().isEmpty) return;

    try {
      final user = AuthController.instance.user!;
      final messageData = {
        'text': text,
        'sender': user.displayName ?? 'Anonymous',
        'senderId': user.uid,
        'isMe': true,
        'type': 'text',
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (replyTo != null) {
        messageData['replyTo'] = {
          'id': replyTo['id'],
          'text': replyTo['text'],
          'sender': replyTo['sender'],
          'type': replyTo['type'],
        };

        // Send notification to the original message sender
        final notificationController = NotificationController.instance;
        final originalSenderId = replyTo['senderId'];
        if (originalSenderId != user.uid) {
          final originalSender =
              await _firestore.collection('users').doc(originalSenderId).get();
          final playerID = originalSender.data()?['oneSignalPlayerId'];
          if (playerID != null) {
            await notificationController.sendReplyNotification(
              recipientPlayerId: playerID,
              senderName: user.displayName ?? 'Anonymous',
              originalMessage: replyTo['text'],
              replyMessage: text,
            );
          }
        }
      }

      await _firestore
          .collection('rooms')
          .doc(roomId)
          .collection('messages')
          .add(messageData);
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Future<void> createPoll(String question, List<String> options) async {
    if (question.trim().isEmpty || options.length < 2) return;

    try {
      final user = AuthController.instance.user!;
      final poll = Poll(
        question: question,
        options: options,
        votes: Map.fromIterable(
          options,
          key: (option) => option,
          value: (option) => <String>[],
        ),
        createdAt: DateTime.now(),
        createdBy: user.uid,
      );

      await _firestore
          .collection('rooms')
          .doc(roomId)
          .collection('messages')
          .add({
            'type': 'poll',
            'sender': user.displayName ?? 'Anonymous',
            'senderId': user.uid,
            'isMe': true,
            'pollData': poll.toMap(),
            'createdAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('Error creating poll: $e');
    }
  }

  Future<void> addReaction(String messageId, String reaction) async {
    try {
      final user = AuthController.instance.user!;
      final messageRef = _firestore
          .collection('rooms')
          .doc(roomId)
          .collection('messages')
          .doc(messageId);

      final message = await messageRef.get();
      final reactions =
          (message.data()?['reactions'] as Map<String, dynamic>?) ?? {};

      // Remove existing reaction from this user if any
      reactions.forEach((key, value) {
        final users = List<String>.from(value as List);
        if (users.contains(user.uid)) {
          users.remove(user.uid);
          reactions[key] = users;
        }
      });

      // Add new reaction
      if (!reactions.containsKey(reaction)) {
        reactions[reaction] = [user.uid];
      } else {
        final users = List<String>.from(reactions[reaction] as List);
        if (!users.contains(user.uid)) {
          users.add(user.uid);
          reactions[reaction] = users;
        }
      }

      await messageRef.update({'reactions': reactions});

      // Send notification to the message sender
      final notificationController = NotificationController.instance;
      final messageSenderId = message.data()?['senderId'];
      if (messageSenderId != user.uid) {
        final messageSender =
            await _firestore.collection('users').doc(messageSenderId).get();
        final playerID = messageSender.data()?['oneSignalPlayerId'];
        print(playerID);
        if (playerID != null) {
          await notificationController.sendReactionNotification(
            recipientPlayerId: playerID,
            senderName: user.displayName ?? 'Anonymous',
            message: message.data()?['text'] ?? '',
            reaction: reaction,
          );
        }
      }
    } catch (e) {
      print('Error adding reaction: $e');
    }
  }

  Future<void> votePoll(String messageId, String option) async {
    try {
      final user = AuthController.instance.user!;
      final messageRef = _firestore
          .collection('rooms')
          .doc(roomId)
          .collection('messages')
          .doc(messageId);

      final message = await messageRef.get();
      if (!message.exists) return;

      final pollData = Map<String, dynamic>.from(message.data()!['pollData']);
      final votesData = pollData['votes'] as Map<String, dynamic>;
      final votes = votesData.map(
        (key, value) => MapEntry(
          key,
          (value as List<dynamic>).map((e) => e.toString()).toList(),
        ),
      );

      // Remove user's previous vote if any
      for (var entry in votes.entries) {
        entry.value.remove(user.uid);
      }

      // Add new vote
      if (!votes.containsKey(option)) {
        votes[option] = [];
      }
      votes[option]!.add(user.uid);

      // Update poll data
      pollData['votes'] = votes;
      await messageRef.update({'pollData': pollData});
    } catch (e) {
      print('Error voting in poll: $e');
    }
  }
}
