import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_mark.dart';

enum _AuthMode { signup, login }

/// Login / Sign-up screen backed by Supabase email/password auth.
class AuthScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onSuccess;
  final _AuthMode initialMode;

  const AuthScreen({
    super.key,
    required this.onBack,
    required this.onSuccess,
    this.initialMode = _AuthMode.signup,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late _AuthMode _mode = widget.initialMode;
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _showPassword = false;
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String? _validate() {
    final name = _name.text.trim();
    final email = _email.text.trim();
    final password = _password.text;

    if (_mode == _AuthMode.signup && name.isEmpty) {
      return 'Please enter your name.';
    }
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return 'Please enter a valid email address.';
    }
    if (password.isEmpty) return 'Please enter your password.';

    // Login: no strength rules (existing accounts must still work).
    if (_mode == _AuthMode.login) return null;

    final lower = password.toLowerCase();
    final local = email.split('@').first.toLowerCase();
    const common = ['123456', '12345678', '123456789', 'password', 'qwerty', '111111','11111111'];

    if (password.length < 8) return 'Password must be at least 8 characters.';
    if (common.contains(lower)) return 'This password is too common.';
    if (lower == email.toLowerCase() ||
        (local.length >= 3 && lower.contains(local))) {
      return 'Password must not contain your email.';
    }
    return null;
  }

  Future<void> _submit() async {
    if (_loading) return;

    final problem = _validate();
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }

    final email = _email.text.trim();

    setState(() {
      _error = null;
      _loading = true;
    });

    try {
      final auth = Supabase.instance.client.auth;
      if (_mode == _AuthMode.signup) {
        final response = await auth.signUp(
          email: email,
          password: _password.text,
          data: {'display_name': _name.text.trim()},
        );
        if (mounted) {
          if (response.session != null) {
            widget.onSuccess();
          } else {
            setState(() => _error =
                'Account created. Please check your email to confirm your account.');
          }
        }
      } else {
        await auth.signInWithPassword(
          email: email,
          password: _password.text,
        );
        if (mounted) widget.onSuccess();
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSignup = _mode == _AuthMode.signup;
    return Scaffold(
      backgroundColor: context.mc.frame,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(28, 25, 28, 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Back ──
              GestureDetector(
                onTap: widget.onBack,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back, size: 17, color: context.mc.textMuted),
                    SizedBox(width: 7),
                    Text('Back', style: TextStyle(fontSize: 11, color: context.mc.textMuted)),
                  ],
                ),
              ),
              // ── Header ──
              Padding(
                padding: EdgeInsets.only(top: 54, bottom: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BrandMark(),
                    SizedBox(height: 38),
                    Text(
                      isSignup
                          ? 'A WARDROBE, MADE PERSONAL.'
                          : 'WELCOME BACK TO YOUR EDIT.',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.3,
                        color: context.mc.brandSoft,
                      ),
                    ),
                    SizedBox(height: 13),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: MuseTheme.serif,
                          fontSize: 42,
                          fontWeight: FontWeight.w500,
                          height: 1.0,
                          letterSpacing: -2.52,
                          color: context.mc.textStrong,
                        ),
                        children: [
                          TextSpan(text: isSignup ? 'Start with\n' : 'Good to\n'),
                          TextSpan(
                            text: isSignup
                                ? 'something good.'
                                : 'see you again.',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: context.mc.brandLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // ── Tabs ──
              Row(
                children: [
                  _TabButton(
                    label: 'Create account',
                    active: isSignup,
                    onTap: () => setState(() {
                      _mode = _AuthMode.signup;
                      _error = null;
                    }),
                  ),
                  SizedBox(width: 23),
                  _TabButton(
                    label: 'Sign in',
                    active: !isSignup,
                    onTap: () => setState(() {
                      _mode = _AuthMode.login;
                      _error = null;
                    }),
                  ),
                ],
              ),
              SizedBox(height: 25),
              // ── Form ──
              if (isSignup) _Field(
                label: 'Name',
                controller: _name,
                placeholder: 'Abdo hossam',
              ),
              _Field(
                label: 'Email address',
                controller: _email,
                placeholder: 'abdohossam5776@gmail.com',
                keyboardType: TextInputType.emailAddress,
              ),
              _PasswordField(
                controller: _password,
                showPassword: _showPassword,
                onToggle: () => setState(() => _showPassword = !_showPassword),
              ),
              if (_error != null)
                Padding(
                  padding: EdgeInsets.only(top: 4, bottom: 15),
                  child: Text(
                    _error!,
                    style: TextStyle(fontSize: 10, color: context.mc.error),
                  ),
                ),
              SizedBox(height: 8),
              // ── Submit ──
              GestureDetector(
                onTap: _loading ? null : _submit,
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: context.mc.primaryButton.copyWith(
                    color: _loading ? context.mc.brand.withOpacity(0.65) : context.mc.brand,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _loading
                            ? 'Please wait...'
                            : isSignup
                                ? 'Create my account'
                                : 'Sign in',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                      SizedBox(width: 9),
                      Icon(Icons.arrow_forward, size: 17, color: Colors.white),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 25),
              // ── Switch ──
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isSignup
                          ? 'Already have an account?'
                          : 'New to muse?',
                      style: TextStyle(fontSize: 10, color: context.mc.textMuted),
                    ),
                    SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => setState(() {
                        _mode = isSignup ? _AuthMode.login : _AuthMode.signup;
                        _error = null;
                      }),
                      child: Text(
                        isSignup ? 'Sign in' : 'Create an account',
                        style: TextStyle(
                          fontSize: 10,
                          color: context.mc.brand,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabButton({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: active ? context.mc.textStrong : context.mc.textMuted,
            ),
          ),
        ),
        SizedBox(height: 12),
        Container(
          height: 2,
          width: 80,
          color: active ? context.mc.brand : Colors.transparent,
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String placeholder;
  final TextInputType? keyboardType;

  const _Field({
    required this.label,
    required this.controller,
    required this.placeholder,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: context.mc.textMid)),
          SizedBox(height: 7),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(fontSize: 12, color: context.mc.textStrong),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(fontSize: 12, color: context.mc.textFaint),
              contentPadding: EdgeInsets.symmetric(horizontal: 13),
              constraints: BoxConstraints(minHeight: 43),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: context.mc.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: context.mc.brandSoft),
              ),
              filled: true,
              fillColor: context.mc.inputFill,
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool showPassword;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.controller,
    required this.showPassword,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Password', style: TextStyle(fontSize: 10, color: context.mc.textMid)),
          SizedBox(height: 7),
          TextField(
            controller: controller,
            obscureText: !showPassword,
            style: TextStyle(fontSize: 12, color: context.mc.textStrong),
            decoration: InputDecoration(
              hintText: 'At least 8 characters',
              hintStyle: TextStyle(fontSize: 12, color: context.mc.textFaint),
              contentPadding: EdgeInsets.symmetric(horizontal: 13),
              constraints: BoxConstraints(minHeight: 43),
              suffixIcon: IconButton(
                icon: Icon(
                  showPassword ? Icons.visibility_off : Icons.visibility,
                  size: 16,
                  color: context.mc.textMuted,
                ),
                onPressed: onToggle,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: context.mc.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: context.mc.brandSoft),
              ),
              filled: true,
              fillColor: context.mc.inputFill,
            ),
          ),
        ],
      ),
    );
  }
}