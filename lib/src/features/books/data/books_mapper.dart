import '../../../models/word_book.dart';
import 'book_record.dart';
import 'word_record.dart';

WordBook toWordBook(BookRecord book, List<WordRecord> words) {
  return WordBook(
    id: book.id,
    title: book.title,
    level: book.level,
    description: book.description,
    coverStyle: book.coverStyle,
    words: words
        .map(
          (word) => WordItem(
            id: word.id,
            word: word.word,
            phonetic: word.phonetic,
            partOfSpeech: word.partOfSpeech,
            meaning: word.meaning,
            isWrong: word.isWrong,
          ),
        )
        .toList(),
  );
}
