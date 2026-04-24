import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/supabase/supabase_client_provider.dart';
import 'features/auth/auth_gate.dart';
import 'features/books/data/books_repository.dart';
import 'features/home/home_page.dart';
import 'features/home/state/home_provider.dart';
import 'theme/app_theme.dart';

class RapidWordApp extends ConsumerWidget {
  const RapidWordApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = getSupabaseClientOrNull();
    final repository = supabase == null ? null : BooksRepository(supabase);

    return MaterialApp(
      title: '速刷单词',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: ProviderScope(
        overrides: [
          booksRepositoryProvider.overrideWithValue(repository),
        ],
        child: supabase == null ? const HomePage(supabaseEnabled: false) : AuthGate(client: supabase),
      ),
    );
  }
}
