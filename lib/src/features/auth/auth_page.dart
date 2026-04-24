import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({
    super.key,
    required this.client,
    required this.onSignedIn,
  });

  final SupabaseClient client;
  final VoidCallback onSignedIn;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final StreamSubscription<AuthState> _authSubscription;

  bool _isLoading = false;
  String? _message;
  bool _signUpMode = false;

  @override
  void initState() {
    super.initState();
    _authSubscription = widget.client.auth.onAuthStateChange.listen((data) {
      if (!mounted) {
        return;
      }
      if (data.session != null) {
        widget.onSignedIn();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      setState(() => _message = '请输入邮箱和密码');
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      if (_signUpMode) {
        await widget.client.auth.signUp(
          email: email,
          password: password,
        );
        if (!mounted) {
          return;
        }
        setState(() {
          _message = '注册请求已提交，请检查邮箱；如果你已关闭邮箱确认，也可以直接返回登录。';
        });
      } else {
        await widget.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
      }
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _message = error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _message = '登录失败，请检查网络或 Supabase 配置');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isCompact = size.width < 640;
    final horizontalPadding = isCompact ? 18.0 : 28.0;
    final verticalPadding = isCompact ? 22.0 : 28.0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7DDFF0), Color(0xFFBCF4EF), Color(0xFFF3FEFC)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 16 : 24,
                vertical: isCompact ? 20 : 28,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      verticalPadding,
                      horizontalPadding,
                      verticalPadding,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '速刷单词',
                          style: isCompact
                              ? theme.textTheme.headlineLarge
                              : theme.textTheme.displaySmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _signUpMode ? '先创建账号，再把词书、错词本和学习进度同步起来。' : '登录后即可同步词书、错词本和学习进度。',
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(labelText: '邮箱'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: '密码'),
                        ),
                        const SizedBox(height: 18),
                        if (_message != null) ...[
                          Text(_message!, style: theme.textTheme.bodyMedium),
                          const SizedBox(height: 12),
                        ],
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _isLoading ? null : _submit,
                            child: Text(
                              _isLoading ? '处理中...' : (_signUpMode ? '注册账号' : '登录'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    setState(() {
                                      _signUpMode = !_signUpMode;
                                      _message = null;
                                    });
                                  },
                            child: Text(_signUpMode ? '已有账号，去登录' : '没有账号，先注册'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
