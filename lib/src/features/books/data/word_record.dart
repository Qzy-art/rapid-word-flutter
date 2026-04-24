class WordRecord {
  const WordRecord({
    required this.id,
    required this.bookId,
    required this.word,
    required this.phonetic,
    required this.partOfSpeech,
    required this.meaning,
    required this.isWrong,
  });

  final String id;
  final String bookId;
  final String word;
  final String phonetic;
  final String partOfSpeech;
  final String meaning;
  final bool isWrong;

  factory WordRecord.fromJson(Map<String, dynamic> json) {
    return WordRecord(
      id: json['id'] as String,
      bookId: json['book_id'] as String,
      word: json['word'] as String? ?? '',
      phonetic: json['phonetic'] as String? ?? '',
      partOfSpeech: json['part_of_speech'] as String? ?? '',
      meaning: json['meaning'] as String? ?? '',
      isWrong: json['is_wrong'] as bool? ?? false,
    );
  }
}
