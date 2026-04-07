import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:language_learning_app/config/theme.dart';

/// Combined login + signup screen with real Firebase auth.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Controllers – always fresh when tab switches
  TextEditingController _emailCtrl    = TextEditingController();
  TextEditingController _passwordCtrl = TextEditingController();
  TextEditingController _nameCtrl     = TextEditingController();
  TextEditingController _confirmCtrl  = TextEditingController();

  final _loginFormKey  = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;
  late Animation<double>  _fadeAnim;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _fadeAnim  = CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut);
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    _emailCtrl.dispose(); _passwordCtrl.dispose();
    _nameCtrl.dispose();  _confirmCtrl.dispose();
    super.dispose();
  }

  void _switchTab(bool toLogin) {
    if (_isLogin == toLogin) return;
    // Dispose old and create fresh controllers to clear all fields
    _emailCtrl.dispose();    _emailCtrl    = TextEditingController();
    _passwordCtrl.dispose(); _passwordCtrl = TextEditingController();
    _nameCtrl.dispose();     _nameCtrl     = TextEditingController();
    _confirmCtrl.dispose();  _confirmCtrl  = TextEditingController();

    _slideCtrl.reset();
    setState(() { _isLogin = toLogin; _errorMessage = null; });
    _slideCtrl.forward();
  }

  // ── Firebase Auth ──────────────────────────────────────────────────────────

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email:    _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      // StreamBuilder in _AppRouter will auto-navigate on auth state change
    } on FirebaseAuthException catch (e) {
      setState(() { _errorMessage = _friendlyError(e.code); });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignup() async {
    if (!_signupFormKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email:    _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      // Update display name
      await cred.user?.updateDisplayName(_nameCtrl.text.trim());
      // Auth state change will auto-redirect
    } on FirebaseAuthException catch (e) {
      setState(() { _errorMessage = _friendlyError(e.code); });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found':     return 'No account found with that email.';
      case 'wrong-password':     return 'Incorrect password. Try again.';
      case 'email-already-in-use': return 'An account with this email already exists.';
      case 'weak-password':      return 'Password must be at least 6 characters.';
      case 'invalid-email':      return 'Please enter a valid email address.';
      case 'too-many-requests':  return 'Too many attempts. Please wait a moment.';
      case 'network-request-failed': return 'No internet connection.';
      default:                   return 'Something went wrong. Please try again.';
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.primary,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ── Hero gradient top ─────────────────────────────────
          Container(
            height: size.height * 0.42,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1557C0), Color(0xFF1A73E8), Color(0xFF2196F3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Decorative circles
          Positioned(top: -40, right: -60, child: _circle(180, Colors.white.withValues(alpha: 0.05))),
          Positioned(top: 80,  left: -50, child: _circle(140, Colors.white.withValues(alpha: 0.05))),

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ── Logo & title ─────────────────────────────────
                const SizedBox(height: 32),
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: Center(
                    child: Text('LQ', style: GoogleFonts.plusJakartaSans(
                      fontSize: 24, fontWeight: FontWeight.w800,
                      color: Colors.white, letterSpacing: -0.5,
                    )),
                  ),
                ),
                const SizedBox(height: 14),
                Text('LingoQuest', style: GoogleFonts.plusJakartaSans(
                  fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white,
                )),
                const SizedBox(height: 6),
                Text('Master languages, one quest at a time',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),

                const SizedBox(height: 28),

                // ── White card sheet ──────────────────────────────
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.bgDark : Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: SingleChildScrollView(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                      child: Column(children: [

                        // Segmented pill toggle
                        Container(
                          height: 48,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : AppColors.neutralLight,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: LayoutBuilder(builder: (ctx, constraints) {
                            final w = (constraints.maxWidth - 8) / 2;
                            return Stack(
                              children: [
                                AnimatedPositioned(
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeInOutCubic,
                                  left: _isLogin ? 0 : w,
                                  top: 0, bottom: 0, width: w,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () => _switchTab(true),
                                      child: Center(child: Text('Log in',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14, fontWeight: FontWeight.w600,
                                          color: _isLogin ? Colors.white : AppColors.neutralMid,
                                        ),
                                      )),
                                    )),
                                    Expanded(child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () => _switchTab(false),
                                      child: Center(child: Text('Sign up',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14, fontWeight: FontWeight.w600,
                                          color: !_isLogin ? Colors.white : AppColors.neutralMid,
                                        ),
                                      )),
                                    )),
                                  ],
                                ),
                              ],
                            );
                          }),
                        ),

                        const SizedBox(height: 24),

                        // Error banner
                        if (_errorMessage != null) ...[
                          _ErrorBanner(message: _errorMessage!),
                          const SizedBox(height: 16),
                        ],

                        // Animated form
                        SlideTransition(
                          position: _slideAnim,
                          child: FadeTransition(
                            opacity: _fadeAnim,
                            child: _isLogin ? _loginForm() : _signupForm(),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Divider
                        Row(children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('or', style: TextStyle(color: AppColors.neutralMid, fontSize: 13)),
                          ),
                          const Expanded(child: Divider()),
                        ]),

                        const SizedBox(height: 20),

                        // Google button
                        _GoogleButton(),

                        if (!_isLogin) ...[
                          const SizedBox(height: 20),
                          Text.rich(
                            TextSpan(
                              text: 'By signing up you agree to our ',
                              style: TextStyle(color: AppColors.neutralMid, fontSize: 12),
                              children: [
                                TextSpan(text: 'Terms', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                                const TextSpan(text: ' & '),
                                TextSpan(text: 'Privacy Policy', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Login form ─────────────────────────────────────────────────────────────
  Widget _loginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        _Field(
          controller: _emailCtrl,
          label: 'Email',
          icon: Iconsax.sms,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: _emailValidator,
        ),
        const SizedBox(height: 12),
        _Field(
          controller: _passwordCtrl,
          label: 'Password',
          icon: Iconsax.lock,
          isPassword: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _handleLogin(),
          validator: _passwordValidator,
        ),
        TextButton(
          onPressed: _showForgotPassword,
          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 4)),
          child: Text('Forgot password?',
            style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w500)),
        ),
        const SizedBox(height: 4),
        _SubmitButton(label: 'Log in', isLoading: _isLoading, onPressed: _handleLogin),
      ]),
    );
  }

  // ── Signup form ────────────────────────────────────────────────────────────
  Widget _signupForm() {
    return Form(
      key: _signupFormKey,
      child: Column(children: [
        _Field(
          controller: _nameCtrl,
          label: 'Full name',
          icon: Iconsax.user,
          textInputAction: TextInputAction.next,
          validator: (v) => (v?.trim().isEmpty ?? true) ? 'Name is required' : null,
        ),
        const SizedBox(height: 12),
        _Field(
          controller: _emailCtrl,
          label: 'Email',
          icon: Iconsax.sms,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: _emailValidator,
        ),
        const SizedBox(height: 12),
        _Field(
          controller: _passwordCtrl,
          label: 'Password',
          icon: Iconsax.lock,
          isPassword: true,
          textInputAction: TextInputAction.next,
          validator: _passwordValidator,
        ),
        const SizedBox(height: 12),
        _Field(
          controller: _confirmCtrl,
          label: 'Confirm password',
          icon: Iconsax.lock_1,
          isPassword: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _handleSignup(),
          validator: (v) => v != _passwordCtrl.text ? 'Passwords do not match' : null,
        ),
        const SizedBox(height: 20),
        _SubmitButton(label: 'Create account', isLoading: _isLoading, onPressed: _handleSignup),
      ]),
    );
  }

  String? _emailValidator(String? v) {
    if (v?.trim().isEmpty ?? true) return 'Email is required';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v!.trim())) return 'Enter a valid email';
    return null;
  }
  String? _passwordValidator(String? v) {
    if (v?.isEmpty ?? true) return 'Password is required';
    if (v!.length < 6) return 'Min 6 characters';
    return null;
  }

  void _showForgotPassword() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ForgotPasswordSheet(),
    );
  }

  Widget _circle(double size, Color color) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}

