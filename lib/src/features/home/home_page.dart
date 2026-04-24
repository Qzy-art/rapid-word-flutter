import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/app_shell.dart';
import '../books/books_page.dart';
import '../result/result_page.dart';
import '../review/review_page.dart';
import '../wrong_words/wrong_words_page.dart';
import 'state/home_provider.dart';
import 'state/home_state.dart';
import 'widgets/home_dashboard.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({
    super.key,
    this.supabaseEnabled = false,
    this.onSignOut,
    this.currentUserEmail,
  });

  final bool supabaseEnabled;
  final Future<void> Function()? onSignOut;
  final String? currentUserEmail;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(homeNotifierProvider.notifier);
      notifier.loadCloudBooks().then((_) => notifier.restoreLocalProgress());
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeNotifierProvider);
    final notifier = ref.read(homeNotifierProvider.notifier);
    final selectedBook = notifier.selectedBook;
    final wrongWords = notifier.wrongWords;
    final reviewWords = notifier.reviewWords;

    final pages = [
      HomeDashboard(
        book: selectedBook,
        wrongCount: wrongWords.length,
        todayCount: notifier.todayCount,
        totalSessions: state.dashboardStats.totalSessions,
        knownRate: state.dashboardStats.knownRate,
        wrongReviewCount: state.dashboardStats.wrongReviewCount,
        supabaseEnabled: widget.supabaseEnabled,
        cloudMessage: state.isLoadingCloud ? '正在同步云端数据...' : state.cloudMessage,
        onContinuePressed: notifier.startFullReview,
        onReviewWrongPressed: notifier.startWrongReview,
        onManageBooksPressed: () => notifier.changeTab(HomeTab.books),
      ),
      BooksPage(
        books: state.books,
        selectedBook: selectedBook,
        onSelectBook: notifier.selectBook,
        onStartReview: notifier.startFullReview,
        onCreateBook: ({
          required title,
          required level,
          required description,
        }) => notifier.createBook(
          title: title,
          level: level,
          description: description,
        ),
        onAddWord: ({
          required word,
          required phonetic,
          required partOfSpeech,
          required meaning,
        }) => notifier.addWord(
          word: word,
          phonetic: phonetic,
          partOfSpeech: partOfSpeech,
          meaning: meaning,
        ),
        onImportWords: notifier.importWords,
        onEditBook: ({
          required title,
          required level,
          required description,
        }) => notifier.updateBook(
          title: title,
          level: level,
          description: description,
        ),
        onEditWord: ({
          required wordId,
          required word,
          required phonetic,
          required partOfSpeech,
          required meaning,
        }) => notifier.updateWord(
          wordId: wordId,
          word: word,
          phonetic: phonetic,
          partOfSpeech: partOfSpeech,
          meaning: meaning,
        ),
        onDeleteWord: notifier.deleteWord,
      ),
      ReviewPage(
        book: selectedBook,
        words: reviewWords,
        currentIndex: state.reviewIndex,
        mode: state.reviewMode,
        knownCount: state.sessionKnown,
        unknownCount: state.sessionUnknown,
        onRestart: () {
          if (state.reviewMode == ReviewMode.wrongWords) {
            notifier.startWrongReview();
            return;
          }
          notifier.startFullReview(selectedBook.id);
        },
        onKnown: () => notifier.recordDecision(true),
        onUnknown: () => notifier.recordDecision(false),
      ),
      ResultPage(
        wrongCount: wrongWords.length,
        session: state.lastSession,
        onPrimaryPressed:
            wrongWords.isNotEmpty ? notifier.startWrongReview : () => notifier.startFullReview(selectedBook.id),
        onHomePressed: notifier.goHome,
      ),
      WrongWordsPage(
        words: wrongWords,
        onReviewWrongPressed: notifier.startWrongReview,
      ),
    ];

    return AppShell(
      title: '速刷单词',
      subtitle: widget.currentUserEmail == null ? '考前快刷\n多端互通' : '${widget.currentUserEmail}\n多端互通',
      currentIndex: state.currentTab.index,
      onDestinationSelected: (value) => notifier.changeTab(HomeTab.values[value]),
      body: pages[state.currentTab.index],
      trailing: widget.onSignOut == null
          ? null
          : IconButton(
              tooltip: '退出登录',
              onPressed: () => widget.onSignOut!.call(),
              icon: const Icon(Icons.logout_rounded),
            ),
    );
  }
}
