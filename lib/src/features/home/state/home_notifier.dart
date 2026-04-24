import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/word_book.dart';
import '../../books/data/books_mapper.dart';
import '../../books/data/books_repository.dart';
import 'home_state.dart';

class HomeNotifier extends StateNotifier<HomeState> {
  static const _resumeStateKey = 'rapid_word_resume_state';

  HomeNotifier({
    required List<WordBook> initialBooks,
    required this.booksRepository,
  }) : super(HomeState.initial(initialBooks));

  final BooksRepository? booksRepository;

  WordBook get selectedBook =>
      state.books.firstWhere((book) => book.id == state.selectedBookId);

  List<WordItem> get wrongWords =>
      selectedBook.words.where((word) => word.isWrong).toList();

  List<WordItem> get reviewWords =>
      state.reviewMode == ReviewMode.wrongWords ? wrongWords : selectedBook.words;

  int get todayCount =>
      booksRepository == null ? state.sessionKnown + state.sessionUnknown : state.dashboardStats.todayReviewed;

  void changeTab(HomeTab tab) {
    state = state.copyWith(currentTab: tab);
    unawaited(_persistLocalProgress());
  }

  void selectBook(String bookId) {
    state = state.copyWith(
      selectedBookId: bookId,
      currentTab: HomeTab.books,
    );
    unawaited(_persistLocalProgress());
  }

  void goHome() {
    state = state.copyWith(currentTab: HomeTab.dashboard);
    unawaited(_persistLocalProgress());
  }

  void startFullReview([String? bookId]) {
    final nextBookId = bookId ?? state.selectedBookId;
    final reviewCount = _reviewWordsFor(
      mode: ReviewMode.fullBook,
      selectedBookId: nextBookId,
    ).length;

    state = state.copyWith(
      selectedBookId: nextBookId,
      reviewMode: ReviewMode.fullBook,
      reviewIndex: 0,
      sessionKnown: 0,
      sessionUnknown: 0,
      clearActiveSessionId: true,
      currentTab: HomeTab.review,
    );
    unawaited(_persistLocalProgress());

    if (reviewCount > 0) {
      unawaited(_startCloudSession(
        bookId: nextBookId,
        mode: ReviewMode.fullBook,
        totalCount: reviewCount,
      ));
    }
  }

  void startWrongReview() {
    final reviewCount = wrongWords.length;
    state = state.copyWith(
      reviewMode: ReviewMode.wrongWords,
      reviewIndex: 0,
      sessionKnown: 0,
      sessionUnknown: 0,
      clearActiveSessionId: true,
      currentTab: reviewCount == 0 ? HomeTab.wrongWords : HomeTab.review,
    );
    unawaited(_persistLocalProgress());

    if (reviewCount > 0) {
      unawaited(_startCloudSession(
        bookId: state.selectedBookId,
        mode: ReviewMode.wrongWords,
        totalCount: reviewCount,
      ));
    }
  }

  Future<void> recordDecision(bool known) async {
    final words = reviewWords;
    if (words.isEmpty || state.reviewIndex >= words.length) {
      return;
    }

    final current = words[state.reviewIndex];
    final updatedWord = current.copyWith(
      isWrong: known ? (state.reviewMode == ReviewMode.wrongWords ? false : current.isWrong) : true,
    );

    final sessionId = state.activeSessionId;

    final updatedBooks = _replaceWordInSelectedBook(
      wordId: current.id,
      updatedWord: updatedWord,
    );

    final nextKnown = state.sessionKnown + (known ? 1 : 0);
    final nextUnknown = state.sessionUnknown + (known ? 0 : 1);
    final nextIndex = state.reviewIndex + 1;
    final reachedEnd = nextIndex >= words.length;
    final summary = SessionSummary(
      mode: state.reviewMode,
      done: nextKnown + nextUnknown,
      known: nextKnown,
      unknown: nextUnknown,
    );

    state = state.copyWith(
      books: updatedBooks,
      reviewIndex: nextIndex,
      sessionKnown: nextKnown,
      sessionUnknown: nextUnknown,
      currentTab: reachedEnd ? HomeTab.result : HomeTab.review,
      lastSession: reachedEnd ? summary : state.lastSession,
      clearActiveSessionId: reachedEnd,
    );
    unawaited(_persistLocalProgress());

    // Keep review interactions snappy on mobile web by moving cloud writes
    // off the critical UI path.
    unawaited(_persistWrongFlag(
      wordId: current.id,
      isWrong: updatedWord.isWrong,
      fallbackMessage: '云端错词状态同步失败，当前继续保留本地结果。',
    ));

    if (sessionId != null) {
      unawaited(_persistStudyRecord(
        sessionId: sessionId,
        wordId: current.id,
        known: known,
      ));
    }

    if (!reachedEnd && sessionId != null) {
      unawaited(_persistSessionProgress(
        sessionId: sessionId,
        reviewIndex: nextIndex,
        knownCount: nextKnown,
        unknownCount: nextUnknown,
      ));
    }

    if (reachedEnd && sessionId != null) {
      unawaited(_finishCloudSession(
        sessionId: sessionId,
        summary: summary,
      ).then((_) => loadDashboardStats()));
    }
  }

