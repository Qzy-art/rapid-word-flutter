import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/mock_data.dart';
import 'home_state.dart';
import '../../books/data/books_repository.dart';
import 'home_notifier.dart';

final booksRepositoryProvider = Provider<BooksRepository?>((ref) => null);

final homeNotifierProvider =
    StateNotifierProvider.autoDispose<HomeNotifier, HomeState>(
  (ref) {
  final repository = ref.watch(booksRepositoryProvider);
  return HomeNotifier(
    initialBooks: mockBooks,
    booksRepository: repository,
  );
  },
  dependencies: [booksRepositoryProvider],
);
