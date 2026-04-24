import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../home/home_page.dart';
import 'auth_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
    required this.client,
  });

  final SupabaseClient client;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final StreamSubscription<AuthState> _authSubscription;
  Session? _session;

  @override
  void initState() {
    super.initState();
    _session = widget.client.auth.currentSession;
    _authSubscription = widget.client.auth.onAuthStateChange.listen((data) {
      if (!mounted) {
        return;
      }
      setState(() {
        _session = data.session;
      });
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_session == null) {
      return AuthPage(
        client: widget.client,
        onSignedIn: () {
          if (mounted) {
            setState(() {
              _session = widget.client.auth.currentSession;
            });
          }
        },
      );
    }

    return HomePage(
      supabaseEnabled: true,
      onSignOut: () async {
        await widget.client.auth.signOut();
      },
      currentUserEmail: _session?.user.email,
    );
  }
}
