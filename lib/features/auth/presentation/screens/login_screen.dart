import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/email_validator.dart';
import '../providers/login_form_provider.dart';
import '../widgets/login_body.dart';

/// Main authentication login screen ("Welcome back").
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// thin composition screen, zero password retention beyond disposal.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.returnTo, this.initialEmail});

  /// Optional route destination to return to after successful login.
  final String? returnTo;

  /// Optional email address to prefill (e.g. after session expiry).
  final String? initialEmail;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final FocusNode _emailFocusNode;
  late final FocusNode _passwordFocusNode;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
    _passwordController = TextEditingController();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.clear();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(loginFormProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    ref.listen<LoginFormState>(loginFormProvider, (prev, next) {
      if (next.isSuccess && !(prev?.isSuccess ?? false)) {
        TextInput.finishAutofillContext();
        final returnTo = widget.returnTo;
        final target = (returnTo != null && !returnTo.startsWith('/lesson'))
            ? returnTo
            : '/path';
        debugPrint('[LoginScreen] 🚀 Login successful, navigating to $target');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.authSuccessLogin),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go(target);
      }
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.background,
        resizeToAvoidBottomInset: true,
        body: LoginBody(
          formState: formState,
          emailController: _emailController,
          passwordController: _passwordController,
          emailFocusNode: _emailFocusNode,
          passwordFocusNode: _passwordFocusNode,
          onLogin: _handleLogin,
          onGoogleSignIn: () =>
              ref.read(loginFormProvider.notifier).submitWithGoogle(),
          onTogglePasswordVisibility: () =>
              ref.read(loginFormProvider.notifier).togglePasswordVisibility(),
          onForgotPassword: _handleForgotPassword,
          onCreateAccount: _handleCreateAccount,
        ),
      ),
    );
  }

  void _handleLogin() {
    debugPrint(
      '[LoginScreen] "Log in" tapped (email: "${_emailController.text.trim()}")',
    );
    ref
        .read(loginFormProvider.notifier)
        .submitWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  void _handleForgotPassword() {
    final email = _emailController.text.trim();
    final isValid = EmailValidator.validate(email) == null;
    final query = isValid ? '?email=${Uri.encodeComponent(email)}' : '';
    context.push('/forgot-password$query');
  }

  void _handleCreateAccount() {
    final dest = widget.returnTo != null
        ? '?returnTo=${Uri.encodeComponent(widget.returnTo!)}'
        : '';
    // TODO(question): Navigate to real Register route when built (replace, not push)
    context.go('/register$dest');
  }
}