  Future<void> createBook({
    required String title,
    required String level,
    required String description,
  }) async {
    final normalizedLevel = level.isEmpty ? '自定义词书' : level;
    final normalizedDescription = description.isEmpty ? '手动创建的词书。' : description;
    final repository = booksRepository;

    if (repository != null) {
      try {
        await repository.createBook(
          title: title,
          level: normalizedLevel,
          description: normalizedDescription,
          coverStyle: 'mint',
        );
        await loadCloudBooks();
        state = state.copyWith(currentTab: HomeTab.books);
        return;
      } catch (_) {
        _setCloudMessage('云端创建失败，已回退到本地创建。');
      }
    }

    final newBook = WordBook(
      id: 'book-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      level: normalizedLevel,
      description: normalizedDescription,
      coverStyle: 'mint',
      words: const [],
    );

    state = state.copyWith(
      books: [newBook, ...state.books],
      selectedBookId: newBook.id,
      currentTab: HomeTab.books,
    );
    unawaited(_persistLocalProgress());
  }

  Future<void> addWord({
    required String word,
    required String phonetic,
    required String partOfSpeech,
    required String meaning,
  }) async {
    final repository = booksRepository;

    if (repository != null) {
      try {
        await repository.addWord(
          bookId: selectedBook.id,
          word: word,
          phonetic: phonetic,
          partOfSpeech: partOfSpeech,
          meaning: meaning,
        );
        await loadCloudBooks();
        state = state.copyWith(currentTab: HomeTab.books);
        return;
      } catch (_) {
        _setCloudMessage('云端加词失败，已回退到本地添加。');
      }
    }

    final newWord = WordItem(
      id: 'word-${DateTime.now().microsecondsSinceEpoch}',
      word: word,
      phonetic: phonetic,
      partOfSpeech: partOfSpeech,
      meaning: meaning,
    );

    state = state.copyWith(
      books: _replaceSelectedBook(
        selectedBook.copyWith(words: [newWord, ...selectedBook.words]),
      ),
      currentTab: HomeTab.books,
    );
    unawaited(_persistLocalProgress());
  }

  Future<void> importWords(String rawText) async {
    final lines = rawText
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return;
    }

    final repository = booksRepository;
    if (repository != null) {
      try {
        for (final line in lines) {
          final parts = line.split('|').map((item) => item.trim()).toList();
          if (parts.isEmpty || parts.first.isEmpty) {
            continue;
          }

          await repository.addWord(
            bookId: selectedBook.id,
            word: parts.first,
            phonetic: parts.length > 1 ? parts[1] : '',
            partOfSpeech: parts.length > 2 ? parts[2] : '',
            meaning: parts.length > 3 ? parts[3] : '待补充释义',
          );
        }
        await loadCloudBooks();
        state = state.copyWith(currentTab: HomeTab.books);
        return;
      } catch (_) {
        _setCloudMessage('云端导入失败，已回退到本地导入。');
      }
    }

    final existing = selectedBook.words.map((word) => word.word.toLowerCase()).toSet();
    final imported = <WordItem>[];

    for (final line in lines) {
      final parts = line.split('|').map((item) => item.trim()).toList();
      if (parts.isEmpty || parts.first.isEmpty) {
        continue;
      }

      final headword = parts.first;
      if (existing.contains(headword.toLowerCase())) {
        continue;
      }

      imported.add(
        WordItem(
          id: 'import-${DateTime.now().microsecondsSinceEpoch}-${imported.length}',
          word: headword,
          phonetic: parts.length > 1 ? parts[1] : '',
          partOfSpeech: parts.length > 2 ? parts[2] : '',
          meaning: parts.length > 3 ? parts[3] : '待补充释义',
        ),
      );
      existing.add(headword.toLowerCase());
    }

