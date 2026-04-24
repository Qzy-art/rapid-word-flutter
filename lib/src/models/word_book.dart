class WordItem {
  const WordItem({
    required this.id,
    required this.word,
    required this.meaning,
    this.phonetic = '',
    this.partOfSpeech = '',
    this.isWrong = false,
  });

  final String id;
  final String word;
  final String meaning;
  final String phonetic;
  final String partOfSpeech;
  final bool isWrong;

  WordItem copyWith({
    String? id,
    String? word,
    String? meaning,
    String? phonetic,
    String? partOfSpeech,
    bool? isWrong,
  }) {
    return WordItem(
      id: id ?? this.id,
      word: word ?? this.word,
      meaning: meaning ?? this.meaning,
      phonetic: phonetic ?? this.phonetic,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      isWrong: isWrong ?? this.isWrong,
    );
  }
}

class WordBook {
  const WordBook({
    required this.id,
    required this.title,
    required this.level,
    required this.description,
    required this.coverStyle,
    required this.words,
  });

  final String id;
  final String title;
  final String level;
  final String description;
  final String coverStyle;
  final List<WordItem> words;

  WordBook copyWith({
    String? id,
    String? title,
    String? level,
    String? description,
    String? coverStyle,
    List<WordItem>? words,
  }) {
    return WordBook(
      id: id ?? this.id,
      title: title ?? this.title,
      level: level ?? this.level,
      description: description ?? this.description,
      coverStyle: coverStyle ?? this.coverStyle,
      words: words ?? this.words,
    );
  }
}
