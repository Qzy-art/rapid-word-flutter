import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app.dart';
import 'src/core/supabase/supabase_bootstrap.dart';

Future<void> main() async {
  await initializeSupabase();
  runApp(const ProviderScope(child: RapidWordApp()));
}
