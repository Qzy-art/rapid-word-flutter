import 'package:supabase_flutter/supabase_flutter.dart';

import 'book_record.dart';
import 'word_record.dart';

class DashboardStatsRecord {
  const DashboardStatsRecord({
    required this.todayReviewed,
    required this.totalSessions,
    required this.knownRate,
    required this.wrongReviewCount,
  });

  final int todayReviewed;
  final int totalSessions;
  final double knownRate;
  final int wrongReviewCount;
}

class ActiveStudySessionRecord {
  const ActiveStudySessionRecord({
    required this.sessionId,
    required this.bookId,
    required this.reviewMode,
    required this.reviewIndex,
    required this.sessionKnown,
    required this.sessionUnknown,
  });

  final String sessionId;
  final String bookId;
  final String reviewMode;
  final int reviewIndex;
  final int sessionKnown;
  final int sessionUnknown;
}

class BooksRepository {
  const BooksRepository(this._client);

  final SupabaseClient _client;

  Future<List<BookRecord>> fetchBooks() async {
    final response = await _client
        .from('word_books')
        .select()
        .order('created_at', ascending: false);

    return response.map<BookRecord>((json) => BookRecord.fromJson(json)).toList();
  }

  Future<String> createBook({
    required String title,
    required String level,
    required String description,
    required String coverStyle,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final response = await _client
        .from('word_books')
        .insert({
          'title': title,
          'level': level,
          'description': description,
          'cover_style': coverStyle,
          'owner_user_id': userId,
        })
        .select('id')
        .single();

    return response['id'] as String;
  }

  Future<void> updateBook({
    required String bookId,
    required String title,
    required String level,
    required String description,
  }) async {
    await _client.from('word_books').update({
      'title': title,
      'level': level,
      'description': description,
    }).eq('id', bookId);
  }

  Future<List<WordRecord>> fetchWords(String bookId) async {
    final response = await _client
        .from('words')
        .select()
        .eq('book_id', bookId)
        .order('created_at', ascending: true);

    return response.map<WordRecord>((json) => WordRecord.fromJson(json)).toList();
  }

  Future<void> addWord({
    required String bookId,
    required String word,
    required String phonetic,
    required String partOfSpeech,
    required String meaning,
  }) async {
    await _client.from('words').insert({
      'book_id': bookId,
      'word': word,
      'phonetic': phonetic,
      'part_of_speech': partOfSpeech,
      'meaning': meaning,
    });
  }

  Future<void> updateWord({
    required String wordId,
    required String word,
    required String phonetic,
    required String partOfSpeech,
    required String meaning,
  }) async {
    await _client.from('words').update({
      'word': word,
      'phonetic': phonetic,
      'part_of_speech': partOfSpeech,
      'meaning': meaning,
    }).eq('id', wordId);
  }

  Future<void> deleteWord(String wordId) async {
    await _client.from('words').delete().eq('id', wordId);
  }

  Future<void> setWrongFlag({
    required String wordId,
    required bool isWrong,
  }) async {
    await _client.from('words').update({'is_wrong': isWrong}).eq('id', wordId);
  }

  Future<String> createStudySession({
    required String bookId,
    required String reviewMode,
    required int totalCount,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final response = await _client
        .from('study_sessions')
        .insert({
          'user_id': userId,
          'book_id': bookId,
          'review_mode': reviewMode,
          'total_count': totalCount,
          'review_index': 0,
          'session_known': 0,
          'session_unknown': 0,
          'is_completed': false,
        })
        .select('id')
        .single();

    return response['id'] as String;
  }

  Future<void> addStudyRecord({
    required String sessionId,
    required String wordId,
    required bool known,
  }) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from('study_records').insert({
      'session_id': sessionId,
      'user_id': userId,
      'word_id': wordId,
      'result': known ? 'known' : 'unknown',
    });
  }

  Future<void> finishStudySession({
    required String sessionId,
    required int totalCount,
    required int knownCount,
    required int unknownCount,
  }) async {
    await _client.from('study_sessions').update({
      'total_count': totalCount,
      'known_count': knownCount,
      'unknown_count': unknownCount,
      'review_index': totalCount,
      'session_known': knownCount,
      'session_unknown': unknownCount,
      'is_completed': true,
    }).eq('id', sessionId);
  }

  Future<void> updateStudySessionProgress({
    required String sessionId,
    required int reviewIndex,
    required int knownCount,
    required int unknownCount,
  }) async {
    await _client.from('study_sessions').update({
      'review_index': reviewIndex,
      'session_known': knownCount,
      'session_unknown': unknownCount,
    }).eq('id', sessionId);
  }

  Future<ActiveStudySessionRecord?> fetchActiveStudySession() async {
    final userId = _client.auth.currentUser!.id;
    final response = await _client
        .from('study_sessions')
        .select('id, book_id, review_mode, review_index, session_known, session_unknown')
        .eq('user_id', userId)
        .eq('is_completed', false)
        .order('created_at', ascending: false)
        .limit(1);

    if (response.isEmpty) {
      return null;
    }

    final row = response.first;
    return ActiveStudySessionRecord(
      sessionId: row['id'] as String,
      bookId: row['book_id'] as String,
      reviewMode: row['review_mode'] as String,
      reviewIndex: (row['review_index'] as num?)?.toInt() ?? 0,
      sessionKnown: (row['session_known'] as num?)?.toInt() ?? 0,
      sessionUnknown: (row['session_unknown'] as num?)?.toInt() ?? 0,
    );
  }

  Future<DashboardStatsRecord> fetchDashboardStats() async {
    final userId = _client.auth.currentUser!.id;
    final now = DateTime.now().toUtc();
    final startOfDay = DateTime.utc(now.year, now.month, now.day).toIso8601String();

    final totalSessionsResponse = await _client
        .from('study_sessions')
        .select('review_mode, total_count, known_count, is_completed')
        .eq('user_id', userId);

    final todaySessionsResponse = await _client
        .from('study_sessions')
        .select('total_count')
        .eq('user_id', userId)
        .eq('is_completed', true)
        .gte('created_at', startOfDay);

    final completedSessions = totalSessionsResponse
        .where((row) => row['is_completed'] == true)
        .toList();

    final totalSessions = completedSessions.length;
    final wrongReviewCount = completedSessions.where((row) => row['review_mode'] == 'wrong_words').length;
    final knownTotal = completedSessions.fold<int>(
      0,
      (sum, row) => sum + ((row['known_count'] as num?)?.toInt() ?? 0),
    );
    final reviewedTotal = completedSessions.fold<int>(
      0,
      (sum, row) => sum + ((row['total_count'] as num?)?.toInt() ?? 0),
    );
    final todayReviewed = todaySessionsResponse.fold<int>(
      0,
      (sum, row) => sum + ((row['total_count'] as num?)?.toInt() ?? 0),
    );

    return DashboardStatsRecord(
      todayReviewed: todayReviewed,
      totalSessions: totalSessions,
      knownRate: reviewedTotal == 0 ? 0 : knownTotal / reviewedTotal,
      wrongReviewCount: wrongReviewCount,
    );
  }
}