    if (imported.isEmpty) {
      return;
    }

    state = state.copyWith(
      books: _replaceSelectedBook(
        selectedBook.copyWith(words: [...selectedBook.words, ...imported]),
      ),
      currentTab: HomeTab.books,
    );
    unawaited(_persistLocalProgress());
  }

  Future<void> updateBook({
    required String title,
    required String level,
    required String description,
  }) async {
    final updatedBook = selectedBook.copyWith(
      title: title,
      level: level.isEmpty ? selectedBook.level : level,
      description: description.isEmpty ? selectedBook.description : description,
    );

    final repository = booksRepository;
    if (repository != null) {
      try {
        await repository.updateBook(
          bookId: selectedBook.id,
          title: updatedBook.title,
          level: updatedBook.level,
          description: updatedBook.description,
        );
        await loadCloudBooks();
        state = state.copyWith(currentTab: HomeTab.books);
        return;
      } catch (_) {
        _setCloudMessage('云端更新词书失败，已回退到本地修改。');
      }
    }

    state = state.copyWith(
      books: _replaceSelectedBook(updatedBook),
      currentTab: HomeTab.books,
    );
    unawaited(_persistLocalProgress());
  }

  Future<void> updateWord({
    required String wordId,
    required String word,
    required String phonetic,
    required String partOfSpeech,
    required String meaning,
  }) async {
    final wordIndex = selectedBook.words.indexWhere((item) => item.id == wordId);
    if (wordIndex < 0) {
      return;
    }

    final updatedWord = selectedBook.words[wordIndex].copyWith(
      word: word,
      phonetic: phonetic,
      partOfSpeech: partOfSpeech,
      meaning: meaning,
    );

    final repository = booksRepository;
    if (repository != null) {
      try {
        await repository.updateWord(
          wordId: wordId,
          word: word,
          phonetic: phonetic,
          partOfSpeech: partOfSpeech,
          meaning: meaning,
        );
        await loadCloudBooks();
        state = state.copyWith(currentTab: HomeTab.books);
        return;
      } catch (_) {
        _setCloudMessage('云端改单词失败，已回退到本地修改。');
      }
    }

    state = state.copyWith(
      books: _replaceWordInSelectedBook(
        wordId: wordId,
        updatedWord: updatedWord,
      ),
      currentTab: HomeTab.books,
    );
    unawaited(_persistLocalProgress());
  }

  Future<void> deleteWord(String wordId) async {
    final repository = booksRepository;
    if (repository != null) {
      try {
        await repository.deleteWord(wordId);
        await loadCloudBooks();
        state = state.copyWith(currentTab: HomeTab.books);
        return;
      } catch (_) {
        _setCloudMessage('云端删词失败，已回退到本地删除。');
      }
    }

    state = state.copyWith(
      books: _replaceSelectedBook(
        selectedBook.copyWith(
          words: selectedBook.words.where((item) => item.id != wordId).toList(),
        ),
      ),
      currentTab: HomeTab.books,
    );
    unawaited(_persistLocalProgress());
  }

  Future<void> loadCloudBooks() async {
    final repository = booksRepository;
    if (repository == null) {
      return;
    }

    state = state.copyWith(
      isLoadingCloud: true,
      cloudMessage: '正在尝试加载云端数据',
    );

    try {
      final bookRecords = await repository.fetchBooks();
      final dashboardStats = await repository.fetchDashboardStats();
      final books = await Future.wait(
        bookRecords.map((book) async {
          final words = await repository.fetchWords(book.id);
          return toWordBook(book, words);
        }),
      );

      state = state.copyWith(
        books: books.isEmpty ? state.books : books,
        selectedBookId: books.isEmpty ? state.selectedBookId : books.first.id,
        cloudMessage: books.isEmpty ? '云端已连接，但还没有词书数据。' : '已加载云端词书和统计数据。',
        dashboardStats: DashboardStats(
          todayReviewed: dashboardStats.todayReviewed,
          totalSessions: dashboardStats.totalSessions,
          knownRate: dashboardStats.knownRate,
          wrongReviewCount: dashboardStats.wrongReviewCount,
        ),
        isLoadingCloud: false,
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingCloud: false,
        cloudMessage: '云端加载失败，当前继续使用本地 mock 数据。',
      );
    }
  }

  Future<void> loadDashboardStats() async {
    final repository = booksRepository;
    if (repository == null) {
      return;
    }

    try {
      final dashboardStats = await repository.fetchDashboardStats();
      state = state.copyWith(
        dashboardStats: DashboardStats(
          todayReviewed: dashboardStats.todayReviewed,
          totalSessions: dashboardStats.totalSessions,
          knownRate: dashboardStats.knownRate,
          wrongReviewCount: dashboardStats.wrongReviewCount,
        ),
      );
    } catch (_) {
      _setCloudMessage('云端统计刷新失败，当前继续显示已有统计。');
    }
  }

  Future<void> restoreLocalProgress() async {
    final restoredCloud = await _restoreCloudProgress();
    if (restoredCloud) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_resumeStateKey);
    if (raw == null || raw.isEmpty) {
      return;
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final wrongIds = ((decoded['wrongWordIds'] as List?) ?? const [])
          .whereType<String>()
          .toSet();

      final restoredBooks = state.books
          .map(
            (book) => book.copyWith(
              words: book.words
                  .map((word) => word.copyWith(isWrong: wrongIds.contains(word.id)))
                  .toList(),
            ),
          )
          .toList();

      final selectedBookId = decoded['selectedBookId'] as String?;
      final resolvedBookId = restoredBooks.any((book) => book.id == selectedBookId)
          ? selectedBookId!
          : restoredBooks.first.id;

      final reviewModeIndex = (decoded['reviewMode'] as num?)?.toInt() ?? ReviewMode.fullBook.index;
      final reviewMode = ReviewMode.values[reviewModeIndex.clamp(0, ReviewMode.values.length - 1)];

      final currentTabIndex = (decoded['currentTab'] as num?)?.toInt() ?? HomeTab.dashboard.index;
      var currentTab = HomeTab.values[currentTabIndex.clamp(0, HomeTab.values.length - 1)];

      final reviewableWords = _reviewWordsForBooks(
        books: restoredBooks,
        mode: reviewMode,
        selectedBookId: resolvedBookId,
      );
      final savedReviewIndex = (decoded['reviewIndex'] as num?)?.toInt() ?? 0;
      final reviewIndex = reviewableWords.isEmpty
          ? 0
          : savedReviewIndex.clamp(0, reviewableWords.length - 1);

      if (currentTab == HomeTab.review && reviewableWords.isEmpty) {
        currentTab = HomeTab.dashboard;
      }

      state = state.copyWith(
        books: restoredBooks,
        selectedBookId: resolvedBookId,
        reviewMode: reviewMode,
        currentTab: currentTab,
        reviewIndex: reviewIndex,
        sessionKnown: (decoded['sessionKnown'] as num?)?.toInt() ?? 0,
        sessionUnknown: (decoded['sessionUnknown'] as num?)?.toInt() ?? 0,
      );
    } catch (_) {
      await prefs.remove(_resumeStateKey);
    }
  }

  Future<void> _persistLocalProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = <String, dynamic>{
      'selectedBookId': state.selectedBookId,
      'currentTab': state.currentTab.index,
      'reviewMode': state.reviewMode.index,
      'reviewIndex': state.reviewIndex,
      'sessionKnown': state.sessionKnown,
      'sessionUnknown': state.sessionUnknown,
      'wrongWordIds': [
        for (final book in state.books)
          for (final word in book.words)
            if (word.isWrong) word.id,
      ],
    };
    await prefs.setString(_resumeStateKey, jsonEncode(payload));
  }

  Future<bool> _restoreCloudProgress() async {
    final repository = booksRepository;
    if (repository == null) {
      return false;
    }

    try {
      final activeSession = await repository.fetchActiveStudySession();
      if (activeSession == null) {
        return false;
      }

      final hasBook = state.books.any((book) => book.id == activeSession.bookId);
      if (!hasBook) {
        return false;
      }

      final reviewMode = activeSession.reviewMode == 'wrong_words'
          ? ReviewMode.wrongWords
          : ReviewMode.fullBook;

      final reviewableWords = _reviewWordsForBooks(
        books: state.books,
        mode: reviewMode,
        selectedBookId: activeSession.bookId,
      );

      final safeIndex = reviewableWords.isEmpty
          ? 0
          : activeSession.reviewIndex.clamp(0, reviewableWords.length - 1);

      state = state.copyWith(
        selectedBookId: activeSession.bookId,
        reviewMode: reviewMode,
        reviewIndex: safeIndex,
        sessionKnown: activeSession.sessionKnown,
        sessionUnknown: activeSession.sessionUnknown,
        activeSessionId: activeSession.sessionId,
        currentTab: reviewableWords.isEmpty ? HomeTab.dashboard : HomeTab.review,
      );
      unawaited(_persistLocalProgress());
      return true;
    } catch (_) {
      _setCloudMessage('云端进度恢复失败，已回退到本地记录。');
      return false;
    }
  }

  Future<void> _persistSessionProgress({
    required String sessionId,
    required int reviewIndex,
    required int knownCount,
    required int unknownCount,
  }) async {
    final repository = booksRepository;
    if (repository == null) {
      return;
    }

    try {
      await repository.updateStudySessionProgress(
        sessionId: sessionId,
        reviewIndex: reviewIndex,
        knownCount: knownCount,
        unknownCount: unknownCount,
      );
    } catch (_) {
      _setCloudMessage('云端进度同步失败，当前先保存在本地。');
    }
  }

  Future<void> _startCloudSession({
    required String bookId,
    required ReviewMode mode,
    required int totalCount,
  }) async {
    final repository = booksRepository;
    if (repository == null) {
      return;
    }

    try {
      final sessionId = await repository.createStudySession(
        bookId: bookId,
        reviewMode: _reviewModeValue(mode),
        totalCount: totalCount,
      );
      state = state.copyWith(activeSessionId: sessionId);
    } catch (_) {
      _setCloudMessage('云端学习会话创建失败，当前继续使用本地流程。');
    }
  }

  Future<void> _persistWrongFlag({
    required String wordId,
    required bool isWrong,
    required String fallbackMessage,
  }) async {
    final repository = booksRepository;
    if (repository == null) {
      return;
    }

    try {
      await repository.setWrongFlag(wordId: wordId, isWrong: isWrong);
    } catch (_) {
      _setCloudMessage(fallbackMessage);
    }
  }

  Future<void> _persistStudyRecord({
    required String sessionId,
    required String wordId,
    required bool known,
  }) async {
    final repository = booksRepository;
    if (repository == null) {
      return;
    }

    try {
      await repository.addStudyRecord(
        sessionId: sessionId,
        wordId: wordId,
        known: known,
      );
    } catch (_) {
      _setCloudMessage('云端学习记录写入失败，当前继续保留本地结果。');
    }
  }

  Future<void> _finishCloudSession({
    required String sessionId,
    required SessionSummary summary,
  }) async {
    final repository = booksRepository;
    if (repository == null) {
      return;
    }

    try {
      await repository.finishStudySession(
        sessionId: sessionId,
        totalCount: summary.done,
        knownCount: summary.known,
        unknownCount: summary.unknown,
      );
    } catch (_) {
      _setCloudMessage('云端学习会话汇总失败，当前继续保留本地结果。');
    }
  }

  List<WordItem> _reviewWordsFor({
    required ReviewMode mode,
    required String selectedBookId,
  }) {
    return _reviewWordsForBooks(
      books: state.books,
      mode: mode,
      selectedBookId: selectedBookId,
    );
  }

  List<WordItem> _reviewWordsForBooks({
    required List<WordBook> books,
    required ReviewMode mode,
    required String selectedBookId,
  }) {
    final book = books.firstWhere((item) => item.id == selectedBookId);
    return mode == ReviewMode.wrongWords ? book.words.where((word) => word.isWrong).toList() : book.words;
  }

  String _reviewModeValue(ReviewMode mode) {
    return mode == ReviewMode.wrongWords ? 'wrong_words' : 'full_book';
  }

  List<WordBook> _replaceSelectedBook(WordBook updatedBook) {
    return [
      for (final book in state.books)
        if (book.id == updatedBook.id) updatedBook else book,
    ];
  }

  List<WordBook> _replaceWordInSelectedBook({
    required String wordId,
    required WordItem updatedWord,
  }) {
    final updatedWords = [
      for (final item in selectedBook.words)
        if (item.id == wordId) updatedWord else item,
    ];
    return _replaceSelectedBook(selectedBook.copyWith(words: updatedWords));
  }

  void _setCloudMessage(String message) {
    state = state.copyWith(cloudMessage: message);
  }
}
