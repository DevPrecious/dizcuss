import 'package:dizcuss/controllers/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReactionPopup extends StatelessWidget {
  const ReactionPopup({
    Key? key,
    required this.messageId,
    required this.onReactionSelected,
  }) : super(key: key);

  final String messageId;
  final Function(String reaction) onReactionSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ChatController.reactions.map((reaction) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => onReactionSelected(reaction),
              child: Container(
                padding: EdgeInsets.all(8),
                child: Text(
                  reaction,
                  style: TextStyle(fontSize: 24.sp),
                ),
              ),
            ),
          );
        }).toList(),
      ),
      ),
    );
  }
}