// ── Reusable field ─────────────────────────────────────────────────────────

class _Field extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmitted;

  const _Field({
    required this.controller, required this.label, required this.icon,
    this.isPassword = false, this.keyboardType, this.textInputAction,
    this.validator, this.onSubmitted,
  });
  @override State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  bool _obscure = true;
  bool _focused = false;
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }
  @override
  void dispose() { _focus.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: widget.controller,
      focusNode: _focus,
      obscureText: widget.isPassword && _obscure,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        color: isDark ? AppColors.textPrimaryDark : AppColors.neutralDark,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: Icon(widget.icon, size: 18,
          color: _focused ? AppColors.primary : AppColors.neutralMid),
        suffixIcon: widget.isPassword
            ? GestureDetector(
                onTap: () => setState(() => _obscure = !_obscure),
                child: Icon(_obscure ? Iconsax.eye_slash : Iconsax.eye, size: 18, color: AppColors.neutralMid),
              )
            : null,
      ),
    );
  }
}

// ── Submit button ──────────────────────────────────────────────────────────

class _SubmitButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;
  const _SubmitButton({required this.label, required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }
}

// ── Google button ──────────────────────────────────────────────────────────

class _GoogleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight.withValues(alpha: 0.15), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: 0.15)),
            child: Center(child: Text('G', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary))),
          ),
          const SizedBox(width: 12),
          Text('Continue with Google',
            style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textPrimaryDark : AppColors.neutralDark)),
        ]),
      ),
    );
  }
}

// ── Error banner ───────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        Icon(Iconsax.warning_2, size: 16, color: AppColors.error),
        const SizedBox(width: 10),
        Expanded(child: Text(message, style: TextStyle(color: AppColors.error, fontSize: 13))),
      ]),
    );
  }
}

// ── Forgot password sheet ──────────────────────────────────────────────────

class _ForgotPasswordSheet extends StatefulWidget {
  @override
  State<_ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}
class _ForgotPasswordSheetState extends State<_ForgotPasswordSheet> {
  final _ctrl = TextEditingController();
  bool _sent = false, _loading = false;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _send() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _ctrl.text.trim());
      setState(() => _sent = true);
    } catch (_) {
      setState(() => _sent = true); // Don't reveal if email exists
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.neutralLight, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 20),
        Text('Reset password', style: AppTextStyles.sectionHeading()),
        const SizedBox(height: 8),
        Text(_sent
            ? 'Check your inbox for a reset link.'
            : 'Enter your email and we\'ll send you a reset link.',
          style: AppTextStyles.caption()),
        const SizedBox(height: 20),
        if (!_sent) ...[
          _Field(controller: _ctrl, label: 'Email', icon: Iconsax.sms, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: _loading ? null : _send,
              child: _loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : Text('Send reset link', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ] else ...[
          SizedBox(width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Done', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ]),
    );
  }
}
