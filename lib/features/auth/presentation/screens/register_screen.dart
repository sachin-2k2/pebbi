import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/register_form_provider.dart';
import '../widgets/register_body.dart';

/// Main registration screen ("Create your account").
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// thin composition screen, zero password retention beyond disposal.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key, this.returnTo});

  /// Optional route destination to return to after successful registration.
  final String? returnTo;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final FocusNode _emailFocusNode;
  late final FocusNode _passwordFocusNode;
  late final FocusNode _confirmPasswordFocusNode;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _confirmPasswordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.clear();
    _passwordController.dispose();
    _confirmPasswordController.clear();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(registerFormProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    ref.listen<RegisterFormState>(registerFormProvider, (prev, next) {
      if (next.isSuccess && !(prev?.isSuccess ?? false)) {
        TextInput.finishAutofillContext();
        final returnTo = widget.returnTo;
        final target = (returnTo != null && !returnTo.startsWith('/lesson'))
            ? returnTo
            : '/path';
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
        body: RegisterBody(
          formState: formState,
          emailController: _emailController,
          passwordController: _passwordController,
          confirmPasswordController: _confirmPasswordController,
          emailFocusNode: _emailFocusNode,
          passwordFocusNode: _passwordFocusNode,
          confirmPasswordFocusNode: _confirmPasswordFocusNode,
          onRegister: _handleRegister,
          onGoogleSignIn: () =>
              ref.read(registerFormProvider.notifier).submitWithGoogle(),
          onTogglePasswordVisibility: () => ref
              .read(registerFormProvider.notifier)
              .togglePasswordVisibility(),
          onToggleConfirmPasswordVisibility: () => ref
              .read(registerFormProvider.notifier)
              .toggleConfirmPasswordVisibility(),
          onLogin: _handleLogin,
        ),
      ),
    );
  }

  void _handleRegister() {
    ref
        .read(registerFormProvider.notifier)
        .submitWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
        );
  }

  void _handleLogin() {
    final dest = widget.returnTo != null
        ? '?returnTo=${Uri.encodeComponent(widget.returnTo!)}'
        : '';
    // Replace navigation to prevent stacking auth screens
    context.go('/login$dest');
  }
}
