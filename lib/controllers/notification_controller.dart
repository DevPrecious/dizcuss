import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationController extends GetxController {
  static NotificationController get instance =>
      Get.find<NotificationController>();

  // OneSignal REST API Key - you should store this securely
  static const String restApiKey = 'api_key';
  static const String appId = 'app_id';

  // Store user's OneSignal ID
  String? _playerID;

  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    // Get the player ID for the current user
    final deviceState = await OneSignal.User.pushSubscription;
    _playerID = deviceState.id;
  }

  // Send notification when someone replies to a message
  Future<void> sendReplyNotification({
    required String recipientPlayerId,
    required String senderName,
    required String originalMessage,
    required String replyMessage,
  }) async {
    final notification = {
      'include_player_ids': [recipientPlayerId],
      'headings': {'en': 'New Reply from $senderName'},
      'contents': {
        'en':
            'Reply to "${_truncateMessage(originalMessage)}": ${_truncateMessage(replyMessage)}',
      },
    };

    await _sendNotification(notification);
  }

  // Send notification when someone reacts to a message
  Future<void> sendReactionNotification({
    required String recipientPlayerId,
    required String senderName,
    required String message,
    required String reaction,
  }) async {
    final notification = {
      'include_player_ids': [recipientPlayerId],
      'headings': {'en': 'New Reaction from $senderName'},
      'contents': {
        'en':
            '$senderName reacted with $reaction to your message: ${_truncateMessage(message)}',
      },
    };

    await _sendNotification(notification);
  }

  // Helper method to send notification using OneSignal REST API
  Future<void> _sendNotification(Map<String, dynamic> notification) async {
    try {
      final Map<String, dynamic> payload = {
        'app_id': appId,
        'target_channel': 'push',
        'headings': notification['headings'],
        'contents': notification['contents'],
        'include_player_ids': notification['include_player_ids'],
      };

      final response = await http.post(
        Uri.parse('https://api.onesignal.com/notifications'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Key $restApiKey',
        },
        body: json.encode(payload),
      );

      if (response.statusCode != 200) {
        print('Failed to send notification: ${response.body}');
      } else {
        print('Notification sent successfully');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // Helper method to truncate long messages
  String _truncateMessage(String message, {int maxLength = 50}) {
    if (message.length <= maxLength) return message;
    return '${message.substring(0, maxLength)}...';
  }

  // Get the current user's player ID
  String? get playerID => _playerID;
}
