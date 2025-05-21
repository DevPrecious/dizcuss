import 'package:dizcuss/controllers/auth_controller.dart';
import 'package:dizcuss/models/poll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PollWidget extends StatelessWidget {
  final Poll poll;
  final Function(String) onVote;

  const PollWidget({
    Key? key,
    required this.poll,
    required this.onVote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthController.instance.user!;
    bool hasVoted = false;
    String? userVote;

    // Check if user has voted
    for (var entry in poll.votes.entries) {
      if (entry.value.contains(currentUser.uid)) {
        hasVoted = true;
        userVote = entry.key;
        break;
      }
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            poll.question,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          ...poll.options.map((option) {
            final votes = poll.votes[option]?.length ?? 0;
            final totalVotes = poll.votes.values
                .fold(0, (sum, list) => sum + list.length);
            final percentage = totalVotes > 0 ? (votes / totalVotes) * 100 : 0.0;
            final isSelected = userVote == option;

            return GestureDetector(
              onTap: hasVoted ? null : () => onVote(option),
              child: Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue.withOpacity(0.3)
                      : Colors.grey[700],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                            ),
                          ),
                          if (hasVoted) ...[
                            SizedBox(height: 4.h),
                            LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Colors.grey[600],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blue,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (hasVoted)
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.sp,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
          SizedBox(height: 8.h),
          Text(
            'Total votes: ${poll.votes.values.fold(0, (sum, list) => sum + list.length)}',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}
