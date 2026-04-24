class BookRecord {
  const BookRecord({
    required this.id,
    required this.title,
    required this.level,
    required this.description,
    required this.coverStyle,
    required this.ownerUserId,
  });

  final String id;
  final String title;
  final String level;
  final String description;
  final String coverStyle;
  final String ownerUserId;

  factory BookRecord.fromJson(Map<String, dynamic> json) {
    return BookRecord(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      level: json['level'] as String? ?? '',
      description: json['description'] as String? ?? '',
      coverStyle: json['cover_style'] as String? ?? 'mint',
      ownerUserId: json['owner_user_id'] as String? ?? '',
    );
  }
}
