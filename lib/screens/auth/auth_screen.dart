import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models.dart';
import '../../state/app_state.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isSignUp = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  final _signInFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();

  final _signInEmailController = TextEditingController();
  final _signInPasswordController = TextEditingController();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _errorMessage = null;
    });
  }

  Future<void> _submit() async {
    final appState = context.read<AppState>();
    setState(() {
      _errorMessage = null;
    });

    try {
      if (_isSignUp) {
        if (!_signUpFormKey.currentState!.validate()) {
          return;
        }
        setState(() => _isSubmitting = true);
        await appState.register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim().toLowerCase(),
          password: _passwordController.text,
        );
      } else {
        if (!_signInFormKey.currentState!.validate()) {
          return;
        }
        setState(() => _isSubmitting = true);
        await appState.signIn(
          email: _signInEmailController.text.trim().toLowerCase(),
          password: _signInPasswordController.text,
        );
      }
    } on AuthException catch (error) {
      setState(() => _errorMessage = error.message);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 8),
                child: IconButton(
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          await context.read<AppState>().continueAsGuest();
                        },
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Misafir olarak devam et',
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'KKTC Caraba',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isSignUp
                            ? 'Dakikalar içinde ücretsiz hesap oluştur'
                            : 'Hoş geldin, hesabına giriş yap',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 32),
                      ToggleButtons(
                        isSelected: [!_isSignUp, _isSignUp],
                        onPressed: (index) {
                          final shouldSignUp = index == 1;
                          if (shouldSignUp != _isSignUp) {
                            _toggleMode();
                          }
                        },
                        borderRadius: BorderRadius.circular(18),
                        fillColor:
                            theme.colorScheme.primary.withValues(alpha: .12),
                        selectedColor: theme.colorScheme.primary,
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('Giriş Yap'),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('Kayıt Ol'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: .08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: theme.textTheme.bodyMedium!.copyWith(
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      if (_errorMessage != null) const SizedBox(height: 16),
                      _isSignUp ? _buildSignUpForm(theme) : _buildSignInForm(),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: theme.colorScheme.primary,
                        ),
                        child: _isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(_isSignUp ? 'Hesap Oluştur' : 'Giriş Yap'),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _isSubmitting ? null : _toggleMode,
                        child: Text(
                          _isSignUp
                              ? 'Hesabın var mı? Giriş yap'
                              : 'Hesabın yok mu? Hemen kaydol',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInForm() {
    return Form(
      key: _signInFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _signInEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'E-posta'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'E-posta adresinizi girin';
              }
              if (!value.contains('@')) {
                return 'Geçerli bir e-posta girin';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _signInPasswordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Şifre'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Şifrenizi girin';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpForm(ThemeData theme) {
    return Form(
      key: _signUpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Ad Soyad'),
            validator: (value) => value == null || value.isEmpty
                ? 'Adınızı soyadınızı girin'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'E-posta'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'E-posta girin';
              }
              if (!value.contains('@')) {
                return 'Geçerli bir e-posta girin';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Şifre'),
            validator: (value) {
              if (value == null || value.length < 6) {
                return 'Şifre en az 6 karakter olmalı';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Şifre (Tekrar)'),
            validator: (value) {
              if (value != _passwordController.text) {
                return 'Şifreler eşleşmiyor';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
