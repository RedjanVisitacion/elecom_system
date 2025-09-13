class Candidate {
  final int id;
  final String name;
  final String position;
  final String description;
  final String imageUrl;
  final bool isActive;

  Candidate({
    required this.id,
    required this.name,
    required this.position,
    required this.description,
    required this.imageUrl,
    required this.isActive,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      id: int.parse(json['id'].toString()),
      name: json['name'],
      position: json['position'],
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      isActive:
          json['is_active'] == 1 ||
          json['is_active'] == true ||
          json['is_active'] == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'description': description,
      'image_url': imageUrl,
      'is_active': isActive,
    };
  }
}
