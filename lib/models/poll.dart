class Poll {
  final String question;
  final List<String> options;
  final Map<String, List<String>> votes; // option -> list of user IDs who voted
  final DateTime createdAt;
  final String createdBy;
  final DateTime? endsAt;

  Poll({
    required this.question,
    required this.options,
    required this.votes,
    required this.createdAt,
    required this.createdBy,
    this.endsAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'votes': votes.map((key, value) => MapEntry(key, value)),
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'endsAt': endsAt?.toIso8601String(),
    };
  }

  factory Poll.fromMap(Map<String, dynamic> map) {
    return Poll(
      question: map['question'] as String,
      options: List<String>.from(map['options']),
      votes: Map<String, List<String>>.from(
        map['votes'].map(
          (key, value) => MapEntry(
            key as String,
            List<String>.from(value as List),
          ),
        ),
      ),
      createdAt: DateTime.parse(map['createdAt']),
      createdBy: map['createdBy'] as String,
      endsAt: map['endsAt'] != null ? DateTime.parse(map['endsAt']) : null,
    );
  }
}
