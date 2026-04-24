import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

SupabaseClient? getSupabaseClientOrNull() {
  if (!SupabaseConfig.isConfigured) {
    return null;
  }
  return Supabase.instance.client;
}
