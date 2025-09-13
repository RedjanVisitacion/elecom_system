class Vote {
  final int id;
  final int userId;
  final int candidateId;
  final String position;
  final String candidateName;
  final DateTime createdAt;

  Vote({
    required this.id,
    required this.userId,
    required this.candidateId,
    required this.position,
    required this.candidateName,
    required this.createdAt,
  });

  factory Vote.fromJson(Map<String, dynamic> json) {
    return Vote(
      id: int.parse(json['id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      candidateId: int.parse(json['candidate_id'].toString()),
      position: json['position'],
      candidateName: json['candidate_name'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'candidate_id': candidateId,
      'position': position,
      'candidate_name': candidateName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
