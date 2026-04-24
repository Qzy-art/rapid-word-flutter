import '../models/word_book.dart';
import 'cet4_words.dart';

final mockBooks = <WordBook>[
  const WordBook(
    id: 'ky-5500',
    title: '考研核心 5500',
    level: '高频考研',
    description: '适合考前快刷，先用少量样例演示完整闭环。',
    coverStyle: 'mint',
    words: [
      WordItem(id: 'w1', word: 'impression', phonetic: '/ɪmˈpreʃən/', partOfSpeech: 'n.', meaning: '印象；感想'),
      WordItem(id: 'w2', word: 'cooperation', phonetic: '/kəʊˌɒpəˈreɪʃən/', partOfSpeech: 'n.', meaning: '合作；协作'),
      WordItem(id: 'w3', word: 'guarantee', phonetic: '/ˌɡærənˈtiː/', partOfSpeech: 'n./v.', meaning: '保证；担保'),
      WordItem(id: 'w4', word: 'concerned', phonetic: '/kənˈsɜːnd/', partOfSpeech: 'adj.', meaning: '关心的；有关的'),
      WordItem(id: 'w5', word: 'engage', phonetic: '/ɪnˈɡeɪdʒ/', partOfSpeech: 'v.', meaning: '从事；吸引', isWrong: true),
      WordItem(id: 'w6', word: 'perceive', phonetic: '/pəˈsiːv/', partOfSpeech: 'v.', meaning: '察觉；理解', isWrong: true),
    ],
  ),
  WordBook(
    id: 'cet4',
    title: '四级试用词书',
    level: 'CET-4',
    description: '按四级常见范围整理的试用版，含音标、词性和中文释义，当前已扩展到 500 词。',
    coverStyle: 'sun',
    words: cet4Words,
  ),
  const WordBook(
    id: 'ielts',
    title: '雅思核心词',
    level: 'IELTS',
    description: '偏学术和场景表达，适合后续扩展。',
    coverStyle: 'sky',
    words: [],
  ),
];
