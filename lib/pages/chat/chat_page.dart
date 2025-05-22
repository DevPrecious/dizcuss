import 'package:dizcuss/consts/color.dart';
import 'package:dizcuss/controllers/auth_controller.dart';
import 'package:dizcuss/controllers/chat_controller.dart';
import 'package:dizcuss/models/poll.dart';
import 'package:dizcuss/pages/chat/widgets/poll_widget.dart';
import 'package:dizcuss/pages/chat/widgets/reaction_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key, required this.roomId, required this.roomTitle})
    : super(key: key);

  final String roomId;
  final String roomTitle;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final ChatController _chatController;
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _pollQuestionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  // For swipe to reply functionality
  Map<String, dynamic>? _replyToMessage;

  @override
  void initState() {
    super.initState();
    _chatController = Get.put(
      ChatController(roomId: widget.roomId),
      tag: widget.roomId,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _pollQuestionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    Get.delete<ChatController>(tag: widget.roomId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.roomTitle, style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (_chatController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                reverse: true,
                itemCount: _chatController.messages.length,
                itemBuilder: (context, index) {
                  final msg = _chatController.messages[index];
                  final isMe =
                      msg['senderId'] == AuthController.instance.user?.uid;
                  return Dismissible(
                    key: Key(msg['id']),
                    direction: DismissDirection.startToEnd,
                    background: Container(
                      color: Colors.blue.withOpacity(0.2),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.centerLeft,
                      child: Icon(Icons.reply, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      setState(() {
                        _replyToMessage = msg;
                      });
                      return false;
                    },
                    child: Material(
                      color: Colors.transparent,
                      child: Builder(
                        builder:
                            (context) => GestureDetector(
                              onLongPress: () {
                                final RenderBox overlay =
                                    Overlay.of(
                                          context,
                                        ).context.findRenderObject()
                                        as RenderBox;
                                final RenderBox button =
                                    context.findRenderObject() as RenderBox;
                                final Offset position = button.localToGlobal(
                                  Offset(
                                    0,
                                    -60,
                                  ), // Show popup above the message
                                  ancestor: overlay,
                                );

                                showMenu(
                                  context: context,
                                  position: RelativeRect.fromLTRB(
                                    position.dx,
                                    position.dy,
                                    position.dx + button.size.width,
                                    position.dy + 60,
                                  ),
                                  items: [
                                    PopupMenuItem(
                                      padding: EdgeInsets.zero,
                                      child: ReactionPopup(
                                        messageId: msg['id'],
                                        onReactionSelected: (reaction) {
                                          _chatController.addReaction(
                                            msg['id'],
                                            reaction,
                                          );
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                  ],
                                  elevation: 0,
                                  color: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                );
                              },
                              child: Align(
                                alignment:
                                    isMe
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 6),
                                  child: Column(
                                    crossAxisAlignment:
                                        isMe
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            isMe
                                                ? MainAxisAlignment.end
                                                : MainAxisAlignment.start,
                                        children: [
                                          if (!msg['isMe'])
                                            CircleAvatar(radius: 15),
                                          SizedBox(width: 8.w),
                                          Text(
                                            msg['sender'],
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4.h),
                                      Container(
                                        padding: EdgeInsets.all(12),
                                        constraints: BoxConstraints(
                                          maxWidth: 280.w,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              isMe
                                                  ? Colors.blueAccent
                                                  : Colors.grey[800],
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            topRight: Radius.circular(12),
                                            bottomLeft:
                                                isMe
                                                    ? Radius.circular(12)
                                                    : Radius.circular(0),
                                            bottomRight:
                                                isMe
                                                    ? Radius.circular(0)
                                                    : Radius.circular(12),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (msg['replyTo'] != null) ...[
                                              Container(
                                                padding: EdgeInsets.all(8),
                                                margin: EdgeInsets.only(
                                                  bottom: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.black26,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      msg['replyTo']['sender'],
                                                      style: TextStyle(
                                                        color: Colors.blue,
                                                        fontSize: 12.sp,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      msg['replyTo']['text'] ??
                                                          'Poll',
                                                      style: TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 12.sp,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            msg['type'] == 'poll'
                                                ? PollWidget(
                                                  poll: msg['poll'] as Poll,
                                                  onVote: (option) {
                                                    _chatController.votePoll(
                                                      msg['id'],
                                                      option,
                                                    );
                                                  },
                                                )
                                                : Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      msg['text'] ?? '',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14.sp,
                                                      ),
                                                    ),
                                                    if (msg['reactions'] !=
                                                            null &&
                                                        (msg['reactions']
                                                                as Map<
                                                                  String,
                                                                  dynamic
                                                                >)
                                                            .isNotEmpty)
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                          top: 8,
                                                        ),
                                                        child: Wrap(
                                                          spacing: 4,
                                                          children: [
                                                            for (final entry
                                                                in (msg['reactions']
                                                                        as Map<
                                                                          String,
                                                                          dynamic
                                                                        >)
                                                                    .entries)
                                                              if ((entry.value
                                                                      as List)
                                                                  .isNotEmpty)
                                                                Container(
                                                                  padding:
                                                                      EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            8,
                                                                        vertical:
                                                                            4,
                                                                      ),
                                                                  decoration: BoxDecoration(
                                                                    color:
                                                                        Colors
                                                                            .black26,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          12,
                                                                        ),
                                                                  ),
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      Text(
                                                                        entry
                                                                            .key,
                                                                        style: TextStyle(
                                                                          fontSize:
                                                                              16.sp,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            4,
                                                                      ),
                                                                      Text(
                                                                        (entry.value
                                                                                as List)
                                                                            .length
                                                                            .toString(),
                                                                        style: TextStyle(
                                                                          color:
                                                                              Colors.white70,
                                                                          fontSize:
                                                                              12.sp,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                          ],
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_replyToMessage != null)
                  Container(
                    padding: EdgeInsets.all(8),
                    color: Colors.grey[900],
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Replying to ${_replyToMessage!['sender']}',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12.sp,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                _replyToMessage!['text'] ?? 'Poll',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12.sp,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.white70),
                          onPressed: () {
                            setState(() {
                              _replyToMessage = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                Container(
                  padding: EdgeInsets.all(8),
                  color: backgroundColor,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: textController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(color: Colors.white54),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.white54),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.white54),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.poll, color: Colors.white),
                        onPressed: () => _showCreatePollDialog(context),
                      ),
                      IconButton(
                        icon: Icon(Icons.send, color: Colors.white),
                        onPressed: () {
                          if (textController.text.trim().isNotEmpty) {
                            _chatController.sendMessage(
                              textController.text.trim(),
                              replyTo: _replyToMessage,
                            );
                            setState(() {
                              _replyToMessage = null;
                            });
                            textController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreatePollDialog(BuildContext context) {
    _pollQuestionController.clear();
    for (var controller in _optionControllers) {
      controller.clear();
    }
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: backgroundColor,
            title: Text('Create Poll', style: TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _pollQuestionController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter your question',
                      hintStyle: TextStyle(color: Colors.white54),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ...List.generate(_optionControllers.length, (index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _optionControllers[index],
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Option ${index + 1}',
                                hintStyle: TextStyle(color: Colors.white54),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white54),
                                ),
                              ),
                            ),
                          ),
                          if (_optionControllers.length > 2)
                            IconButton(
                              icon: Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                setState(() {
                                  final controller = _optionControllers
                                      .removeAt(index);
                                  controller.dispose();
                                });
                              },
                            ),
                        ],
                      ),
                    );
                  }),
                  if (_optionControllers.length < 5)
                    TextButton.icon(
                      icon: Icon(Icons.add, color: Colors.white),
                      label: Text(
                        'Add Option',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        setState(() {
                          _optionControllers.add(TextEditingController());
                        });
                      },
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text('Cancel', style: TextStyle(color: Colors.white54)),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text('Create', style: TextStyle(color: Colors.blue)),
                onPressed: () {
                  if (_pollQuestionController.text.trim().isEmpty) {
                    return;
                  }

                  final options =
                      _optionControllers
                          .map((c) => c.text.trim())
                          .where((text) => text.isNotEmpty)
                          .toList();

                  if (options.length < 2) {
                    return;
                  }

                  _chatController.createPoll(
                    _pollQuestionController.text.trim(),
                    options,
                  );

                  _pollQuestionController.clear();
                  for (var controller in _optionControllers) {
                    controller.clear();
                  }

                  Navigator.pop(context);
                },
              ),
            ],
          ),
    );
  }
}
