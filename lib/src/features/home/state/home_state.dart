import '../../../models/word_book.dart';

enum ReviewMode { fullBook, wrongWords }

enum HomeTab { dashboard, books, review, result, wrongWords }

class SessionSummary {
  const SessionSummary({
    required this.mode,
    required this.done,
    required this.known,
    required this.unknown,
  });

  final ReviewMode mode;
  final int done;
  final int known;
  final int unknown;
}

class DashboardStats {
  const DashboardStats({
    required this.todayReviewed,
    required this.totalSessions,
    required this.knownRate,
    required this.wrongReviewCount,
  });

  final int todayReviewed;
  final int totalSessions;
  final double knownRate;
  final int wrongReviewCount;

  factory DashboardStats.empty() {
    return const DashboardStats(
      todayReviewed: 0,
      totalSessions: 0,
      knownRate: 0,
      wrongReviewCount: 0,
    );
  }
}

class HomeState {
  const HomeState({
    required this.books,
    required this.selectedBookId,
    required this.currentTab,
    required this.reviewMode,
    required this.reviewIndex,
    required this.sessionKnown,
    required this.sessionUnknown,
    required this.activeSessionId,
    required this.isLoadingCloud,
    required this.cloudMessage,
    required this.dashboardStats,
    required this.lastSession,
  });

  final List<WordBook> books;
  final String selectedBookId;
  final HomeTab currentTab;
  final ReviewMode reviewMode;
  final int reviewIndex;
  final int sessionKnown;
  final int sessionUnknown;
  final String? activeSessionId;
  final bool isLoadingCloud;
  final String? cloudMessage;
  final DashboardStats dashboardStats;
  final SessionSummary lastSession;

  factory HomeState.initial(List<WordBook> books) {
    final clonedBooks = books
        .map(
          (book) => book.copyWith(
            words: book.words.map((word) => word.copyWith()).toList(),
          ),
        )
        .toList();

    return HomeState(
      books: clonedBooks,
      selectedBookId: clonedBooks.first.id,
      currentTab: HomeTab.dashboard,
      reviewMode: ReviewMode.fullBook,
      reviewIndex: 0,
      sessionKnown: 0,
      sessionUnknown: 0,
      activeSessionId: null,
      isLoadingCloud: false,
      cloudMessage: null,
      dashboardStats: DashboardStats.empty(),
      lastSession: const SessionSummary(
        mode: ReviewMode.fullBook,
        done: 0,
        known: 0,
        unknown: 0,
      ),
    );
  }

  HomeState copyWith({
    List<WordBook>? books,
    String? selectedBookId,
    HomeTab? currentTab,
    ReviewMode? reviewMode,
    int? reviewIndex,
    int? sessionKnown,
    int? sessionUnknown,
    String? activeSessionId,
    bool clearActiveSessionId = false,
    bool? isLoadingCloud,
    String? cloudMessage,
    DashboardStats? dashboardStats,
    SessionSummary? lastSession,
  }) {
    return HomeState(
      books: books ?? this.books,
      selectedBookId: selectedBookId ?? this.selectedBookId,
      currentTab: currentTab ?? this.currentTab,
      reviewMode: reviewMode ?? this.reviewMode,
      reviewIndex: reviewIndex ?? this.reviewIndex,
      sessionKnown: sessionKnown ?? this.sessionKnown,
      sessionUnknown: sessionUnknown ?? this.sessionUnknown,
      activeSessionId: clearActiveSessionId ? null : activeSessionId ?? this.activeSessionId,
      isLoadingCloud: isLoadingCloud ?? this.isLoadingCloud,
      cloudMessage: cloudMessage ?? this.cloudMessage,
      dashboardStats: dashboardStats ?? this.dashboardStats,
      lastSession: lastSession ?? this.lastSession,
    );
  }
}
